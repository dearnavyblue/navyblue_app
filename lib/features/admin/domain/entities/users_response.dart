// lib/features/admin/domain/entities/users_response.dart

import 'package:navyblue_app/brick/models/user.model.dart';

class UsersResponse {
  final List<User> users;
  final int totalCount;
  final int currentPage;
  final int totalPages;

  const UsersResponse({
    required this.users,
    required this.totalCount,
    required this.currentPage,
    required this.totalPages,
  });

  factory UsersResponse.fromJson(Map<String, dynamic> json) {
    return UsersResponse(
      users: (json['users'] as List? ?? []) // Changed from 'results' to 'users'
          .map((u) => User.fromJson(u))
          .toList(),
      totalCount: json['totalCount'] ??
          0, // Changed from 'totalResults' to 'totalCount'
      currentPage:
          json['currentPage'] ?? 1, // Changed from 'page' to 'currentPage'
      totalPages: json['totalPages'] ?? 1,
    );
  }
}
