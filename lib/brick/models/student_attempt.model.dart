import 'package:brick_offline_first_with_rest/brick_offline_first_with_rest.dart';
import 'package:brick_rest/brick_rest.dart';
import 'package:brick_sqlite/brick_sqlite.dart';

@ConnectOfflineFirstWithRest()
class StudentAttempt extends OfflineFirstWithRestModel {
  @Sqlite(unique: true)
  @Rest(name: 'id')
  final String id;

  @Rest(name: 'paperId')
  final String paperId;

  @Rest(name: 'mode')
  final String mode; // PRACTICE or EXAM

  @Rest(name: 'enableHints')
  final bool enableHints;

  @Rest(name: 'startedAt')
  final DateTime startedAt;

  @Rest(name: 'timerStartedAt')
  final DateTime? timerStartedAt;

  @Rest(name: 'completedAt')
  final DateTime? completedAt;

  @Rest(name: 'lastActivityAt')
  final DateTime? lastActivityAt;

  @Rest(name: 'totalMarksEarned')
  final int? totalMarksEarned;

  @Rest(name: 'totalMarksPossible')
  final int? totalMarksPossible;

  @Rest(name: 'percentageScore')
  final double? percentageScore;

  @Rest(name: 'timeSpentMinutes')
  final int? timeSpentMinutes;

  @Rest(name: 'questionsAttempted')
  final int questionsAttempted;

  @Rest(name: 'questionsCompleted')
  final int questionsCompleted;

  @Rest(name: 'isAbandoned')
  final bool isAbandoned;

  @Rest(name: 'autoSubmitted')
  final bool autoSubmitted;

  // Use Map<String, dynamic> to avoid type casting issues
  @Rest(name: 'stepStatuses')
  @Sqlite()
  final Map<String, dynamic>? stepStatuses;

  @Rest(name: 'calculatedProgress')
  @Sqlite()
  final Map<String, dynamic>? calculatedProgress;

  // Local-only fields for offline functionality
  @Sqlite()
  @Rest(ignore: true)
  final DateTime? lastSyncedAt;

  @Sqlite()
  @Rest(ignore: true)
  final bool needsSync;

  @Sqlite()
  @Rest(ignore: true)
  final String? deviceInfo;

  StudentAttempt({
    required this.id,
    required this.paperId,
    this.mode = 'PRACTICE',
    this.enableHints = true,
    required this.startedAt,
    this.timerStartedAt,
    this.completedAt,
    this.lastActivityAt,
    this.totalMarksEarned,
    this.totalMarksPossible,
    this.percentageScore,
    this.timeSpentMinutes,
    this.questionsAttempted = 0,
    this.questionsCompleted = 0,
    this.isAbandoned = false,
    this.autoSubmitted = false,
    this.stepStatuses,
    this.calculatedProgress,
    this.lastSyncedAt,
    this.needsSync = false,
    this.deviceInfo,
  });

  // Helper methods
  bool get isCompleted => completedAt != null;
  bool get isInProgress => !isCompleted && !isAbandoned;
  bool get isPracticeMode => mode == 'PRACTICE';
  bool get isExamMode => mode == 'EXAM';

  // Helper getter for lastActivityAt with fallback
  DateTime get effectiveLastActivityAt => lastActivityAt ?? startedAt;

  // Helper getter for lastSyncedAt with fallback
  DateTime get effectiveLastSyncedAt => lastSyncedAt ?? startedAt;

  double get progressPercentage {
    if (totalMarksPossible == null || totalMarksPossible == 0) return 0.0;
    return ((totalMarksEarned ?? 0) / totalMarksPossible!) * 100;
  }

  // Helper method to get step status - with safe casting
  String getStepStatus(String stepId) {
    if (stepStatuses == null) return 'NOT_ATTEMPTED';
    final status = stepStatuses![stepId];
    return status?.toString() ?? 'NOT_ATTEMPTED';
  }

  // Helper method to check if step is marked as correct
  bool isStepCorrect(String stepId) {
    return getStepStatus(stepId) == 'CORRECT';
  }

  // Helper method to get count of marked steps
  int get markedStepsCount {
    if (stepStatuses == null) return 0;
    return stepStatuses!.values
        .where((status) => status?.toString() != 'NOT_ATTEMPTED')
        .length;
  }

  // Helper method to get count of correct steps
  int get correctStepsCount {
    if (stepStatuses == null) return 0;
    return stepStatuses!.values
        .where((status) => status?.toString() == 'CORRECT')
        .length;
  }

  // Helper methods for calculated progress - with null safety
  int get calculatedEarnedMarks {
    try {
      return calculatedProgress?['earnedMarks']?.toInt() ??
          totalMarksEarned ??
          0;
    } catch (e) {
      return totalMarksEarned ?? 0;
    }
  }

  int get calculatedPossibleMarks {
    try {
      return calculatedProgress?['possibleMarks']?.toInt() ??
          totalMarksPossible ??
          0;
    } catch (e) {
      return totalMarksPossible ?? 0;
    }
  }

