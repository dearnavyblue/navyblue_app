// lib/brick/models/question.model.dart
import 'package:brick_offline_first_with_rest/brick_offline_first_with_rest.dart';
import 'package:brick_rest/brick_rest.dart';
import 'package:brick_sqlite/brick_sqlite.dart';
import 'package:navyblue_app/brick/models/question_part.model.dart';
import 'package:navyblue_app/brick/models/solution_step.model.dart';

@ConnectOfflineFirstWithRest()
class Question extends OfflineFirstWithRestModel {
  @Sqlite(unique: true)
  @Rest(name: 'id')
  final String id;

  @Rest(name: 'paperId')
  final String paperId;

  @Rest(name: 'questionNumber')
  final String questionNumber;

  @Rest(name: 'contextText')
  final String? contextText;

  @Rest(name: 'contextImages')
  final List<String> contextImages;

  @Rest(name: 'topics')
  final List<String> topics;

  @Rest(name: 'totalMarks')
  final int? totalMarks;

  @Rest(name: 'orderIndex')
  final int orderIndex;

  @Rest(name: 'pageNumber')
  final int pageNumber;

  // Add this new field for simple questions
  @Rest(name: 'questionText')
  final String? questionText;

  @Rest(name: 'hintText')
  final String? hintText;

  @Rest(name: 'isActive')
  final bool isActive;

  @Rest(name: 'createdAt')
  final DateTime createdAt;

  // Relationships
  @Rest(name: 'parts')
  final List<QuestionPart> parts;

  // Add direct solution steps for simple questions
  @Rest(name: 'solutionSteps')
  final List<SolutionStep> solutionSteps;

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

  Question({
    required this.id,
    required this.paperId,
    required this.questionNumber,
    required this.contextText,
    this.contextImages = const [],
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
  }) : lastSyncedAt = lastSyncedAt ?? DateTime.now();

  // Add helper methods
  bool get isSimpleQuestion => parts.isEmpty && solutionSteps.isNotEmpty;
  bool get isMultiPartQuestion => parts.isNotEmpty;

  Question copyWith({
    String? id,
    String? paperId,
    String? questionNumber,
    String? contextText,
    List<String>? contextImages,
    List<String>? topics,
    int? totalMarks,
    int? orderIndex,
    int? pageNumber,
    String? questionText, // Add this
    String? hintText, // Add this
    bool? isActive,
    DateTime? createdAt,
    List<QuestionPart>? parts,
    List<SolutionStep>? solutionSteps, // Add this
    DateTime? lastSyncedAt,
    bool? needsSync,
    String? deviceInfo,
  }) {
    return Question(
      id: id ?? this.id,
      paperId: paperId ?? this.paperId,
      questionNumber: questionNumber ?? this.questionNumber,
      contextText: contextText ?? this.contextText,
      contextImages: contextImages ?? this.contextImages,
      topics: topics ?? this.topics,
      totalMarks: totalMarks ?? this.totalMarks,
      orderIndex: orderIndex ?? this.orderIndex,
      pageNumber: pageNumber ?? this.pageNumber,
      questionText: questionText ?? this.questionText, // Add this
      hintText: hintText ?? this.hintText, // Add this
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      parts: parts ?? this.parts,
      solutionSteps: solutionSteps ?? this.solutionSteps, // Add this
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      needsSync: needsSync ?? this.needsSync,
      deviceInfo: deviceInfo ?? this.deviceInfo,
    );
  }

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] ?? '',
      paperId: json['paperId'] ?? '',
      questionNumber: json['questionNumber'] ?? '',
      contextText: json['contextText'] ?? '',
      contextImages: List<String>.from(json['contextImages'] ?? []),
      topics: List<String>.from(json['topics'] ?? []),
      totalMarks: json['totalMarks'],
      orderIndex: json['orderIndex'] ?? 0,
      pageNumber: json['pageNumber'] ?? 1,
      questionText: json['questionText'], // Add this
      hintText: json['hintText'], // Add this
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      parts: json['parts'] != null
          ? (json['parts'] as List)
              .map((partJson) => QuestionPart.fromJson(partJson))
              .toList()
          : [],
      solutionSteps: json['solutionSteps'] != null // Add this
          ? (json['solutionSteps'] as List)
              .map((stepJson) => SolutionStep.fromJson(stepJson))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'paperId': paperId,
      'questionNumber': questionNumber,
      'contextText': contextText,
      'contextImages': contextImages,
      'topics': topics,
      'totalMarks': totalMarks,
      'orderIndex': orderIndex,
      'pageNumber': pageNumber,
      'questionText': questionText, // Add this
      'hintText': hintText, // Add this
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'parts': parts.map((part) => part.toJson()).toList(),
      'solutionSteps':
          solutionSteps.map((step) => step.toJson()).toList(), // Add this
    };
  }
}
