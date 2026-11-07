import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/auth/auth_service.dart';
import '../../../core/theme/comic_colors.dart';
import '../../../core/theme/comic_typography.dart';
import '../../../core/widgets/comic_button.dart';
import '../../../core/widgets/comic_panel.dart';
import '../../../core/widgets/dimension_flip_logo.dart';

enum AuthMode { signIn, signUp }

/// Comic Universe Authentication Screen (Sign In & Sign Up)
class AuthScreen extends ConsumerStatefulWidget {
  final String? redirectPath;

  const AuthScreen({
    super.key,
    this.redirectPath,
  });

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  AuthMode _mode = AuthMode.signIn;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _switchMode(AuthMode newMode) {
    setState(() {
      _mode = newMode;
      _errorMessage = null;
    });
  }

  Future<void> _submit() async {
    setState(() => _errorMessage = null);

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_mode == AuthMode.signUp &&
        _passwordController.text.trim() !=
            _confirmPasswordController.text.trim()) {
      setState(() {
        _errorMessage = 'Passwords do not match. Please verify.';
      });
      return;
    }

    setState(() => _isLoading = true);

    final authService = ref.read(authServiceProvider);
    AuthResult result;

    if (_mode == AuthMode.signIn) {
      result = await authService.signIn(
        email: _emailController.text,
        password: _passwordController.text,
      );
    } else {
      result = await authService.signUp(
        email: _emailController.text,
        password: _passwordController.text,
        name: _nameController.text.trim().isNotEmpty
            ? _nameController.text.trim()
            : null,
      );
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.isSuccess) {
      // Update riverpod state
      ref.read(currentUserProvider.notifier).setUser(result.user);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: ComicColors.cardBackground,
          behavior: SnackBarBehavior.floating,
          content: Text(
            _mode == AuthMode.signIn
                ? '⚡ Welcome back, ${result.user?.name ?? 'Scholar'}!'
                : '🚀 Welcome to Lorvani, ${result.user?.name ?? 'Scholar'}!',
            style: ComicTypography.body(
              color: ComicColors.electricYellow,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );

      if (context.canPop()) {
        context.pop(true);
      } else {
        context.go('/home');
      }
    } else {
      setState(() {
        _errorMessage = result.errorMessage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSignUp = _mode == AuthMode.signUp;

    return Scaffold(
      backgroundColor: ComicColors.deepCharcoal,
      appBar: AppBar(
        title: Text(
          isSignUp ? 'JOIN THE UNIVERSE' : 'SCHOLAR SIGN IN',
          style: ComicTypography.comicDisplay(fontSize: 20),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Dimension Flip Logo & Tagline
                  const Center(
                    child: DimensionFlipLogo(
                      variant: DimensionFlipVariant.primary,
                      size: 42,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isSignUp
                        ? 'Create your account for unlimited AI comics'
                        : 'Sign in to access all your comic stories',
                    textAlign: TextAlign.center,
                    style: ComicTypography.body(
                      fontSize: 13,
                      color: ComicColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Mode Toggle Bar (Sign In / Sign Up)
                  Container(
                    decoration: BoxDecoration(
                      color: ComicColors.cardBackground,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: ComicColors.comicBorder, width: 1.5),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _switchMode(AuthMode.signIn),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: !isSignUp
                                    ? ComicColors.comicPurple
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  'Sign In',
                                  style: ComicTypography.title(
                                    fontSize: 14,
                                    color: !isSignUp
                                        ? Colors.white
                                        : ComicColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _switchMode(AuthMode.signUp),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: isSignUp
                                    ? ComicColors.comicPurple
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  'Create Account',
                                  style: ComicTypography.title(
                                    fontSize: 14,
                                    color: isSignUp
                                        ? Colors.white
                                        : ComicColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Error Message Banner (e.g. Account Already Exists)
                  if (_errorMessage != null) ...[
                    ComicPanel(
                      backgroundColor: const Color(0xFF3D1923),
                      borderColor: Colors.redAccent,
                      borderWidth: 1.8,
                      borderRadius: 12,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline_rounded,
                              color: Colors.redAccent, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: ComicTypography.caption(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Form Fields Panel
                  ComicPanel(
                    backgroundColor: ComicColors.cardBackground,
                    borderColor: ComicColors.comicPurple.withValues(alpha: 0.5),
                    borderRadius: 16,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Name Field (Only on Sign Up)
                        if (isSignUp) ...[
                          Text(
                            'Your Name / Alias',
                            style: ComicTypography.title(
                              fontSize: 13,
                              color: ComicColors.skyCyan,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _nameController,
                            style: ComicTypography.body(color: Colors.white),
                            decoration: _inputDecoration(
                              hint: 'Explorer Nova',
                              icon: Icons.person_outline_rounded,
                            ),
                          ),
                          const SizedBox(height: 14),
                        ],

                        // Email Field
                        Text(
                          'Email Address',
                          style: ComicTypography.title(
                            fontSize: 13,
                            color: ComicColors.skyCyan,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: ComicTypography.body(color: Colors.white),
                          validator: (value) => AuthService.validateEmail(value),
                          decoration: _inputDecoration(
                            hint: 'scholar@lorvani.com',
                            icon: Icons.email_outlined,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Password Field
                        Text(
                          'Password',
                          style: ComicTypography.title(
                            fontSize: 13,
                            color: ComicColors.skyCyan,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          style: ComicTypography.body(color: Colors.white),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your password.';
                            }
                            if (value.trim().length < 6) {
                              return 'Password must be at least 6 characters.';
                            }
                            return null;
                          },
                          decoration: _inputDecoration(
                            hint: '••••••••',
                            icon: Icons.lock_outline_rounded,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_rounded
                                    : Icons.visibility_rounded,
                                color: ComicColors.textSecondary,
                                size: 18,
                              ),
                              onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                        ),

                        // Confirm Password (Only on Sign Up)
                        if (isSignUp) ...[
                          const SizedBox(height: 14),
                          Text(
                            'Confirm Password',
                            style: ComicTypography.title(
                              fontSize: 13,
                              color: ComicColors.skyCyan,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirmPassword,
                            style: ComicTypography.body(color: Colors.white),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please confirm your password.';
                              }
                              if (value.trim() !=
                                  _passwordController.text.trim()) {
                                return 'Passwords do not match.';
                              }
                              return null;
                            },
                            decoration: _inputDecoration(
                              hint: '••••••••',
                              icon: Icons.lock_clock_outlined,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility_off_rounded
                                      : Icons.visibility_rounded,
                                  color: ComicColors.textSecondary,
                                  size: 18,
                                ),
                                onPressed: () => setState(() =>
                                    _obscureConfirmPassword =
                                        !_obscureConfirmPassword),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Submit CTA
                  ComicButton(
                    text: _isLoading
                        ? 'Verifying...'
                        : isSignUp
                            ? 'Create Free Account'
                            : 'Sign In & Continue',
                    icon: isSignUp
                        ? Icons.rocket_launch_rounded
                        : Icons.login_rounded,
                    variant: ComicButtonVariant.gradient,
                    onPressed: _isLoading ? null : _submit,
                  ),
                  const SizedBox(height: 16),

                  // Guest / Continue Without Login (if permitted)
                  Center(
                    child: TextButton(
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop(false);
                        } else {
                          context.go('/home');
                        }
                      },
                      child: Text(
                        'Continue as Guest',
                        style: ComicTypography.caption(
                          fontSize: 13,
                          color: ComicColors.textSecondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: ComicTypography.body(
        fontSize: 13,
        color: ComicColors.textMuted,
      ),
      prefixIcon: Icon(icon, color: ComicColors.comicPurple, size: 20),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: ComicColors.deepCharcoal,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            const BorderSide(color: ComicColors.comicBorder, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            const BorderSide(color: ComicColors.comicBorder, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            const BorderSide(color: ComicColors.comicPurple, width: 2.0),
      ),
    );
  }
}

