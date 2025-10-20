import 'package:flutter/material.dart';
import 'package:navyblue_app/brick/models/mcq_option.model.dart';
import 'package:navyblue_app/core/widgets/latex_text_widget.dart';
import 'package:navyblue_app/core/widgets/network_image_widget.dart';
import '../../../../brick/models/question.model.dart';
import '../widgets/paper_page_scaffold.dart';
import '../widgets/paper_header.dart';
import '../widgets/paper_header_data.dart';

class PaperTabWidget extends StatelessWidget {
  final List<Question> questions;
  final String? instructions;
  final int currentPage;
  final int totalPages;
  final bool showHints;
  final bool isPracticeMode;
  final VoidCallback onPreviousPage;
  final VoidCallback onNextPage;
  final VoidCallback onToggleHints;
  final bool canGoToPrevious;
  final bool canGoToNext;
  final String pageDisplayText;
  final bool isOnInstructionsPage;
  final PaperHeaderData? headerData;

  String _parens(int? n) => n == null ? '' : '(${n})';
  String _brackets(int? n) => n == null ? '' : '[${n}]';

  bool _isContextOnly(Question q) {
    final hasContext = (q.contextText?.trim().isNotEmpty == true) ||
        q.contextImages.isNotEmpty;
    final hasOwnPrompt = q.questionText != null;
    final hasOwnMcq = q.mcqOptions != null && q.mcqOptions!.isNotEmpty;
    return hasContext && !hasOwnPrompt && !hasOwnMcq && q.isMultiPartQuestion;
  }

