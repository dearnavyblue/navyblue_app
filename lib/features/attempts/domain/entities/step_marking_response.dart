// lib/features/attempts/domain/entities/step_marking_response.dart
import '../../../../brick/models/step_attempt.model.dart';

class StepMarkingResponse {
  final StepAttempt stepAttempt;

  const StepMarkingResponse({
    required this.stepAttempt,
  });

  factory StepMarkingResponse.fromJson(Map<String, dynamic> json) {
    return StepMarkingResponse(
      stepAttempt: StepAttempt.fromJson(json),
    );
  }
}
