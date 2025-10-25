// lib/features/admin/presentation/widgets/edit_solution_step_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navyblue_app/brick/models/solution_step.model.dart';
import '../providers/admin_presentation_providers.dart';

class EditSolutionStepDialog extends ConsumerStatefulWidget {
  final SolutionStep step;
  final VoidCallback? onSaved;

  const EditSolutionStepDialog({
    super.key,
    required this.step,
    this.onSaved,
  });

  @override
  ConsumerState<EditSolutionStepDialog> createState() =>
      _EditSolutionStepDialogState();
}

class _EditSolutionStepDialogState
    extends ConsumerState<EditSolutionStepDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _descriptionController;
  late TextEditingController _workingOutController;
  late TextEditingController _marksController;
  late TextEditingController _teachingNoteController;
  late TextEditingController _orderIndexController;
  late bool _isCriticalStep;

  @override
  void initState() {
    super.initState();
    _descriptionController =
        TextEditingController(text: widget.step.description);
    _workingOutController =
        TextEditingController(text: widget.step.workingOut ?? '');
    _marksController =
        TextEditingController(text: widget.step.marksForThisStep.toString());
    _teachingNoteController =
        TextEditingController(text: widget.step.teachingNote ?? '');
    _orderIndexController =
        TextEditingController(text: widget.step.orderIndex.toString());
    _isCriticalStep = widget.step.isCriticalStep;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _workingOutController.dispose();
    _marksController.dispose();
    _teachingNoteController.dispose();
    _orderIndexController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final adminState = ref.watch(adminControllerProvider);

    return AlertDialog(
      title: Text('Edit Solution Step ${widget.step.stepNumber}'),
      content: SizedBox(
        width: 600,
        height: 450, // Reduced height since no hint field
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Step Description',
                    hintText: 'What is done in this step',
                  ),
                  maxLines: 2,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter step description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _workingOutController,
                  decoration: const InputDecoration(
                    labelText: 'Working Out',
                    hintText: 'Mathematical working or calculations',
                  ),
                  maxLines: 4,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _marksController,
                        decoration: const InputDecoration(
                          labelText: 'Marks for This Step',
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
                  controller: _teachingNoteController,
                  decoration: const InputDecoration(
                    labelText: 'Teaching Note (Optional)',
                    hintText: 'Pedagogical guidance for educators',
                    helperText:
                        'Notes to help teachers understand and teach this step',
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                Card(
                  color: Colors.red.withValues(alpha: 0.05),
                  child: SwitchListTile(
                    title: const Text('Critical Step'),
                    subtitle: const Text(
                        'Mark as a critical step that students must get right'),
                    value: _isCriticalStep,
                    onChanged: (value) {
                      setState(() {
                        _isCriticalStep = value;
                      });
                    },
                    secondary: Icon(
                      _isCriticalStep
                          ? Icons.priority_high
                          : Icons.info_outline,
                      color: _isCriticalStep
                          ? Colors.red
                          : theme.colorScheme.onSurfaceVariant,
                    ),
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
          onPressed: adminState.isLoading ? null : _saveStep,
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

  void _saveStep() async {
    if (_formKey.currentState!.validate()) {
      final updateData = {
        'description': _descriptionController.text,
        'workingOut': _workingOutController.text.isEmpty
            ? null
            : _workingOutController.text,
        'marksForThisStep': int.parse(_marksController.text),
        'teachingNote': _teachingNoteController.text.isEmpty
            ? null
            : _teachingNoteController.text,
        'orderIndex': int.parse(_orderIndexController.text),
        'isCriticalStep': _isCriticalStep,
        // Note: No hintText here - hints are now at part/question level
      };

      await ref
          .read(adminControllerProvider.notifier)
          .updateSolutionStep(widget.step.id, updateData);

      if (mounted) {
        Navigator.of(context).pop();
        widget.onSaved?.call();
      }
    }
  }
}
