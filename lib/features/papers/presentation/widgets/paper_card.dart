// lib/features/papers/presentation/widgets/paper_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:navyblue_app/core/theme/app_theme.dart';
import '../../../../core/widgets/pill.dart';
import '../../../attempts/domain/entities/attempt_config.dart';
import '../../../auth/presentation/providers/auth_presentation_providers.dart';
import '../../../attempts/presentation/providers/attempts_presentation_providers.dart';
import '../controllers/papers_controller.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/constants/app_constants.dart';

class PaperCard extends ConsumerWidget {
  final PaperAvailability paperAvailability;
  final VoidCallback? onTap;

  const PaperCard({
    super.key,
    required this.paperAvailability,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authState = ref.watch(authControllerProvider);
    final paper = paperAvailability.paper;

    // Get province color from theme extension
    final provinceColors = theme.extension<ProvinceColors>();
    final provinceColor =
        provinceColors?.getColor(paper.province) ?? const Color(0xFF95BBC4);

    return Card(
      elevation: 2,
      color: provinceColor, // Dynamic color based on province
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row - Text on left, Image on right
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left side - Text content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top small text - Marks and duration
                        Text(
                          _buildTopLine(paper),
                          style: const TextStyle(
                            fontSize: 9.35,
                            height: 1.4,
                            color: Color(0x82000000),
                          ),
                        ),

                        const SizedBox(height: 3),

                        // Subject name (large, bold)
                        Text(
                          AppConfig.getSubjectDisplayName(paper.subject),
                          style: const TextStyle(
                            fontSize: 17.35,
                            height: 1.4,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),

                        // Paper details - Year, Term, Paper, Province
                        Text(
                          _buildPaperDetails(paper),
                          style: const TextStyle(
                            fontSize: 17.35,
                            height: 1.4,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Right side - Small thumbnail image
                  Container(
                    width: 56,
                    height: 75,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 4.34,
                          offset: const Offset(0, 4.34),
                        ),
                      ],
                      image: const DecorationImage(
                        image: AssetImage(AppConstants.pastPaperThumbnailPath),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Bottom Row - Action Buttons
              _buildActionButtons(context, ref, authState, theme),
            ],
          ),
        ),
      ),
    );
  }

  String _buildTopLine(dynamic paper) {
    // Format: Marks • Duration (e.g., "150 marks • 3 hours")
    final marks = paper.totalMarks != null ? '${paper.totalMarks} marks' : '';
    final duration = _formatDuration(paper.durationMinutes);

    if (marks.isEmpty) {
      return duration;
    }

    return '$marks • $duration';
  }

  String _formatDuration(int minutes) {
    if (minutes >= 60) {
      final hours = minutes / 60;
      if (hours == hours.toInt()) {
        return '${hours.toInt()} ${hours.toInt() == 1 ? 'hour' : 'hours'}';
      }
      return '${hours.toStringAsFixed(1)} hours';
    }
    return '$minutes min';
  }

  String _buildPaperDetails(dynamic paper) {
    // Format: {year} {examPeriod} {paperType} - {Province Abbreviation}
    // Example: "2024 November P1 - KZN"
    final provinceAbbr =
        AppConfig.getProvinceAbbreviation(paper.province ?? '');
    final examPeriod = AppConfig.getExamPeriodDisplayName(paper.examPeriod);
    final paperType = AppConfig.getPaperTypeDisplayName(paper.paperType);

    // Build the string with parts that exist
    final parts = <String>[];
    parts.add(paper.year.toString());
    if (examPeriod.isNotEmpty) parts.add(examPeriod);
    if (paperType.isNotEmpty) parts.add(paperType);

    final mainPart = parts.join(' ');

    // Add province if available
    if (provinceAbbr.isNotEmpty) {
      return '$mainPart - $provinceAbbr';
    }

    return mainPart;
  }

  Widget _buildActionButtons(
      BuildContext context, WidgetRef ref, dynamic authState, ThemeData theme) {
    if (!authState.isLoggedIn) {
      return InkWell(
        onTap: () => _requireLogin(context),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.login, size: 17, color: Colors.black),
              SizedBox(width: 8),
              Text(
                'LOGIN TO START',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Determine which buttons to show
    final showPractice = paperAvailability.canStartPractice;
    final showExam = paperAvailability.canStartExam;

    if (!showPractice && !showExam) {
      return const Pill(
        label: 'All attempts used',
        variant: PillVariant.subtle,
      );
    }

    // Two separate rounded button containers
    return Row(
      children: [
        if (showPractice)
          Expanded(
            child: Pill(
              label: 'Start Practice',
              variant: PillVariant.subtle,
              leading: const Icon(Icons.psychology_outlined, size: 17.35),
              onTap: () => _startAttempt(
                context,
                ref,
                AttemptConfig.practice(paperAvailability.paper.id),
              ),
            ),
          ),
        if (showPractice && showExam) const SizedBox(width: 12),
        if (showExam)
          Expanded(
            child: Pill(
              label: 'Start Exam',
              variant: PillVariant.subtle,
              leading: const Icon(Icons.timer_outlined, size: 17.35),
              onTap: () => _startAttempt(
                context,
                ref,
                AttemptConfig.exam(
                  paperAvailability.paper.id,
                  paperAvailability.paper.durationMinutes,
                ),
              ),
            ),
          ),
      ],
    );
  }

  // CRITICAL: Updated to await navigation and refresh on return
  Future<void> _startAttempt(
      BuildContext context, WidgetRef ref, AttemptConfig config) async {
    // Navigate and wait for return
    await context.push(
        '/attempt/${paperAvailability.paper.id}?mode=${config.mode.toLowerCase()}');

    // When we return, refresh the attempts list
    if (context.mounted) {
      await ref.read(userAttemptsControllerProvider.notifier).refreshAttempts();
    }
  }

  void _requireLogin(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Required'),
        content: const Text('Please login to start attempting papers.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/login');
            },
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }
}
