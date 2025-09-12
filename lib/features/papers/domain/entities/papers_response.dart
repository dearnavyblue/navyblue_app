// lib/features/papers/domain/entities/papers_response.dart
import '../../../../brick/models/exam_paper.model.dart';

class PapersResponse {
  final List<ExamPaper> papers;
  final int totalCount;
  final int totalPages;
  final int currentPage;

  const PapersResponse({
    required this.papers,
    required this.totalCount,
    required this.totalPages,
    required this.currentPage,
  });

  factory PapersResponse.fromJson(Map<String, dynamic> json) {
    return PapersResponse(
      papers: (json['papers'] as List<dynamic>? ?? [])
          .map((paper) => ExamPaper.fromJson(paper))
          .toList(),
      totalCount: json['totalCount'] ?? 0,
      totalPages: json['totalPages'] ?? 1,
      currentPage: json['currentPage'] ?? 1,
    );
  }
}
