import 'dart:developer' as developer;
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

enum LogLevel {
  debug,
  info,
  warning,
  error,
}

/// Centralized logging service for the app
/// Logs to console in development and Firebase Crashlytics in production
class LoggingService {
  static final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;

  /// Log a debug message (development only)
  static void debug(String message, {String? tag, dynamic error, StackTrace? stackTrace}) {
    _log(LogLevel.debug, message, tag, error, stackTrace);
  }

  /// Log an informational message
  static void info(String message, {String? tag, dynamic error, StackTrace? stackTrace}) {
    _log(LogLevel.info, message, tag, error, stackTrace);
  }

  /// Log a warning message
  static void warning(String message, {String? tag, dynamic error, StackTrace? stackTrace}) {
    _log(LogLevel.warning, message, tag, error, stackTrace);
  }

  /// Log an error message
  static void error(String message, {String? tag, dynamic error, StackTrace? stackTrace}) {
    _log(LogLevel.error, message, tag, error, stackTrace);
  }

  /// Internal logging method
  static void _log(
    LogLevel level,
    String message,
    String? tag,
    dynamic error,
    StackTrace? stackTrace,
  ) {
    final prefix = _getPrefix(level, tag);
    final logMessage = '$prefix $message';

    // Console logging
    developer.log(
      logMessage,
      level: _getLevelValue(level),
      name: 'AgroPine.${tag ?? "App"}',
      error: error,
      stackTrace: stackTrace,
    );

    // Print for debugging
    if (kDebugMode) {
      debugPrint(logMessage);
      if (error != null) {
        debugPrint('Error: $error');
      }
      if (stackTrace != null) {
        debugPrint('StackTrace: $stackTrace');
      }
    }

    // Send to Crashlytics if error
    if (level == LogLevel.error || level == LogLevel.warning) {
      _crashlytics.recordError(
        error ?? Exception(message),
        stackTrace ?? StackTrace.current,
        reason: message,
        fatal: level == LogLevel.error,
      );
    }
  }

  /// Get log level prefix
  static String _getPrefix(LogLevel level, String? tag) {
    final tagStr = tag != null ? '[$tag]' : '';
    switch (level) {
      case LogLevel.debug:
        return '[DEBUG] $tagStr';
      case LogLevel.info:
        return '[INFO] $tagStr';
      case LogLevel.warning:
        return '[WARNING] $tagStr';
      case LogLevel.error:
        return '[ERROR] $tagStr';
    }
  }

  /// Convert LogLevel to developer.Level value
  static int _getLevelValue(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return 500; // FINEST
      case LogLevel.info:
        return 800; // INFO
      case LogLevel.warning:
        return 900; // WARNING
      case LogLevel.error:
        return 1000; // SEVERE
    }
  }

  /// Log API request
  static void logApiRequest(String endpoint, String method, {Map<String, dynamic>? params}) {
    final message = 'API Request: $method $endpoint';
    if (params != null) {
      info('$message | Params: $params', tag: 'API');
    } else {
      info(message, tag: 'API');
    }
  }

  /// Log API response
  static void logApiResponse(String endpoint, int statusCode, {dynamic body}) {
    final message = 'API Response: $endpoint | Status: $statusCode';
    if (body != null) {
      info('$message | Response: $body', tag: 'API');
    } else {
      info(message, tag: 'API');
    }
  }

  /// Log API error
  static void logApiError(
    String endpoint,
    dynamic error, {
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) {
    final message = 'API Error: $endpoint | Error: $error';
    String fullMessage = message;
    if (context != null) {
      fullMessage += ' | Context: $context';
    }
    _log(LogLevel.error, fullMessage, 'API', error, stackTrace);
  }

  /// Log user action
  static void logUserAction(String action, {Map<String, dynamic>? data}) {
    String message = 'User Action: $action';
    if (data != null) {
      message += ' | Data: $data';
    }
    info(message, tag: 'USER_ACTION');
  }

  /// Log authentication event
  static void logAuthEvent(String event, {String? userId, dynamic error}) {
    String message = 'Auth Event: $event';
    if (userId != null) {
      message += ' | User: $userId';
    }
    if (error != null) {
      error(message, tag: 'AUTH', error: error);
    } else {
      info(message, tag: 'AUTH');
    }
  }

  /// Log performance metric
  static void logPerformance(String operation, Duration duration) {
    info(
      'Performance: $operation completed in ${duration.inMilliseconds}ms',
      tag: 'PERFORMANCE',
    );
  }

  /// Log data cache hit/miss
  static void logCacheEvent(String key, bool isHit) {
    final status = isHit ? 'HIT' : 'MISS';
    info('Cache $status for key: $key', tag: 'CACHE');
  }

  /// Set user for Crashlytics tracking
  static Future<void> setUser(String userId, {String? email, String? username}) async {
    await _crashlytics.setUserIdentifier(userId);
    if (email != null) {
      _crashlytics.setCustomKey('email', email);
    }
    if (username != null) {
      _crashlytics.setCustomKey('username', username);
    }
    info('User identified: $userId', tag: 'AUTH');
  }

  /// Clear user on logout
  static Future<void> clearUser() async {
    info('User logged out', tag: 'AUTH');
    // Crashlytics doesn't have a clear method, but this marks logout
  }
}
