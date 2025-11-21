class AppConstants {
  // App Info
  static const String appName = 'Easacc';
  static const String appVersion = '1.0.0';

  // Storage Keys
  static const String keyWebUrl = 'web_url';
  static const String keySelectedDevice = 'selected_device';
  static const String keyIsLoggedIn = 'is_logged_in';
  static const String keyUserEmail = 'user_email';
  static const String keyAuthProvider = 'auth_provider';

  // Default Values
  static const String defaultWebUrl = 'https://www.google.com';
  static const String defaultDevice = 'None';

  // Network Timeout
  static const int networkTimeoutSeconds = 30;
  static const int networkRetryAttempts = 3;

  // Screen Breakpoints (for responsive design)
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;
  static const double desktopBreakpoint = 1440;
}
