import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthUser {
  final String email;
  final String name;
  final DateTime createdAt;

  const AuthUser({
    required this.email,
    required this.name,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'name': name,
        'createdAt': createdAt.toIso8601String(),
      };

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
        email: json['email'] as String,
        name: json['name'] as String? ?? 'Explorer',
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
            DateTime.now(),
      );
}

class AuthResult {
  final bool isSuccess;
  final String? errorMessage;
  final AuthUser? user;

  const AuthResult._({
    required this.isSuccess,
    this.errorMessage,
    this.user,
  });

  factory AuthResult.success(AuthUser user) => AuthResult._(
        isSuccess: true,
        user: user,
      );

  factory AuthResult.error(String message) => AuthResult._(
        isSuccess: false,
        errorMessage: message,
      );
}

/// Persistent Authentication & Guest 1-Story Trial Policy Service
class AuthService {
  static const _usersDbKey = 'lorvani_auth_users_db';
  static const _currentSessionKey = 'lorvani_auth_session';
  static const _guestStoriesCountKey = 'lorvani_guest_stories_count';

  final SharedPreferences? _prefs;

  AuthService([this._prefs]);

  static Future<AuthService> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    return AuthService(prefs);
  }

  /// Current authenticated user (null if guest)
  AuthUser? getCurrentUser() {
    final raw = _prefs?.getString(_currentSessionKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return AuthUser.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  bool get isLoggedIn => getCurrentUser() != null;

  /// Number of free stories generated as a guest
  int get guestStoriesCount => _prefs?.getInt(_guestStoriesCountKey) ?? 0;

  /// Policy: Guests can generate 1 story for free; subsequent stories require login
  bool get canGenerateStory => isLoggedIn || guestStoriesCount < 1;

  /// Records story generation, incrementing guest counter if unauthenticated
  Future<void> recordStoryGenerated() async {
    if (!isLoggedIn && _prefs != null) {
      final current = guestStoriesCount;
      await _prefs.setInt(_guestStoriesCountKey, current + 1);
    }
  }

  Map<String, Map<String, dynamic>> _getUsersDb() {
    final raw = _prefs?.getString(_usersDbKey);
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map(
        (key, value) => MapEntry(key, Map<String, dynamic>.from(value as Map)),
      );
    } catch (_) {
      return {};
    }
  }

  Future<void> _saveUsersDb(Map<String, Map<String, dynamic>> db) async {
    if (_prefs == null) return;
    await _prefs.setString(_usersDbKey, jsonEncode(db));
  }

  /// Register a new account
  Future<AuthResult> signUp({
    required String email,
    required String password,
    String? name,
  }) async {
    final trimmedEmail = email.trim().toLowerCase();
    final trimmedPassword = password.trim();

    // 1. Email format regex validation
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,6}$');
    if (!emailRegex.hasMatch(trimmedEmail)) {
      return AuthResult.error('Please enter a valid email address.');
    }

    // 2. Password length check
    if (trimmedPassword.length < 6) {
      return AuthResult.error('Password must be at least 6 characters long.');
    }

    final db = _getUsersDb();

    // 3. Duplicate user check
    if (db.containsKey(trimmedEmail)) {
      return AuthResult.error(
        'An account with this email already exists. Please sign in instead.',
      );
    }

    final userName = name?.trim().isNotEmpty == true
        ? name!.trim()
        : trimmedEmail.split('@').first;

    final user = AuthUser(
      email: trimmedEmail,
      name: userName,
      createdAt: DateTime.now(),
    );

    db[trimmedEmail] = {
      'email': trimmedEmail,
      'password': trimmedPassword,
      'name': userName,
      'createdAt': user.createdAt.toIso8601String(),
    };

    await _saveUsersDb(db);
    await _prefs?.setString(_currentSessionKey, jsonEncode(user.toJson()));

    return AuthResult.success(user);
  }

  /// Sign in with existing credentials
  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    final trimmedEmail = email.trim().toLowerCase();
    final trimmedPassword = password.trim();

    final db = _getUsersDb();

    // 1. Account existence check
    if (!db.containsKey(trimmedEmail)) {
      return AuthResult.error(
        'No account found with this email. Please create an account.',
      );
    }

    final userData = db[trimmedEmail]!;

    // 2. Password verification
    if (userData['password'] != trimmedPassword) {
      return AuthResult.error('Incorrect password. Please try again.');
    }

    final user = AuthUser.fromJson(userData);
    await _prefs?.setString(_currentSessionKey, jsonEncode(user.toJson()));

    return AuthResult.success(user);
  }

  /// End current authenticated session
  Future<void> signOut() async {
    await _prefs?.remove(_currentSessionKey);
  }

  /// For testing or resetting demo state
  Future<void> resetGuestTrial() async {
    await _prefs?.remove(_guestStoriesCountKey);
  }
}

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

class CurrentUserNotifier extends Notifier<AuthUser?> {
  @override
  AuthUser? build() {
    return ref.watch(authServiceProvider).getCurrentUser();
  }

  void setUser(AuthUser? user) {
    state = user;
  }
}

final currentUserProvider =
    NotifierProvider<CurrentUserNotifier, AuthUser?>(CurrentUserNotifier.new);

