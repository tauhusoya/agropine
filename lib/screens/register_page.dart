import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../widgets/password_strength_indicator.dart';
import '../widgets/animations.dart';
import '../utils/input_validators.dart';
import '../services/firebase_auth_service.dart';

class RegisterPage extends StatefulWidget {
  final VoidCallback onSwitchToLogin;
  final VoidCallback? onBackToLanding;

  const RegisterPage({
    super.key,
    required this.onSwitchToLogin,
    this.onBackToLanding,
  });

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  bool _agreedToTerms = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    
    _firstNameController.addListener(_updateValidationState);
    _lastNameController.addListener(_updateValidationState);
    _emailController.addListener(_updateValidationState);
    _passwordController.addListener(_updateValidationState);
    _confirmPasswordController.addListener(_updateValidationState);
  }

  void _updateValidationState() {
    setState(() {
      _errorMessage = null;
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
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

    return WillPopScope(
      onWillPop: () async {
        if (widget.onBackToLanding != null) {
          widget.onBackToLanding!();
          return false; // Prevent default back behavior
        }
        return true; // Allow default back behavior if no callback
      },
      child: SingleChildScrollView(
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
                // Back Button
                if (widget.onBackToLanding != null)
                  GestureDetector(
                    onTap: widget.onBackToLanding,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.borderColor),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.arrow_back, size: 20),
                    ),
                  ),
                const SizedBox(height: 24),
                // Header
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create Account',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Join us and start growing your business',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                // Error Message Display
                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.errorRed.withValues(alpha: 0.1),
                      border: Border.all(color: AppTheme.errorRed),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    margin: const EdgeInsets.only(bottom: 24),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: AppTheme.errorRed,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.errorRed,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
            StaggeredFadeInWidget(
              itemDelay: const Duration(milliseconds: 150),
              children: [
                CustomTextField(
                  label: 'First Name',
                  hint: 'Enter your first name',
                  controller: _firstNameController,
                  keyboardType: TextInputType.name,
                  prefixIcon: Icons.person_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'First name is required';
                    }
                    return null;
                  },
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 24),
                CustomTextField(
                  label: 'Last Name',
                  hint: 'Enter your last name',
                  controller: _lastNameController,
                  keyboardType: TextInputType.name,
                  prefixIcon: Icons.person_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Last name is required';
                    }
                    return null;
                  },
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 24),
                CustomTextField(
                  label: 'Email Address',
                  hint: 'Enter your email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: InputValidators.validateEmail,
                  enabled: !_isLoading,
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
                  enabled: !_isLoading,
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
                  enabled: !_isLoading,
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
                    activeColor: AppTheme.lightGreen,
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
                child: CustomButton(
                  label: 'Create Account',
                  onPressed: _handleRegister,
                  isLoading: _isLoading,
                  isEnabled: _agreedToTerms,
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
              ],
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
                      child: const Text('Sign In', style: TextStyle(
                        color: AppTheme.primaryGold,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      )),
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
      ),
    );
  }

  Future<void> _handleRegister() async {
    // Validate all fields
    final firstNameError = _firstNameController.text.isEmpty ? 'First name is required' : null;
    final lastNameError = _lastNameController.text.isEmpty ? 'Last name is required' : null;
    final emailError = InputValidators.validateEmail(_emailController.text);
    final passwordError = InputValidators.validatePassword(_passwordController.text);
    final confirmError = InputValidators.validatePasswordConfirmation(
      _confirmPasswordController.text,
      _passwordController.text,
    );

    // Show first error encountered
    final errorMessage = firstNameError ?? lastNameError ?? emailError ?? passwordError ?? confirmError;
    if (errorMessage != null) {
      setState(() {
        _errorMessage = errorMessage;
      });
      return;
    }

    if (!_agreedToTerms) {
      setState(() {
        _errorMessage = 'Please agree to the terms and conditions';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final firebaseAuthService = FirebaseAuthService();
      await firebaseAuthService.registerWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        accountType: 'individual',
        businessNumber: null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created successfully!'),
            backgroundColor: AppTheme.lightGreen,
          ),
        );
        // Navigation to dashboard will be handled by auth state changes
        widget.onSwitchToLogin();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

