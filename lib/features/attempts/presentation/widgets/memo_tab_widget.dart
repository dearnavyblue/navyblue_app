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
        const SizedBox(height: 32),

        // Questions content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: questions
                  .map((question) => _buildQuestionMemo(context, question))
                  .toList(),
            ),
          ),
        ),

        // Navigation footer

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
                onPressed: canGoToPrevious
                    ? onPreviousPage
                    : null, // Use computed property
                icon: const Icon(Icons.chevron_left),
                label: const Text('Previous'),
              ),
              Text(
                pageDisplayText, // Use computed display text
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              TextButton.icon(
                onPressed:
                    canGoToNext ? onNextPage : null, // Use computed property
                icon: const Icon(Icons.chevron_right),
                label: const Text('Next'),
                iconAlignment: IconAlignment.end,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionMemo(BuildContext context, Question question) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 32,
                child: Text(
                  question.questionNumber,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (question.contextText != null) ...[
                      LaTeXTextWidget(
                          text: question.contextText!,
                          style: theme.textTheme.bodyMedium),
                    ],
                    if (question.contextImages.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      ...question.contextImages.map((imageUrl) => Container(
                            margin: const EdgeInsets.only(bottom: 4),
                            child: NetworkImageWidget(
                              imageUrl: imageUrl,
                              height: 120,
                              fit: BoxFit.contain,
                              borderRadius: BorderRadius.circular(4),
                              semanticsLabel:
                                  'Question ${question.questionNumber} image',
                            ),
                          )),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Handle simple vs multi-part questions
          if (question.parts.isEmpty) ...[
            // Simple question - show direct solution steps
            _buildSimpleQuestionMemo(context, question),
          ] else ...[
            // Multi-part question - show parts
            ...question.organizedParts
                .map((part) => _buildQuestionPartMemo(context, part)),
          ],
        ],
      ),
    );
  }

  Widget _buildSimpleQuestionMemo(BuildContext context, Question question) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(left: 16, bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question text without marks
          if (question.questionText != null) ...[
            LaTeXTextWidget(
              text: question.questionText!,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
          ],

          // Direct solution steps
          if (question.solutionSteps.isNotEmpty) ...[
            Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.08),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Working:',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ...question.solutionSteps.map<Widget>(
                    (step) => _buildSolutionStep(context, step),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuestionPartMemo(BuildContext context, part) {
    final theme = Theme.of(context);
    final partMarksEarned = _calculatePartMarks(part);

    return Container(
      margin: const EdgeInsets.only(left: 16, bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Part header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Part ${part.partNumber}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$partMarksEarned ${partMarksEarned == 1 ? 'mark' : 'marks'} / ${part.marks}',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: partMarksEarned == part.marks
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),

          // Solution steps
          if (part.solutionSteps.isNotEmpty) ...[
            const SizedBox(height: 6),
            Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.08),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Working:',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ...part.solutionSteps
                      .map(
                        (step) => _buildSolutionStep(context, step),
                      )
                      .toList(),
                ],
              ),
            ),
          ],

          // Sub-parts
          if (part.subParts.isNotEmpty) ...[
            const SizedBox(height: 4),
            ...part.subParts
                .map((subPart) => _buildSubPartMemo(context, subPart))
                .toList(),
          ],
        ],
      ),
    );
  }

  Widget _buildSolutionStep(BuildContext context, step) {
    final theme = Theme.of(context);
    final status = stepStatuses[step.id] ?? 'NOT_ATTEMPTED';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Two-button toggle for marking
              Row(
                children: [
                  // Incorrect button
                  InkWell(
                    onTap: () {
                      // Toggle: if already incorrect, mark as not attempted
                      final newStatus =
                          status == 'INCORRECT' ? 'NOT_ATTEMPTED' : 'INCORRECT';
                      onMarkStep(step.id, newStatus);
                    },
                    borderRadius: BorderRadius.circular(4),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: status == 'INCORRECT'
                            ? theme.colorScheme.error
                            : theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: status == 'INCORRECT'
                              ? theme.colorScheme.error
                              : theme.colorScheme.outline.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        Icons.close,
                        size: 18,
                        color: status == 'INCORRECT'
                            ? theme.colorScheme.onError
                            : theme.colorScheme.onSurfaceVariant
                                .withOpacity(0.5),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  // Correct button
                  InkWell(
                    onTap: () {
                      // Toggle: if already correct, mark as not attempted
                      final newStatus =
                          status == 'CORRECT' ? 'NOT_ATTEMPTED' : 'CORRECT';
                      onMarkStep(step.id, newStatus);
                    },
                    borderRadius: BorderRadius.circular(4),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: status == 'CORRECT'
                            ? theme.colorScheme.primary
                            : theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: status == 'CORRECT'
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outline.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        Icons.check,
                        size: 18,
                        color: status == 'CORRECT'
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurfaceVariant
                                .withOpacity(0.5),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              Expanded(
                child: LaTeXTextWidget(
                  text: step.description,
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                ),
              ),
              if (step.marksForThisStep != null) ...[
                Text(
                  '${step.marksForThisStep} ${step.marksForThisStep == 1 ? 'mark' : 'marks'}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 10,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ] else ...[
                Text(
                  'guidance',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 10,
                    color: theme.colorScheme.tertiary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
          // Working out section
          if (step.workingOut != null && step.workingOut!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Container(
              margin: const EdgeInsets.only(left: 60),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color:
                    theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: LaTeXTextWidget(
                text: step.workingOut!,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 10,
                  fontFamily: 'monospace',
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
          // Solution images
          if (step.solutionImages != null &&
              step.solutionImages!.isNotEmpty) ...[
            const SizedBox(height: 4),
            ...step.solutionImages!.map((imageUrl) => Container(
                  margin: const EdgeInsets.only(left: 60, bottom: 4),
                  child: NetworkImageWidget(
                    imageUrl: imageUrl,
                    height: 120,
                    fit: BoxFit.contain,
                    borderRadius: BorderRadius.circular(4),
                    semanticsLabel: 'Solution step image',
                  ),
                )),
          ],
        ],
      ),
    );
  }

  Widget _buildSubPartMemo(BuildContext context, subPart) {
    final theme = Theme.of(context);
    final partMarksEarned = _calculatePartMarks(subPart);

    return Container(
      margin: const EdgeInsets.only(left: 24, bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Subpart header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                subPart.partNumber,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: LaTeXTextWidget(
                    text: subPart.partText,
                    style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                  ),
                ),
              ),
              Text(
                '$partMarksEarned ${partMarksEarned == 1 ? 'mark' : 'marks'} / ${subPart.marks}',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 10,
                  color: partMarksEarned == subPart.marks
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),

          // Solution steps
          if (subPart.solutionSteps.isNotEmpty) ...[
            Container(
              margin: const EdgeInsets.only(left: 8, top: 4),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: subPart.solutionSteps.map<Widget>((step) {
                  return _buildSolutionStep(context, step);
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  num _calculatePartMarks(part) {
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
    return earned;
  }
}
