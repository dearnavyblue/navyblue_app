import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:navyblue_app/brick/models/student_attempt.model.dart';
import 'package:navyblue_app/brick/models/exam_paper.model.dart';

class UserAttemptCard extends StatelessWidget {
  final StudentAttempt attempt;
  final ExamPaper? paper;
  final VoidCallback? onTap;

  const UserAttemptCard({
    super.key,
    required this.attempt,
    this.paper,
    this.onTap,
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
      final isExam = attempt.mode == 'EXAM';
      final isCompleted = attempt.isCompleted;

      final progress = _getProgress();

      return Card(
        elevation: 2,
        margin: EdgeInsets.zero,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap ?? () => _resumeAttempt(context),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            paper?.title ?? 'Loading...',
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          if (paper != null)
                            Text(
                              '${paper!.subject} • ${_formatGrade(paper!.grade)} • ${paper!.syllabus}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            paper?.year.toString() ?? '',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isExam
                                ? theme.colorScheme.tertiaryContainer
                                : theme.colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            isExam ? 'EXAM' : 'PRACTICE',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: isExam
                                  ? theme.colorScheme.onTertiaryContainer
                                  : theme.colorScheme.onSecondaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Paper detail chips
                if (paper != null) ...[
                  Row(
                    children: [
                      _buildDetailChip(context, Icons.access_time,
                          '${paper!.durationMinutes} min'),
                      const SizedBox(width: 8),
                      if (paper!.totalMarks != null)
                        _buildDetailChip(context, Icons.assignment,
                            '${paper!.totalMarks} marks'),
                      const SizedBox(width: 8),
                      _buildDetailChip(context, Icons.school,
                          _formatExamLevel(paper!.examLevel)),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],

                // Progress for in-progress attempts
                if (!isCompleted && progress['possibleMarks']! > 0) ...[
                  LinearProgressIndicator(
                    value: progress['earnedMarks']!.toDouble() /
                        progress['possibleMarks']!,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    color: theme.colorScheme.primary,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progress: ${progress['earnedMarks']}/${progress['possibleMarks']} marks',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (progress['totalSteps']! > 0)
                        Text(
                          '${progress['markedSteps']}/${progress['totalSteps']} steps marked',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],

                // Completed attempt score
                if (isCompleted && progress['possibleMarks']! > 0) ...[
                  LinearProgressIndicator(
                    value: progress['earnedMarks']!.toDouble() /
                        progress['possibleMarks']!,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    color: _getScoreColor(
                      (progress['earnedMarks']! / progress['possibleMarks']!) *
                          100,
                      theme,
                    ),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Score: ${((progress['earnedMarks']! / progress['possibleMarks']!) * 100).toStringAsFixed(1)}%',
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w500),
                      ),
                      Text(
                        '${progress['earnedMarks']}/${progress['possibleMarks']} marks',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],

                // Show basic info if no progress data available
                if (progress['possibleMarks']! == 0) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isCompleted ? 'Completed' : 'In Progress',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onTap ?? () => _resumeAttempt(context),
                        icon: Icon(
                            isCompleted
                                ? Icons.visibility_outlined
                                : Icons.play_arrow_outlined,
                            size: 18),
                        label: Text(
                            isCompleted ? 'VIEW RESULTS' : 'RESUME ATTEMPT'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isExam
                              ? theme.colorScheme.tertiaryContainer
                              : theme.colorScheme.secondaryContainer,
                          foregroundColor: isExam
                              ? theme.colorScheme.onTertiaryContainer
                              : theme.colorScheme.onSecondaryContainer,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _startNewAttempt(context),
                        icon: Icon(
                            isExam
                                ? Icons.timer_outlined
                                : Icons.psychology_outlined,
                            size: 18),
                        label: Text('NEW ${isExam ? 'EXAM' : 'PRACTICE'}'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              theme.colorScheme.surfaceContainerHighest,
                          foregroundColor: theme.colorScheme.onSurfaceVariant,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
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

  Widget _buildDetailChip(BuildContext context, IconData icon, String text) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(text, style: theme.textTheme.bodySmall),
        ],
      ),
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

  void _startNewAttempt(BuildContext context) {
    context
        .push('/attempt/${attempt.paperId}?mode=${attempt.mode.toLowerCase()}');
  }

  String _formatGrade(String grade) {
    switch (grade) {
      case 'GRADE_10':
        return 'Grade 10';
      case 'GRADE_11':
        return 'Grade 11';
      case 'GRADE_12':
        return 'Grade 12';
      default:
        return grade;
    }
  }

  String _formatExamLevel(String level) {
    switch (level) {
      case 'TEACHER_MADE':
        return 'Teacher Made';
      case 'PROVINCIAL':
        return 'Provincial';
      case 'NATIONAL':
        return 'National';
      default:
        return level;
    }
  }
}
