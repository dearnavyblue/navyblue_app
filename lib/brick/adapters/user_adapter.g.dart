// GENERATED CODE DO NOT EDIT
part of '../brick.g.dart';

Future<User> _$UserFromRest(Map<String, dynamic> data,
    {required RestProvider provider,
    OfflineFirstWithRestRepository? repository}) async {
  return User(
      id: data['id'] as String,
      email: data['email'] as String,
      firstName: data['firstName'] as String,
      lastName: data['lastName'] as String,
      grade: data['grade'] as String,
      province: data['province'] as String,
      syllabus: data['syllabus'] as String,
      schoolName: data['schoolName'] as String?,
      role: data['role'] as String,
      isEmailVerified: data['isEmailVerified'] as bool,
      createdAt: DateTime.parse(data['createdAt'] as String));
}

Future<Map<String, dynamic>> _$UserToRest(User instance,
    {required RestProvider provider,
    OfflineFirstWithRestRepository? repository}) async {
  return {
    'id': instance.id,
    'email': instance.email,
    'firstName': instance.firstName,
    'lastName': instance.lastName,
    'grade': instance.grade,
    'province': instance.province,
    'syllabus': instance.syllabus,
    'schoolName': instance.schoolName,
    'role': instance.role,
    'isEmailVerified': instance.isEmailVerified,
    'createdAt': instance.createdAt.toIso8601String(),
    'full_name': instance.fullName,
    'is_admin': instance.isAdmin,
    'is_token_valid': instance.isTokenValid,
    'grade_display_name': instance.gradeDisplayName,
    'subject_display_name': instance.subjectDisplayName
  };
}

Future<User> _$UserFromSqlite(Map<String, dynamic> data,
    {required SqliteProvider provider,
    OfflineFirstWithRestRepository? repository}) async {
  return User(
      id: data['id'] as String,
      email: data['email'] as String,
      firstName: data['first_name'] as String,
      lastName: data['last_name'] as String,
      grade: data['grade'] as String,
      province: data['province'] as String,
      syllabus: data['syllabus'] as String,
      schoolName:
          data['school_name'] == null ? null : data['school_name'] as String?,
      role: data['role'] as String,
      isEmailVerified: data['is_email_verified'] == 1,
      createdAt: DateTime.parse(data['created_at'] as String),
      accessToken:
          data['access_token'] == null ? null : data['access_token'] as String?,
      refreshToken: data['refresh_token'] == null
          ? null
          : data['refresh_token'] as String?,
      tokenExpiresAt: data['token_expires_at'] == null
          ? null
          : data['token_expires_at'] == null
              ? null
              : DateTime.tryParse(data['token_expires_at'] as String),
      lastLoginAt: data['last_login_at'] == null
          ? null
          : data['last_login_at'] == null
              ? null
              : DateTime.tryParse(data['last_login_at'] as String),
      lastSyncedAt: DateTime.parse(data['last_synced_at'] as String),
      needsSync: data['needs_sync'] == 1,
      deviceInfo:
          data['device_info'] == null ? null : data['device_info'] as String?)
    ..primaryKey = data['_brick_id'] as int;
}

Future<Map<String, dynamic>> _$UserToSqlite(User instance,
    {required SqliteProvider provider,
    OfflineFirstWithRestRepository? repository}) async {
  return {
    'id': instance.id,
    'email': instance.email,
    'first_name': instance.firstName,
    'last_name': instance.lastName,
    'grade': instance.grade,
    'province': instance.province,
    'syllabus': instance.syllabus,
    'school_name': instance.schoolName,
    'role': instance.role,
    'is_email_verified': instance.isEmailVerified ? 1 : 0,
    'created_at': instance.createdAt.toIso8601String(),
    'access_token': instance.accessToken,
    'refresh_token': instance.refreshToken,
    'token_expires_at': instance.tokenExpiresAt?.toIso8601String(),
    'last_login_at': instance.lastLoginAt?.toIso8601String(),
    'last_synced_at': instance.lastSyncedAt.toIso8601String(),
    'needs_sync': instance.needsSync ? 1 : 0,
    'device_info': instance.deviceInfo,
    'full_name': instance.fullName,
    'is_admin': instance.isAdmin ? 1 : 0,
    'is_token_valid': instance.isTokenValid ? 1 : 0,
    'grade_display_name': instance.gradeDisplayName,
    'subject_display_name': instance.subjectDisplayName
  };
}

