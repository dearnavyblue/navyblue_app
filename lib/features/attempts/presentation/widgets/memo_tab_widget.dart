// lib/features/attempts/presentation/widgets/memo_tab_widget.dart
import 'package:flutter/material.dart';
import 'package:navyblue_app/core/widgets/latex_text_widget.dart';
import '../../../../brick/models/question.model.dart';
import '../../../../core/widgets/network_image_widget.dart';
import '../../domain/entities/attempt_progress.dart';

class MemoTabWidget extends StatelessWidget {
  final List<Question> questions;
  final AttemptProgress? progress;
  final Map<String, bool> expandedSolutions;
  final Map<String, String> stepStatuses;
  final Function(String stepId, String status) onMarkStep;
  final Function(String partId) onToggleExpansion;
  final VoidCallback onPreviousPage;
  final VoidCallback onNextPage;
  final int currentPage;
  final int totalPages;
  final bool canGoToPrevious;
  final bool canGoToNext;
  final String pageDisplayText;
  final bool isOnInstructionsPage;

  const MemoTabWidget({
    super.key,
    required this.questions,
    this.progress,
    required this.expandedSolutions,
    required this.stepStatuses,
    required this.onMarkStep,
    required this.onToggleExpansion,
    required this.onPreviousPage,
    required this.onNextPage,
    required this.currentPage,
    required this.totalPages,
    required this.canGoToPrevious,
    required this.canGoToNext,
    required this.pageDisplayText,
    required this.isOnInstructionsPage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: questions
                  .map((q) => _buildQuestionSection(context, q))
                  .toList(),
            ),
          ),
        ),

        // Footer nav
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border(
              top: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: canGoToPrevious ? onPreviousPage : null,
                icon: const Icon(Icons.chevron_left),
                label: const Text('Previous'),
              ),
              Text(
                pageDisplayText,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton.icon(
                onPressed: canGoToNext ? onNextPage : null,
                icon: const Icon(Icons.chevron_right),
                label: const Text('Next'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ===== Question header (NO context rendering) =====
  Widget _buildQuestionSection(BuildContext context, Question question) {
    final theme = Theme.of(context);
    final totalMarks = _totalQuestionMarks(question);
    final earnedMarks = _calculateQuestionMarks(question);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header line
          Row(
            children: [
              Expanded(
                child: Text(
                  question.questionNumber,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                '$earnedMarks/$totalMarks marks',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Only render parts/subparts (no simple-question steps)
          if (question.parts.isNotEmpty)
            Column(
              children: question.organizedParts.map((part) {
                final earned = _calculatePartMarks(part);
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface, // white card for part
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant.withOpacity(0.5),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Part header — JUST THE NUMBER
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                part.partNumber,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Text(
                              '$earned ${earned == 1 ? 'mark' : 'marks'} / ${part.marks}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: earned == part.marks
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Part steps (no grey), with conditional right rail
                        _buildStepsRows(context, steps: part.solutionSteps),

                        // Subparts (still inside the part card)
                        if (part.subParts.isNotEmpty)
                          ...part.subParts.map((sp) {
                            final earnedSp = _calculatePartMarks(sp);
                            return Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          sp.partNumber,
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '$earnedSp ${earnedSp == 1 ? 'mark' : 'marks'} / ${sp.marks}',
                                        style:
                                            theme.textTheme.bodySmall?.copyWith(
                                          color: earnedSp == sp.marks
                                              ? theme.colorScheme.primary
                                              : theme
                                                  .colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  _buildStepsRows(context,
                                      steps: sp.solutionSteps),
                                ],
                              ),
                            );
                          }),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  // ====== Step rows (full-width dividers; hide rail if no marks) ======
  Widget _buildStepsRows(BuildContext context, {required List steps}) {
    final theme = Theme.of(context);
    if (steps.isEmpty) return const SizedBox.shrink();

    const double railWidth = 40;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.15),
        ),
      ),
      child: Column(
        children: List.generate(steps.length, (index) {
          final step = steps[index];
          final isLast = index == steps.length - 1;
          final status = stepStatuses[step.id] ?? 'NOT_ATTEMPTED';
          final int marks = step.marksForThisStep ?? 0;
          final bool showRail = marks > 0; // 1) no checkmarks if no marks

          // Light, legible background per status (left column only)
          Color? leftBg = Colors.transparent;
          if (marks > 0 && status == 'CORRECT') {
            leftBg = Colors.green.withOpacity(0.10);
          } else if (marks > 0 && status == 'INCORRECT') {
            leftBg = Theme.of(context).colorScheme.error.withOpacity(0.08);
          }

          return Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start, // rail at top
                children: [
                  // LEFT content column (text + right-aligned marks)
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      color: leftBg,
                      child: _buildStepLeftContent(context, step),
                    ),
                  ),

                  // RIGHT gutter rail — only when marks > 0
                  if (showRail)
                    Container(
                      width: railWidth,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 8),
                      child: _buildRailButtons(context, step),
                    ),
                ],
              ),

              // FULL-WIDTH divider (across left + rail)
              if (!isLast)
                Divider(
                  height: 1,
                  thickness: 1,
                  color: theme.colorScheme.outlineVariant.withOpacity(0.6),
                ),
            ],
          );
        }),
      ),
    );
  }

  // ==== Left content: text + RIGHT-aligned, italic marks ====
  Widget _buildStepLeftContent(BuildContext context, dynamic step) {
    final theme = Theme.of(context);
    final int marks = step.marksForThisStep ?? 0;

    final String marksLabel =
        marks > 0 ? (marks == 1 ? '1 mark' : '$marks marks') : '0 marks';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Step text (wraps)
            Expanded(
              child: LaTeXTextWidget(
                text: step.description,
                style: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
              ),
            ),
            const SizedBox(width: 8),
            // 2) marks label right-most & italic
            Text(
              '[$marksLabel]',
              textAlign: TextAlign.right,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 11,
                fontStyle: FontStyle.italic,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),

        // Working out (optional)
        if (step.workingOut != null && step.workingOut!.isNotEmpty) ...[
          const SizedBox(height: 6),
          LaTeXTextWidget(
            text: step.workingOut!,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 11,
              fontFamily: 'monospace',
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],

        // Images (optional) — keeping since some subparts might need them
        if (step.solutionImages != null && step.solutionImages!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: step.solutionImages!.map<Widget>((url) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: NetworkImageWidget(
                    imageUrl: url,
                    height: 120,
                    fit: BoxFit.contain,
                    borderRadius: BorderRadius.circular(6),
                    semanticsLabel: 'Solution step image',
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  // ===== Right rail (✓/×) =====
  Widget _buildRailButtons(BuildContext context, dynamic step) {
    final theme = Theme.of(context);
    final status = stepStatuses[step.id] ?? 'NOT_ATTEMPTED';

    Widget button({
      required IconData icon,
      required bool active,
      required Color activeColor,
      required VoidCallback onTap,
    }) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: active ? activeColor : theme.colorScheme.surface,
            shape: BoxShape.circle,
            border: Border.all(
              color: active
                  ? activeColor
                  : theme.colorScheme.outline.withOpacity(0.35),
              width: 1.5,
            ),
          ),
          child: Icon(
            icon,
            size: 18,
            color: active
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        button(
          icon: Icons.check,
          active: status == 'CORRECT',
          activeColor: Colors.green,
          onTap: () {
            final newStatus = status == 'CORRECT' ? 'NOT_ATTEMPTED' : 'CORRECT';
            onMarkStep(step.id, newStatus);
          },
        ),
        const SizedBox(height: 6),
        button(
          icon: Icons.close,
          active: status == 'INCORRECT',
          activeColor: theme.colorScheme.error,
          onTap: () {
            final newStatus =
                status == 'INCORRECT' ? 'NOT_ATTEMPTED' : 'INCORRECT';
            onMarkStep(step.id, newStatus);
          },
        ),
      ],
    );
  }

  // ===== Marks helpers =====
  num _calculatePartMarks(dynamic part) {
    num earned = 0;
    for (final step in part.solutionSteps) {
      if (stepStatuses[step.id] == 'CORRECT') {
        earned += step.marksForThisStep ?? 0;
      }
    }
    return earned;
  }

  int _calculateQuestionMarks(Question question) {
    int earned = 0;
    for (final step in question.solutionSteps) {
      if (stepStatuses[step.id] == 'CORRECT') {
        earned += step.marksForThisStep ?? 0;
      }
    }
    for (final part in question.parts) {
      for (final step in part.solutionSteps) {
        if (stepStatuses[step.id] == 'CORRECT') {
          earned += step.marksForThisStep ?? 0;
        }
      }
      for (final sp in part.subParts) {
        for (final step in sp.solutionSteps) {
          if (stepStatuses[step.id] == 'CORRECT') {
            earned += step.marksForThisStep ?? 0;
          }
        }
      }
    }
    return earned;
  }

  int _totalQuestionMarks(Question q) {
    int total = 0;
    for (final s in q.solutionSteps) {
      total += s.marksForThisStep ?? 0;
    }
    for (final p in q.parts) {
      for (final s in p.solutionSteps) {
        total += s.marksForThisStep ?? 0;
      }
      for (final sp in p.subParts) {
        for (final s in sp.solutionSteps) {
          total += s.marksForThisStep ?? 0;
        }
      }
    }
    return total;
  }
}
