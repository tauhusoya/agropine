import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Unified analytics and crash reporting service
class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  static final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;

  /// Initialize crash reporting
  static Future<void> initCrashReporting() async {
    // Skip Crashlytics initialization on web platform
    // Web has limited Crashlytics support and causes initialization errors
    if (kIsWeb) {
      debugPrint('⚠ Analytics: Skipping Crashlytics initialization on web platform');
      return;
    }

    if (kDebugMode) {
      // Force disable Crashlytics collection while doing every day development.
      // Temporarily disable collection to let you modify the app and test APIs.
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
    } else {
      // Enable collection for production builds
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    }

    // Pass all uncaught "fatal" errors from the framework to Crashlytics
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };

    // Pass all uncaught async errors that aren't handled by the Flutter framework
    // to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  /// Log page view
  static Future<void> logPageView({
    required String pageName,
    Map<String, String>? parameters,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'page_view',
        parameters: {
          'page_name': pageName,
          ...?parameters,
        },
      );
      debugPrint('✓ Analytics: Page view logged - $pageName');
    } catch (e) {
      debugPrint('✗ Analytics error logging page view: $e');
    }
  }

  /// Log search event
  static Future<void> logSearch({
    required String searchTerm,
    required int resultCount,
    String? category,
    String? location,
  }) async {
    try {
      await _analytics.logSearch(
        searchTerm: searchTerm,
      );
      await _analytics.logEvent(
        name: 'search_completed',
        parameters: {
          'search_term': searchTerm,
          'result_count': resultCount,
          if (category != null) 'category': category,
          if (location != null) 'location': location,
        },
      );
      debugPrint('✓ Analytics: Search logged - $searchTerm ($resultCount results)');
    } catch (e) {
      debugPrint('✗ Analytics error logging search: $e');
    }
  }

  /// Log vendor view
  static Future<void> logVendorView({
    required String vendorId,
    required String vendorName,
    required String vendorType,
    required double distance,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'vendor_viewed',
        parameters: {
          'vendor_id': vendorId,
          'vendor_name': vendorName,
          'vendor_type': vendorType,
          'distance_km': distance.toStringAsFixed(2),
        },
      );
      debugPrint('✓ Analytics: Vendor viewed - $vendorName ($vendorType)');
    } catch (e) {
      debugPrint('✗ Analytics error logging vendor view: $e');
    }
  }

  /// Log product view
  static Future<void> logProductView({
    required String productName,
    required String productCategory,
    required String vendorId,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'product_viewed',
        parameters: {
          'product_name': productName,
          'product_category': productCategory,
          'vendor_id': vendorId,
        },
      );
      debugPrint('✓ Analytics: Product viewed - $productName');
    } catch (e) {
      debugPrint('✗ Analytics error logging product view: $e');
    }
  }

  /// Log login event
  static Future<void> logLogin({
    required String method, // 'email', 'google', 'apple'
    bool success = true,
    String? errorMessage,
  }) async {
    try {
      await _analytics.logLogin(loginMethod: method);
      await _analytics.logEvent(
        name: 'login_attempt',
        parameters: {
          'method': method,
          'success': success,
          if (!success && errorMessage != null) 'error': errorMessage,
        },
      );
      debugPrint('✓ Analytics: Login logged - $method (success: $success)');
    } catch (e) {
      debugPrint('✗ Analytics error logging login: $e');
    }
  }

  /// Log signup event
  static Future<void> logSignUp({
    required String accountType, // 'customer', 'vendor'
    bool success = true,
    String? errorMessage,
  }) async {
    try {
      await _analytics.logSignUp(signUpMethod: accountType);
      await _analytics.logEvent(
        name: 'signup_completed',
        parameters: {
          'account_type': accountType,
          'success': success,
          if (!success && errorMessage != null) 'error': errorMessage,
        },
      );
      debugPrint('✓ Analytics: Signup logged - $accountType (success: $success)');
    } catch (e) {
      debugPrint('✗ Analytics error logging signup: $e');
    }
  }

  /// Log filter/sort event
  static Future<void> logFilter({
    required String filterType, // 'category', 'distance', 'rating', etc
    required String filterValue,
    required int resultCount,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'filter_applied',
        parameters: {
          'filter_type': filterType,
          'filter_value': filterValue,
          'result_count': resultCount,
        },
      );
      debugPrint('✓ Analytics: Filter applied - $filterType: $filterValue');
    } catch (e) {
      debugPrint('✗ Analytics error logging filter: $e');
    }
  }

  /// Log error to Crashlytics
  static Future<void> recordError(
    dynamic error,
    StackTrace? stackTrace, {
    String? context,
    bool fatal = false,
  }) async {
    try {
      await _crashlytics.recordError(
        error,
        stackTrace,
        fatal: fatal,
        reason: context,
      );
      debugPrint('✓ Crashlytics: Error recorded${context != null ? ' - $context' : ''}');
    } catch (e) {
      debugPrint('✗ Crashlytics error: $e');
    }
  }

  /// Set user properties
  static Future<void> setUserProperties({
    String? userId,
    String? accountType,
    String? location,
  }) async {
    try {
      if (userId != null) {
        _crashlytics.setUserIdentifier(userId);
      }
      if (accountType != null) {
        await _analytics.setUserProperty(name: 'account_type', value: accountType);
      }
      if (location != null) {
        await _analytics.setUserProperty(name: 'user_location', value: location);
      }
      debugPrint('✓ Analytics: User properties set');
    } catch (e) {
      debugPrint('✗ Analytics error setting user properties: $e');
    }
  }

  /// Clear user properties (on logout)
  static Future<void> clearUserProperties() async {
    try {
      _crashlytics.setUserIdentifier('');
      debugPrint('✓ Analytics: User properties cleared');
    } catch (e) {
      debugPrint('✗ Analytics error clearing user properties: $e');
    }
  }

  /// Log contact event (call/message vendor)
  static Future<void> logVendorContact({
    required String vendorId,
    required String vendorName,
    required String contactMethod, // 'call', 'message', 'email'
  }) async {
    try {
      await _analytics.logEvent(
        name: 'vendor_contacted',
        parameters: {
          'vendor_id': vendorId,
          'vendor_name': vendorName,
          'contact_method': contactMethod,
        },
      );
      debugPrint('✓ Analytics: Vendor contacted - $vendorName ($contactMethod)');
    } catch (e) {
      debugPrint('✗ Analytics error logging vendor contact: $e');
    }
  }

  /// Log pagination event
  static Future<void> logPagination({
    required String listName,
    required int pageNumber,
    required int itemsPerPage,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'pagination_event',
        parameters: {
          'list_name': listName,
          'page_number': pageNumber,
          'items_per_page': itemsPerPage,
        },
      );
      debugPrint('✓ Analytics: Pagination - $listName page $pageNumber');
    } catch (e) {
      debugPrint('✗ Analytics error logging pagination: $e');
    }
  }
}
