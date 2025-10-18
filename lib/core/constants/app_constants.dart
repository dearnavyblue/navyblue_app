class AppConstants {
  // Route Names
  static const String splashRoute = '/splash';
  static const String onboardingRoute = '/onboarding';
  static const String loginRoute = '/login';
  static const String registerRoute = '/register';
  static const String homeRoute = '/home';
  static const String papersRoute = '/papers';
  static const String attemptRoute = '/attempt';
  static const String progressRoute = '/progress';
  static const String profileRoute = '/profile';
  static const String moreRoute = '/more';

  // Asset Paths
  static const String logoPath = 'assets/images/logo.png';
  static const String placeholderImagePath = 'assets/images/placeholder.png';
  static const String pastPaperThumbnailPath = '/images/past_paper_thumbnail.png';
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);
  
  // Error Messages
  static const String genericError = 'Something went wrong. Please try again.';
  static const String networkError = 'No internet connection. Working offline.';
  static const String timeoutError = 'Request timeout. Please try again.';
  static const String authError = 'Authentication failed. Please login again.';
  
  // Success Messages
  static const String attemptStarted = 'Paper attempt started successfully';
  static const String stepMarked = 'Step marked successfully';
  static const String attemptCompleted = 'Attempt completed successfully';
  static const String syncCompleted = 'Data synced successfully';
  
  // Validation
  static const int minPasswordLength = 8;
  static const int maxNameLength = 50;
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 50;
  
  // Storage Keys
  static const String authTokenKey = 'auth_token';
  static const String userDataKey = 'user_data';
  static const String lastSyncKey = 'last_sync_time';
  static const String themeKey = 'theme_mode';
  
  // Self-Marking System
  static const List<String> markingOptions = [
    'CORRECT',
    'INCORRECT', 
    'NOT_ATTEMPTED'
  ];
  
  static const Map<String, String> markingDisplayNames = {
    'CORRECT': 'Correct',
    'INCORRECT': 'Incorrect',
    'NOT_ATTEMPTED': 'Not Attempted',
  };
  
  // Progress Levels
  static const Map<int, String> readinessLevels = {
    80: 'Excellent',
    70: 'Good',
    60: 'Fair',
    0: 'Needs Work',
  };
  
  // Colors (complementing Material Design 3)
  static const Map<String, int> customColors = {
    'success': 0xFF4CAF50,
    'warning': 0xFFFF9800,
    'error': 0xFFF44336,
    'info': 0xFF2196F3,
  };
}