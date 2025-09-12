// lib/features/admin/domain/entities/papers_response.dart

import 'package:navyblue_app/brick/models/exam_paper.model.dart';

class PapersResponse {
  final List<ExamPaper> papers;
  final int totalCount;
  final int currentPage;
  final int totalPages;

  const PapersResponse({
    required this.papers,
    required this.totalCount,
    required this.currentPage,
    required this.totalPages,
  });

  factory PapersResponse.fromJson(Map<String, dynamic> json) {
    return PapersResponse(
      papers:
          (json['papers'] as List? ?? []) // Change from 'results' to 'papers'
              .map((p) => ExamPaper.fromJson(p))
              .toList(),
      totalCount:
          json['totalCount'] ?? 0, // Change from 'totalResults' to 'totalCount'
      currentPage:
          json['currentPage'] ?? 1, // Change from 'page' to 'currentPage'
      totalPages: json['totalPages'] ?? 1,
    );
  }
}
