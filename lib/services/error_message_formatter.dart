import 'error_handler.dart';

/// Standardized error message formatter
class ErrorMessageFormatter {
  // Color codes for error severity
  static const Map<String, String> _severityPrefix = {
    'critical': '❌',
    'error': '⚠️',
    'warning': '⚠️',
    'info': 'ℹ️',
  };

  /// Format error exception into user-friendly message
  static String formatError(AppException exception, {String severity = 'error'}) {
    final prefix = _severityPrefix[severity] ?? '❌';
    return '$prefix ${exception.message}';
  }

  /// Format validation error with context
  static String formatValidationError(
    AppException exception, {
    String fieldName = 'Field',
  }) {
    return '${_severityPrefix['error']} $fieldName: ${exception.message}';
  }

  /// Format network error
  static String formatNetworkError(AppException exception) {
    final message = exception.message.toLowerCase();
    if (message.contains('timeout')) {
      return '${_severityPrefix['warning']} Connection timeout. Please check your internet and try again.';
    } else if (message.contains('connection')) {
      return '${_severityPrefix['warning']} Connection error. Please check your internet and try again.';
    } else if (message.contains('404')) {
      return '${_severityPrefix['error']} Resource not found. Please try again later.';
    } else if (message.contains('500')) {
      return '${_severityPrefix['error']} Server error. Please try again later.';
    }
    return '${_severityPrefix['warning']} Network error: ${exception.message}';
  }

  /// Format authentication error
  static String formatAuthError(AppException exception) {
    final message = exception.message.toLowerCase();
    if (message.contains('password')) {
      return '${_severityPrefix['error']} Incorrect password. Please try again.';
    } else if (message.contains('email') || message.contains('user')) {
      return '${_severityPrefix['error']} Invalid email or password.';
    } else if (message.contains('already')) {
      return '${_severityPrefix['error']} This account already exists. Please log in or use another email.';
    } else if (message.contains('verified')) {
      return '${_severityPrefix['warning']} Please verify your email before logging in.';
    }
    return '${_severityPrefix['error']} Authentication failed: ${exception.message}';
  }

  /// Format database/firestore error
  static String formatDatabaseError(AppException exception) {
    final message = exception.message.toLowerCase();
    if (message.contains('permission')) {
      return '${_severityPrefix['error']} Permission denied. Please contact support.';
    } else if (message.contains('not found')) {
      return '${_severityPrefix['warning']} Data not found. It may have been deleted.';
    }
    return '${_severityPrefix['error']} Database error: ${exception.message}';
  }

  /// Format location error
  static String formatLocationError(AppException exception) {
    final message = exception.message.toLowerCase();
    if (message.contains('permission')) {
      return '${_severityPrefix['warning']} Please enable location permission in settings to see nearby vendors.';
    } else if (message.contains('timeout')) {
      return '${_severityPrefix['warning']} Location request timed out. Please try again.';
    }
    return '${_severityPrefix['warning']} Cannot get location: ${exception.message}';
  }

  /// Format file/upload error
  static String formatUploadError(AppException exception) {
    final message = exception.message.toLowerCase();
    if (message.contains('size')) {
      return '${_severityPrefix['error']} File is too large. Maximum size is 5MB.';
    } else if (message.contains('format') || message.contains('type')) {
      return '${_severityPrefix['error']} Invalid file format. Supported: JPG, PNG, PDF.';
    }
    return '${_severityPrefix['error']} Upload failed: ${exception.message}';
  }

  /// Get error code description
  static String getErrorCodeDescription(String code) {
    switch (code) {
      case 'VALIDATION_EMPTY':
        return 'Required field is empty';
      case 'VALIDATION_TOO_SHORT':
        return 'Value is too short';
      case 'VALIDATION_TOO_LONG':
        return 'Value is too long';
      case 'VALIDATION_INVALID_FORMAT':
        return 'Invalid format';
      case 'VALIDATION_PASSWORD_MISMATCH':
        return 'Passwords do not match';
      case 'AUTH_NETWORK_ERROR':
      case 'FIRESTORE_NETWORK_ERROR':
        return 'Network error - check your connection';
      case 'AUTH_WRONG_PASSWORD':
        return 'Incorrect password';
      case 'AUTH_USER_NOT_FOUND':
        return 'User not found';
      case 'AUTH_EMAIL_IN_USE':
        return 'Email already in use';
      case 'FIRESTORE_PERMISSION_DENIED':
        return 'Permission denied - not authorized';
      case 'FIRESTORE_NOT_FOUND':
        return 'Data not found';
      default:
        return 'Unknown error';
    }
  }

  /// Format error for toast notification (brief)
  static String formatErrorForToast(AppException exception) {
    final message = exception.message;
    if (message.length > 60) {
      return '${message.substring(0, 57)}...';
    }
    return message;
  }

  /// Format error with retry suggestion
  static String formatErrorWithRetry(AppException exception, {String action = 'operation'}) {
    return '${formatError(exception)}\n\nWould you like to retry this $action?';
  }

  /// Build error dialog title based on error code
  static String getErrorDialogTitle(String code) {
    if (code.contains('VALIDATION')) {
      return 'Validation Error';
    } else if (code.contains('AUTH')) {
      return 'Authentication Error';
    } else if (code.contains('NETWORK')) {
      return 'Connection Error';
    } else if (code.contains('FIRESTORE')) {
      return 'Database Error';
    }
    return 'Error';
  }
}
