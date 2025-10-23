// lib/brick/models/question.model.dart
import 'package:brick_offline_first_with_rest/brick_offline_first_with_rest.dart';
import 'package:brick_rest/brick_rest.dart';
import 'package:brick_sqlite/brick_sqlite.dart';
import 'package:navyblue_app/brick/models/mcq_option.model.dart';
import 'package:navyblue_app/brick/models/question_part.model.dart';
import 'package:navyblue_app/brick/models/solution_step.model.dart';

@ConnectOfflineFirstWithRest()
class Question extends OfflineFirstWithRestModel {
  @Sqlite(unique: true)
  @Rest(name: 'id')
  final String id;

  // OPTIMIZATION: Index paperId for efficient filtering by paper
  @Sqlite(index: true)
  @Rest(name: 'paperId')
  final String paperId;

  @Rest(name: 'questionNumber')
  final String questionNumber;

  @Rest(name: 'contextText')
  final String? contextText;

  @Rest(name: 'contextImages')
  final List<String> contextImages;

  @Rest(name: 'contextTopics')
  final List<String> contextTopics;

  @Rest(name: 'topics')
  final List<String> topics;

  @Rest(name: 'totalMarks')
  final int? totalMarks;

  // OPTIMIZATION: Index orderIndex for sorting questions
  @Sqlite(index: true)
  @Rest(name: 'orderIndex')
  final int orderIndex;

  // OPTIMIZATION: Index pageNumber for filtering by page
  @Sqlite(index: true)
  @Rest(name: 'pageNumber')
  final int pageNumber;

  @Rest(name: 'questionText')
  final String? questionText;

  @Rest(name: 'hintText')
  final String? hintText;

  // OPTIMIZATION: Index isActive for filtering active questions
  @Sqlite(index: true)
  @Rest(name: 'isActive')
  final bool isActive;

  @Rest(name: 'createdAt')
  final DateTime createdAt;

  @Rest(name: 'mcqOptions')
  final List<MCQOption>? mcqOptions;

  // Relationships
  @Rest(name: 'parts')
  final List<QuestionPart> parts;

  @Rest(name: 'solutionSteps')
  final List<SolutionStep> solutionSteps;

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

  Question({
    required this.id,
    required this.paperId,
    required this.questionNumber,
    required this.contextText,
    this.contextImages = const [],
    this.contextTopics = const [],
    this.topics = const [],
    this.totalMarks,
    required this.orderIndex,
    required this.pageNumber,
    this.questionText,
    this.hintText,
    this.isActive = true,
    required this.createdAt,
    this.parts = const [],
    this.solutionSteps = const [],
    DateTime? lastSyncedAt,
    this.needsSync = false,
    this.deviceInfo,
    this.mcqOptions,
  }) : lastSyncedAt = lastSyncedAt ?? DateTime.now();

  // Helper methods
  bool get isSimpleQuestion => parts.isEmpty && solutionSteps.isNotEmpty;
  bool get isMultiPartQuestion => parts.isNotEmpty;
  bool get isMCQQuestion => mcqOptions != null && mcqOptions!.isNotEmpty;

  Question copyWith({
    String? id,
    String? paperId,
    String? questionNumber,
    String? contextText,
    List<String>? contextImages,
    List<String>? contextTopics,
    List<String>? topics,
    int? totalMarks,
    int? orderIndex,
    int? pageNumber,
    String? questionText,
    String? hintText,
    bool? isActive,
    DateTime? createdAt,
    List<QuestionPart>? parts,
    List<SolutionStep>? solutionSteps,
    DateTime? lastSyncedAt,
    bool? needsSync,
    String? deviceInfo,
    List<MCQOption>? mcqOptions,
  }) {
    return Question(
      id: id ?? this.id,
      paperId: paperId ?? this.paperId,
      questionNumber: questionNumber ?? this.questionNumber,
      contextText: contextText ?? this.contextText,
      contextImages: contextImages ?? this.contextImages,
      contextTopics: contextTopics ?? this.contextTopics,
      topics: topics ?? this.topics,
      totalMarks: totalMarks ?? this.totalMarks,
      orderIndex: orderIndex ?? this.orderIndex,
      pageNumber: pageNumber ?? this.pageNumber,
      questionText: questionText ?? this.questionText,
      hintText: hintText ?? this.hintText,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      parts: parts ?? this.parts,
      solutionSteps: solutionSteps ?? this.solutionSteps,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      needsSync: needsSync ?? this.needsSync,
      deviceInfo: deviceInfo ?? this.deviceInfo,
      mcqOptions: mcqOptions ?? this.mcqOptions,
    );
  }

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] ?? '',
      paperId: json['paperId'] ?? '',
      questionNumber: json['questionNumber'] ?? '',
      contextText: json['contextText'] ?? '',
      contextImages: List<String>.from(json['contextImages'] ?? []),
      contextTopics: List<String>.from(json['contextTopics'] ?? []),
      topics: List<String>.from(json['topics'] ?? []),
      totalMarks: json['totalMarks'],
      orderIndex: json['orderIndex'] ?? 0,
      pageNumber: json['pageNumber'] ?? 1,
      questionText: json['questionText'],
      hintText: json['hintText'],
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      parts: json['parts'] != null
          ? (json['parts'] as List)
              .map((partJson) => QuestionPart.fromJson(partJson))
              .toList()
          : [],
      solutionSteps: json['solutionSteps'] != null
          ? (json['solutionSteps'] as List)
              .map((stepJson) => SolutionStep.fromJson(stepJson))
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
      'paperId': paperId,
      'questionNumber': questionNumber,
      'contextText': contextText,
      'contextImages': contextImages,
      'contextTopics': contextTopics,
      'topics': topics,
      'totalMarks': totalMarks,
      'orderIndex': orderIndex,
      'pageNumber': pageNumber,
      'questionText': questionText,
      'hintText': hintText,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'parts': parts.map((part) => part.toJson()).toList(),
      'solutionSteps': solutionSteps.map((step) => step.toJson()).toList(),
      'mcqOptions': mcqOptions?.map((opt) => opt.toJson()).toList(),
    };
  }

  List<QuestionPart> get organizedParts {
    // Get only top-level parts (nestingLevel 1 or no parent)
    final topLevelParts = parts
        .where((part) => part.nestingLevel == 1 || part.parentPartId == null)
        .toList();

    // For each top-level part, populate its subParts
    return topLevelParts.map((topPart) {
      final children =
          parts.where((part) => part.parentPartId == topPart.id).toList();

      // Return a copy with populated subParts
      return topPart.copyWith(subParts: children);
    }).toList();
  }
}
