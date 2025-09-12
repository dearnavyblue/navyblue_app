// lib/features/admin/presentation/widgets/question_detail_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navyblue_app/brick/models/question.model.dart';
import 'package:navyblue_app/brick/models/question_part.model.dart';
import 'package:navyblue_app/brick/models/solution_step.model.dart';
import 'package:navyblue_app/core/widgets/latex_text_widget.dart';
import 'package:navyblue_app/core/widgets/network_image_widget.dart';
import '../providers/admin_presentation_providers.dart';
import 'edit_question_part_dialog.dart';
import 'edit_solution_step_dialog.dart';
import 'add_question_part_dialog.dart';
import 'add_solution_step_dialog.dart';

class QuestionDetailDialog extends ConsumerStatefulWidget {
  final Question question;
  final VoidCallback? onQuestionUpdated;

  const QuestionDetailDialog({
    super.key,
    required this.question,
    this.onQuestionUpdated,
  });

  @override
  ConsumerState<QuestionDetailDialog> createState() =>
      _QuestionDetailDialogState();
}

class _QuestionDetailDialogState extends ConsumerState<QuestionDetailDialog>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          children: [
            // Header with question type indicator
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Question ${widget.question.questionNumber}',
                      style: TextStyle(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Question type indicator
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: widget.question.isSimpleQuestion
                          ? Colors.green.withOpacity(0.8)
                          : Colors.blue.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      widget.question.isSimpleQuestion
                          ? 'Simple'
                          : 'Multi-part',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (widget.question.totalMarks != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${widget.question.totalMarks} marks',
                        style: TextStyle(
                          color: theme.colorScheme.onSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  // Delete Question Button
                  IconButton(
                    onPressed: () => _showDeleteQuestionDialog(context),
                    icon: const Icon(Icons.delete, color: Colors.red),
                    tooltip: 'Delete Question',
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    tooltip: 'Close',
                  ),
                ],
              ),
            ),

            // Tab Bar
            Container(
              color: theme.colorScheme.primaryContainer.withOpacity(0.3),
              child: TabBar(
                controller: _tabController,
                tabs: [
                  const Tab(text: 'Context', icon: Icon(Icons.article)),
                  Tab(
                    text: widget.question.isSimpleQuestion
                        ? 'Direct Steps (${widget.question.solutionSteps.length})'
                        : 'Parts (${widget.question.parts.length})',
                    icon: Icon(widget.question.isSimpleQuestion
                        ? Icons.list_alt
                        : Icons.list),
                  ),
                  const Tab(
                    text: 'Solutions',
                    icon: Icon(Icons.lightbulb),
                  ),
                ],
              ),
            ),

            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildContextTab(theme),
                  widget.question.isSimpleQuestion
                      ? _buildDirectStepsTab(theme)
                      : _buildPartsTab(theme),
                  _buildSolutionsTab(theme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContextTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Basic info
          Row(
            children: [
              _buildInfoCard(
                  'Page', widget.question.pageNumber.toString(), Icons.book),
              const SizedBox(width: 16),
              _buildInfoCard(
                  'Order', widget.question.orderIndex.toString(), Icons.sort),
            ],
          ),

          const SizedBox(height: 16),

          // Context text
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.article,
                        size: 20,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Question Context',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LaTeXTextWidget(
                    text: widget.question.contextText,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Question text for simple questions
          if (widget.question.isSimpleQuestion &&
              widget.question.questionText != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.quiz,
                          size: 20,
                          color: theme.colorScheme.secondary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Question Text',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    LaTeXTextWidget(
                      text: widget.question.questionText!,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 16),

          // Question hint for simple questions
          if (widget.question.isSimpleQuestion &&
              widget.question.hintText != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          size: 20,
                          color: Colors.orange[700],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Question Hint',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    LaTeXTextWidget(
                      text: widget.question.hintText!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.orange[700],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 16),

          // Context images
          if (widget.question.contextImages.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.image,
                          size: 20,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Context Images (${widget.question.contextImages.length})',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildImageGallery(widget.question.contextImages, theme),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 16),

          // Topics
          if (widget.question.topics.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.tag,
                          size: 20,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Topics',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.question.topics.map((topic) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            topic,
                            style: TextStyle(
                              color: theme.colorScheme.onSecondaryContainer,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDirectStepsTab(ThemeData theme) {
    return Column(
      children: [
        // Add Direct Solution Step Button
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showAddDirectSolutionStepDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Solution Step'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Direct Solution Steps List
        Expanded(
          child: widget.question.solutionSteps.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No solution steps found',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Add solution steps to show how to solve this question',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Steps summary
                      Card(
                        color: Colors.green.withOpacity(0.1),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(
                                Icons.list_alt,
                                color: Colors.green[700],
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Solution Steps Summary',
                                      style:
                                          theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '${widget.question.solutionSteps.length} steps • ${_getTotalMarksFromDirectSteps()} marks total',
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Individual solution steps
                      ...widget.question.solutionSteps
                          .asMap()
                          .entries
                          .map((entry) {
                        final index = entry.key;
                        final step = entry.value;
                        return Padding(
                          padding: EdgeInsets.only(
                              bottom: index <
                                      widget.question.solutionSteps.length - 1
                                  ? 16
                                  : 0),
                          child: _buildSolutionStep(step, theme),
                        );
                      }),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildPartsTab(ThemeData theme) {
    return Column(
      children: [
        // Add Part Button
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showAddPartDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Add New Part'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Parts List
        Expanded(
          child: widget.question.parts.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.quiz_outlined,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No parts found',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Add parts to break down this question',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Parts summary
                      Card(
                        color:
                            theme.colorScheme.primaryContainer.withOpacity(0.3),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(
                                Icons.analytics_outlined,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Parts Summary',
                                      style:
                                          theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '${widget.question.parts.length} parts • ${_getTotalMarksFromParts()} marks total',
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Individual parts
                      ...widget.question.parts.asMap().entries.map((entry) {
                        final index = entry.key;
                        final part = entry.value;
                        return Padding(
                          padding: EdgeInsets.only(
                              bottom: index < widget.question.parts.length - 1
                                  ? 16
                                  : 0),
                          child: _buildPartCard(part, theme),
                        );
                      }),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildSolutionsTab(ThemeData theme) {
    final allSolutions = <SolutionStep>[];

    // Collect solutions from both direct steps and parts
    allSolutions.addAll(widget.question.solutionSteps);
    for (final part in widget.question.parts) {
      allSolutions.addAll(part.solutionSteps);
    }

    if (allSolutions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.lightbulb_outline,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'No solutions found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.question.isSimpleQuestion
                  ? 'Add solution steps directly to this question'
                  : 'Add parts first, then add solution steps to each part',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Solutions summary
          Card(
            color: Colors.amber.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb,
                    color: Colors.amber[700],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Solutions Overview',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${allSolutions.length} steps • ${allSolutions.map((s) => s.marksForThisStep).fold(0, (a, b) => a + b)} marks total',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Direct solution steps for simple questions
          if (widget.question.isSimpleQuestion &&
              widget.question.solutionSteps.isNotEmpty)
            _buildDirectSolutionSection(theme),

          // Group solutions by part for multi-part questions
          if (widget.question.isMultiPartQuestion)
            ...widget.question.parts
                .where((part) => part.solutionSteps.isNotEmpty)
                .map((part) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: _buildPartSolutions(part, theme),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildDirectSolutionSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Add Solution button
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Direct Solution',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => _showAddDirectSolutionStepDialog(context),
                  icon:
                      const Icon(Icons.add_circle_outline, color: Colors.green),
                  tooltip: 'Add Solution Step',
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Solution steps
            ...widget.question.solutionSteps.asMap().entries.map((entry) {
              final index = entry.key;
              final step = entry.value;
              return Padding(
                padding: EdgeInsets.only(
                    bottom: index < widget.question.solutionSteps.length - 1
                        ? 16
                        : 0),
                child: _buildSolutionStep(step, theme),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildPartCard(QuestionPart part, ThemeData theme) {
    return Card(
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            part.partNumber,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
        ),
        title: Text(
          part.partText,
          style:
              theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        subtitle: Row(
          children: [
            Icon(Icons.score,
                size: 16, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 4),
            Text('${part.marks} marks'),
            if (part.requiresWorking) ...[
              const SizedBox(width: 16),
              const Icon(Icons.edit_note, size: 16, color: Colors.orange),
              const SizedBox(width: 4),
              const Text('Working required',
                  style: TextStyle(color: Colors.orange)),
            ],
            if (part.solutionSteps.isNotEmpty) ...[
              const SizedBox(width: 16),
              Icon(Icons.lightbulb, size: 16, color: Colors.amber[700]),
              const SizedBox(width: 4),
              Text('${part.solutionSteps.length} steps'),
            ],
            if (part.hintText != null) ...[
              const SizedBox(width: 16),
              Icon(Icons.tips_and_updates, size: 16, color: Colors.blue[700]),
              const SizedBox(width: 4),
              const Text('Has hint', style: TextStyle(color: Colors.blue)),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Add Solution Step Button
            IconButton(
              onPressed: () => _showAddSolutionStepDialog(context, part),
              icon: const Icon(Icons.add_circle_outline, color: Colors.green),
              tooltip: 'Add Solution Step',
            ),
            // Edit Part Button
            IconButton(
              onPressed: () => _showEditPartDialog(context, part),
              icon: const Icon(Icons.edit, color: Colors.blue),
              tooltip: 'Edit Part',
            ),
            // Delete Part Button
            IconButton(
              onPressed: () => _showDeletePartDialog(context, part),
              icon: const Icon(Icons.delete, color: Colors.red),
              tooltip: 'Delete Part',
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Part hint
                if (part.hintText != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.tips_and_updates,
                                size: 16, color: Colors.blue[700]),
                            const SizedBox(width: 6),
                            Text(
                              'Hint:',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LaTeXTextWidget(
                          text: part.hintText!,
                          style: TextStyle(color: Colors.blue[700]),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Part images
                if (part.partImages.isNotEmpty) ...[
                  Text(
                    'Part Images',
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildImageGallery(part.partImages, theme),
                  const SizedBox(height: 16),
                ],

                // Part details
                Row(
                  children: [
                    _buildPartDetailChip(
                        'Level ${part.nestingLevel}', Icons.layers, theme),
                    const SizedBox(width: 8),
                    _buildPartDetailChip(
                        'Order ${part.orderIndex}', Icons.sort, theme),
                    if (part.parentPartId != null) ...[
                      const SizedBox(width: 8),
                      _buildPartDetailChip(
                          'Sub-part', Icons.subdirectory_arrow_right, theme),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPartSolutions(QuestionPart part, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Part header with Add Solution button
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Part ${part.partNumber}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    part.partText,
                    style: theme.textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  onPressed: () => _showAddSolutionStepDialog(context, part),
                  icon:
                      const Icon(Icons.add_circle_outline, color: Colors.green),
                  tooltip: 'Add Solution Step',
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Solution steps
            ...part.solutionSteps.asMap().entries.map((entry) {
              final index = entry.key;
              final step = entry.value;
              return Padding(
                padding: EdgeInsets.only(
                    bottom: index < part.solutionSteps.length - 1 ? 16 : 0),
                child: _buildSolutionStep(step, theme),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSolutionStep(SolutionStep step, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: step.isCriticalStep
              ? Colors.red.withOpacity(0.3)
              : theme.colorScheme.outline.withOpacity(0.2),
          width: step.isCriticalStep ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
        color: step.isCriticalStep
            ? Colors.red.withOpacity(0.05)
            : theme.colorScheme.surface,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Step header with action buttons
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: step.isCriticalStep
                        ? Colors.red
                        : theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      '${step.stepNumber}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    step.description,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${step.marksForThisStep} marks',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.green[700],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Edit Solution Step Button
                IconButton(
                  onPressed: () => _showEditSolutionStepDialog(context, step),
                  icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                  tooltip: 'Edit Step',
                ),
                // Delete Solution Step Button
                IconButton(
                  onPressed: () => _showDeleteSolutionStepDialog(context, step),
                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                  tooltip: 'Delete Step',
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Working out
            if (step.workingOut != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest
                      .withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calculate, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'Working:',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LaTeXTextWidget(
                      text: step.workingOut!,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Solution images
            if (step.solutionImages.isNotEmpty) ...[
              Text(
                'Solution Images',
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildImageGallery(step.solutionImages, theme),
              const SizedBox(height: 12),
            ],

            // Teaching note
            if (step.teachingNote != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.school, size: 16, color: Colors.blue[700]),
                        const SizedBox(width: 6),
                        Text(
                          'Teaching Note:',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LaTeXTextWidget(
                      text: step.teachingNote!,
                      style: TextStyle(color: Colors.blue[700]),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Critical step indicator
            if (step.isCriticalStep) ...[
              const SizedBox(height: 8),
              const Row(
                children: [
                  Icon(Icons.priority_high, size: 16, color: Colors.red),
                  SizedBox(width: 6),
                  Text(
                    'Critical Step',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Helper methods for CRUD operations
  void _showDeleteQuestionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Question'),
        content: Text(
          'Are you sure you want to delete Question ${widget.question.questionNumber}?\n\nThis will also delete all parts and solution steps. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(context).pop(); // Close confirmation dialog
              Navigator.of(context).pop(); // Close question detail dialog

              await ref
                  .read(adminControllerProvider.notifier)
                  .deleteQuestion(widget.question.id);
              widget.onQuestionUpdated?.call();
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showEditPartDialog(BuildContext context, QuestionPart part) {
    showDialog(
      context: context,
      builder: (context) => EditQuestionPartDialog(
        part: part,
        onSaved: () {
          widget.onQuestionUpdated?.call();
        },
      ),
    );
  }

  void _showDeletePartDialog(BuildContext context, QuestionPart part) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Part'),
        content: Text(
          'Are you sure you want to delete Part ${part.partNumber}?\n\nThis will also delete all solution steps for this part. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await ref
                  .read(adminControllerProvider.notifier)
                  .deleteQuestionPart(part.id);
              widget.onQuestionUpdated?.call();
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showEditSolutionStepDialog(BuildContext context, SolutionStep step) {
    showDialog(
      context: context,
      builder: (context) => EditSolutionStepDialog(
        step: step,
        onSaved: () {
          widget.onQuestionUpdated?.call();
        },
      ),
    );
  }

  void _showDeleteSolutionStepDialog(BuildContext context, SolutionStep step) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Solution Step'),
        content: Text(
          'Are you sure you want to delete Solution Step ${step.stepNumber}?\n\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await ref
                  .read(adminControllerProvider.notifier)
                  .deleteSolutionStep(step.id);
              widget.onQuestionUpdated?.call();
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAddPartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddQuestionPartDialog(
        questionId: widget.question.id,
        onSaved: () {
          widget.onQuestionUpdated?.call();
        },
      ),
    );
  }

  void _showAddSolutionStepDialog(BuildContext context, QuestionPart part) {
    showDialog(
      context: context,
      builder: (context) => AddSolutionStepDialog.forPart(
        part: part,
        onSaved: () {
          widget.onQuestionUpdated?.call();
        },
      ),
    );
  }

  void _showAddDirectSolutionStepDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddSolutionStepDialog.forDirectQuestion(
        questionId: widget.question.id,
        question: widget.question,
        onSaved: () {
          widget.onQuestionUpdated?.call();
        },
      ),
    );
  }

  Widget _buildImageGallery(List<String> imageUrls, ThemeData theme) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: imageUrls.length,
        itemBuilder: (context, index) {
          return Padding(
            padding:
                EdgeInsets.only(right: index < imageUrls.length - 1 ? 8 : 0),
            child: GestureDetector(
              onTap: () => _showImageViewer(context, imageUrls, index),
              child: NetworkImageWidget(
                imageUrl: imageUrls[index],
                width: 120,
                height: 120,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(icon, size: 24),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPartDetailChip(String label, IconData icon, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  int _getTotalMarksFromParts() {
    return widget.question.parts
        .map((part) => part.marks)
        .fold(0, (sum, marks) => sum + marks);
  }

  int _getTotalMarksFromDirectSteps() {
    return widget.question.solutionSteps
        .map((step) => step.marksForThisStep)
        .fold(0, (sum, marks) => sum + marks);
  }

  void _showImageViewer(
      BuildContext context, List<String> imageUrls, int initialIndex) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            PageView.builder(
              controller: PageController(initialPage: initialIndex),
              itemCount: imageUrls.length,
              itemBuilder: (context, index) {
                return Center(
                  child: InteractiveViewer(
                    child: NetworkImageWidget(
                      imageUrl: imageUrls[index],
                      fit: BoxFit.contain,
                    ),
                  ),
                );
              },
            ),
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, color: Colors.white),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black54,
                ),
              ),
            ),
            // Image counter
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${initialIndex + 1} of ${imageUrls.length}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
