import 'package:flutter/material.dart';
import '../utils/constants.dart';
import 'error_handler.dart';

/// Comprehensive input validation service
class InputValidationService {
  /// Validate email address
  static AppException? validateEmail(String email) {
    if (email.isEmpty) {
      return AppException(
        message: ErrorMessages.emailRequired,
        code: ErrorCode.validationEmpty,
      );
    }

    final emailRegex = RegExp(ValidationPatterns.email);
    if (!emailRegex.hasMatch(email)) {
      return AppException(
        message: ErrorMessages.invalidEmail,
        code: ErrorCode.validationInvalidFormat,
      );
    }

    return null;
  }

  /// Validate password
  static AppException? validatePassword(String password) {
    if (password.isEmpty) {
      return AppException(
        message: ErrorMessages.passwordRequired,
        code: ErrorCode.validationEmpty,
      );
    }

    if (password.length < AppConstants.minPasswordLength) {
      return AppException(
        message: 'Password must be at least ${AppConstants.minPasswordLength} characters',
        code: ErrorCode.validationTooShort,
      );
    }

    if (password.length > AppConstants.maxPasswordLength) {
      return AppException(
        message: 'Password must not exceed ${AppConstants.maxPasswordLength} characters',
        code: ErrorCode.validationTooLong,
      );
    }

    // Check for strong password pattern
    final passwordRegex = RegExp(ValidationPatterns.password);
    if (!passwordRegex.hasMatch(password)) {
      return AppException(
        message: ErrorMessages.passwordTooWeak,
        code: ErrorCode.validationInvalidFormat,
        details: 'Must include uppercase, lowercase, number, and special character',
      );
    }

    return null;
  }

  /// Validate password confirmation
  static AppException? validatePasswordConfirmation(
    String password,
    String confirmPassword,
  ) {
    if (confirmPassword.isEmpty) {
      return AppException(
        message: 'Please confirm your password',
        code: ErrorCode.validationEmpty,
      );
    }

    if (password != confirmPassword) {
      return AppException(
        message: ErrorMessages.passwordMismatch,
        code: ErrorCode.validationPasswordMismatch,
      );
    }

    return null;
  }

  /// Validate name field
  static AppException? validateName(
    String name, {
    String fieldName = 'Name',
    int minLength = AppConstants.minNameLength,
    int maxLength = AppConstants.maxNameLength,
  }) {
    if (name.isEmpty) {
      return AppException(
        message: '$fieldName ${ErrorMessages.requiredField}',
        code: ErrorCode.validationEmpty,
      );
    }

    if (name.length < minLength) {
      return AppException(
        message: '$fieldName must be at least $minLength characters',
        code: ErrorCode.validationTooShort,
      );
    }

    if (name.length > maxLength) {
      return AppException(
        message: '$fieldName must not exceed $maxLength characters',
        code: ErrorCode.validationTooLong,
      );
    }

    // Check for valid name characters (letters, spaces, hyphens)
    final nameRegex = RegExp(r"^[a-zA-Z\s\-']*$");
    if (!nameRegex.hasMatch(name)) {
      return AppException(
        message: '$fieldName can only contain letters, spaces, hyphens, and apostrophes',
        code: ErrorCode.validationInvalidFormat,
      );
    }

    return null;
  }

  /// Validate phone number
  static AppException? validatePhoneNumber(String phone) {
    if (phone.isEmpty) {
      return AppException(
        message: 'Phone number ${ErrorMessages.requiredField}',
        code: ErrorCode.validationEmpty,
      );
    }

    if (phone.length < AppConstants.minPhoneLength) {
      return AppException(
        message: ErrorMessages.phoneInvalid,
        code: ErrorCode.validationTooShort,
      );
    }

    if (phone.length > AppConstants.maxPhoneLength) {
      return AppException(
        message: ErrorMessages.phoneInvalid,
        code: ErrorCode.validationTooLong,
      );
    }

    final phoneRegex = RegExp(ValidationPatterns.phone);
    if (!phoneRegex.hasMatch(phone)) {
      return AppException(
        message: ErrorMessages.phoneInvalid,
        code: ErrorCode.validationInvalidFormat,
      );
    }

    return null;
  }

  /// Validate SSM ID (Malaysia)
  static AppException? validateSSMId(String ssmId) {
    if (ssmId.isEmpty) {
      // SSM ID is optional in vendor registration
      return null;
    }

    if (ssmId.length != AppConstants.ssmIdLength) {
      return AppException(
        message: 'SSM ID must be ${AppConstants.ssmIdLength} digits',
        code: ErrorCode.validationInvalidFormat,
      );
    }

    final ssmRegex = RegExp(ValidationPatterns.ssmId);
    if (!ssmRegex.hasMatch(ssmId)) {
      return AppException(
        message: 'SSM ID must contain only digits',
        code: ErrorCode.validationInvalidFormat,
      );
    }

    return null;
  }

  /// Validate generic required field
  static AppException? validateRequired(
    String value, {
    String fieldName = 'This field',
  }) {
    if (value.trim().isEmpty) {
      return AppException(
        message: '$fieldName ${ErrorMessages.requiredField}',
        code: ErrorCode.validationEmpty,
      );
    }

    return null;
  }

