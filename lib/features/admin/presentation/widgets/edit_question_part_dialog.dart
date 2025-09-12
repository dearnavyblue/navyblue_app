// lib/features/admin/presentation/widgets/edit_question_part_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navyblue_app/brick/models/question_part.model.dart';
import '../providers/admin_presentation_providers.dart';

class EditQuestionPartDialog extends ConsumerStatefulWidget {
  final QuestionPart part;
  final VoidCallback? onSaved;

  const EditQuestionPartDialog({
    super.key,
    required this.part,
    this.onSaved,
  });

  @override
  ConsumerState<EditQuestionPartDialog> createState() =>
      _EditQuestionPartDialogState();
}

class _EditQuestionPartDialogState
    extends ConsumerState<EditQuestionPartDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _partNumberController;
  late TextEditingController _partTextController;
  late TextEditingController _marksController;
  late TextEditingController _orderIndexController;
  late TextEditingController _nestingLevelController;
  late TextEditingController _hintTextController; // Add hint controller
  late bool _requiresWorking;

  @override
  void initState() {
    super.initState();
    _partNumberController = TextEditingController(text: widget.part.partNumber);
    _partTextController = TextEditingController(text: widget.part.partText);
    _marksController =
        TextEditingController(text: widget.part.marks.toString());
    _orderIndexController =
        TextEditingController(text: widget.part.orderIndex.toString());
    _nestingLevelController =
        TextEditingController(text: widget.part.nestingLevel.toString());
    _hintTextController = TextEditingController(
        text: widget.part.hintText ?? ''); // Initialize hint
    _requiresWorking = widget.part.requiresWorking;
  }

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
      title: Text('Edit Part ${widget.part.partNumber}'),
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
                    labelText: 'Part Number',
                    hintText: 'e.g., 1.1, 2a, etc.',
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
                    labelText: 'Part Text',
                    hintText: 'Question part description',
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
                          labelText: 'Marks',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter marks';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Please enter valid number';
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
                          labelText: 'Order Index',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter order';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Please enter valid number';
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
                    hintText: '1 for main part, 2 for sub-part',
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
                SwitchListTile(
                  title: const Text('Requires Working'),
                  subtitle:
                      const Text('Does this part require showing working?'),
                  value: _requiresWorking,
                  onChanged: (value) {
                    setState(() {
                      _requiresWorking = value;
                    });
                  },
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
              : const Text('Save'),
        ),
      ],
    );
  }

  void _savePart() async {
    if (_formKey.currentState!.validate()) {
      final updateData = {
        'partNumber': _partNumberController.text,
        'partText': _partTextController.text,
        'marks': int.parse(_marksController.text),
        'hintText': _hintTextController.text.trim().isEmpty
            ? null
            : _hintTextController.text.trim(), // Include hint
        'orderIndex': int.parse(_orderIndexController.text),
        'nestingLevel': int.parse(_nestingLevelController.text),
        'requiresWorking': _requiresWorking,
      };

      await ref
          .read(adminControllerProvider.notifier)
          .updateQuestionPart(widget.part.id, updateData);

      if (mounted) {
        Navigator.of(context).pop();
        widget.onSaved?.call();
      }
    }
  }
}
