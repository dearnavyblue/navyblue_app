// lib/brick/models/question_part.model.dart
import 'package:brick_offline_first_with_rest/brick_offline_first_with_rest.dart';
import 'package:brick_rest/brick_rest.dart';
import 'package:brick_sqlite/brick_sqlite.dart';
import 'package:navyblue_app/brick/models/mcq_option.model.dart';
import 'package:navyblue_app/brick/models/solution_step.model.dart';

@ConnectOfflineFirstWithRest()
class QuestionPart extends OfflineFirstWithRestModel {
  @Sqlite(unique: true)
  @Rest(name: 'id')
  final String id;

  // OPTIMIZATION: Index questionId for filtering parts by question
  @Sqlite(index: true)
  @Rest(name: 'questionId')
  final String questionId;

  // OPTIMIZATION: Index parentPartId for finding sub-parts
  @Sqlite(index: true)
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

  // OPTIMIZATION: Index nestingLevel for filtering by depth
  @Sqlite(index: true)
  @Rest(name: 'nestingLevel')
  final int nestingLevel;

  // OPTIMIZATION: Index orderIndex for sorting parts
  @Sqlite(index: true)
  @Rest(name: 'orderIndex')
  final int orderIndex;

  @Rest(name: 'requiresWorking')
  final bool requiresWorking;

  // OPTIMIZATION: Index isActive for filtering active parts
  @Sqlite(index: true)
  @Rest(name: 'isActive')
  final bool isActive;

  @Rest(name: 'createdAt')
  final DateTime createdAt;

  @Rest(name: 'mcqOptions')
  final List<MCQOption>? mcqOptions;

  // Relationships
  @Rest(name: 'solutionSteps')
  final List<SolutionStep> solutionSteps;

  @Rest(name: 'subParts')
  final List<QuestionPart> subParts;

  // Local-only fields for offline functionality
  @Sqlite(index: true)
  @Rest(ignore: true)
  final DateTime lastSyncedAt;

  @Sqlite(index: true)
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
    this.mcqOptions,
  }) : lastSyncedAt = lastSyncedAt ?? DateTime.now();

  // Helper methods
  bool get hasSubParts => subParts.isNotEmpty;
  bool get hasSolutionSteps => solutionSteps.isNotEmpty;
  int get totalSteps => solutionSteps.length;
  bool get isMCQPart => mcqOptions != null && mcqOptions!.isNotEmpty;

  QuestionPart copyWith({
    String? id,
    String? questionId,
    String? parentPartId,
    String? partNumber,
    String? partText,
    int? marks,
    List<String>? partImages,
    String? hintText,
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
    List<MCQOption>? mcqOptions,
  }) {
    return QuestionPart(
      id: id ?? this.id,
      questionId: questionId ?? this.questionId,
      parentPartId: parentPartId ?? this.parentPartId,
      partNumber: partNumber ?? this.partNumber,
      partText: partText ?? this.partText,
      marks: marks ?? this.marks,
      partImages: partImages ?? this.partImages,
      hintText: hintText ?? this.hintText,
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
      mcqOptions: mcqOptions ?? this.mcqOptions,
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
      hintText: json['hintText'],
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
      mcqOptions: json['mcqOptions'] != null
          ? (json['mcqOptions'] as List)
              .map((optionJson) => MCQOption.fromJson(optionJson))
              .toList()
          : null,
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
      'hintText': hintText,
      'nestingLevel': nestingLevel,
      'orderIndex': orderIndex,
      'requiresWorking': requiresWorking,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'solutionSteps': solutionSteps.map((step) => step.toJson()).toList(),
      'subParts': subParts.map((part) => part.toJson()).toList(),
      'mcqOptions': mcqOptions?.map((opt) => opt.toJson()).toList(),
    };
  }
}
