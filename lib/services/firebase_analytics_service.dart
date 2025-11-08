import 'package:firebase_analytics/firebase_analytics.dart';

class FirebaseAnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  // Track user authentication events
  static Future<void> logUserSignup({required String method}) async {
    await _analytics.logSignUp(signUpMethod: method);
  }

  static Future<void> logUserLogin({required String method}) async {
    await _analytics.logLogin(loginMethod: method);
  }

  static Future<void> logUserLogout() async {
    await _analytics.logEvent(
      name: 'user_logout',
      parameters: {},
    );
  }

  // Track password reset attempts
  static Future<void> logPasswordResetRequested({required String email}) async {
    await _analytics.logEvent(
      name: 'password_reset_requested',
      parameters: {
        'email_domain': email.split('@').last,
      },
    );
  }

  static Future<void> logPasswordResetSuccess() async {
    await _analytics.logEvent(
      name: 'password_reset_success',
      parameters: {},
    );
  }

  static Future<void> logPasswordResetFailed({required String reason}) async {
    await _analytics.logEvent(
      name: 'password_reset_failed',
      parameters: {
        'reason': reason,
      },
    );
  }

  // Track farmer/location browsing
  static Future<void> logFarmerSearch({
    required String? category,
    required int resultCount,
  }) async {
    await _analytics.logEvent(
      name: 'farmer_search',
      parameters: {
        'category': category ?? 'all',
        'result_count': resultCount,
      },
    );
  }

  // Track category selection
  static Future<void> logCategorySelected({required String category}) async {
    await _analytics.logEvent(
      name: 'category_selected',
      parameters: {
        'category': category,
      },
    );
  }

  // Track location access
  static Future<void> logLocationAccessed() async {
    await _analytics.logEvent(
      name: 'location_accessed',
      parameters: {},
    );
  }

  static Future<void> logLocationAccessDenied({required String reason}) async {
    await _analytics.logEvent(
      name: 'location_access_denied',
      parameters: {
        'reason': reason,
      },
    );
  }

  // Track app screen views
  static Future<void> logScreenView({required String screenName}) async {
    await _analytics.logScreenView(screenName: screenName);
  }

  // Track user profile views
  static Future<void> logViewUserProfile({required String userType}) async {
    await _analytics.logEvent(
      name: 'view_user_profile',
      parameters: {
        'user_type': userType, // 'farmer', 'trader', 'buyer'
      },
    );
  }

  // Track error events
  static Future<void> logError({
    required String errorCode,
    required String errorMessage,
  }) async {
    await _analytics.logEvent(
      name: 'app_error',
      parameters: {
        'error_code': errorCode,
        'error_message': errorMessage,
      },
    );
  }
}
