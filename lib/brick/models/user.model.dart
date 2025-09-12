// lib/brick/models/user.model.dart
import 'package:brick_offline_first_with_rest/brick_offline_first_with_rest.dart';
import 'package:brick_rest/brick_rest.dart';
import 'package:brick_sqlite/brick_sqlite.dart';

@ConnectOfflineFirstWithRest()
class User extends OfflineFirstWithRestModel {
  @Sqlite(unique: true)
  @Rest(name: 'id')
  final String id;

  @Rest(name: 'email')
  final String email;

  @Rest(name: 'firstName')
  final String firstName;

  @Rest(name: 'lastName')
  final String lastName;

  @Rest(name: 'grade')
  final String grade;

  @Rest(name: 'province')
  final String province;

  @Rest(name: 'syllabus')
  final String syllabus;

  @Rest(name: 'schoolName')
  final String? schoolName;

  @Rest(name: 'role')
  final String role;

  @Rest(name: 'isEmailVerified')
  final bool isEmailVerified;

  @Rest(name: 'createdAt')
  final DateTime createdAt;

  // Local-only authentication fields
  @Sqlite()
  @Rest(ignore: true)
  final String? accessToken;

  @Sqlite()
  @Rest(ignore: true)
  final String? refreshToken;

  @Sqlite()
  @Rest(ignore: true)
  final DateTime? tokenExpiresAt;

  @Sqlite()
  @Rest(ignore: true)
  final DateTime? lastLoginAt;

  // Local-only fields for offline functionality
  @Sqlite()
  @Rest(ignore: true)
  final DateTime lastSyncedAt;

  @Sqlite()
  @Rest(ignore: true)
  final bool needsSync;

  @Sqlite()
  @Rest(ignore: true)
  final String? deviceInfo;

  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.grade,
    required this.province,
    required this.syllabus,
    this.schoolName,
    this.role = 'USER',
    this.isEmailVerified = false,
    required this.createdAt,
    this.accessToken,
    this.refreshToken,
    this.tokenExpiresAt,
    this.lastLoginAt,
    DateTime? lastSyncedAt,
    this.needsSync = false,
    this.deviceInfo,
  }) : lastSyncedAt = lastSyncedAt ?? DateTime.now();

  User copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? grade,
    String? province,
    String? syllabus,
    String? schoolName,
    String? role,
    bool? isEmailVerified,
    DateTime? createdAt,
    String? accessToken,
    String? refreshToken,
    DateTime? tokenExpiresAt,
    DateTime? lastLoginAt,
    DateTime? lastSyncedAt,
    bool? needsSync,
    String? deviceInfo,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      grade: grade ?? this.grade,
      province: province ?? this.province,
      syllabus: syllabus ?? this.syllabus,
      schoolName: schoolName ?? this.schoolName,
      role: role ?? this.role,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      createdAt: createdAt ?? this.createdAt,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      tokenExpiresAt: tokenExpiresAt ?? this.tokenExpiresAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      needsSync: needsSync ?? this.needsSync,
      deviceInfo: deviceInfo ?? this.deviceInfo,
    );
  }

  User clearAuthTokens() {
    return User(
      id: id,
      email: email,
      firstName: firstName,
      lastName: lastName,
      grade: grade,
      province: province,
      syllabus: syllabus,
      schoolName: schoolName,
      role: role,
      isEmailVerified: isEmailVerified,
      createdAt: createdAt,
      // Explicitly set tokens to null
      accessToken: null,
      refreshToken: null,
      tokenExpiresAt: null,
      lastLoginAt: null,
      lastSyncedAt: lastSyncedAt,
      needsSync: needsSync,
      deviceInfo: deviceInfo,
    );
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      grade: json['grade'],
      province: json['province'],
      syllabus: json['syllabus'],
      schoolName: json['schoolName'],
      role: json['role'] ?? 'USER',
      isEmailVerified: json['isEmailVerified'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      accessToken: null,
      refreshToken: null,
      tokenExpiresAt: null,
      lastLoginAt: null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'grade': grade,
      'province': province,
      'syllabus': syllabus,
      'schoolName': schoolName,
      'role': role,
      'isEmailVerified': isEmailVerified,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Helper methods
  String get fullName => '$firstName $lastName';
  bool get isAdmin => role == 'ADMIN';
  bool get isTokenValid {
    // If we don't have both access token and expiry, we're not valid
    if (accessToken == null || tokenExpiresAt == null) {
      return false;
    }

    // Check if token hasn't expired
    return DateTime.now().isBefore(tokenExpiresAt!);
  }

  String get gradeDisplayName {
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

  String get subjectDisplayName {
    switch (syllabus) {
      case 'CAPS':
        return 'CAPS';
      case 'IEB':
        return 'IEB';
      default:
        return syllabus;
    }
  }
}
