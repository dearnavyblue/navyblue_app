import 'package:flutter/material.dart';
import 'package:navyblue_app/core/widgets/latex_text_widget.dart';
import 'package:navyblue_app/core/widgets/network_image_widget.dart';
import '../../../../brick/models/question.model.dart';

class PaperTabWidget extends StatelessWidget {
  final List<Question> questions;
  final int currentPage;
  final int totalPages;
  final bool showHints;
  final bool isPracticeMode;
  final VoidCallback onPreviousPage;
  final VoidCallback onNextPage;
  final VoidCallback onToggleHints;

  const PaperTabWidget({
    super.key,
    required this.questions,
    required this.currentPage,
    required this.totalPages,
    required this.showHints,
    required this.isPracticeMode,
    required this.onPreviousPage,
    required this.onNextPage,
    required this.onToggleHints,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        const SizedBox(height: 32),

        /// Questions content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: questions
                  .map((question) => _buildQuestion(context, question))
                  .toList(),
            ),
          ),
        ),

        /// Navigation footer
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
                onPressed: currentPage > 1 ? onPreviousPage : null,
                icon: const Icon(Icons.chevron_left),
                label: const Text('Previous'),
              ),
              Text(
                'Page $currentPage of $totalPages',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              TextButton.icon(
                onPressed: currentPage < totalPages ? onNextPage : null,
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

  Widget _buildQuestion(BuildContext context, Question question) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Question header
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
                    LaTeXTextWidget(
                      text: question.contextText,
                      style: theme.textTheme.bodyLarge,
                    ),
                    if (question.contextImages.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      ...question.contextImages.map(
                        (imageUrl) => Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: SizedBox(
                            width: double.infinity,
                            child: NetworkImageWidget(
                              imageUrl: imageUrl,
                              height: 200,
                              fit: BoxFit.contain,
                              borderRadius: BorderRadius.circular(8),
                              semanticsLabel:
                                  'Question ${question.questionNumber} image',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (question.totalMarks != null)
                Container(
                  margin: const EdgeInsets.only(left: 16),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.colorScheme.outlineVariant),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '(${question.totalMarks})',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Handle simple questions vs multi-part questions
          if (question.isSimpleQuestion) ...[
            // Simple question - show questionText and hint
            Container(
              margin: const EdgeInsets.only(left: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (question.questionText != null) ...[
                    LaTeXTextWidget(
                      text: question.questionText!,
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                  ],
                  // Show hint for simple question
                  if (showHints && question.hintText != null)
                    _buildQuestionHint(context, question.hintText!),
                ],
              ),
            ),
          ] else if (question.isMultiPartQuestion) ...[
            // Multi-part question - show parts
            ...question.parts.map((part) => _buildQuestionPart(context, part)),
          ],
        ],
      ),
    );
  }

  Widget _buildQuestionHint(BuildContext context, String hintText) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.primaryContainer),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lightbulb_outline,
            size: 18,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hint:',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                LaTeXTextWidget(
                  text: hintText,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionPart(BuildContext context, part) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(left: 32, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 32,
                child: Text(
                  part.partNumber,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LaTeXTextWidget(
                      text: part.partText,
                      style: theme.textTheme.bodyMedium,
                    ),
                    if (part.partImages.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      ...part.partImages.map(
                        (imageUrl) => Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          child: SizedBox(
                            width: double.infinity,
                            child: NetworkImageWidget(
                              imageUrl: imageUrl,
                              height: 200,
                              fit: BoxFit.contain,
                              borderRadius: BorderRadius.circular(8),
                              semanticsLabel:
                                  'Question ${part.partNumber} image',
                            ),
                          ),
                        ),
                      ),
                    ],
                    // Show hint for this part
                    if (showHints && part.hintText != null) ...[
                      const SizedBox(height: 8),
                      _buildPartHint(context, part.hintText!),
                    ],
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 12),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '(${part.marks})',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSecondaryContainer,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          if (part.subParts.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...part.subParts.map((subPart) => _buildSubPart(context, subPart)),
          ],
        ],
      ),
    );
  }

  Widget _buildPartHint(BuildContext context, String hintText) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: theme.colorScheme.primaryContainer.withOpacity(0.8),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lightbulb_outline,
            size: 16,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hint:',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 2),
                LaTeXTextWidget(
                  text: hintText,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubPart(BuildContext context, subPart) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(left: 32, bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 32,
                child: Text(
                  subPart.partNumber,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LaTeXTextWidget(
                      text: subPart.partText,
                      style: theme.textTheme.bodyMedium,
                    ),
                    if (subPart.partImages.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      ...subPart.partImages.map(
                        (imageUrl) => Container(
                          margin: const EdgeInsets.only(bottom: 4),
                          child: SizedBox(
                            width: double.infinity,
                            child: NetworkImageWidget(
                              imageUrl: imageUrl,
                              height: 200,
                              fit: BoxFit.contain,
                              borderRadius: BorderRadius.circular(8),
                              semanticsLabel:
                                  'Sub-question ${subPart.partNumber} image',
                            ),
                          ),
                        ),
                      ),
                    ],
                    // Show hint for this sub-part
                    if (showHints && subPart.hintText != null) ...[
                      const SizedBox(height: 6),
                      _buildPartHint(context, subPart.hintText!),
                    ],
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  '(${subPart.marks})',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
