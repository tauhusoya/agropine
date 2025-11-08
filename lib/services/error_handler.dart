import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'logging_service.dart';

/// Standardized error codes for the application
class ErrorCode {
  // Authentication errors
  static const String authWeakPassword = 'AUTH_WEAK_PASSWORD';
  static const String authEmailInUse = 'AUTH_EMAIL_IN_USE';
  static const String authInvalidEmail = 'AUTH_INVALID_EMAIL';
  static const String authUserNotFound = 'AUTH_USER_NOT_FOUND';
  static const String authWrongPassword = 'AUTH_WRONG_PASSWORD';
  static const String authTooManyRequests = 'AUTH_TOO_MANY_REQUESTS';
  static const String authUserDisabled = 'AUTH_USER_DISABLED';
  static const String authNetworkError = 'AUTH_NETWORK_ERROR';
  static const String authOperationNotAllowed = 'AUTH_OPERATION_NOT_ALLOWED';

  // Firestore errors
  static const String firestorePermissionDenied = 'FIRESTORE_PERMISSION_DENIED';
  static const String firestoreNotFound = 'FIRESTORE_NOT_FOUND';
  static const String firestoreAlreadyExists = 'FIRESTORE_ALREADY_EXISTS';
  static const String firestoreInvalidArgument = 'FIRESTORE_INVALID_ARGUMENT';
  static const String firestoreNetworkError = 'FIRESTORE_NETWORK_ERROR';

  // Validation errors
  static const String validationEmpty = 'VALIDATION_EMPTY';
  static const String validationInvalidFormat = 'VALIDATION_INVALID_FORMAT';
  static const String validationTooShort = 'VALIDATION_TOO_SHORT';
  static const String validationTooLong = 'VALIDATION_TOO_LONG';
  static const String validationPasswordMismatch = 'VALIDATION_PASSWORD_MISMATCH';

  // Location errors
  static const String locationPermissionDenied = 'LOCATION_PERMISSION_DENIED';
  static const String locationUnavailable = 'LOCATION_UNAVAILABLE';
  static const String locationTimeout = 'LOCATION_TIMEOUT';

  // Generic errors
  static const String unknown = 'UNKNOWN_ERROR';
  static const String timeout = 'TIMEOUT_ERROR';
  static const String cancelled = 'CANCELLED_ERROR';
}

/// Custom exception classes
class AppException implements Exception {
  final String message;
  final String? code;
  final String? details;
  final dynamic originalError;

  AppException({
    required this.message,
    this.code,
    this.details,
    this.originalError,
  });

  @override
  String toString() => message;

  void log() {
    debugPrint('❌ AppException [${code ?? 'UNKNOWN'}]: $message');
    if (details != null) {
      debugPrint('   Details: $details');
    }
    if (originalError != null) {
      debugPrint('   Original: $originalError');
    }
  }
}

class NetworkException extends AppException {
  NetworkException({
    required super.message,
    super.code,
    super.details,
    super.originalError,
  });
}

class AuthException extends AppException {
  AuthException({
    required super.message,
    super.code,
    super.details,
    super.originalError,
  });
}

class FirebaseException extends AppException {
  FirebaseException({
    required super.message,
    super.code,
    super.details,
    super.originalError,
  });
}

class ValidationException extends AppException {
  ValidationException({
    required super.message,
    super.code,
    super.details,
    super.originalError,
  });
}

/// Centralized error handling service
class ErrorHandler {
  /// Handle authentication errors
  static String handleAuthError(FirebaseAuthException e) {
    LoggingService.logAuthEvent(
      'Auth Error',
      error: e,
    );

    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'email-already-in-use':
        return 'Email already registered. Try logging in instead';
      case 'weak-password':
        return 'Password is too weak. Use uppercase, lowercase, numbers, and special characters';
      case 'invalid-email':
        return 'Enter a valid email address';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many login attempts. Please try again later';
      case 'account-exists-with-different-credential':
        return 'Account exists with different credentials';
      case 'invalid-credential':
        return 'Invalid credentials provided';
      case 'operation-not-allowed':
        return 'This operation is not allowed';
      default:
        return 'Authentication failed: ${e.message}';
    }
  }

  /// Handle Firestore/Firebase errors
  static String handleFirebaseError(dynamic e) {
    if (e is FirebaseException) {
      LoggingService.error(
        'Firebase Error: ${e.code}',
        tag: 'FIREBASE',
        error: e,
      );

      switch (e.code) {
        case 'permission-denied':
          return 'You do not have permission to perform this action';
        case 'not-found':
          return 'The requested item was not found';
        case 'already-exists':
          return 'This item already exists';
        case 'invalid-argument':
          return 'Invalid data provided';
        case 'failed-precondition':
          return 'Operation failed. Please try again';
        case 'aborted':
          return 'Operation was aborted';
        case 'out-of-range':
          return 'Value is out of valid range';
        case 'unavailable':
          return 'Service is currently unavailable. Please try again';
        case 'data-loss':
          return 'Unrecoverable data loss occurred';
        case 'unauthenticated':
          return 'You must be logged in to perform this action';
        default:
          return 'An error occurred: ${e.message}';
      }
    }
    return 'An unexpected error occurred';
  }

  /// Handle network errors
  static String handleNetworkError(dynamic e) {
    LoggingService.logApiError(
      'Network Request',
      e,
      context: {'error': e.toString()},
    );

    if (e.toString().contains('SocketException')) {
      return 'No internet connection. Please check your network and try again';
    }
    if (e.toString().contains('TimeoutException')) {
      return 'Request timed out. Please check your connection and try again';
    }
    if (e.toString().contains('ClientException')) {
      return 'Request failed. Please try again';
    }
    return 'Network error occurred. Please try again';
  }

  /// Handle validation errors
  static String handleValidationError(String message) {
    LoggingService.warning(
      'Validation Error: $message',
      tag: 'VALIDATION',
    );
    return message;
  }

  /// Generic error handler
  static String handleError(dynamic error, {String? customMessage}) {
    LoggingService.error(
      'Error occurred',
      tag: 'ERROR_HANDLER',
      error: error,
    );

    if (customMessage != null) {
      return customMessage;
    }

    if (error is FirebaseAuthException) {
      return handleAuthError(error);
    }

    if (error is FirebaseException) {
      return handleFirebaseError(error);
    }

    if (error is NetworkException) {
      return handleNetworkError(error.originalError);
    }

    if (error is AppException) {
      return error.message;
    }

    if (error is Exception) {
      return error.toString();
    }

    return 'An unexpected error occurred. Please try again';
  }

  /// Retry logic for failed operations
  static Future<T> retryOperation<T>(
    Future<T> Function() operation, {
    int maxAttempts = 3,
    Duration delay = const Duration(seconds: 2),
    String operationName = 'Operation',
  }) async {
    int attempt = 0;

    while (attempt < maxAttempts) {
      try {
        attempt++;
        LoggingService.info(
          '$operationName - Attempt $attempt of $maxAttempts',
          tag: 'RETRY',
        );
        return await operation();
      } catch (e) {
        if (attempt >= maxAttempts) {
          LoggingService.error(
            '$operationName failed after $maxAttempts attempts',
            tag: 'RETRY',
            error: e,
          );
          rethrow;
        }
        LoggingService.warning(
          '$operationName failed. Retrying in ${delay.inSeconds}s...',
          tag: 'RETRY',
          error: e,
        );
        await Future.delayed(delay);
      }
    }

    throw Exception('Operation failed');
  }
}
