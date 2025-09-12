// lib/features/admin/presentation/screens/admin_papers_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navyblue_app/features/admin/presentation/controllers/admin_controller.dart';
import '../providers/admin_presentation_providers.dart';
import '../widgets/paper_upload_dialog.dart';
import '../widgets/add_questions_dialog.dart';
import 'paper_questions_screen.dart';

class AdminPapersScreen extends ConsumerStatefulWidget {
  const AdminPapersScreen({super.key});

  @override
  ConsumerState<AdminPapersScreen> createState() => _AdminPapersScreenState();
}

class _AdminPapersScreenState extends ConsumerState<AdminPapersScreen> {
  @override
  void initState() {
    super.initState();
    // Load papers when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminControllerProvider.notifier).loadPapers();
    });
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
      body: Column(
        children: [
          // Upload Paper Button
          Container(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: adminState.isLoading
                    ? null
                    : () => _showUploadPaperDialog(context),
                icon: const Icon(Icons.upload_file),
                label: const Text('Upload Complete Paper JSON'),
              ),
            ),
          ),

          // Papers List
          Expanded(
            child: adminState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : adminState.papers.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.description_outlined,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No papers found',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Upload your first paper to get started',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => ref
                            .read(adminControllerProvider.notifier)
                            .loadPapers(),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: adminState.papers.length,
                          itemBuilder: (context, index) {
                            final paper = adminState.papers[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                // UPDATED: Navigate to questions screen instead of add questions dialog
                                onTap: () =>
                                    _navigateToQuestions(context, paper),
                                title: Text(
                                  paper.title,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${paper.subject} • ${paper.grade} • ${paper.syllabus}',
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${paper.year} • ${paper.examPeriod} • ${paper.durationMinutes}min',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color:
                                            theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Status indicator
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: paper.isActive
                                            ? Colors.green.withOpacity(0.1)
                                            : Colors.red.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        paper.isActive ? 'Active' : 'Inactive',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: paper.isActive
                                              ? Colors.green[700]
                                              : Colors.red[700],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),

                                    // NEW: Add Questions button
                                    IconButton(
                                      onPressed: adminState.isLoading
                                          ? null
                                          : () => _showAddQuestionsDialog(
                                              context, paper),
                                      icon: const Icon(
                                        Icons.add_circle_outline,
                                        color: Colors.blue,
                                      ),
                                      tooltip: 'Add Questions',
                                    ),

                                    // Toggle Status button
                                    IconButton(
                                      onPressed: adminState.isLoading
                                          ? null
                                          : () => ref
                                              .read(adminControllerProvider
                                                  .notifier)
                                              .togglePaperStatus(paper.id),
                                      icon: Icon(
                                        paper.isActive
                                            ? Icons.toggle_on
                                            : Icons.toggle_off,
                                        color: paper.isActive
                                            ? Colors.green
                                            : Colors.grey,
                                      ),
                                      tooltip: paper.isActive
                                          ? 'Deactivate Paper'
                                          : 'Activate Paper',
                                    ),

                                    // Delete button
                                    IconButton(
                                      onPressed: adminState.isLoading
                                          ? null
                                          : () => _showDeleteConfirmation(
                                              context, paper.id, paper.title),
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      tooltip: 'Delete Paper',
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  void _showUploadPaperDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const PaperUploadDialog(),
    );
  }

  void _showAddQuestionsDialog(BuildContext context, paper) {
    showDialog(
      context: context,
      builder: (context) => AddQuestionsDialog(paper: paper),
    );
  }

  // NEW: Navigate to questions screen
  void _navigateToQuestions(BuildContext context, paper) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PaperQuestionsScreen(paper: paper),
      ),
    );
  }

  void _showDeleteConfirmation(
      BuildContext context, String paperId, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Paper'),
        content: Text(
          'Are you sure you want to delete "$title"?\n\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(adminControllerProvider.notifier).deletePaper(paperId);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
