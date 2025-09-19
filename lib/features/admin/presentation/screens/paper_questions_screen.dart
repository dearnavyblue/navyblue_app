// lib/features/admin/presentation/screens/paper_questions_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navyblue_app/brick/models/exam_paper.model.dart';
import 'package:navyblue_app/brick/models/question.model.dart';
import 'package:navyblue_app/core/widgets/latex_text_widget.dart';
import '../controllers/admin_controller.dart';
import '../providers/admin_presentation_providers.dart';
import '../widgets/add_questions_dialog.dart';
import '../widgets/question_detail_dialog.dart';

class PaperQuestionsScreen extends ConsumerStatefulWidget {
  final ExamPaper paper;

  const PaperQuestionsScreen({
    super.key,
    required this.paper,
  });

  @override
  ConsumerState<PaperQuestionsScreen> createState() =>
      _PaperQuestionsScreenState();
}

class _PaperQuestionsScreenState extends ConsumerState<PaperQuestionsScreen> {
  @override
  void initState() {
    super.initState();
    // Load questions when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(adminControllerProvider.notifier)
          .loadPaperQuestions(widget.paper.id);
    });
  }

  @override
  void dispose() {
    // Clear questions when leaving screen
    ref.read(adminControllerProvider.notifier).clearCurrentPaperQuestions();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminControllerProvider);
    final theme = Theme.of(context);

    // Listen for errors
    ref.listen<AdminState>(adminControllerProvider, (previous, next) {
      if (next.error != null && next.error != previous?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: theme.colorScheme.error,
            action: SnackBarAction(
              label: 'Dismiss',
              textColor: theme.colorScheme.onError,
              onPressed: () {
                ref.read(adminControllerProvider.notifier).clearError();
              },
            ),
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.paper.title,
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              '${widget.paper.subject} • ${widget.paper.grade}',
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => _showAddQuestionsDialog(context),
            icon: const Icon(Icons.add),
            tooltip: 'Add Questions',
          ),
          IconButton(
            onPressed: () => ref
                .read(adminControllerProvider.notifier)
                .loadPaperQuestions(widget.paper.id),
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Paper Info Card
          Container(
            margin: const EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${widget.paper.year} ${widget.paper.examPeriod}',
                                style: theme.textTheme.titleMedium,
                              ),
                              Text(
                                '${widget.paper.durationMinutes} min',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: widget.paper.isActive
                                ? Colors.green.withOpacity(0.1)
                                : Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            widget.paper.isActive ? 'Active' : 'Inactive',
                            style: TextStyle(
                              fontSize: 12,
                              color: widget.paper.isActive
                                  ? Colors.green[700]
                                  : Colors.red[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (widget.paper.instructions != null) ...[
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 8),
                      Text(
                        'Instructions:',
                        style: theme.textTheme.titleSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.paper.instructions!,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // Questions Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  'Questions (${adminState.currentPaperQuestions.length})',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (widget.paper.totalMarks != null) ...[
                  const Spacer(),
                  Text(
                    'Total Marks: ${widget.paper.totalMarks}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Questions List
          Expanded(
            child: adminState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : adminState.currentPaperQuestions.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.quiz_outlined,
                              size: 64,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No questions found',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Add questions to this paper to get started',
                              style: TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () => _showAddQuestionsDialog(context),
                              icon: const Icon(Icons.add),
                              label: const Text('Add Questions'),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => ref
                            .read(adminControllerProvider.notifier)
                            .loadPaperQuestions(widget.paper.id),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: adminState.currentPaperQuestions.length,
                          itemBuilder: (context, index) {
                            final question =
                                adminState.currentPaperQuestions[index];
                            return _buildQuestionCard(context, question, theme);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(
      BuildContext context, Question question, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showQuestionDetail(context, question),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Question header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Q${question.questionNumber}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Page ${question.pageNumber}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  if (question.totalMarks != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${question.totalMarks} marks',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.onSecondaryContainer,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // Question context

              if (question.contextText != null) ...[
                LaTeXTextWidget(
                  text: question.contextText!,
                  style: theme.textTheme.bodyMedium,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              // Topics and images info
              if (question.topics.isNotEmpty ||
                  question.contextImages.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    // Topics
                    ...question.topics.take(3).map((topic) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            topic,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.blue,
                            ),
                          ),
                        )),
                    // Image indicator
                    if (question.contextImages.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.image,
                              size: 10,
                              color: Colors.orange,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${question.contextImages.length}',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.orange,
                              ),
                            ),
                          ],
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
  }

  void _showAddQuestionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddQuestionsDialog(paper: widget.paper),
    );
  }

  void _showQuestionDetail(BuildContext context, Question question) {
    showDialog(
      context: context,
      builder: (context) => QuestionDetailDialog(question: question),
    );
  }
}
