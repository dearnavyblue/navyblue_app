// lib/brick/models/mcq_option.model.dart
import 'package:brick_offline_first_with_rest/brick_offline_first_with_rest.dart';
import 'package:brick_rest/brick_rest.dart';
import 'package:brick_sqlite/brick_sqlite.dart';

@ConnectOfflineFirstWithRest()
class MCQOption extends OfflineFirstWithRestModel {
  @Sqlite(unique: true)
  @Rest(name: 'id')
  final String id;

  // OPTIMIZATION: Index questionId for filtering options by question
  @Sqlite(index: true)
  @Rest(name: 'questionId')
  final String? questionId;

  // OPTIMIZATION: Index partId for filtering options by question part
  @Sqlite(index: true)
  @Rest(name: 'partId')
  final String? partId;

  @Rest(name: 'label')
  final String label;

  @Rest(name: 'text')
  final String? text;

  @Rest(name: 'optionImages')
  final List<String> optionImages;

  // OPTIMIZATION: Index isCorrect for quick lookups of correct answers
  @Sqlite(index: true)
  @Rest(name: 'isCorrect')
  final bool isCorrect;

  // OPTIMIZATION: Index orderIndex for sorting options
  @Sqlite(index: true)
  @Rest(name: 'orderIndex')
  final int orderIndex;

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

  MCQOption({
    required this.id,
    this.questionId,
    this.partId,
    required this.label,
    this.text,
    this.optionImages = const [],
    required this.isCorrect,
    this.orderIndex = 0,
    required this.createdAt,
    DateTime? lastSyncedAt,
    this.needsSync = false,
    this.deviceInfo,
  }) : lastSyncedAt = lastSyncedAt ?? DateTime.now();

  // Helper methods
  bool get hasText => text != null && text!.isNotEmpty;
  bool get hasImages => optionImages.isNotEmpty;
  bool get belongsToQuestion => questionId != null;
  bool get belongsToPart => partId != null;

  MCQOption copyWith({
    String? id,
    String? questionId,
    String? partId,
    String? label,
    String? text,
    List<String>? optionImages,
    bool? isCorrect,
    int? orderIndex,
    DateTime? createdAt,
    DateTime? lastSyncedAt,
    bool? needsSync,
    String? deviceInfo,
  }) {
    return MCQOption(
      id: id ?? this.id,
      questionId: questionId ?? this.questionId,
      partId: partId ?? this.partId,
      label: label ?? this.label,
      text: text ?? this.text,
      optionImages: optionImages ?? this.optionImages,
      isCorrect: isCorrect ?? this.isCorrect,
      orderIndex: orderIndex ?? this.orderIndex,
      createdAt: createdAt ?? this.createdAt,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      needsSync: needsSync ?? this.needsSync,
      deviceInfo: deviceInfo ?? this.deviceInfo,
    );
  }

  factory MCQOption.fromJson(Map<String, dynamic> json) {
    return MCQOption(
      id: json['id'] ?? '',
      questionId: json['questionId'],
      partId: json['partId'],
      label: json['label'] ?? '',
      text: json['text'],
      optionImages: List<String>.from(json['optionImages'] ?? []),
      isCorrect: json['isCorrect'] ?? false,
      orderIndex: json['orderIndex'] ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'questionId': questionId,
      'partId': partId,
      'label': label,
      'text': text,
      'optionImages': optionImages,
      'isCorrect': isCorrect,
      'orderIndex': orderIndex,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
