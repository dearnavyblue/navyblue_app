// lib/features/papers/presentation/widgets/paper_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../attempts/domain/entities/attempt_config.dart';
import '../../../auth/presentation/providers/auth_presentation_providers.dart';
import '../../../attempts/presentation/providers/attempts_presentation_providers.dart';
import '../controllers/papers_controller.dart';

class PaperCard extends ConsumerWidget {
  final PaperAvailability paperAvailability;
  final VoidCallback? onTap;

  const PaperCard({
    super.key,
    required this.paperAvailability,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authState = ref.watch(authControllerProvider);
    final paper = paperAvailability.paper;

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Paper Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          paper.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${paper.subject} • ${_formatGrade(paper.grade)} • ${paper.syllabus}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      paper.year.toString(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Paper Details
              Row(
                children: [
                  _buildDetailChip(
                    context,
                    Icons.access_time,
                    '${paper.durationMinutes} min',
                  ),
                  const SizedBox(width: 8),
                  if (paper.totalMarks != null)
                    _buildDetailChip(
                      context,
                      Icons.assignment,
                      '${paper.totalMarks} marks',
                    ),
                  const SizedBox(width: 8),
                  _buildDetailChip(
                    context,
                    Icons.school,
                    _formatExamLevel(paper.examLevel),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Attempt Status Indicators
              if (!paperAvailability.hasAnyAvailability)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'All attempts used',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onErrorContainer,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              else
                Row(
                  children: [
                    if (!paperAvailability.canStartPractice)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Practice used',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    if (!paperAvailability.canStartPractice &&
                        !paperAvailability.canStartExam)
                      const SizedBox(width: 6),
                    if (!paperAvailability.canStartExam)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Exam used',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: 10,
                          ),
                        ),
                      ),
                  ],
                ),

              const SizedBox(height: 16),

              // Smart Action Buttons
              _buildActionButtons(context, ref, authState, theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(
      BuildContext context, WidgetRef ref, dynamic authState, ThemeData theme) {
    if (!authState.isLoggedIn) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => _requireLogin(context),
          icon: const Icon(Icons.login, size: 18),
          label: const Text('LOGIN TO START'),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      );
    }

    // Show available buttons based on what hasn't been attempted
    final buttons = <Widget>[];

    if (paperAvailability.canStartPractice) {
      buttons.add(
        ElevatedButton.icon(
          onPressed: () => _startAttempt(
              context, ref, AttemptConfig.practice(paperAvailability.paper.id)),
          icon: const Icon(Icons.psychology_outlined, size: 18),
          label: const Text('START PRACTICE'),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.secondaryContainer,
            foregroundColor: theme.colorScheme.onSecondaryContainer,
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      );
    }

    if (paperAvailability.canStartExam) {
      if (buttons.isNotEmpty) buttons.add(const SizedBox(width: 12));

      buttons.add(
        ElevatedButton.icon(
          onPressed: () => _startAttempt(
              context,
              ref,
              AttemptConfig.exam(paperAvailability.paper.id,
                  paperAvailability.paper.durationMinutes)),
          icon: const Icon(Icons.timer_outlined, size: 18),
          label: const Text('START EXAM'),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.tertiaryContainer,
            foregroundColor: theme.colorScheme.onTertiaryContainer,
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      );
    }

    // If only one button available, make it full width
    if (buttons.length == 1) {
      return SizedBox(
        width: double.infinity,
        child: buttons.first,
      );
    }

    // For multiple buttons, wrap them in Expanded within the Row
    return Row(
      children: buttons.map((button) => Expanded(child: button)).toList(),
    );
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
          Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
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

  // CRITICAL: Updated to await navigation and refresh on return
  Future<void> _startAttempt(
      BuildContext context, WidgetRef ref, AttemptConfig config) async {
    print('=== STARTING ATTEMPT ===');
    print('Paper ID: ${paperAvailability.paper.id}');
    print('Mode: ${config.mode}');

    // Navigate and wait for return
    await context.push(
        '/attempt/${paperAvailability.paper.id}?mode=${config.mode.toLowerCase()}');

    // When we return, refresh the attempts list
    print('=== RETURNED FROM ATTEMPT ===');
    if (context.mounted) {
      print('Refreshing attempts after return...');
      await ref.read(userAttemptsControllerProvider.notifier).refreshAttempts();
      print('Attempts refreshed');
    }
  }

  void _requireLogin(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Required'),
        content: const Text('Please login to start attempting papers.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/login');
            },
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }
}
