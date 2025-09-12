// lib/features/attempts/domain/repositories/attempts_repository.dart
import 'package:navyblue_app/features/attempts/domain/entities/user_attempts_response.dart';

import '../entities/attempt_result.dart';
import '../entities/attempt_config.dart';
import '../entities/attempt_response.dart';
import '../entities/step_marking_response.dart';
import '../entities/attempt_progress.dart';
import '../../../../brick/models/student_attempt.model.dart';

abstract class AttemptsRepository {
  Future<AttemptResult<AttemptResponse>> createAttempt(AttemptConfig config);
  
Future<AttemptResult<UserAttemptsResponse>> getUserAttempts({
  int? page,
  int? limit,
  String? status,
});
  
  Future<AttemptResult<StudentAttempt>> getAttempt(String attemptId);
  
  Future<AttemptResult<StepMarkingResponse>> markStep({
    required String attemptId,
    required String stepId,
    required String status,
  });
  
  Future<AttemptResult<AttemptProgress>> getAttemptProgress(String attemptId);
  
  Future<AttemptResult<StudentAttempt>> completeAttempt({
    required String attemptId,
    bool autoSubmitted = false,
  });
}