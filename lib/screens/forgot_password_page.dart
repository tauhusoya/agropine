import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';
import '../utils/input_validators.dart';
import '../services/firebase_auth_service.dart';

class ForgotPasswordPage extends StatefulWidget {
  final VoidCallback onBackToLogin;

  const ForgotPasswordPage({
    super.key,
    required this.onBackToLogin,
  });

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  late TextEditingController _emailController;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isEmailValid = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _emailController.addListener(_updateValidationState);
  }

  void _updateValidationState() {
    setState(() {
      _isEmailValid = InputValidators.validateEmail(_emailController.text) == null;
      _errorMessage = null;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back Button
            GestureDetector(
              onTap: widget.onBackToLogin,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.borderColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.arrow_back, size: 20),
              ),
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
            // Header
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Forgot Password?',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'No worries! Enter your email address and we\'ll send you a link to reset your password.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 3,
                ),
              ],
            ),
            const SizedBox(height: 40),
            // Email Field
            Text(
              'Email Address',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              enabled: !_isLoading,
              onChanged: (_) => _updateValidationState(),
              decoration: InputDecoration(
                hintText: 'Enter your registered email',
                prefixIcon: const Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: 32),
            // Send Reset Link Button
            Semantics(
              label: 'Send reset link button',
              button: true,
              enabled: !_isLoading && _isEmailValid,
              onTap: (!_isLoading && _isEmailValid) ? _handleSendResetLink : null,
              child: CustomButton(
                label: 'Send Reset Link',
                onPressed: _handleSendResetLink,
                isLoading: _isLoading,
                isEnabled: _isEmailValid,
              ),
            ),
            const SizedBox(height: 24),
            // Back to Login Link
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Remember your password? ',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  TextButton(
                    onPressed: widget.onBackToLogin,
                    child: const Text('Sign In'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSendResetLink() async {
    final emailError = InputValidators.validateEmail(_emailController.text);
    if (emailError != null) {
      setState(() {
        _errorMessage = emailError;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final firebaseAuthService = FirebaseAuthService();
      await firebaseAuthService.sendPasswordResetEmail(_emailController.text.trim());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password reset link sent to your email. Please check your inbox.'),
            backgroundColor: AppTheme.lightGreen,
          ),
        );
        widget.onBackToLogin();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to send reset email. Please try again.';
          _isLoading = false;
        });
      }
    }
  }
}

