// lib/features/admin/presentation/widgets/add_solution_step_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navyblue_app/brick/models/question_part.model.dart';
import 'package:navyblue_app/brick/models/question.model.dart';
import '../providers/admin_presentation_providers.dart';

class AddSolutionStepDialog extends ConsumerStatefulWidget {
  final QuestionPart? part;
  final String? questionId;
  final Question? question;
  final VoidCallback? onSaved;

  const AddSolutionStepDialog({
    super.key,
    this.part,
    this.questionId,
    this.question,
    this.onSaved,
  }) : assert(part != null || (questionId != null && question != null),
            'Either part must be provided, or both questionId and question must be provided');

  // Named constructor for part-based solution steps
  const AddSolutionStepDialog.forPart({
    super.key,
    required QuestionPart this.part,
    this.onSaved,
  })  : questionId = null,
        question = null;

  // Named constructor for direct question steps
  const AddSolutionStepDialog.forDirectQuestion({
    super.key,
    required String questionId,
    required Question question,
    this.onSaved,
  })  : part = null,
        questionId = questionId,
        question = question;

  @override
  ConsumerState<AddSolutionStepDialog> createState() =>
      _AddSolutionStepDialogState();
}

class _AddSolutionStepDialogState extends ConsumerState<AddSolutionStepDialog> {
  final _formKey = GlobalKey<FormState>();
  final _stepNumberController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _workingOutController = TextEditingController();
  final _marksController = TextEditingController();
  final _teachingNoteController = TextEditingController();
  final _orderIndexController = TextEditingController();
  bool _isCriticalStep = false;

  bool get _isDirectStep => widget.part == null;

  @override
  void initState() {
    super.initState();

    if (_isDirectStep) {
      // For direct question steps
      final existingSteps = widget.question!.solutionSteps.length;
      final nextStepNumber = existingSteps + 1;
      _stepNumberController.text = nextStepNumber.toString();
      _orderIndexController.text = existingSteps.toString();
    } else {
      // For part-based steps
      final existingSteps = widget.part!.solutionSteps.length;
      final nextStepNumber = existingSteps + 1;
      _stepNumberController.text = nextStepNumber.toString();
      _orderIndexController.text = existingSteps.toString();
    }
  }

  @override
  void dispose() {
    _stepNumberController.dispose();
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
      title: Text(_isDirectStep
          ? 'Add Direct Solution Step'
          : 'Add Solution Step to Part ${widget.part!.partNumber}'),
      content: SizedBox(
        width: 600,
        height: 500,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Context card - different for direct vs part-based steps
                if (_isDirectStep)
                  Card(
                    color: Colors.green.withOpacity(0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.lightbulb,
                                  color: Colors.green[700], size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Adding direct solution step',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Question ${widget.question!.questionNumber}: ${widget.question!.contextText}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Simple question • ${widget.question!.solutionSteps.length} existing steps',
                            style: theme.textTheme.labelSmall,
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Card(
                    color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Adding solution step to:',
                            style: theme.textTheme.labelMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Part ${widget.part!.partNumber}: ${widget.part!.partText}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${widget.part!.marks} marks • ${widget.part!.solutionSteps.length} existing steps',
                            style: theme.textTheme.labelSmall,
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 16),

                // Form fields
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        controller: _stepNumberController,
                        decoration: const InputDecoration(
                          labelText: 'Step Number *',
                          helperText: 'Step sequence',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter step number';
                          }
                          final step = int.tryParse(value);
                          if (step == null || step < 1) {
                            return 'Please enter valid step number (1 or higher)';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        controller: _orderIndexController,
                        decoration: const InputDecoration(
                          labelText: 'Order Index *',
                          helperText: 'Display order',
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
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        controller: _marksController,
                        decoration: const InputDecoration(
                          labelText: 'Marks *',
                          helperText: 'Marks for step',
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
                  ],
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Step Description *',
                    hintText: 'What is done in this step',
                    helperText:
                        'Brief description of what this step accomplishes',
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
                    labelText: 'Working Out (Optional)',
                    hintText: 'Mathematical working, calculations, or formulas',
                    helperText: 'Show the mathematical working for this step',
                  ),
                  maxLines: 4,
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
                  color: Colors.red.withOpacity(0.05),
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
          onPressed: adminState.isLoading ? null : _saveStep,
          child: adminState.isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Add Step'),
        ),
      ],
    );
  }

  void _saveStep() async {
    if (_formKey.currentState!.validate()) {
      final stepData = {
        'stepNumber': int.parse(_stepNumberController.text),
        'description': _descriptionController.text.trim(),
        'workingOut': _workingOutController.text.trim().isEmpty
            ? null
            : _workingOutController.text.trim(),
        'marksForThisStep': int.parse(_marksController.text),
        'teachingNote': _teachingNoteController.text.trim().isEmpty
            ? null
            : _teachingNoteController.text.trim(),
        'orderIndex': int.parse(_orderIndexController.text),
        'isCriticalStep': _isCriticalStep,
        'solutionImages': <String>[], // Empty initially
      };

      if (_isDirectStep) {
        // For direct question solution steps
        await ref
            .read(adminControllerProvider.notifier)
            .createDirectSolutionStep(widget.questionId!, stepData);
      } else {
        // For part-based solution steps
        await ref
            .read(adminControllerProvider.notifier)
            .createSolutionStep(widget.part!.id, stepData);
      }

      if (mounted && !ref.read(adminControllerProvider).isLoading) {
        Navigator.of(context).pop();
        widget.onSaved?.call();
      }
    }
  }
}
