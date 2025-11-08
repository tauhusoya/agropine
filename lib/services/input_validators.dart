/// Comprehensive input validation service for form fields
class InputValidators {
  /// Validate email format
  /// Returns error message or null if valid
  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Email is required';
    }

    email = email.trim();

    if (email.length > 254) {
      return 'Email is too long';
    }

    // Simple email validation
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9][a-zA-Z0-9._-]*@[a-zA-Z0-9][a-zA-Z0-9.-]*\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(email)) {
      return 'Enter a valid email address';
    }

    return null;
  }

  /// Validate password strength
  /// Returns error message or null if valid
  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password is required';
    }

    if (password.length < 8) {
      return 'Password must be at least 8 characters';
    }

    if (password.length > 128) {
      return 'Password is too long';
    }

    if (!password.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }

    if (!password.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }

    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one digit';
    }

    if (!password.contains(RegExp(r'[@$!%*?&#-]'))) {
      return 'Password must contain at least one special character';
    }

    return null;
  }

  /// Validate password confirmation
  static String? validatePasswordConfirmation(
    String? password,
    String? confirmation,
  ) {
    if (confirmation == null || confirmation.isEmpty) {
      return 'Please confirm your password';
    }

    if (password != confirmation) {
      return 'Passwords do not match';
    }

    return null;
  }

  /// Validate phone number (Malaysia format)
  static String? validatePhoneNumber(String? phone) {
    if (phone == null || phone.isEmpty) {
      return 'Phone number is required';
    }

    phone = phone.replaceAll(RegExp(r'[^\d+]'), '');

    if (phone.length < 10) {
      return 'Phone number too short (minimum 10 digits)';
    }

    if (phone.length > 15) {
      return 'Phone number too long';
    }

    return null;
  }

  /// Validate username
  static String? validateUsername(String? username) {
    if (username == null || username.isEmpty) {
      return 'Username is required';
    }

    username = username.trim();

    if (username.length < 3) {
      return 'Username must be at least 3 characters';
    }

    if (username.length > 20) {
      return 'Username must be at most 20 characters';
    }

    final usernameRegex = RegExp(r'^[a-zA-Z0-9_]{3,20}$');
    if (!usernameRegex.hasMatch(username)) {
      return 'Username can only contain letters, numbers, and underscores';
    }

    return null;
  }

  /// Validate full name
  static String? validateName(String? name) {
    if (name == null || name.isEmpty) {
      return 'Name is required';
    }

    name = name.trim();

    if (name.length < 2) {
      return 'Name must be at least 2 characters';
    }

    if (name.length > 50) {
      return 'Name is too long';
    }

    final nameRegex = RegExp(r"^[a-zA-Z\s\-'.]+$");
    if (!nameRegex.hasMatch(name)) {
      return 'Name can only contain letters, spaces, hyphens, and apostrophes';
    }

    return null;
  }

  /// Validate generic text field (required)
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validate field with min length
  static String? validateMinLength(
    String? value,
    int minLength,
    String fieldName,
  ) {
    final error = validateRequired(value, fieldName);
    if (error != null) return error;

    if (value!.length < minLength) {
      return '$fieldName must be at least $minLength characters';
    }
    return null;
  }

  /// Validate field with max length
  static String? validateMaxLength(
    String? value,
    int maxLength,
    String fieldName,
  ) {
    final error = validateRequired(value, fieldName);
    if (error != null) return error;

    if (value!.length > maxLength) {
      return '$fieldName must be at most $maxLength characters';
    }
    return null;
  }

  /// Validate URL format
  static String? validateUrl(String? url) {
    if (url == null || url.isEmpty) {
      return 'URL is required';
    }

    try {
      Uri.parse(url);
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        return 'URL must start with http:// or https://';
      }
      return null;
    } catch (e) {
      return 'Enter a valid URL';
    }
  }

  /// Validate number field
  static String? validateNumber(String? value, String fieldName) {
    final error = validateRequired(value, fieldName);
    if (error != null) return error;

    if (int.tryParse(value!) == null) {
      return '$fieldName must be a valid number';
    }
    return null;
  }

  /// Check if string is a valid number
  static bool isNumber(String value) {
    return int.tryParse(value) != null || double.tryParse(value) != null;
  }

  /// Check if string contains only letters
  static bool isAlphabetic(String value) {
    return RegExp(r'^[a-zA-Z]+$').hasMatch(value);
  }

  /// Check if string contains only alphanumeric characters
  static bool isAlphanumeric(String value) {
    return RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value);
  }
}
