import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

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
  bool _emailSent = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_emailSent) {
      return _buildEmailSentScreen();
    }

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
            // Illustration
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppTheme.primaryGold.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(
                  Icons.mail_outline,
                  size: 60,
                  color: AppTheme.primaryGold,
                ),
              ),
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
              decoration: InputDecoration(
                hintText: 'Enter your registered email',
                prefixIcon: const Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: 32),
            // Send Reset Link Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleSendResetLink,
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
                    : const Text('Send Reset Link'),
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

  Widget _buildEmailSentScreen() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 60),
            // Success Illustration
            Center(
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: AppTheme.primaryGold.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(35),
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  size: 70,
                  color: AppTheme.primaryGold,
                ),
              ),
            ),
            const SizedBox(height: 40),
            // Success Message
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Check Your Email',
                  style: Theme.of(context).textTheme.displayMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'We\'ve sent a password reset link to ${_emailController.text}. Please check your inbox and follow the instructions.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            const SizedBox(height: 40),
            // Info Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryYellow.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.primaryYellow.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: AppTheme.primaryYellow,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'The link will expire in 24 hours. If you don\'t receive an email, check your spam folder.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            // Back to Login Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: widget.onBackToLogin,
                child: const Text('Back to Sign In'),
              ),
            ),
            const SizedBox(height: 16),
            // Resend Link Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    _emailSent = false;
                  });
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: AppTheme.borderColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Send Another Link',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textDark,
                      ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSendResetLink() async {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email address')),
      );
      return;
    }

    // Basic email validation
    if (!_emailController.text.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isLoading = false;
        _emailSent = true;
      });
    }
  }
}
