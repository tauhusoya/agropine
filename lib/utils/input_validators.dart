class InputValidators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number';
    }
    return null;
  }

  static String? validatePasswordConfirmation(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  /// Validate full name
  static String? validateFullName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Full name is required';
    }
    if (value.length < 2) {
      return 'Full name must be at least 2 characters';
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      return 'Full name should only contain letters and spaces';
    }
    return null;
  }

  static PasswordStrength checkPasswordStrength(String password) {
    if (password.isEmpty) return PasswordStrength.empty;
    if (password.length < 8) return PasswordStrength.weak;

    int strength = 0;
    if (RegExp(r'[a-z]').hasMatch(password)) strength++;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength++;
    if (RegExp(r'[0-9]').hasMatch(password)) strength++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) strength++;

    if (password.length >= 12) strength++;

    if (strength <= 2) return PasswordStrength.weak;
    if (strength <= 3) return PasswordStrength.medium;
    return PasswordStrength.strong;
  }
}

enum PasswordStrength {
  empty,
  weak,
  medium,
  strong,
}

extension PasswordStrengthExtension on PasswordStrength {
  String get label {
    switch (this) {
      case PasswordStrength.empty:
        return '';
      case PasswordStrength.weak:
        return 'Weak';
      case PasswordStrength.medium:
        return 'Medium';
      case PasswordStrength.strong:
        return 'Strong';
    }
  }

  int get strength_percent {
    switch (this) {
      case PasswordStrength.empty:
        return 0;
      case PasswordStrength.weak:
        return 33;
      case PasswordStrength.medium:
        return 66;
      case PasswordStrength.strong:
        return 100;
    }
  }
}
