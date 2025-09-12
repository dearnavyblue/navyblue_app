// lib/brick/models/question_part.model.dart
import 'package:brick_offline_first_with_rest/brick_offline_first_with_rest.dart';
import 'package:brick_rest/brick_rest.dart';
import 'package:brick_sqlite/brick_sqlite.dart';
import 'package:navyblue_app/brick/models/solution_step.model.dart';

@ConnectOfflineFirstWithRest()
class QuestionPart extends OfflineFirstWithRestModel {
  @Sqlite(unique: true)
  @Rest(name: 'id')
  final String id;

  @Rest(name: 'questionId')
  final String questionId;

  @Rest(name: 'parentPartId')
  final String? parentPartId;

  @Rest(name: 'partNumber')
  final String partNumber;

  @Rest(name: 'partText')
  final String partText;

  @Rest(name: 'marks')
  final int marks;

  @Rest(name: 'partImages')
  final List<String> partImages;

  @Rest(name: 'hintText')
  final String? hintText;

  @Rest(name: 'nestingLevel')
  final int nestingLevel;

  @Rest(name: 'orderIndex')
  final int orderIndex;

  @Rest(name: 'requiresWorking')
  final bool requiresWorking;

  @Rest(name: 'isActive')
  final bool isActive;

  @Rest(name: 'createdAt')
  final DateTime createdAt;

  // Relationships
  @Rest(name: 'solutionSteps')
  final List<SolutionStep> solutionSteps;

  @Rest(name: 'subParts')
  final List<QuestionPart> subParts;

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

  QuestionPart({
    required this.id,
    required this.questionId,
    this.parentPartId,
    required this.partNumber,
    required this.partText,
    this.marks = 0,
    this.partImages = const [],
    this.hintText,
    this.nestingLevel = 1,
    required this.orderIndex,
    this.requiresWorking = false,
    this.isActive = true,
    required this.createdAt,
    this.solutionSteps = const [],
    this.subParts = const [],
    DateTime? lastSyncedAt,
    this.needsSync = false,
    this.deviceInfo,
  }) : lastSyncedAt = lastSyncedAt ?? DateTime.now();

  QuestionPart copyWith({
    String? id,
    String? questionId,
    String? parentPartId,
    String? partNumber,
    String? partText,
    int? marks,
    List<String>? partImages,
    String? hintText, // Add this
    int? nestingLevel,
    int? orderIndex,
    bool? requiresWorking,
    bool? isActive,
    DateTime? createdAt,
    List<SolutionStep>? solutionSteps,
    List<QuestionPart>? subParts,
    DateTime? lastSyncedAt,
    bool? needsSync,
    String? deviceInfo,
  }) {
    return QuestionPart(
      id: id ?? this.id,
      questionId: questionId ?? this.questionId,
      parentPartId: parentPartId ?? this.parentPartId,
      partNumber: partNumber ?? this.partNumber,
      partText: partText ?? this.partText,
      marks: marks ?? this.marks,
      partImages: partImages ?? this.partImages,
      hintText: hintText ?? this.hintText, // Add this
      nestingLevel: nestingLevel ?? this.nestingLevel,
      orderIndex: orderIndex ?? this.orderIndex,
      requiresWorking: requiresWorking ?? this.requiresWorking,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      solutionSteps: solutionSteps ?? this.solutionSteps,
      subParts: subParts ?? this.subParts,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      needsSync: needsSync ?? this.needsSync,
      deviceInfo: deviceInfo ?? this.deviceInfo,
    );
  }

  factory QuestionPart.fromJson(Map<String, dynamic> json) {
    return QuestionPart(
      id: json['id'] ?? '',
      questionId: json['questionId'] ?? '',
      parentPartId: json['parentPartId'],
      partNumber: json['partNumber'] ?? '',
      partText: json['partText'] ?? '',
      marks: json['marks'] ?? 0,
      partImages: List<String>.from(json['partImages'] ?? []),
      hintText: json['hintText'], // Add this
      nestingLevel: json['nestingLevel'] ?? 1,
      orderIndex: json['orderIndex'] ?? 0,
      requiresWorking: json['requiresWorking'] ?? false,
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      solutionSteps: json['solutionSteps'] != null
          ? (json['solutionSteps'] as List)
              .map((stepJson) => SolutionStep.fromJson(stepJson))
              .toList()
          : [],
      subParts: json['subParts'] != null
          ? (json['subParts'] as List)
              .map((partJson) => QuestionPart.fromJson(partJson))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'questionId': questionId,
      'parentPartId': parentPartId,
      'partNumber': partNumber,
      'partText': partText,
      'marks': marks,
      'partImages': partImages,
      'hintText': hintText, // Add this
      'nestingLevel': nestingLevel,
      'orderIndex': orderIndex,
      'requiresWorking': requiresWorking,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'solutionSteps': solutionSteps.map((step) => step.toJson()).toList(),
      'subParts': subParts.map((part) => part.toJson()).toList(),
    };
  }

  // Helper methods
  bool get hasSubParts => subParts.isNotEmpty;
  bool get hasSolutionSteps => solutionSteps.isNotEmpty;
  int get totalSteps => solutionSteps.length;
}
