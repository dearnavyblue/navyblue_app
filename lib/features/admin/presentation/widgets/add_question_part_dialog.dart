// lib/features/admin/presentation/widgets/add_question_part_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/admin_presentation_providers.dart';

class AddQuestionPartDialog extends ConsumerStatefulWidget {
  final String questionId;
  final VoidCallback? onSaved;

  const AddQuestionPartDialog({
    super.key,
    required this.questionId,
    this.onSaved,
  });

  @override
  ConsumerState<AddQuestionPartDialog> createState() =>
      _AddQuestionPartDialogState();
}

class _AddQuestionPartDialogState extends ConsumerState<AddQuestionPartDialog> {
  final _formKey = GlobalKey<FormState>();
  final _partNumberController = TextEditingController();
  final _partTextController = TextEditingController();
  final _marksController = TextEditingController();
  final _orderIndexController = TextEditingController();
  final _nestingLevelController = TextEditingController(text: '1');
  final _hintTextController = TextEditingController(); // Add hint controller
  bool _requiresWorking = false;

  @override
  void dispose() {
    _partNumberController.dispose();
    _partTextController.dispose();
    _marksController.dispose();
    _orderIndexController.dispose();
    _nestingLevelController.dispose();
    _hintTextController.dispose(); // Dispose hint controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final adminState = ref.watch(adminControllerProvider);

    return AlertDialog(
      title: const Text('Add New Question Part'),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _partNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Part Number *',
                    hintText: 'e.g., 1.1, 2a, 3(i), etc.',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter part number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _partTextController,
                  decoration: const InputDecoration(
                    labelText: 'Part Text *',
                    hintText: 'Enter the question part description',
                    helperText: 'What does this part ask students to do?',
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter part text';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Add hint text field
                TextFormField(
                  controller: _hintTextController,
                  decoration: const InputDecoration(
                    labelText: 'Hint Text (Optional)',
                    hintText: 'Helpful hint to guide students on this part',
                    helperText:
                        'Guidance on approach or key concepts for this part',
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _marksController,
                        decoration: const InputDecoration(
                          labelText: 'Marks *',
                          helperText: 'Total marks for this part',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter marks';
                          }
                          final marks = int.tryParse(value);
                          if (marks == null || marks < 0) {
                            return 'Please enter valid marks (0 or higher)';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _orderIndexController,
                        decoration: const InputDecoration(
                          labelText: 'Order Index *',
                          helperText: 'Display order (0, 1, 2...)',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter order';
                          }
                          final order = int.tryParse(value);
                          if (order == null || order < 0) {
                            return 'Please enter valid order (0 or higher)';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nestingLevelController,
                  decoration: const InputDecoration(
                    labelText: 'Nesting Level',
                    hintText: '1 for main part, 2 for sub-part, etc.',
                    helperText: 'How deeply nested is this part?',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter nesting level';
                    }
                    final level = int.tryParse(value);
                    if (level == null || level < 1) {
                      return 'Please enter valid level (1 or higher)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Card(
                  child: SwitchListTile(
                    title: const Text('Requires Working'),
                    subtitle: const Text(
                        'Does this part require students to show their working?'),
                    value: _requiresWorking,
                    onChanged: (value) {
                      setState(() {
                        _requiresWorking = value;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 8),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '* Required fields',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed:
              adminState.isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: adminState.isLoading ? null : _savePart,
          child: adminState.isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Add Part'),
        ),
      ],
    );
  }

  void _savePart() async {
    if (_formKey.currentState!.validate()) {
      final partData = {
        'partNumber': _partNumberController.text.trim(),
        'partText': _partTextController.text.trim(),
        'marks': int.parse(_marksController.text),
        'hintText': _hintTextController.text.trim().isEmpty
            ? null
            : _hintTextController.text.trim(), // Include hint
        'orderIndex': int.parse(_orderIndexController.text),
        'nestingLevel': int.parse(_nestingLevelController.text),
        'requiresWorking': _requiresWorking,
        'partImages': <String>[], // Empty initially
      };

      await ref
          .read(adminControllerProvider.notifier)
          .createQuestionPart(widget.questionId, partData);

      if (mounted && !ref.read(adminControllerProvider).isLoading) {
        Navigator.of(context).pop();
        widget.onSaved?.call();
      }
    }
  }
}
