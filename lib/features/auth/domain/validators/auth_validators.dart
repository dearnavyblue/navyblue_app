// lib/features/auth/domain/validators/auth_validators.dart
class AuthValidators {
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    if (!RegExp(r'^(?=.*[a-zA-Z])(?=.*\d)').hasMatch(value)) {
      return 'Password must contain at least one letter and one number';
    }
    return null;
  }

  static String? required(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? name(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    if (value.trim().length < 2) {
      return '$fieldName must be at least 2 characters long';
    }
    if (value.trim().length > 50) {
      return '$fieldName must be less than 50 characters';
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value.trim())) {
      return '$fieldName can only contain letters and spaces';
    }
    return null;
  }

  static String? grade(String? value) {
    if (value == null || value.isEmpty) {
      return 'Grade is required';
    }
    const validGrades = ['GRADE_10', 'GRADE_11', 'GRADE_12'];
    if (!validGrades.contains(value)) {
      return 'Please select a valid grade';
    }
    return null;
  }

  static String? province(String? value) {
    if (value == null || value.isEmpty) {
      return 'Province is required';
    }
    const validProvinces = [
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
    if (!validProvinces.contains(value)) {
      return 'Please select a valid province';
    }
    return null;
  }

  static String? syllabus(String? value) {
    if (value == null || value.isEmpty) {
      return 'Syllabus is required';
    }
    const validSyllabi = ['CAPS', 'IEB'];
    if (!validSyllabi.contains(value)) {
      return 'Please select a valid syllabus';
    }
    return null;
  }

  static String? schoolName(String? value) {
    if (value != null && value.trim().isNotEmpty) {
      if (value.trim().length < 2) {
        return 'School name must be at least 2 characters long';
      }
      if (value.trim().length > 100) {
        return 'School name must be less than 100 characters';
      }
    }
    return null;
  }
}
