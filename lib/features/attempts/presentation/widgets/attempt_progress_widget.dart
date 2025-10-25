// lib/features/attempts/presentation/widgets/attempt_progress_widget.dart
import 'package:flutter/material.dart';
import '../../domain/entities/attempt_progress.dart';

class AttemptProgressWidget extends StatelessWidget {
  final AttemptProgress progress;

  const AttemptProgressWidget({
    super.key,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          Text(
            'Progress',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          _buildProgressChip(
              context, '${progress.correctSteps} correct', Colors.green),
          const SizedBox(width: 8),
          _buildProgressChip(
              context, '${progress.markedSteps} attempted', Colors.blue),
          const SizedBox(width: 8),
          _buildProgressChip(
              context, '${progress.totalSteps} total', Colors.grey),
        ],
      ),
    );
  }

  Widget _buildProgressChip(
      BuildContext context, String text, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: color[700],
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