  int get calculatedMarkedSteps {
    try {
      return calculatedProgress?['markedSteps']?.toInt() ?? 0;
    } catch (e) {
      return 0;
    }
  }

  int get calculatedTotalSteps {
    try {
      return calculatedProgress?['totalSteps']?.toInt() ?? 0;
    } catch (e) {
      return 0;
    }
  }

  StudentAttempt copyWith({
    String? id,
    String? paperId,
    String? mode,
    bool? enableHints,
    DateTime? startedAt,
    DateTime? timerStartedAt,
    DateTime? completedAt,
    DateTime? lastActivityAt,
    int? totalMarksEarned,
    int? totalMarksPossible,
    double? percentageScore,
    int? timeSpentMinutes,
    int? questionsAttempted,
    int? questionsCompleted,
    bool? isAbandoned,
    bool? autoSubmitted,
    Map<String, dynamic>? stepStatuses,
    Map<String, dynamic>? calculatedProgress,
    DateTime? lastSyncedAt,
    bool? needsSync,
    String? deviceInfo,
  }) {
    return StudentAttempt(
      id: id ?? this.id,
      paperId: paperId ?? this.paperId,
      mode: mode ?? this.mode,
      enableHints: enableHints ?? this.enableHints,
      startedAt: startedAt ?? this.startedAt,
      timerStartedAt: timerStartedAt ?? this.timerStartedAt,
      completedAt: completedAt ?? this.completedAt,
      lastActivityAt: lastActivityAt ?? this.lastActivityAt,
      totalMarksEarned: totalMarksEarned ?? this.totalMarksEarned,
      totalMarksPossible: totalMarksPossible ?? this.totalMarksPossible,
      percentageScore: percentageScore ?? this.percentageScore,
      timeSpentMinutes: timeSpentMinutes ?? this.timeSpentMinutes,
      questionsAttempted: questionsAttempted ?? this.questionsAttempted,
      questionsCompleted: questionsCompleted ?? this.questionsCompleted,
      isAbandoned: isAbandoned ?? this.isAbandoned,
      autoSubmitted: autoSubmitted ?? this.autoSubmitted,
      stepStatuses: stepStatuses ?? this.stepStatuses,
      calculatedProgress: calculatedProgress ?? this.calculatedProgress,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      needsSync: needsSync ?? this.needsSync,
      deviceInfo: deviceInfo ?? this.deviceInfo,
    );
  }

  // JSON serialization methods with better error handling
  factory StudentAttempt.fromJson(Map<String, dynamic> json) {
    try {
      return StudentAttempt(
        id: json['id'] as String? ?? '',
        paperId: json['paperId'] as String? ?? '',
        mode: json['mode'] as String? ?? 'PRACTICE',
        enableHints: json['enableHints'] as bool? ?? true,
        startedAt: json['startedAt'] != null
            ? DateTime.parse(json['startedAt'] as String)
            : DateTime.now(),
        timerStartedAt: json['timerStartedAt'] != null
            ? DateTime.parse(json['timerStartedAt'] as String)
            : null,
        completedAt: json['completedAt'] != null
            ? DateTime.parse(json['completedAt'] as String)
            : null,
        lastActivityAt: json['lastActivityAt'] != null
            ? DateTime.parse(json['lastActivityAt'] as String)
            : null,
        totalMarksEarned: json['totalMarksEarned'] as int?,
        totalMarksPossible: json['totalMarksPossible'] as int?,
        percentageScore: json['percentageScore']?.toDouble(),
        timeSpentMinutes: json['timeSpentMinutes'] as int?,
        questionsAttempted: json['questionsAttempted'] as int? ?? 0,
        questionsCompleted: json['questionsCompleted'] as int? ?? 0,
        isAbandoned: json['isAbandoned'] as bool? ?? false,
        autoSubmitted: json['autoSubmitted'] as bool? ?? false,
        stepStatuses: json['stepStatuses'] as Map<String, dynamic>?,
        calculatedProgress: json['calculatedProgress'] as Map<String, dynamic>?,
      );
    } catch (e) {
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'paperId': paperId,
      'mode': mode,
      'enableHints': enableHints,
      'startedAt': startedAt.toIso8601String(),
      'timerStartedAt': timerStartedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'lastActivityAt': lastActivityAt?.toIso8601String(),
      'totalMarksEarned': totalMarksEarned,
      'totalMarksPossible': totalMarksPossible,
      'percentageScore': percentageScore,
      'timeSpentMinutes': timeSpentMinutes,
      'questionsAttempted': questionsAttempted,
      'questionsCompleted': questionsCompleted,
      'isAbandoned': isAbandoned,
      'autoSubmitted': autoSubmitted,
      if (stepStatuses != null) 'stepStatuses': stepStatuses,
      if (calculatedProgress != null) 'calculatedProgress': calculatedProgress,
    };
  }
}