  /// Validate URL
  static AppException? validateUrl(String url) {
    if (url.isEmpty) {
      return null; // URL is typically optional
    }

    final urlRegex = RegExp(ValidationPatterns.url);
    if (!urlRegex.hasMatch(url)) {
      return AppException(
        message: 'Please enter a valid URL',
        code: ErrorCode.validationInvalidFormat,
      );
    }

    return null;
  }

  /// Check password strength and return level (0-4)
  static int getPasswordStrength(String password) {
    if (password.isEmpty) return 0;

    int strength = 0;

    // Length check
    if (password.length >= 8) strength++;
    if (password.length >= 12) strength++;

    // Character variety
    if (RegExp(r'[a-z]').hasMatch(password)) strength++;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength++;
    if (RegExp(r'[0-9]').hasMatch(password)) strength++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) strength++;

    return (strength / 6 * 4).ceil().clamp(0, 4);
  }

  /// Get password strength label
  static String getPasswordStrengthLabel(int strength) {
    switch (strength) {
      case 0:
        return 'Very Weak';
      case 1:
        return 'Weak';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Strong';
      default:
        return 'Unknown';
    }
  }

  /// Get password strength color
  static Color getPasswordStrengthColor(int strength) {
    switch (strength) {
      case 0:
      case 1:
        return const Color(0xFFE53935); // Red
      case 2:
        return const Color(0xFFFB8C00); // Orange
      case 3:
        return const Color(0xFFFDD835); // Yellow
      case 4:
        return const Color(0xFF43A047); // Green
      default:
        return Colors.grey;
    }
  }

  /// Validate entire registration form
  static Map<String, AppException?> validateRegistrationForm({
    required String email,
    required String password,
    required String confirmPassword,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    String? ssmId,
  }) {
    return {
      'email': validateEmail(email),
      'password': validatePassword(password),
      'confirmPassword': validatePasswordConfirmation(password, confirmPassword),
      'firstName': validateName(firstName, fieldName: 'First name'),
      'lastName': validateName(lastName, fieldName: 'Last name'),
      'phoneNumber': validatePhoneNumber(phoneNumber),
      if (ssmId != null) 'ssmId': validateSSMId(ssmId),
    };
  }

  /// Check if form has any errors
  static bool hasFormErrors(Map<String, AppException?> validationResults) {
    return validationResults.values.any((error) => error != null);
  }

  /// Get first error from form validation
  static AppException? getFirstFormError(Map<String, AppException?> validationResults) {
    for (final error in validationResults.values) {
      if (error != null) {
        return error;
      }
    }
    return null;
  }

  /// Validate Malaysian phone number (flexible formats)
  /// Supports: 012-3456-7890, 0123456789, +60123456789, +6012-3456-7890
  static AppException? validateMalaysianPhoneNumber(String phone) {
    if (phone.isEmpty) {
      return AppException(
        message: 'Phone number ${ErrorMessages.requiredField}',
        code: ErrorCode.validationEmpty,
      );
    }

    // Remove common separators and spaces
    final cleaned = phone.replaceAll(RegExp(r'[\s\-().]'), '');

    // Remove leading + if present
    final normalized = cleaned.startsWith('+') ? cleaned.substring(1) : cleaned;

    // Malaysian phone patterns:
    // Local: 01X-XXXX-XXXX (10-11 digits starting with 0)
    // International: 601X-XXXX-XXXX (12 digits starting with 60)
    final malaysianPhoneRegex = RegExp(
      r'^(60)?1\d{8,9}$', // Matches: 0123456789 or 601234567890
    );

    if (!malaysianPhoneRegex.hasMatch(normalized)) {
      return AppException(
        message: 'Invalid Malaysian phone number. Try: 012-3456-7890 or +60-12-3456-7890',
        code: ErrorCode.validationInvalidFormat,
      );
    }

    // Length check
    if (normalized.length < 10 || normalized.length > 12) {
      return AppException(
        message: 'Phone number must be 10-12 digits (excluding separators)',
        code: ErrorCode.validationInvalidFormat,
      );
    }

    return null;
  }

  /// Validate SSM ID with flexible formats
  /// Accepts: 12345-67-8910, 12345678910, or 123456789012
  static AppException? validateFlexibleSSMId(String ssmId) {
    if (ssmId.trim().isEmpty) {
      // SSM ID is optional
      return null;
    }

    // Remove separators (hyphens, spaces)
    final cleaned = ssmId.replaceAll(RegExp(r'[\s\-]'), '');

    // SSM ID should be exactly 12 digits
    if (cleaned.length != 12) {
      return AppException(
        message: 'SSM ID must be 12 digits. Format: 12345-67-8910',
        code: ErrorCode.validationInvalidFormat,
      );
    }

    // Check if all are digits
    if (!RegExp(r'^\d{12}$').hasMatch(cleaned)) {
      return AppException(
        message: 'SSM ID must contain only digits',
        code: ErrorCode.validationInvalidFormat,
      );
    }

    return null;
  }

  /// Validate email with multiple formats
  static AppException? validateFlexibleEmail(String email) {
    if (email.isEmpty) {
      return AppException(
        message: ErrorMessages.emailRequired,
        code: ErrorCode.validationEmpty,
      );
    }

    // Support multiple email formats
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(email)) {
      return AppException(
        message: ErrorMessages.invalidEmail,
        code: ErrorCode.validationInvalidFormat,
      );
    }

    return null;
  }
}
