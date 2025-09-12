// lib/features/admin/presentation/widgets/paper_upload_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/admin_presentation_providers.dart';

class PaperUploadDialog extends ConsumerStatefulWidget {
  const PaperUploadDialog({super.key});

  @override
  ConsumerState<PaperUploadDialog> createState() => _PaperUploadDialogState();
}

class _PaperUploadDialogState extends ConsumerState<PaperUploadDialog> {
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
                Text(
                  'Upload Paper JSON',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    ref
                        .read(adminControllerProvider.notifier)
                        .clearCurrentPaper();
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.close),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // JSON Input
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Paste your paper JSON:',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: TextField(
                      controller: _jsonController,
                      maxLines: null,
                      expands: true,
                      decoration: InputDecoration(
                        hintText: 'Paste your paper JSON here...',
                        border: const OutlineInputBorder(),
                        suffixIcon: _isJsonValid
                            ? const Icon(Icons.check_circle,
                                color: Colors.green)
                            : _jsonController.text.isNotEmpty
                                ? const Icon(Icons.error, color: Colors.red)
                                : null,
                      ),
                      onChanged: _validateAndLoadJson,
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

            // Image Upload Section
            if (_isJsonValid && adminState.currentPaperJson != null)
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Upload Images:',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: _buildImageUploadSection(),
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
                        .clearCurrentPaper();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 16),
                FilledButton(
                  onPressed: (_isJsonValid && !adminState.isLoading)
                      ? _submitPaper
                      : null,
                  child: adminState.isLoading
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Create Paper'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _validateAndLoadJson(String value) {
    if (value.trim().isEmpty) {
      setState(() => _isJsonValid = false);
      return;
    }

    try {
      ref.read(adminControllerProvider.notifier).loadPaperJson(value);
      setState(() => _isJsonValid = true);
    } catch (e) {
      setState(() => _isJsonValid = false);
    }
  }

  Widget _buildImageUploadSection() {
    final adminController = ref.read(adminControllerProvider.notifier);
    final imagePaths = adminController.getImageUploadPaths();
    final imageUploads = ref.watch(adminImageUploadsProvider);

    if (imagePaths.isEmpty) {
      return const Center(
        child: Text(
          'No images needed for this paper',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: imagePaths.length,
      itemBuilder: (context, index) {
        final path = imagePaths[index];
        final hasImage = imageUploads.containsKey(path);

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
    // Convert "questions[0].contextImages" to "Question 0 Context Images"
    return path
        .replaceAll('[', ' ')
        .replaceAll(']', '')
        .replaceAll('.', ' ')
        .split(' ')
        .where((part) => part.isNotEmpty)
        .map((part) {
      if (RegExp(r'^\d+').hasMatch(part)) {
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
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final imageData = file.bytes;
        final fileName = file.name;

        if (imageData != null) {
          await ref
              .read(adminControllerProvider.notifier)
              .uploadImageForPath(path, imageData, fileName);
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

  Future<void> _submitPaper() async {
    await ref.read(adminControllerProvider.notifier).createPaper();

    if (mounted) {
      final adminState = ref.read(adminControllerProvider);
      if (adminState.error == null) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Paper created successfully!')),
        );
      }
    }
  }
}
