import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/password_strength_indicator.dart';
import '../widgets/app_logo.dart';
import '../widgets/animations.dart';
import '../utils/input_validators.dart';
import '../services/google_sign_in_service.dart';

class RegisterPage extends StatefulWidget {
  final VoidCallback onSwitchToLogin;

  const RegisterPage({
    super.key,
    required this.onSwitchToLogin,
  });

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  bool _agreedToTerms = false;
  bool _isLoading = false;
  final _googleSignInService = GoogleSignInService();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    final horizontalPadding = isSmallScreen ? 24.0 : 48.0;
    final verticalPadding = isSmallScreen ? 32.0 : 48.0;
    final maxWidth = isSmallScreen ? double.infinity : 500.0;

    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: verticalPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                // Logo
                Center(
                  child: AppLogo(
                    size: 80,
                    isHero: true,
                    tag: 'register_logo',
                  ),
                ),
                const SizedBox(height: 32),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create Account',
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                  'Join us and start growing your business',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 40),
            StaggeredFadeInWidget(
              itemDelay: const Duration(milliseconds: 150),
              children: [
                CustomTextField(
                  label: 'Full Name',
                  hint: 'Enter your full name',
                  controller: _nameController,
                  keyboardType: TextInputType.name,
                  prefixIcon: Icons.person_outlined,
                  validator: InputValidators.validateFullName,
                ),
                const SizedBox(height: 24),
                // Email Field
                CustomTextField(
                  label: 'Email Address',
                  hint: 'Enter your email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: InputValidators.validateEmail,
                ),
                const SizedBox(height: 24),
                // Password Field
                CustomTextField(
                  label: 'Password',
                  hint: 'Create a strong password',
                  controller: _passwordController,
                  prefixIcon: Icons.lock_outlined,
                  isPassword: true,
                  validator: InputValidators.validatePassword,
                ),
                const SizedBox(height: 8),
                // Password Strength Indicator
                PasswordStrengthIndicator(
                  password: _passwordController.text,
                ),
                const SizedBox(height: 24),
                // Confirm Password Field
                CustomTextField(
                  label: 'Confirm Password',
                  hint: 'Confirm your password',
                  controller: _confirmPasswordController,
                  prefixIcon: Icons.lock_outlined,
                  isPassword: true,
                  validator: (value) {
                    return InputValidators.validatePasswordConfirmation(
                      value,
                      _passwordController.text,
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            Semantics(
              label: 'Terms and conditions checkbox',
              enabled: true,
              onTap: () {
                setState(() {
                  _agreedToTerms = !_agreedToTerms;
                });
              },
              child: Row(
                children: [
                  Checkbox(
                    value: _agreedToTerms,
                    activeColor: AppTheme.primaryGold,
                    onChanged: (value) {
                      setState(() {
                        _agreedToTerms = value ?? false;
                      });
                    },
                  ),
                  Expanded(
                    child: Tooltip(
                      message: 'You must agree to the terms and conditions to create an account',
                      child: Text(
                        'I agree to the Terms & Conditions and Privacy Policy',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Semantics(
              label: 'Create account button',
              button: true,
              enabled: !_isLoading && _agreedToTerms,
              onTap: (_isLoading || !_agreedToTerms) ? null : _handleRegister,
              child: Tooltip(
                message: 'Click to create your new account',
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (_isLoading || !_agreedToTerms) ? null : _handleRegister,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppTheme.textDark,
                              ),
                            ),
                          )
                        : const Text('Create Account'),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Divider
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 1,
                    color: AppTheme.borderColor,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Or sign up with',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 1,
                    color: AppTheme.borderColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Center(
              child: SizedBox(
                width: double.infinity,
                child: _buildGoogleButton(),
              ),
            ),
            const SizedBox(height: 32),
            Semantics(
              label: 'Sign in navigation',
              button: true,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Tooltip(
                    message: 'Click to go to sign in page',
                    child: TextButton(
                      onPressed: widget.onSwitchToLogin,
                      child: const Text('Sign In'),
                    ),
                  ),
                ],
              ),
            ),
          ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleButton() {
    return Semantics(
      label: 'Sign up with Google button',
      button: true,
      enabled: !_isLoading,
      onTap: _isLoading ? null : _handleGoogleSignUp,
      child: Tooltip(
        message: 'Click to sign up using your Google account',
        child: OutlinedButton(
          onPressed: _isLoading ? null : _handleGoogleSignUp,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            side: const BorderSide(color: AppTheme.borderColor),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryGold),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: Image.network(
                        'https://www.gstatic.com/images/branding/product/1x/googleg_standard_color_128dp.png',
                        errorBuilder: (context, error, stackTrace) {
                          return const Text('G');
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Continue with Google',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Future<void> _handleRegister() async {
    // Validate all fields with proper validators
    final nameError = InputValidators.validateFullName(_nameController.text);
    final emailError = InputValidators.validateEmail(_emailController.text);
    final passwordError = InputValidators.validatePassword(_passwordController.text);
    final confirmError = InputValidators.validatePasswordConfirmation(
      _confirmPasswordController.text,
      _passwordController.text,
    );

    // Show first error encountered
    if (nameError != null || emailError != null || passwordError != null || confirmError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(nameError ?? emailError ?? passwordError ?? confirmError ?? 'Validation error'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the terms and conditions'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Replace with actual API call
      // Example: await _authService.register(...)
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created successfully!'),
            backgroundColor: AppTheme.lightGreen,
          ),
        );
        // TODO: Navigate to login or home page
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration failed: ${e.toString()}'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  Future<void> _handleGoogleSignUp() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = await _googleSignInService.signIn();
      if (user != null) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Welcome, ${user.displayName}!'),
              backgroundColor: AppTheme.lightGreen,
            ),
          );
          // TODO: Navigate to home page or complete registration
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google Sign-Up failed: ${e.toString()}'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }
}
