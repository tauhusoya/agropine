import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../widgets/animations.dart';
import '../utils/input_validators.dart';
import '../utils/form_validation_state.dart';
import '../services/firebase_auth_service.dart';
import '../services/error_handler.dart';
import '../services/logging_service.dart';


class LoginPage extends StatefulWidget {
  final VoidCallback onSwitchToRegister;
  final VoidCallback onForgotPassword;
  final VoidCallback? onBackToLanding;

  const LoginPage({
    super.key,
    required this.onSwitchToRegister,
    required this.onForgotPassword,
    this.onBackToLanding,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  bool _isLoading = false;
  String? _errorMessage;
  late LoginFormValidationState _validationState;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _validationState = LoginFormValidationState(
      isEmailValid: false,
      isPasswordValid: false,
    );
    _emailController.addListener(_updateValidationState);
    _passwordController.addListener(_updateValidationState);
  }

  @override
  void dispose() {
    _emailController.removeListener(_updateValidationState);
    _passwordController.removeListener(_updateValidationState);
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _updateValidationState() {
    setState(() {
      _validationState = LoginFormValidationState(
        isEmailValid: InputValidators.validateEmail(_emailController.text) == null,
        isPasswordValid: _passwordController.text.isNotEmpty,
      );
      _errorMessage = null;
    });
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
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome Back',
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sign in to your account to continue',
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
                  const SizedBox(height: 24),
                  // Form Fields with Staggered Animation
                  StaggeredFadeInWidget(
                    itemDelay: const Duration(milliseconds: 150),
                    children: [
                      // Email Field
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
                        hint: 'Enter your password',
                        controller: _passwordController,
                        prefixIcon: Icons.lock_outlined,
                        isPassword: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password is required';
                          }
                          return null;
                        },
                        enabled: !_isLoading,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Forgot Password
                  Semantics(
                    label: 'Forgot password link',
                    button: true,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Tooltip(
                        message: 'Click to reset your password',
                        child: TextButton(
                          onPressed: widget.onForgotPassword,
                          child: const Text('Forgot Password?'),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Semantics(
                    label: 'Sign in button',
                    button: true,
                    enabled: !_isLoading && _validationState.isFormValid,
                    onTap: (!_isLoading && _validationState.isFormValid) ? _handleLogin : null,
                    child: Tooltip(
                      message: 'Click to sign in with your email and password',
                      child: CustomButton(
                        label: 'Sign In',
                        onPressed: _handleLogin,
                        isLoading: _isLoading,
                        isEnabled: _validationState.isFormValid,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Semantics(
                    label: 'Sign up navigation',
                    button: true,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Tooltip(
                          message: 'Click to create a new account',
                          child: TextButton(
                            onPressed: widget.onSwitchToRegister,
                            child: const Text('Sign Up'),
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
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (!_validationState.isFormValid) {
      setState(() {
        _errorMessage = 'Please fill in all required fields';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      LoggingService.logUserAction('login_attempt', data: {
        'email': _emailController.text,
      });

      final firebaseAuthService = FirebaseAuthService();
      final userCredential = await firebaseAuthService.loginWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        LoggingService.logAuthEvent('login_success', userId: userCredential.user?.uid);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Welcome ${userCredential.user?.displayName ?? 'back'}!'),
            backgroundColor: AppTheme.lightGreen,
          ),
        );
        // Navigation to dashboard will be handled by auth state changes
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        LoggingService.error('Login failed', tag: 'AUTH', error: e);
        
        // Get user-friendly error message
        final errorMessage = ErrorHandler.handleAuthError(e);
        
        // Check if it's a "user not found" error, which might mean they signed up with Google
        if (e.code == 'user-not-found' || 
            e.code == 'wrong-password' ||
            e.code == 'invalid-credential') {
          // Offer to set password for Google accounts
          _showSetPasswordDialog(
            email: _emailController.text.trim(),
            errorMessage: errorMessage,
          );
          setState(() {
            _isLoading = false;
          });
          return;
        }
        
        setState(() {
          _errorMessage = errorMessage;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        LoggingService.error('Unexpected login error', tag: 'AUTH', error: e);
        final errorMessage = ErrorHandler.handleError(e);
        
        setState(() {
          _errorMessage = errorMessage;
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

  void _showSetPasswordDialog({
    required String email,
    required String errorMessage,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('No Password Set'),
        content: const Text(
          'It looks like you registered with Google Sign-In. '
          'Would you like to set a password so you can also log in with email?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Not Now'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showSetPasswordForm(email);
            },
            child: const Text('Set Password'),
          ),
        ],
      ),
    );
  }

  void _showSetPasswordForm(String email) {
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    String? errorMessage;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Set Password'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Set a password for $email',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                if (errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      errorMessage!,
                      style: TextStyle(
                        color: AppTheme.errorRed,
                        fontSize: 12,
                      ),
                    ),
                  ),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Confirm Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                passwordController.dispose();
                confirmPasswordController.dispose();
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final password = passwordController.text;
                final confirmPassword = confirmPasswordController.text;

                if (password.isEmpty || confirmPassword.isEmpty) {
                  setState(() {
                    errorMessage = 'Both fields are required';
                  });
                  return;
                }

                if (password != confirmPassword) {
                  setState(() {
                    errorMessage = 'Passwords do not match';
                  });
                  return;
                }

                if (password.length < 6) {
                  setState(() {
                    errorMessage = 'Password must be at least 6 characters';
                  });
                  return;
                }

                try {
                  // First sign in with Google to get the current user
                  // Need to sign in with Google first, then set password
                  setState(() {
                    errorMessage = 'Please sign in with Google first';
                  });
                  
                  passwordController.dispose();
                  confirmPasswordController.dispose();
                  Navigator.pop(context);
                  
                  // Show message
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please sign in with Google first, then you can set a password'),
                        backgroundColor: AppTheme.primaryGold,
                      ),
                    );
                  }
                } catch (e) {
                  setState(() {
                    errorMessage = e.toString();
                  });
                }
              },
              child: const Text('Set Password'),
            ),
          ],
        ),
      ),
    );
  }
}
