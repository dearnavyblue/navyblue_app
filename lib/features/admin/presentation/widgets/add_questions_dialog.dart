// lib/features/admin/presentation/widgets/add_questions_dialog.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../brick/models/exam_paper.model.dart';
import '../providers/admin_presentation_providers.dart';

class AddQuestionsDialog extends ConsumerStatefulWidget {
  final ExamPaper paper;

  const AddQuestionsDialog({super.key, required this.paper});

  @override
  ConsumerState<AddQuestionsDialog> createState() => _AddQuestionsDialogState();
}

class _AddQuestionsDialogState extends ConsumerState<AddQuestionsDialog> {
  final _jsonController = TextEditingController();
  bool _isJsonValid = false;

  @override
  void dispose() {
    _jsonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminControllerProvider);
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;

    return Dialog(
      child: Container(
        width: 600,
        height: screenHeight * 0.8,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Add Questions',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.paper.title,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    ref
                        .read(adminControllerProvider.notifier)
                        .clearCurrentQuestions();
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.close),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // JSON Input for Questions
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Paste questions JSON array:',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: TextField(
                      controller: _jsonController,
                      maxLines: null,
                      expands: true,
                      decoration: InputDecoration(
                        hintText:
                            '[\n  {\n    "questionNumber": "1",\n    "contextText": "...",\n    "parts": [...]\n  }\n]',
                        border: const OutlineInputBorder(),
                        suffixIcon: _isJsonValid
                            ? const Icon(Icons.check_circle,
                                color: Colors.green)
                            : _jsonController.text.isNotEmpty
                                ? const Icon(Icons.error, color: Colors.red)
                                : null,
                      ),
                      onChanged: _validateAndLoadQuestionsJson,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _isJsonValid
                            ? 'Valid JSON ✓'
                            : _jsonController.text.isNotEmpty
                                ? 'Invalid JSON ✗'
                                : '',
                        style: TextStyle(
                          color: _isJsonValid ? Colors.green : Colors.red,
                          fontSize: 12,
                        ),
                      ),
                      TextButton(
                        onPressed: () => _jsonController.clear(),
                        child: const Text('Clear'),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Image Upload Section for Questions
            if (_isJsonValid && adminState.currentQuestionsJson != null)
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Upload Images for Questions:',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: _buildQuestionImageUploadSection(),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 16),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    ref
                        .read(adminControllerProvider.notifier)
                        .clearCurrentQuestions();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 16),
                FilledButton(
                  onPressed: (_isJsonValid && !adminState.isLoading)
                      ? _submitQuestions
                      : null,
                  child: adminState.isLoading
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Add Questions'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _validateAndLoadQuestionsJson(String value) {
    if (value.trim().isEmpty) {
      setState(() => _isJsonValid = false);
      ref.read(adminControllerProvider.notifier).clearCurrentQuestions();
      return;
    }

    try {
      final json = jsonDecode(value);
      if (json is List) {
        ref.read(adminControllerProvider.notifier).loadQuestionsJson(value);
        setState(() => _isJsonValid = true);
      } else {
        setState(() => _isJsonValid = false);
      }
    } catch (e) {
      setState(() => _isJsonValid = false);
    }
  }

  Widget _buildQuestionImageUploadSection() {
    final adminController = ref.read(adminControllerProvider.notifier);
    final imagePaths = adminController.getQuestionImagePaths();
    final questionImageUploads =
        ref.watch(adminControllerProvider).questionImageUploads;

    if (imagePaths.isEmpty) {
      return const Center(
        child: Text(
          'No images needed for these questions',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: imagePaths.length,
      itemBuilder: (context, index) {
        final path = imagePaths[index];
        final hasImage = questionImageUploads.containsKey(path);

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _formatImagePath(path),
                  style: const TextStyle(fontSize: 13),
                ),
              ),
              const SizedBox(width: 12),
              if (hasImage)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '✓ Uploaded',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.green[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => _uploadImageForPath(path),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: const Text('Upload'),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatImagePath(String path) {
    return path
        .replaceAll('[', ' ')
        .replaceAll(']', '')
        .replaceAll('.', ' ')
        .split(' ')
        .where((part) => part.isNotEmpty)
        .map((part) {
      if (RegExp(r'^\d+$').hasMatch(part)) {
        return part;
      }
      return part[0].toUpperCase() + part.substring(1);
    }).join(' ');
  }

  Future<void> _uploadImageForPath(String path) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final imageData = file.bytes;
        final fileName = file.name;

        if (imageData != null && mounted) {
          // ✅ ensure dialog still exists
          await ref
              .read(adminControllerProvider.notifier)
              .uploadImageForQuestionPath(path, imageData, fileName);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error selecting image: $e')),
        );
      }
    }
  }

  Future<void> _submitQuestions() async {
    await ref
        .read(adminControllerProvider.notifier)
        .addQuestionsToPaper(widget.paper.id);

    if (mounted) {
      final adminState = ref.read(adminControllerProvider);
      if (adminState.error == null) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Questions added successfully!')),
        );
      }
    }
  }
}
