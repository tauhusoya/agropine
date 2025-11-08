/// Application-wide constants
class AppConstants {
  // App Info
  static const String appName = 'AgroPine';
  static const String appVersion = '1.0.0';

  // API & Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration locationTimeout = Duration(seconds: 15);
  static const int maxRetryAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 2);

  // Pagination
  static const int pageSize = 20;
  static const int initialLoadSize = 10;

  // Distances
  static const double defaultSearchRadiusKm = 50.0;
  static const double maxSearchRadiusKm = 100.0;
  static const double minSearchRadiusKm = 1.0;

  // Location update intervals
  static const Duration locationUpdateInterval = Duration(minutes: 5);
  static const double locationUpdateMinDistance = 100; // meters

  // Debounce durations
  static const Duration searchDebounce = Duration(milliseconds: 500);
  static const Duration filterDebounce = Duration(milliseconds: 300);

  // Cache durations
  static const Duration userDataCacheDuration = Duration(minutes: 30);
  static const Duration listingsCacheDuration = Duration(minutes: 15);
  static const Duration imageCacheDuration = Duration(days: 7);

  // Validation lengths
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;
  static const int minNameLength = 2;
  static const int maxNameLength = 50;
  static const int minPhoneLength = 7;
  static const int maxPhoneLength = 15;
  static const int ssmIdLength = 12; // Malaysia SSM ID

  // Animation durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 500);
  static const Duration longAnimationDuration = Duration(milliseconds: 1000);

  // Email verification
  static const Duration emailVerificationTimeout = Duration(hours: 24);
  static const Duration tempAccountExpiry = Duration(hours: 24);

  // Welcome modal
  static const Duration welcomeModalDelay = Duration(milliseconds: 500);

  // Firestore collections
  static const String usersCollection = 'users';
  static const String productsCollection = 'products';
  static const String listingsCollection = 'listings';
  static const String categoriesCollection = 'categories';
  static const String reviewsCollection = 'reviews';
  static const String messagesCollection = 'messages';
  static const String ordersCollection = 'orders';
  static const String transactionsCollection = 'transactions';
}

/// Error messages
class ErrorMessages {
  // Generic
  static const String genericError = 'An unexpected error occurred. Please try again.';
  static const String networkError = 'No internet connection. Please check your network and try again.';
  static const String timeoutError = 'Request timed out. Please try again.';
  static const String unknownError = 'Unknown error occurred.';

  // Authentication
  static const String emailRequired = 'Please enter your email address.';
  static const String invalidEmail = 'Please enter a valid email address.';
  static const String passwordRequired = 'Please enter a password.';
  static const String passwordTooWeak = 'Password must be at least 8 characters with uppercase, lowercase, numbers, and special characters.';
  static const String passwordMismatch = 'Passwords do not match.';
  static const String userNotFound = 'No account found with this email.';
  static const String incorrectPassword = 'Incorrect password.';
  static const String emailAlreadyInUse = 'This email is already registered.';
  static const String tooManyAttempts = 'Too many login attempts. Please try again later.';
  static const String accountDisabled = 'This account has been disabled.';

  // Validation
  static const String requiredField = 'This field is required.';
  static const String fieldTooShort = 'This field is too short.';
  static const String fieldTooLong = 'This field is too long.';
  static const String invalidFormat = 'Please enter a valid format.';
  static const String phoneInvalid = 'Please enter a valid phone number.';

  // Firestore
  static const String permissionDenied = 'You do not have permission to perform this action.';
  static const String dataNotFound = 'The requested data was not found.';
  static const String alreadyExists = 'This item already exists.';
  static const String invalidData = 'Invalid data provided.';

  // Email Verification
  static const String emailNotVerified = 'Please verify your email address first.';
  static const String verificationSent = 'Verification email sent. Please check your inbox.';
  static const String verificationExpired = 'Verification link has expired.';

  // Location
  static const String locationPermissionDenied = 'Location permission is required to use this feature.';
  static const String locationUnavailable = 'Location services are not available.';
  static const String locationTimeout = 'Location request timed out.';

  // Vendor Registration
  static const String vendorRegistrationError = 'Failed to complete vendor registration.';
  static const String noEmailStored = 'No email found. Please start the registration process again.';
  static const String tempPasswordNotFound = 'Temporary password not found. Please start the registration process again.';
}

/// Success messages
class SuccessMessages {
  static const String loginSuccess = 'Logged in successfully!';
  static const String registerSuccess = 'Account created successfully!';
  static const String logoutSuccess = 'Logged out successfully!';
  static const String dataUpdated = 'Data updated successfully!';
  static const String dataSaved = 'Data saved successfully!';
  static const String dataDeleted = 'Data deleted successfully!';
  static const String verificationEmailSent = 'Verification email sent successfully!';
  static const String passwordResetSent = 'Password reset email sent. Please check your inbox.';
  static const String vendorRegistrationComplete = 'Vendor registration completed successfully!';
  static const String welcomeShown = 'Welcome message shown!';
}

/// Validation patterns
class ValidationPatterns {
  static const String email = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  static const String password = r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$';
  static const String phone = r'^[0-9\-\+\s]{7,15}$';
  static const String url = r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$';
  static const String ssmId = r'^[0-9]{12}$'; // Malaysia SSM ID
}

/// Routes
class AppRoutes {
  static const String landing = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String dashboard = '/dashboard';
  static const String vendorEmail = '/vendor-email';
  static const String vendorWaiting = '/vendor-waiting';
  static const String vendorDetails = '/vendor-details';
  static const String profile = '/profile';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
}

/// Account types
class AccountType {
  static const String vendor = 'vendor';
  static const String farmer = 'farmer';
  static const String trader = 'trader';
  static const String individual = 'individual';
  static const String guest = 'guest';
}

/// Date format
class DateFormats {
  static const String displayDate = 'MMM dd, yyyy';
  static const String displayDateTime = 'MMM dd, yyyy - HH:mm';
  static const String displayTime = 'HH:mm';
  static const String firebaseTimestamp = 'yyyy-MM-dd HH:mm:ss';
}

/// UI Sizes
class UISizes {
  // Padding & Margin
  static const double paddingXSmall = 4;
  static const double paddingSmall = 8;
  static const double paddingMedium = 16;
  static const double paddingLarge = 24;
  static const double paddingXLarge = 32;

  // Border radius
  static const double radiusSmall = 4;
  static const double radiusMedium = 8;
  static const double radiusLarge = 12;
  static const double radiusXLarge = 16;
  static const double radiusCircle = 999;

  // Icon sizes
  static const double iconSmall = 16;
  static const double iconMedium = 24;
  static const double iconLarge = 32;
  static const double iconXLarge = 48;

  // Button sizes
  static const double buttonHeightSmall = 36;
  static const double buttonHeightMedium = 44;
  static const double buttonHeightLarge = 52;

  // Card sizes
  static const double cardElevation = 2;
  static const double cardElevationHigh = 4;

  // Image sizes
  static const double avatarSmall = 32;
  static const double avatarMedium = 48;
  static const double avatarLarge = 64;
  static const double carouselHeight = 200;
  static const double listingImageHeight = 150;
}
