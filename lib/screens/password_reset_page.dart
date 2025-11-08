import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';
import '../utils/input_validators.dart';

class PasswordResetPage extends StatefulWidget {
  final String? actionCode;
  final VoidCallback? onPasswordReset;

  const PasswordResetPage({
    super.key,
    this.actionCode,
    this.onPasswordReset,
  });

  @override
  State<PasswordResetPage> createState() => _PasswordResetPageState();
}

class _PasswordResetPageState extends State<PasswordResetPage> {
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmPasswordController;

  bool _isLoading = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;
  String? _errorMessage;
  String? _successMessage;
  String? _email;
  bool _isVerifyingCode = true;

  @override
  void initState() {
    super.initState();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    
    // Verify the action code if provided
    if (widget.actionCode != null) {
      _verifyActionCode(widget.actionCode!);
    }
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _verifyActionCode(String code) async {
    try {
      setState(() {
        _isVerifyingCode = true;
      });

      // Verify the reset code and get user email
      final email = await FirebaseAuth.instance.verifyPasswordResetCode(code);

      setState(() {
        _email = email;
        _isVerifyingCode = false;
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isVerifyingCode = false;
        if (e.code == 'invalid-action-code') {
          _errorMessage = 'This password reset link is invalid or has expired.';
        } else if (e.code == 'expired-action-code') {
          _errorMessage = 'This password reset link has expired. Please request a new one.';
        } else {
          _errorMessage = e.message ?? 'Failed to verify reset link.';
        }
      });
    } catch (e) {
      setState(() {
        _isVerifyingCode = false;
        _errorMessage = 'Failed to verify reset link. Please try again.';
      });
    }
  }

  Future<void> _handleResetPassword() async {
    if (widget.actionCode == null) {
      setState(() {
        _errorMessage = 'No reset code provided';
      });
      return;
    }

    // Clear messages
    setState(() {
      _errorMessage = null;
      _successMessage = null;
    });

    // Validate passwords
    final newPasswordError = InputValidators.validatePassword(_newPasswordController.text);
    if (newPasswordError != null) {
      setState(() {
        _errorMessage = newPasswordError;
      });
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'Passwords do not match';
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Confirm password reset with the action code and new password
      await FirebaseAuth.instance.confirmPasswordReset(
        code: widget.actionCode!,
        newPassword: _newPasswordController.text,
      );

      setState(() {
        _isLoading = false;
        _successMessage = 'Password reset successfully!';
        _newPasswordController.clear();
        _confirmPasswordController.clear();
      });

      // Show success and navigate back
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Your password has been reset successfully! Please sign in with your new password.'),
            backgroundColor: AppTheme.lightGreen,
            duration: Duration(seconds: 3),
          ),
        );
      }

      // Wait a moment then callback or pop
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          widget.onPasswordReset?.call();
          if (Navigator.canPop(context)) {
            Navigator.of(context).pop();
          }
        }
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
        if (e.code == 'weak-password') {
          _errorMessage = 'Password is too weak. Please use a stronger password.';
        } else if (e.code == 'expired-action-code') {
          _errorMessage = 'This password reset link has expired. Please request a new one.';
        } else if (e.code == 'invalid-action-code') {
          _errorMessage = 'This password reset link is invalid. Please try again.';
        } else {
          _errorMessage = e.message ?? 'Failed to reset password. Please try again.';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to reset password. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Reset Password',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppTheme.textDark,
                fontWeight: FontWeight.bold,
              ),
        ),
        centerTitle: true,
        backgroundColor: AppTheme.primaryYellow,
        elevation: 0,
      ),
      body: SafeArea(
        child: _isVerifyingCode
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      color: AppTheme.lightGreen,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Verifying reset link...',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppTheme.textLight,
                          ),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Create New Password',
                            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                  color: AppTheme.textDark,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Please enter your new password below.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.textLight,
                                ),
                          ),
                          if (_email != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Email: $_email',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.textLight,
                                    fontStyle: FontStyle.italic,
                                  ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Error Message
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

                      // Success Message
                      if (_successMessage != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.lightGreen.withValues(alpha: 0.1),
                            border: Border.all(color: AppTheme.lightGreen),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          margin: const EdgeInsets.only(bottom: 24),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle_outline,
                                color: AppTheme.lightGreen,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _successMessage!,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: AppTheme.lightGreen,
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Only show form if no error
                      if (_errorMessage == null || _successMessage != null) ...[
                        // New Password Field
                        Text(
                          'New Password',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textDark,
                              ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _newPasswordController,
                          obscureText: !_showNewPassword,
                          enabled: !_isLoading && _successMessage == null,
                          decoration: InputDecoration(
                            hintText: 'Enter a strong password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _showNewPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _showNewPassword = !_showNewPassword;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Password must be at least 6 characters',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.textLight,
                              ),
                        ),
                        const SizedBox(height: 24),

                        // Confirm Password Field
                        Text(
                          'Confirm Password',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textDark,
                              ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _confirmPasswordController,
                          obscureText: !_showConfirmPassword,
                          enabled: !_isLoading && _successMessage == null,
                          decoration: InputDecoration(
                            hintText: 'Confirm your new password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _showConfirmPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _showConfirmPassword = !_showConfirmPassword;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Reset Password Button
                        if (_successMessage == null)
                          Semantics(
                            label: 'Reset password button',
                            button: true,
                            enabled: !_isLoading,
                            child: CustomButton(
                              label: 'Reset Password',
                              onPressed: _handleResetPassword,
                              isLoading: _isLoading,
                            ),
                          ),

                        // Sign In Button (shown after success)
                        if (_successMessage != null)
                          Semantics(
                            label: 'Sign in button',
                            button: true,
                            enabled: !_isLoading,
                            child: CustomButton(
                              label: 'Go to Sign In',
                              onPressed: () {
                                if (Navigator.canPop(context)) {
                                  Navigator.of(context).pop();
                                }
                              },
                              isLoading: false,
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
