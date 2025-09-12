// lib/features/attempts/domain/entities/attempt_config.dart
class AttemptConfig {
  final String paperId;
  final String mode; // PRACTICE or EXAM
  final bool enableHints;
  final int? durationMinutes;

  const AttemptConfig({
    required this.paperId,
    required this.mode,
    this.enableHints = true,
    this.durationMinutes,
  });

  factory AttemptConfig.practice(String paperId) {
    return AttemptConfig(
      paperId: paperId,
      mode: 'PRACTICE',
      enableHints: true,
    );
  }

  factory AttemptConfig.exam(String paperId, int durationMinutes) {
    return AttemptConfig(
      paperId: paperId,
      mode: 'EXAM',
      enableHints: false,
      durationMinutes: durationMinutes,
    );
  }

  bool get isPracticeMode => mode == 'PRACTICE';
  bool get isExamMode => mode == 'EXAM';
}