  TextStyle _marksStyle(BuildContext context) =>
      Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.normal,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ) ??
      const TextStyle(fontSize: 12, fontWeight: FontWeight.w400);

  const PaperTabWidget({
    super.key,
    required this.questions,
    required this.instructions,
    required this.currentPage,
    required this.totalPages,
    required this.showHints,
    required this.isPracticeMode,
    required this.onPreviousPage,
    required this.onNextPage,
    required this.onToggleHints,
    required this.canGoToPrevious,
    required this.canGoToNext,
    required this.pageDisplayText,
    required this.isOnInstructionsPage,
    this.headerData,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final shouldShowHeader = headerData != null &&
        !isOnInstructionsPage &&
        currentPage >= (headerData!.startsAtPage);


    return Column(
      children: [
        /// Content based on current page
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.zero,
            child: PaperPageScaffold(
              enableZoom: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (headerData != null &&
                      !isOnInstructionsPage &&
                      currentPage >= (headerData!.startsAtPage))
                    PaperHeader(
                      data: headerData!,
                      pageNumber: currentPage + (headerData?.pageOffset ?? 0),
                    ),
                  _buildPageContent(
                      context), // questions (or instructions) follow
                ],
              ),
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
                onPressed: canGoToPrevious ? onPreviousPage : null,
                icon: const Icon(Icons.chevron_left),
                label: const Text('Previous'),
              ),
              Text(
                pageDisplayText,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              TextButton.icon(
                onPressed: canGoToNext ? onNextPage : null,
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

  Widget _buildPageContent(BuildContext context) {
    if (isOnInstructionsPage) {
      return _buildInstructionsPage(context);
    }

    if (questions.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: questions
            .map((question) => _buildQuestion(context, question))
            .toList(),
      );
    }

    return _buildLoadingState(context);
  }

  Widget _buildLoadingState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Loading Page $currentPage...',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Content will appear as it becomes available',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionsPage(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'INSTRUCTIONS',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: LaTeXTextWidget(
            text: instructions ?? 'No specific instructions provided.',
            style: theme.textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  Widget _questionHeading(BuildContext context, String number,
      {String? secondary}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'QUESTION $number',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            ),
          ),
          if (secondary != null) ...[
            const SizedBox(width: 8),
            Text(
              secondary,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuestion(BuildContext context, Question question) {
    final heading = _questionHeading(context, question.questionNumber);
    final theme = Theme.of(context);
    final isContextOnly = _isContextOnly(question);

    return Container(
      margin: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          heading,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isContextOnly)
                SizedBox(
                  width: 32,
                  child: Text(
                    question.questionNumber,
                    style: theme.textTheme.labelSmall?.copyWith(
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
                        text: question.contextText!
                      ),
                    ],
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
            ],
          ),

          const SizedBox(height: 16),

          // Handle MCQ questions at question level
          if (question.mcqOptions != null &&
              question.mcqOptions!.isNotEmpty) ...[
            _buildMCQQuestion(context, question),
          ]
          // Handle simple questions
          else if (question.isSimpleQuestion) ...[
            _buildSimpleQuestion(context, question),
          ]
          // Handle multi-part questions
          else if (question.isMultiPartQuestion) ...[
            ...question.organizedParts
                .map((part) => _buildQuestionPart(context, part)),
          ],

          if (question.totalMarks != null) ...[
            const SizedBox(height: 8),
            Container(
              // indent to line up with the main content column (skip the left 32 gutter)
              margin: EdgeInsets.only(left: !isContextOnly ? 32 : 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(_brackets(question.totalMarks),
                      style: _marksStyle(context)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMCQQuestion(BuildContext context, Question question) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(left: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (question.questionText != null) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: LaTeXTextWidget(
                    text: question.questionText!,
                  ),
                ),
                if (question.totalMarks != null) ...[
                  const SizedBox(width: 16),
                  const SizedBox(width: 16),
                  Text(_parens(question.totalMarks),
                      style: _marksStyle(context)),
                ],
              ],
            ),
            const SizedBox(height: 12),
          ],

          // Render MCQ options - work with MCQOption objects directly
          ...question.mcqOptions!.map((option) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: theme.colorScheme.outlineVariant),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.colorScheme.primary,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        option.label,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (option.text != null && option.text!.isNotEmpty) ...[
                          LaTeXTextWidget(
                            text: option.text!,
                          ),
                        ],
                        if (option.optionImages.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          ...option.optionImages.map(
                            (imageUrl) => Container(
                              margin: const EdgeInsets.only(bottom: 4),
                              child: NetworkImageWidget(
                                imageUrl: imageUrl,
                                height: 120,
                                fit: BoxFit.contain,
                                borderRadius: BorderRadius.circular(4),
                                semanticsLabel: 'Option ${option.label} image',
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),

          // Show hint for MCQ if available
          if (showHints && question.hintText != null) ...[
            const SizedBox(height: 12),
            _buildQuestionHint(context, question.hintText!),
          ],
        ],
      ),
    );
  }

  Widget _buildSimpleQuestion(BuildContext context, Question question) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (question.questionText != null) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: LaTeXTextWidget(
                  text: question.questionText!,
                  style: theme.textTheme.bodySmall,
                ),
              ),
              if (question.totalMarks != null) ...[
                const SizedBox(width: 16),
                Text(_parens(question.totalMarks), style: _marksStyle(context)),
              ],
            ],
          ),
          const SizedBox(height: 8),
        ],
        if (showHints && question.hintText != null)
          _buildQuestionHint(context, question.hintText!),
      ],
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

    // Check if this part is an MCQ
    if (part.mcqOptions != null && (part.mcqOptions as List).isNotEmpty) {
      return _buildMCQPart(context, part);
    }

    // Regular part rendering
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LaTeXTextWidget(
                      text: part.partText,
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
                    if (showHints && part.hintText != null) ...[
                      const SizedBox(height: 8),
                      _buildPartHint(context, part.hintText!),
                    ],
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 12),
                child: Text(_parens(part.marks), style: _marksStyle(context)),
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

  Widget _buildMCQPart(BuildContext context, part) {
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
                    ),
                    // Render part images
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
                                  'Question ${part.partNumber} diagram',
                            ),
                          ),
                        ),
                      ),
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
          const SizedBox(height: 12),

          // Render MCQ options for the part
          ...(part.mcqOptions as List<MCQOption>).map((option) {
            return Container(
              margin: const EdgeInsets.only(left: 32, bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(color: theme.colorScheme.outlineVariant),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.colorScheme.primary,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        option.label,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (option.text != null && option.text!.isNotEmpty) ...[
                          LaTeXTextWidget(
                            text: option.text!,
                          ),
                        ],
                        if (option.optionImages.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          ...option.optionImages.map(
                            (imageUrl) => Container(
                              margin: const EdgeInsets.only(bottom: 4),
                              child: NetworkImageWidget(
                                imageUrl: imageUrl,
                                height: 100,
                                fit: BoxFit.contain,
                                borderRadius: BorderRadius.circular(4),
                                semanticsLabel: 'Option ${option.label} image',
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),

          if (showHints && part.hintText != null) ...[
            const SizedBox(height: 8),
            Container(
              margin: const EdgeInsets.only(left: 32),
              child: _buildPartHint(context, part.hintText!),
            ),
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

    // Check if subpart is MCQ
    if (subPart.mcqOptions != null && (subPart.mcqOptions as List).isNotEmpty) {
      return _buildMCQPart(context, subPart);
    }

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
                  style: theme.textTheme.bodySmall?.copyWith(
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
                    if (showHints && subPart.hintText != null) ...[
                      const SizedBox(height: 6),
                      _buildPartHint(context, subPart.hintText!),
                    ],
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 8),
                child:
                    Text(_parens(subPart.marks), style: _marksStyle(context)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
