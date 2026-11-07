import 'package:flutter_test/flutter_test.dart';
import 'package:lorevaani/core/services/auth/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('AuthService & 1-Story Trial Policy Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('validates email format on sign up', () async {
      final service = await AuthService.initialize();
      final result = await service.signUp(
        email: 'invalid-email',
        password: 'password123',
      );

      expect(result.isSuccess, isFalse);
      expect(result.errorMessage, contains('valid email'));
    });

    test('validates password length on sign up', () async {
      final service = await AuthService.initialize();
      final result = await service.signUp(
        email: 'scholar@lorvani.com',
        password: '123',
      );

      expect(result.isSuccess, isFalse);
      expect(result.errorMessage, contains('at least 6 characters'));
    });

    test('registers user and detects duplicate email on subsequent attempt', () async {
      final service = await AuthService.initialize();

      // First registration succeeds
      final firstReg = await service.signUp(
        email: 'explorer@lorvani.com',
        password: 'securePassword123',
        name: 'Aria Explorer',
      );
      expect(firstReg.isSuccess, isTrue);
      expect(service.isLoggedIn, isTrue);
      expect(service.getCurrentUser()?.email, 'explorer@lorvani.com');

      // Second registration with same email fails with duplicate message
      final duplicateReg = await service.signUp(
        email: 'explorer@lorvani.com',
        password: 'anotherPassword',
      );
      expect(duplicateReg.isSuccess, isFalse);
      expect(
        duplicateReg.errorMessage,
        contains('already exists. Please sign in'),
      );
    });

    test('sign in verifies credentials correctly', () async {
      final service = await AuthService.initialize();
      await service.signUp(
        email: 'user@test.com',
        password: 'correctPassword',
      );
      await service.signOut();

      // Wrong password fails
      final wrongPass = await service.signIn(
        email: 'user@test.com',
        password: 'wrongPassword',
      );
      expect(wrongPass.isSuccess, isFalse);
      expect(wrongPass.errorMessage, contains('Incorrect password'));

      // Non-existent user fails
      final nonExistent = await service.signIn(
        email: 'unknown@test.com',
        password: 'correctPassword',
      );
      expect(nonExistent.isSuccess, isFalse);
      expect(nonExistent.errorMessage, contains('No account found'));

      // Correct password succeeds
      final correct = await service.signIn(
        email: 'user@test.com',
        password: 'correctPassword',
      );
      expect(correct.isSuccess, isTrue);
      expect(service.isLoggedIn, isTrue);
    });

    test('enforces 1-story free trial policy for guests', () async {
      final service = await AuthService.initialize();

      // Guest starts with 0 stories and can generate 1 story
      expect(service.isLoggedIn, isFalse);
      expect(service.guestStoriesCount, 0);
      expect(service.canGenerateStory, isTrue);

      // Guest creates 1st story
      await service.recordStoryGenerated();
      expect(service.guestStoriesCount, 1);
      // Now guest limit is reached! Cannot generate 2nd story without login
      expect(service.canGenerateStory, isFalse);

      // User signs in -> Now unlimited stories permitted!
      await service.signUp(
        email: 'member@lorvani.com',
        password: 'password123',
      );
      expect(service.isLoggedIn, isTrue);
      expect(service.canGenerateStory, isTrue);
    });

    test('validates email typos and invalid domains correctly', () {
      expect(AuthService.validateEmail(null), equals('Please enter your email.'));
      expect(AuthService.validateEmail(''), equals('Please enter your email.'));
      expect(AuthService.validateEmail('invalid'), equals('Please enter a valid email address.'));
      expect(
        AuthService.validateEmail('user@gmail.con'),
        equals('Invalid email domain. Did you mean .com?'),
      );
      expect(
        AuthService.validateEmail('user@gmai.com'),
        equals('Did you mean @gmail.com?'),
      );
      expect(
        AuthService.validateEmail('user@yaho.com'),
        equals('Did you mean @yahoo.com?'),
      );
      expect(AuthService.validateEmail('valid.user@gmail.com'), isNull);
    });

    test('recovers session and initializes prefs lazily when not pre-provided', () async {
      final uninitializedService = AuthService();
      final reg = await uninitializedService.signUp(
        email: 'lazy@lorvani.com',
        password: 'password123',
      );
      expect(reg.isSuccess, isTrue);
      expect(uninitializedService.isLoggedIn, isTrue);
      expect(uninitializedService.getCurrentUser()?.email, equals('lazy@lorvani.com'));
    });
  });
}

