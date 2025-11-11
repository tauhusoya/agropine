import 'dart:async';

/// Service for handling retries with exponential backoff
class RetryService {
  static const int maxRetries = 3;
  static const int initialDelayMs = 1000;
  static const double backoffMultiplier = 2.0;

  /// Execute operation with exponential backoff retry logic
  static Future<T> executeWithRetry<T>({
    required Future<T> Function() operation,
    int maxAttempts = maxRetries,
    int initialDelayMs = RetryService.initialDelayMs,
    double backoffMultiplier = RetryService.backoffMultiplier,
    bool Function(Exception)? shouldRetry,
  }) async {
    int attempt = 0;
    Exception? lastException;
    int delayMs = initialDelayMs;

    while (attempt < maxAttempts) {
      try {
        attempt++;
        return await operation();
      } on Exception catch (e) {
        lastException = e;

        // Check if we should retry this specific exception
        if (shouldRetry != null && !shouldRetry(e)) {
          rethrow;
        }

        // If this was the last attempt, throw the exception
        if (attempt >= maxAttempts) {
          rethrow;
        }

        // Print retry attempt
        print('Retry attempt $attempt/$maxAttempts after ${delayMs}ms delay. Error: ${e.toString()}');

        // Wait before retrying (exponential backoff)
        await Future.delayed(Duration(milliseconds: delayMs));

        // Calculate next delay
        delayMs = (delayMs * backoffMultiplier).toInt();
      }
    }

    // This should not be reached, but throw last exception as fallback
    throw lastException ?? Exception('Operation failed after $maxAttempts attempts');
  }

  /// Execute operation with retry and return null on failure (soft fail)
  static Future<T?> executeWithRetrySoftFail<T>({
    required Future<T> Function() operation,
    int maxAttempts = maxRetries,
  }) async {
    try {
      return await executeWithRetry(
        operation: operation,
        maxAttempts: maxAttempts,
      );
    } catch (e) {
      print('Soft fail after retries: $e');
      return null;
    }
  }

  /// Execute operation with retry and custom error handler
  static Future<T> executeWithRetryAndHandler<T>({
    required Future<T> Function() operation,
    required void Function(Exception error, int attempt) onRetry,
    required T Function(Exception error) onFailure,
    int maxAttempts = maxRetries,
  }) async {
    int attempt = 0;
    Exception? lastException;
    int delayMs = initialDelayMs;

    while (attempt < maxAttempts) {
      try {
        attempt++;
        return await operation();
      } on Exception catch (e) {
        lastException = e;

        if (attempt < maxAttempts) {
          onRetry(e, attempt);
          await Future.delayed(Duration(milliseconds: delayMs));
          delayMs = (delayMs * backoffMultiplier).toInt();
        } else {
          return onFailure(e);
        }
      }
    }

    return onFailure(lastException ?? Exception('Unknown error'));
  }

  /// Check if exception is retriable
  static bool isRetriable(Exception exception) {
    final errorMsg = exception.toString().toLowerCase();
    
    // Network errors are retriable
    if (errorMsg.contains('network') ||
        errorMsg.contains('timeout') ||
        errorMsg.contains('connection') ||
        errorMsg.contains('socket')) {
      return true;
    }

    // Firebase errors that are retriable
    if (errorMsg.contains('availability') ||
        errorMsg.contains('deadline-exceeded') ||
        errorMsg.contains('service-unavailable')) {
      return true;
    }

    return false;
  }
}
