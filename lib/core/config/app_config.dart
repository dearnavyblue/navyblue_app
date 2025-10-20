class AppConfig {
  // App Information
  static const String appName = 'NavyBlue';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'SA Exam Prep with Self-Marking System';

  // API Configuration
  static const String baseUrl =
      'https://navyblue-api.vercel.app/v1'; // Change for production
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds

  // Database Configuration
  static const String databaseName = 'mydb';
  static const int databaseVersion = 1;

  // Offline Configuration
  static const int maxOfflineAttempts = 50; // Store max 50 attempts offline
  static const int syncIntervalMinutes =
      15; // Sync every 15 minutes when online

  // UI Configuration
  static const double cardElevation = 2.0;
  static const double borderRadius = 12.0;
  static const double padding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;

  // Feature Flags
  static const bool enableAnalytics = true;
  static const bool enableCrashReporting = false; // Set true for production
  static const bool enableDebugMode = true; // Set false for production

  // South African Education System
  static const List<String> supportedGrades = [
    'GRADE_10',
    'GRADE_11',
    'GRADE_12'
  ];
  static const List<String> supportedSubjects = ['MATH', 'PHYS_SCI'];
  static const List<String> supportedSyllabi = ['CAPS', 'IEB'];
  static const List<String> southAfricanProvinces = [
    'GAUTENG',
    'WESTERN_CAPE',
    'KWAZULU_NATAL',
    'EASTERN_CAPE',
    'LIMPOPO',
    'MPUMALANGA',
    'NORTH_WEST',
    'FREE_STATE',
    'NORTHERN_CAPE',
  ];

  // Get environment-specific base URL
  static String get apiBaseUrl {
    // You can add environment detection logic here
    // For now, returning the default
    return baseUrl;
  }

  // Get display names for enums
  static String getGradeDisplayName(String grade) {
    switch (grade) {
      case 'GRADE_10':
        return 'Grade 10';
      case 'GRADE_11':
        return 'Grade 11';
      case 'GRADE_12':
        return 'Grade 12';
      default:
        return grade;
    }
  }

  static String getSubjectDisplayName(String subject) {
    switch (subject) {
      case 'MATH':
        return 'Mathematics';
      case 'PHYS_SCI':
        return 'Physical Sciences';
      default:
        return subject;
    }
  }

  static String getSyllabusDisplayName(String syllabus) {
    switch (syllabus) {
      case 'CAPS':
        return 'CAPS';
      case 'IEB':
        return 'IEB';
      default:
        return syllabus;
    }
  }

  static String getProvinceDisplayName(String province) {
    switch (province) {
      case 'GAUTENG':
        return 'Gauteng';
      case 'WESTERN_CAPE':
        return 'Western Cape';
      case 'KWAZULU_NATAL':
        return 'KwaZulu-Natal';
      case 'EASTERN_CAPE':
        return 'Eastern Cape';
      case 'LIMPOPO':
        return 'Limpopo';
      case 'MPUMALANGA':
        return 'Mpumalanga';
      case 'NORTH_WEST':
        return 'North West';
      case 'FREE_STATE':
        return 'Free State';
      case 'NORTHERN_CAPE':
        return 'Northern Cape';
      default:
        return province;
    }
  }

  // Get province abbreviations
  static String getProvinceAbbreviation(String province) {
    switch (province) {
      case 'GAUTENG':
        return 'GP';
      case 'WESTERN_CAPE':
        return 'WC';
      case 'KWAZULU_NATAL':
        return 'KZN';
      case 'EASTERN_CAPE':
        return 'EC';
      case 'LIMPOPO':
        return 'LP';
      case 'MPUMALANGA':
        return 'MP';
      case 'NORTH_WEST':
        return 'NW';
      case 'FREE_STATE':
        return 'FS';
      case 'NORTHERN_CAPE':
        return 'NC';
      default:
        return province;
    }
  }

// Get exam period display name
  static String getExamPeriodDisplayName(String? examPeriod) {
    if (examPeriod == null || examPeriod.isEmpty) return '';

    final normalized = examPeriod.toUpperCase().replaceAll('_', '');

    switch (normalized) {
      case 'TERM1':
        return 'March';
      case 'TERM2':
        return 'June';
      case 'TERM3':
        return 'September';
      case 'TERM4':
        return 'November';
      default:
        return examPeriod[0].toUpperCase() +
            examPeriod.substring(1).toLowerCase();
    }
  }

// Get paper type display name
  static String getPaperTypeDisplayName(String? paperType) {
    if (paperType == null || paperType.isEmpty) return '';

    // Convert PAPER_1, PAPER_2, etc to P1, P2
    final normalized = paperType.toUpperCase();

    if (normalized.startsWith('PAPER')) {
      // Extract number from PAPER_1, PAPER_2, etc
      final match = RegExp(r'PAPER[_\s]*(\d+)').firstMatch(normalized);
      if (match != null) {
        return 'P${match.group(1)}';
      }
    }

    return normalized;
  }
}
