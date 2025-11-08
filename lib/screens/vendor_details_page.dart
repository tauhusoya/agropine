import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../widgets/password_strength_indicator.dart';
import '../widgets/animations.dart';
import '../utils/input_validators.dart';
import '../services/firebase_auth_service.dart';

class VendorDetailsPage extends StatefulWidget {
  final String verifiedEmail;
  final VoidCallback? onBackToLanding;
  final FirebaseAuthService firebaseAuthService; // Use shared instance
  final VoidCallback? onRegistrationComplete; // Callback for successful registration

  const VendorDetailsPage({
    super.key,
    required this.verifiedEmail,
    this.onBackToLanding,
    required this.firebaseAuthService,
    this.onRegistrationComplete,
  });

  @override
  State<VendorDetailsPage> createState() => _VendorDetailsPageState();
}

class _VendorDetailsPageState extends State<VendorDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  late TextEditingController _ssmIdController;

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _phoneController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _ssmIdController = TextEditingController();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _ssmIdController.dispose();
    super.dispose();
  }

  Future<void> _handleCompleteRegistration() async {
    // Validate all fields
    final firstNameError = _firstNameController.text.isEmpty ? 'First name is required' : null;
    final lastNameError = _lastNameController.text.isEmpty ? 'Last name is required' : null;
    final phoneError = _phoneController.text.isEmpty ? 'Phone number is required' : null;
    final passwordError = InputValidators.validatePassword(_passwordController.text);
    final confirmError = InputValidators.validatePasswordConfirmation(
      _confirmPasswordController.text,
      _passwordController.text,
    );

    // Show first error encountered
    final errorMessage = firstNameError ?? lastNameError ?? phoneError ?? passwordError ?? confirmError;
    if (errorMessage != null) {
      setState(() {
        _errorMessage = errorMessage;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await widget.firebaseAuthService.completeVendorRegistration(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        password: _passwordController.text,
        ssmId: _ssmIdController.text.trim().isEmpty ? null : _ssmIdController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vendor registration completed successfully!'),
            backgroundColor: AppTheme.lightGreen,
          ),
        );
        
        // Wait a moment for auth state to update
        await Future.delayed(const Duration(milliseconds: 500));
        
        if (mounted) {
          debugPrint('Registration complete - triggering StreamBuilder rebuild');
          
          // Call the callback to notify parent that registration is complete
          // This will trigger the StreamBuilder rebuild in AuthenticationScreen
          widget.onRegistrationComplete?.call();
        }
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
        if (widget.onBackToLanding != null) {
          widget.onBackToLanding!();
          return false;
        }
        return true;
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
                    // Header
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Complete Your Profile',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Fill in your details to complete registration',
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
                    // Email Display (read-only, verified)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.lightGreen.withValues(alpha: 0.1),
                        border: Border.all(color: AppTheme.lightGreen),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: AppTheme.lightGreen,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Email Verified',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.textLight,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.verifiedEmail,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Form Fields with Staggered Animation
                    StaggeredFadeInWidget(
                      itemDelay: const Duration(milliseconds: 150),
                      children: [
                        // First Name
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
                        // Last Name
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
                        // Phone Number
                        CustomTextField(
                          label: 'Phone Number',
                          hint: 'Enter your phone number',
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          prefixIcon: Icons.phone_outlined,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Phone number is required';
                            }
                            return null;
                          },
                          enabled: !_isLoading,
                        ),
                        const SizedBox(height: 24),
                        // Password
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
                        // Confirm Password
                        CustomTextField(
                          label: 'Confirm Password',
                          hint: 'Confirm your password',
                          controller: _confirmPasswordController,
                          prefixIcon: Icons.lock_outlined,
                          isPassword: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Confirm password is required';
                            }
                            if (value != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                          enabled: !_isLoading,
                        ),
                        const SizedBox(height: 24),
                        // SSM ID (Optional)
                        CustomTextField(
                          label: 'SSM ID (Optional)',
                          hint: 'Enter your SSM registration number',
                          controller: _ssmIdController,
                          keyboardType: TextInputType.text,
                          prefixIcon: Icons.badge_outlined,
                          enabled: !_isLoading,
                        ),
                        const SizedBox(height: 32),
                        // Complete Registration Button
                        Semantics(
                          label: 'Complete registration button',
                          button: true,
                          enabled: !_isLoading,
                          onTap: !_isLoading ? _handleCompleteRegistration : null,
                          child: Tooltip(
                            message: 'Click to complete your vendor registration',
                            child: CustomButton(
                              label: 'Complete Registration',
                              onPressed: _handleCompleteRegistration,
                              isLoading: _isLoading,
                              isEnabled: true,
                            ),
                          ),
                        ),
                      ],
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
