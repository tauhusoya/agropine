/// Service for input sanitization and validation
class InputSanitizationService {
  /// Remove HTML/XSS injection attempts
  static String sanitizeHtml(String input) {
    try {
      // Remove HTML tags
      var sanitized = input.replaceAll(RegExp(r'<[^>]*>'), '');
      // Remove HTML entities
      sanitized = sanitized
          .replaceAll('&lt;', '<')
          .replaceAll('&gt;', '>')
          .replaceAll('&quot;', '"')
          .replaceAll('&apos;', "'")
          .replaceAll('&amp;', '&');
      return sanitized;
    } catch (e) {
      return input;
    }
  }

  /// Remove special characters and potential injection attempts
  static String sanitizeUserInput(String input) {
    // Remove leading/trailing whitespace
    String sanitized = input.trim();

    // Remove multiple spaces
    sanitized = sanitized.replaceAll(RegExp(r'\s+'), ' ');

    // Remove common SQL injection patterns
    sanitized = sanitized
        .replaceAll(RegExp(r"[';-]"), '')
        .replaceAll(RegExp(r'["\\]'), '');

    // Remove dangerous characters
    sanitized = sanitized.replaceAll(RegExp(r'[<>{}()[\]|`~!@#$%^&*+=\n\r]'), '');

    return sanitized;
  }

  /// Sanitize email
  static String sanitizeEmail(String email) {
    return email.trim().toLowerCase();
  }

  /// Sanitize phone number - keep only digits and +
  static String sanitizePhoneNumber(String phone) {
    return phone.replaceAll(RegExp(r'[^0-9+]'), '');
  }

  /// Sanitize text for Firestore storage
  static String sanitizeForFirestore(String input) {
    String sanitized = sanitizeHtml(input);
    sanitized = sanitized.trim();
    
    // Limit length to prevent DoS
    if (sanitized.length > 10000) {
      sanitized = sanitized.substring(0, 10000);
    }

    return sanitized;
  }

  /// Sanitize product price to prevent injection
  static double? sanitizePrice(String priceString) {
    try {
      // Remove all non-numeric characters except decimal point
      final sanitized = priceString.replaceAll(RegExp(r'[^0-9.]'), '');
      final price = double.parse(sanitized);
      
      // Validate price is positive and reasonable (max 1 million)
      if (price > 0 && price <= 1000000) {
        return price;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Validate and sanitize URL
  static String? sanitizeUrl(String url) {
    try {
      if (!url.contains('http://') && !url.contains('https://')) {
        url = 'https://$url';
      }
      
      // Basic URL validation
      if (url.length > 500) return null;
      if (url.contains('javascript:')) return null;
      if (url.contains('data:')) return null;

      return url;
    } catch (e) {
      return null;
    }
  }
}
