import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:navyblue_app/brick/models/student_attempt.model.dart';
import 'package:navyblue_app/brick/models/exam_paper.model.dart';
import 'package:navyblue_app/brick/repository.dart';
import 'package:navyblue_app/core/config/app_config.dart';
import 'package:navyblue_app/core/constants/app_constants.dart';
import 'package:navyblue_app/core/theme/app_theme.dart';
import '../../../../core/widgets/pill.dart';

class UserAttemptCard extends StatelessWidget {
  final StudentAttempt attempt;
  final ExamPaper? paper;
  final VoidCallback? onTap;
  final bool showModeBadge;

  const UserAttemptCard({
    super.key,
    required this.attempt,
    this.paper,
    this.onTap,
    this.showModeBadge = false,
  });

  // Get progress from server-calculated data or fallback to stored values
  Map<String, int> _getProgress() {
    try {
      // Use server-calculated progress if available with null safety
      final earnedMarks = attempt.calculatedEarnedMarks ?? 0;
      final possibleMarks = attempt.calculatedPossibleMarks ?? 0;
      final markedSteps = attempt.calculatedMarkedSteps ?? 0;
      final totalSteps = attempt.calculatedTotalSteps ?? 0;

      return {
        'earnedMarks': earnedMarks,
        'possibleMarks': possibleMarks,
        'markedSteps': markedSteps,
        'totalSteps': totalSteps,
      };
    } catch (e) {
      // Return safe fallback values
      return {
        'earnedMarks': 0,
        'possibleMarks': 0,
        'markedSteps': 0,
        'totalSteps': 0,
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    try {
      final theme = Theme.of(context);
      final scheme = theme.colorScheme;
      final isCompleted = attempt.isCompleted;
      final status = Theme.of(context).extension<StatusColors>()!;
      final progress = _getProgress();

      final card = Card(
        elevation: 2,
        margin: EdgeInsets.zero,
        color: scheme.surface,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap ?? () => _resumeAttempt(context),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Thumbnail
                    Container(
                      width: 43,
                      height: 57,
                      decoration: BoxDecoration(
                        color: scheme.surface,
                        borderRadius: BorderRadius.circular(4),
                        boxShadow:
                            (theme.extension<CustomShadows>()?.cardShadows) ??
                                const [],
                        image: const DecorationImage(
                          image:
                              AssetImage(AppConstants.pastPaperThumbnailPath),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Main content - paper info and progress
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Paper info
                          _buildPaperInfoWithSubject(theme, attempt.paperId),
                          const SizedBox(height: 10),

                          // Progress bar
                          if (progress['possibleMarks']! > 0) ...[
                            Stack(
                              children: [
                                Container(
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: scheme.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                                FractionallySizedBox(
                                  widthFactor:
                                      progress['earnedMarks']!.toDouble() /
                                          progress['possibleMarks']!,
                                  child: Container(
                                    height: 5,
                                    decoration: BoxDecoration(
                                      color: isCompleted
                                          ? _getScoreColor(
                                              (progress['earnedMarks']! /
                                                      progress[
                                                          'possibleMarks']!) *
                                                  100,
                                              theme,
                                            )
                                          : status.success,
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  isCompleted
                                      ? 'Score: ${((progress['earnedMarks']! / progress['possibleMarks']!) * 100).toStringAsFixed(1)}%'
                                      : '${((progress['earnedMarks']! / progress['possibleMarks']!) * 100).round()}% complete',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                if (!isCompleted && progress['totalSteps']! > 0)
                                  Text(
                                    '${progress['markedSteps']}/${progress['totalSteps']} steps marked',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: scheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                if (isCompleted)
                                  Text(
                                    '${progress['earnedMarks']}/${progress['possibleMarks']} marks',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: scheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                              ],
                            ),
                          ],

                          // Show basic info if no progress data available
                          if (progress['possibleMarks']! == 0) ...[
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  size: 16,
                                  color: scheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  isCompleted ? 'Completed' : 'In Progress',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),

        // View Results button - ONLY difference for completed attempts
        if (isCompleted) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Pill(
                  label: 'View Results',
                  variant: PillVariant.subtle,
                  leading: const Icon(Icons.visibility_outlined, size: 17.35),
                  onTap: onTap ?? () => _resumeAttempt(context),
                ),
              ),
            ],
          ),
        ],
      ],
    ),
  ),
        ),
      );

      if (!showModeBadge) {
        return card;
      }

      final modeLabel = attempt.mode == 'EXAM' ? 'Exam' : 'Practice';
      final badgeColor = attempt.mode == 'EXAM'
          ? theme.colorScheme.primary
          : theme.colorScheme.secondary;

      return Stack(
        clipBehavior: Clip.none,
        children: [
          card,
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                modeLabel,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                  color: Colors.white,
                  height: 1.2,
                  letterSpacing: -0.01,
                ),
              ),
            ),
          ),
        ],
      );
    } catch (e) {
      // Return error card
      return Card(
        child: ListTile(
          leading: const Icon(Icons.error, color: Colors.red),
          title: const Text('Error loading attempt'),
          subtitle: Text('Attempt: ${attempt.id}\nError: $e'),
          onTap: onTap,
        ),
      );
    }
  }

  Widget _buildPaperInfoWithSubject(ThemeData theme, String paperId) {
    return FutureBuilder<ExamPaper?>(
      future: Repository.instance
          .get<ExamPaper>(
            query: Query.where('id', paperId, limit1: true),
          )
          .then((papers) => papers.isNotEmpty ? papers.first : null),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return Text(
            'Loading...',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          );
        }

        final paper = snapshot.data!;

        final grade = AppConfig.getGradeDisplayName(paper.grade);
        final subject = AppConfig.getSubjectDisplayName(paper.subject);
        final examPeriod = AppConfig.getExamPeriodDisplayName(paper.examPeriod);
        final paperType = AppConfig.getPaperTypeDisplayName(paper.paperType);
        final provinceAbbr =
            AppConfig.getProvinceAbbreviation(paper.province ?? '');

        // Build grade and subject text (e.g., "Grade 10 · Mathematics")
        final gradeSubjectText = '$grade · $subject';

        // Build main paper text (year, period, type)
        final parts = <String>[];
        if (paper.year > 0) parts.add(paper.year.toString());
        if (examPeriod.isNotEmpty) parts.add(examPeriod);
        if (paperType.isNotEmpty) parts.add(paperType);

        final mainText = parts.join(' ');

        final txt = theme.extension<AppTextStyles>()!;

        // Add province if available (e.g., "2024 November P2 - KZN")
        final paperText =
            provinceAbbr.isNotEmpty ? '$mainText - $provinceAbbr' : mainText;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Grade and Subject text with dot separator
            Text(
              gradeSubjectText,
              style: txt.extraExtraSmall.copyWith(
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              paperText,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        );
      },
    );
  }

  Color _getScoreColor(double score, ThemeData theme) {
    if (score >= 80) return theme.colorScheme.primary;
    if (score >= 60) return theme.colorScheme.secondary;
    return theme.colorScheme.error;
  }

  void _resumeAttempt(BuildContext context) {
    context.push(
        '/attempt/${attempt.paperId}?mode=${attempt.mode.toLowerCase()}&resume=${attempt.id}');
  }
}
