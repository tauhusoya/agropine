import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../widgets/animations.dart';
import '../utils/input_validators.dart';
import '../services/firebase_auth_service.dart';

class VendorEmailPage extends StatefulWidget {
  final VoidCallback onBackToLanding;
  final VoidCallback onSignIn;
  final Function(String) onEmailSent; // Callback after email sent, passes email
  final FirebaseAuthService firebaseAuthService; // Use shared instance

  const VendorEmailPage({
    super.key,
    required this.onBackToLanding,
    required this.onSignIn,
    required this.onEmailSent,
    required this.firebaseAuthService,
  });

  @override
  State<VendorEmailPage> createState() => _VendorEmailPageState();
}

class _VendorEmailPageState extends State<VendorEmailPage> {
  final _formKey = GlobalKey<FormState>();
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

  Future<void> _handleSendVerificationEmail() async {
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
      final email = _emailController.text.trim();

      // Set vendor registration mode to prevent dashboard from showing
      widget.firebaseAuthService.setVendorRegistrationMode(true);

      // Send verification email (creates temp account, sends email, signs out)
      await widget.firebaseAuthService.sendVendorVerificationEmail(email);

      if (mounted) {
        // Pass email to waiting page
        widget.onEmailSent(email);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    final horizontalPadding = isSmallScreen ? 24.0 : 48.0;
    final verticalPadding = isSmallScreen ? 32.0 : 48.0;
    final maxWidth = isSmallScreen ? double.infinity : 500.0;

    return WillPopScope(
      onWillPop: () async {
        widget.onBackToLanding();
        return false;
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
                    GestureDetector(
                      onTap: widget.onBackToLanding,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppTheme.borderColor),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: AppTheme.textDark,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Header
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Create Your Vendor Account',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Enter your email address to get started. We\'ll send you a verification link.',
                          style: Theme.of(context).textTheme.bodyMedium,
                          maxLines: 3,
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
                    // Email Input
                    StaggeredFadeInWidget(
                      itemDelay: const Duration(milliseconds: 150),
                      children: [
                        CustomTextField(
                          label: 'Email Address',
                          hint: 'Enter your email',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icons.email_outlined,
                          validator: InputValidators.validateEmail,
                          enabled: !_isLoading,
                        ),
                        const SizedBox(height: 32),
                        // Send Verification Email Button
                        Semantics(
                          label: 'Send verification email button',
                          button: true,
                          enabled: !_isLoading && _isEmailValid,
                          onTap: (!_isLoading && _isEmailValid) ? _handleSendVerificationEmail : null,
                          child: Tooltip(
                            message: 'Click to send verification email',
                            child: CustomButton(
                              label: 'Send Verification Email',
                              onPressed: _handleSendVerificationEmail,
                              isLoading: _isLoading,
                              isEnabled: _isEmailValid,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    // Sign In Link
                    Semantics(
                      label: 'Sign in',
                      button: true,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Want to sign in instead? ',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Tooltip(
                            message: 'Click to go to sign in',
                            child: TextButton(
                              onPressed: widget.onSignIn,
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
      ),
    );
  }
}