/// Construct a [User]
class UserAdapter extends OfflineFirstWithRestAdapter<User> {
  UserAdapter();

  @override
  final Map<String, RuntimeSqliteColumnDefinition> fieldsToSqliteColumns = {
    'primaryKey': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: '_brick_id',
      iterable: false,
      type: int,
    ),
    'id': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'id',
      iterable: false,
      type: String,
    ),
    'email': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'email',
      iterable: false,
      type: String,
    ),
    'firstName': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'first_name',
      iterable: false,
      type: String,
    ),
    'lastName': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'last_name',
      iterable: false,
      type: String,
    ),
    'grade': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'grade',
      iterable: false,
      type: String,
    ),
    'province': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'province',
      iterable: false,
      type: String,
    ),
    'syllabus': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'syllabus',
      iterable: false,
      type: String,
    ),
    'schoolName': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'school_name',
      iterable: false,
      type: String,
    ),
    'role': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'role',
      iterable: false,
      type: String,
    ),
    'isEmailVerified': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'is_email_verified',
      iterable: false,
      type: bool,
    ),
    'createdAt': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'created_at',
      iterable: false,
      type: DateTime,
    ),
    'accessToken': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'access_token',
      iterable: false,
      type: String,
    ),
    'refreshToken': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'refresh_token',
      iterable: false,
      type: String,
    ),
    'tokenExpiresAt': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'token_expires_at',
      iterable: false,
      type: DateTime,
    ),
    'lastLoginAt': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'last_login_at',
      iterable: false,
      type: DateTime,
    ),
    'lastSyncedAt': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'last_synced_at',
      iterable: false,
      type: DateTime,
    ),
    'needsSync': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'needs_sync',
      iterable: false,
      type: bool,
    ),
    'deviceInfo': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'device_info',
      iterable: false,
      type: String,
    ),
    'fullName': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'full_name',
      iterable: false,
      type: String,
    ),
    'isAdmin': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'is_admin',
      iterable: false,
      type: bool,
    ),
    'isTokenValid': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'is_token_valid',
      iterable: false,
      type: bool,
    ),
    'gradeDisplayName': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'grade_display_name',
      iterable: false,
      type: String,
    ),
    'subjectDisplayName': const RuntimeSqliteColumnDefinition(
      association: false,
      columnName: 'subject_display_name',
      iterable: false,
      type: String,
    )
  };
  @override
  Future<int?> primaryKeyByUniqueColumns(
      User instance, DatabaseExecutor executor) async {
    final results = await executor.rawQuery('''
        SELECT * FROM `User` WHERE id = ? LIMIT 1''', [instance.id]);

    // SQFlite returns [{}] when no results are found
    if (results.isEmpty || (results.length == 1 && results.first.isEmpty)) {
      return null;
    }

    return results.first['_brick_id'] as int;
  }

  @override
  final String tableName = 'User';

  @override
  Future<User> fromRest(Map<String, dynamic> input,
          {required provider,
          covariant OfflineFirstWithRestRepository? repository}) async =>
      await _$UserFromRest(input, provider: provider, repository: repository);
  @override
  Future<Map<String, dynamic>> toRest(User input,
          {required provider,
          covariant OfflineFirstWithRestRepository? repository}) async =>
      await _$UserToRest(input, provider: provider, repository: repository);
  @override
  Future<User> fromSqlite(Map<String, dynamic> input,
          {required provider,
          covariant OfflineFirstWithRestRepository? repository}) async =>
      await _$UserFromSqlite(input, provider: provider, repository: repository);
  @override
  Future<Map<String, dynamic>> toSqlite(User input,
          {required provider,
          covariant OfflineFirstWithRestRepository? repository}) async =>
      await _$UserToSqlite(input, provider: provider, repository: repository);
}
