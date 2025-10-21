import 'package:navyblue_app/core/config/app_config.dart';
import '../../../../brick/models/exam_paper.model.dart';

class PaperHeaderData {
  final String leftTitle; // e.g. "Mathematics / P1"
  final String rightTitle; // e.g. "DBE/November 2024" or "GP/November 2024"
  final String? centerSubtitle; // e.g. "Grade 12"
  final int pageOffset; // add if printed numbering starts later
  final int startsAtPage; // first page that should show header

  const PaperHeaderData({
    required this.leftTitle,
    required this.rightTitle,
    this.centerSubtitle,
    this.pageOffset = 0,
    this.startsAtPage = 1,
  });
}

extension ExamPaperHeaderX on ExamPaper {
  PaperHeaderData toHeaderData() {
    final subject = AppConfig.getSubjectDisplayName(this.subject ?? '').trim();
    final pType = _paperTypeShort(paperType);
    final left = [
      if (subject.isNotEmpty) subject,
      if (pType.isNotEmpty) pType,
    ].join(' / ');

    final issuer = (province != null && province!.isNotEmpty)
        ? AppConfig.getProvinceAbbreviation(province!)
        : 'DBE';

    final period = AppConfig.getExamPeriodDisplayName(examPeriod);
    final yr = (year?.toString() ?? '').trim();
    final right = [
      issuer,
      if (period.isNotEmpty && yr.isNotEmpty)
        '$period $yr'
      else if (period.isNotEmpty)
        period
      else
        yr,
    ].join('/');

    // CENTER = GRADE (your request)
    final center = AppConfig.getGradeDisplayName(grade ?? '').trim();
    final centerText = center.isEmpty ? null : center;

    return PaperHeaderData(
      leftTitle: left,
      rightTitle: right,
      centerSubtitle: centerText, // e.g. "Grade 12"
      pageOffset: 0,
      startsAtPage:
          1, // bump if you later have a cover page before instructions, etc.
    );
  }
}

String _paperTypeShort(String? raw) {
  if (raw == null || raw.isEmpty) return '';
  final up = raw.toUpperCase();
  final match = RegExp(r'(\d+)').firstMatch(up);
  if (match != null) return 'P${match.group(1)}'; // "Paper 1" -> "P1"
  return up.replaceAll(RegExp(r'[^A-Z0-9]'), '');
}
