// lib/brick/models/solution_step.model.dart
import 'package:brick_offline_first_with_rest/brick_offline_first_with_rest.dart';
import 'package:brick_rest/brick_rest.dart';
import 'package:brick_sqlite/brick_sqlite.dart';

@ConnectOfflineFirstWithRest()
class SolutionStep extends OfflineFirstWithRestModel {
  @Sqlite(unique: true)
  @Rest(name: 'id')
  final String id;

  // Make both optional to support dual ownership
  @Rest(name: 'partId')
  final String? partId;

  @Rest(name: 'questionId')
  final String? questionId;

  @Rest(name: 'stepNumber')
  final int stepNumber;

  @Rest(name: 'description')
  final String description;

  @Rest(name: 'workingOut')
  final String? workingOut;

  @Rest(name: 'marksForThisStep')
  final int? marksForThisStep;

  @Rest(name: 'solutionImages')
  final List<String> solutionImages;

  @Rest(name: 'teachingNote')
  final String? teachingNote;

  @Rest(name: 'orderIndex')
  final int orderIndex;

  @Rest(name: 'isCriticalStep')
  final bool isCriticalStep;

  @Rest(name: 'createdAt')
  final DateTime createdAt;

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

  SolutionStep({
    required this.id,
    this.partId, // Make optional
    this.questionId, // Add this
    required this.stepNumber,
    required this.description,
    this.workingOut,
    required this.marksForThisStep,
    this.solutionImages = const [],
    this.teachingNote,
    required this.orderIndex,
    this.isCriticalStep = false,
    required this.createdAt,
    DateTime? lastSyncedAt,
    this.needsSync = false,
    this.deviceInfo,
  }) : lastSyncedAt = lastSyncedAt ?? DateTime.now();

  // Add helper methods
  bool get belongsToPart => partId != null;
  bool get belongsToQuestion => questionId != null;

  SolutionStep copyWith({
    String? id,
    String? partId,
    String? questionId, // Add this
    int? stepNumber,
    String? description,
    String? workingOut,
    int? marksForThisStep,
    List<String>? solutionImages,
    String? teachingNote,
    int? orderIndex,
    bool? isCriticalStep,
    DateTime? createdAt,
    DateTime? lastSyncedAt,
    bool? needsSync,
    String? deviceInfo,
  }) {
    return SolutionStep(
      id: id ?? this.id,
      partId: partId ?? this.partId,
      questionId: questionId ?? this.questionId, // Add this
      stepNumber: stepNumber ?? this.stepNumber,
      description: description ?? this.description,
      workingOut: workingOut ?? this.workingOut,
      marksForThisStep: marksForThisStep ?? this.marksForThisStep,
      solutionImages: solutionImages ?? this.solutionImages,
      teachingNote: teachingNote ?? this.teachingNote,
      orderIndex: orderIndex ?? this.orderIndex,
      isCriticalStep: isCriticalStep ?? this.isCriticalStep,
      createdAt: createdAt ?? this.createdAt,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      needsSync: needsSync ?? this.needsSync,
      deviceInfo: deviceInfo ?? this.deviceInfo,
    );
  }

  factory SolutionStep.fromJson(Map<String, dynamic> json) {
    return SolutionStep(
      id: json['id'] ?? '',
      partId: json['partId'], // Can be null now
      questionId: json['questionId'], // Add this
      stepNumber: json['stepNumber'] ?? 1,
      description: json['description'] ?? '',
      workingOut: json['workingOut'],
      marksForThisStep: json['marksForThisStep'] ?? 0,
      solutionImages: List<String>.from(json['solutionImages'] ?? []),
      teachingNote: json['teachingNote'],
      orderIndex: json['orderIndex'] ?? 0,
      isCriticalStep: json['isCriticalStep'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'partId': partId,
      'questionId': questionId, // Add this
      'stepNumber': stepNumber,
      'description': description,
      'workingOut': workingOut,
      'marksForThisStep': marksForThisStep,
      'solutionImages': solutionImages,
      'teachingNote': teachingNote,
      'orderIndex': orderIndex,
      'isCriticalStep': isCriticalStep,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
