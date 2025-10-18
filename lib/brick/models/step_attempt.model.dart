// lib/brick/models/step_attempt.model.dart
import 'package:brick_offline_first_with_rest/brick_offline_first_with_rest.dart';
import 'package:brick_rest/brick_rest.dart';
import 'package:brick_sqlite/brick_sqlite.dart';

@ConnectOfflineFirstWithRest()
class StepAttempt extends OfflineFirstWithRestModel {
  @Sqlite(unique: true)
  @Rest(name: 'id')
  final String id;

  // OPTIMIZATION: Index studentAttemptId for filtering by attempt
  @Sqlite(index: true)
  @Rest(name: 'studentAttemptId')
  final String studentAttemptId;

  // OPTIMIZATION: Index stepId for looking up specific steps
  @Sqlite(index: true)
  @Rest(name: 'stepId')
  final String stepId;

  // OPTIMIZATION: Index status for filtering by status
  @Sqlite(index: true)
  @Rest(name: 'status')
  final String status; // CORRECT, INCORRECT, NOT_ATTEMPTED

  @Rest(name: 'markedAt')
  final DateTime markedAt;

  // Local-only fields for offline functionality
  @Sqlite(index: true)
  @Rest(ignore: true)
  final DateTime lastSyncedAt;

  // OPTIMIZATION: Index needsSync for finding pending syncs
  @Sqlite(index: true)
  @Rest(ignore: true)
  final bool needsSync;

  StepAttempt({
    required this.id,
    required this.studentAttemptId,
    required this.stepId,
    required this.status,
    DateTime? markedAt,
    DateTime? lastSyncedAt,
    this.needsSync = false,
  })  : markedAt = markedAt ?? DateTime.now(),
        lastSyncedAt = lastSyncedAt ?? DateTime.now();

  // Helper getters
  bool get isCorrect => status == 'CORRECT';
  bool get isIncorrect => status == 'INCORRECT';
  bool get isNotAttempted => status == 'NOT_ATTEMPTED';

  StepAttempt copyWith({
    String? id,
    String? studentAttemptId,
    String? stepId,
    String? status,
    DateTime? markedAt,
    DateTime? lastSyncedAt,
    bool? needsSync,
  }) {
    return StepAttempt(
      id: id ?? this.id,
      studentAttemptId: studentAttemptId ?? this.studentAttemptId,
      stepId: stepId ?? this.stepId,
      status: status ?? this.status,
      markedAt: markedAt ?? this.markedAt,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      needsSync: needsSync ?? this.needsSync,
    );
  }

  factory StepAttempt.fromJson(Map<String, dynamic> json) {
    return StepAttempt(
      id: json['id'] ?? '',
      studentAttemptId: json['studentAttemptId'] ?? '',
      stepId: json['stepId'] ?? '',
      status: json['status'] ?? 'NOT_ATTEMPTED',
      markedAt: json['markedAt'] != null
          ? DateTime.parse(json['markedAt'])
          : DateTime.now(),
      lastSyncedAt: json['lastSyncedAt'] != null
          ? DateTime.parse(json['lastSyncedAt'])
          : DateTime.now(),
      needsSync: json['needsSync'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentAttemptId': studentAttemptId,
      'stepId': stepId,
      'status': status,
      'markedAt': markedAt.toIso8601String(),
    };
  }
}
