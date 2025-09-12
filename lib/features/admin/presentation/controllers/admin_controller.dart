// lib/features/admin/presentation/controllers/admin_controller.dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navyblue_app/brick/models/exam_paper.model.dart';
import 'package:navyblue_app/brick/models/question.model.dart';
import 'package:navyblue_app/brick/models/user.model.dart';
import 'package:navyblue_app/features/admin/domain/providers/admin_use_case_providers.dart';

class AdminState {
  final List<ExamPaper> papers;
  final List<User> users;
  final List<Question> currentPaperQuestions;
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? currentPaperJson;
  final Map<String, dynamic>? currentQuestionsJson;
  final Map<String, String> imageUploads;
  final Map<String, String> questionImageUploads;

  const AdminState({
    this.papers = const [],
    this.users = const [],
    this.currentPaperQuestions = const [],
    this.isLoading = false,
    this.error,
    this.currentPaperJson,
    this.currentQuestionsJson,
    this.imageUploads = const {},
    this.questionImageUploads = const {},
  });

  AdminState copyWith({
    List<ExamPaper>? papers,
    List<User>? users,
    List<Question>? currentPaperQuestions,
    bool? isLoading,
    String? error,
    Map<String, dynamic>? currentPaperJson,
    Map<String, dynamic>? currentQuestionsJson,
    Map<String, String>? imageUploads,
    Map<String, String>? questionImageUploads,
  }) {
    return AdminState(
      papers: papers ?? this.papers,
      users: users ?? this.users,
      currentPaperQuestions:
          currentPaperQuestions ?? this.currentPaperQuestions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentPaperJson: currentPaperJson ?? this.currentPaperJson,
      currentQuestionsJson: currentQuestionsJson ?? this.currentQuestionsJson,
      imageUploads: imageUploads ?? this.imageUploads,
      questionImageUploads: questionImageUploads ?? this.questionImageUploads,
    );
  }
}

class AdminController extends StateNotifier<AdminState> {
  final Ref _ref;

  AdminController(this._ref) : super(const AdminState());

  Future<void> loadPapers() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final getPapersUseCase = _ref.read(getPapersUseCaseProvider);
      final result = await getPapersUseCase();

      if (result.isSuccess) {
        state = state.copyWith(
          papers: result.data!.papers,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: result.error,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load papers: ${e.toString()}',
      );
    }
  }

  Future<void> loadPaperQuestions(String paperId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final getPaperQuestionsUseCase =
          _ref.read(getPaperQuestionsUseCaseProvider);
      final result = await getPaperQuestionsUseCase(paperId);

      if (result.isSuccess) {
        state = state.copyWith(
          currentPaperQuestions: result.data!,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: result.error,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load questions: ${e.toString()}',
      );
    }
  }

  Future<void> createPaper() async {
    if (state.currentPaperJson == null) {
      state = state.copyWith(error: 'No paper JSON loaded');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final createPaperUseCase = _ref.read(createPaperUseCaseProvider);
      final result = await createPaperUseCase(state.currentPaperJson!);

      if (result.isSuccess) {
        state = state.copyWith(
          papers: [...state.papers, result.data!],
          isLoading: false,
          currentPaperJson: null,
          imageUploads: {},
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: result.error,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to create paper: ${e.toString()}',
      );
    }
  }

  Future<void> deletePaper(String paperId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final deletePaperUseCase = _ref.read(deletePaperUseCaseProvider);
      final result = await deletePaperUseCase(paperId);

      if (result.isSuccess) {
        final updatedPapers =
            state.papers.where((p) => p.id != paperId).toList();
        state = state.copyWith(papers: updatedPapers, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false, error: result.error);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to delete paper: ${e.toString()}',
      );
    }
  }

  Future<void> togglePaperStatus(String paperId) async {
    final paper = state.papers.firstWhere((p) => p.id == paperId);
    final newStatus = !paper.isActive;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final updateStatusUseCase = _ref.read(updatePaperStatusUseCaseProvider);
      final result = await updateStatusUseCase(paperId, newStatus);

      if (result.isSuccess) {
        final updatedPapers = state.papers.map((p) {
          return p.id == paperId ? p.copyWith(isActive: newStatus) : p;
        }).toList();

        state = state.copyWith(papers: updatedPapers, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false, error: result.error);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to update paper status: ${e.toString()}',
      );
    }
  }

  Future<void> addQuestionsToPaper(String paperId) async {
    if (state.currentQuestionsJson == null) {
      state = state.copyWith(error: 'No questions JSON loaded');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final addQuestionsUseCase = _ref.read(addQuestionsToPaperUseCaseProvider);
      final questionsArray =
          state.currentQuestionsJson!['questions'] as List<dynamic>;
      final questionsData = questionsArray.cast<Map<String, dynamic>>();

      final result = await addQuestionsUseCase(paperId, questionsData);

      if (result.isSuccess) {
        await loadPapers();
        state = state.copyWith(
          isLoading: false,
          currentQuestionsJson: null,
          questionImageUploads: {},
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: result.error,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to add questions: ${e.toString()}',
      );
    }
  }

  Future<void> deleteQuestion(String questionId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final deleteQuestionUseCase = _ref.read(deleteQuestionUseCaseProvider);
      final result = await deleteQuestionUseCase(questionId);

      if (result.isSuccess) {
        final updatedQuestions = state.currentPaperQuestions
            .where((q) => q.id != questionId)
            .toList();
        state = state.copyWith(
          currentPaperQuestions: updatedQuestions,
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false, error: result.error);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to delete question: ${e.toString()}',
      );
    }
  }

  Future<void> createQuestionPart(
      String questionId, Map<String, dynamic> partData) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final createPartUseCase = _ref.read(createQuestionPartUseCaseProvider);
      final result = await createPartUseCase(questionId, partData);

      if (result.isSuccess) {
        await _reloadCurrentQuestions();
      } else {
        state = state.copyWith(isLoading: false, error: result.error);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to create question part: ${e.toString()}',
      );
    }
  }

  Future<void> updateQuestionPart(
      String partId, Map<String, dynamic> updateData) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final updatePartUseCase = _ref.read(updateQuestionPartUseCaseProvider);
      final result = await updatePartUseCase(partId, updateData);

      if (result.isSuccess) {
        await _reloadCurrentQuestions();
      } else {
        state = state.copyWith(isLoading: false, error: result.error);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to update question part: ${e.toString()}',
      );
    }
  }

  Future<void> deleteQuestionPart(String partId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final deletePartUseCase = _ref.read(deleteQuestionPartUseCaseProvider);
      final result = await deletePartUseCase(partId);

      if (result.isSuccess) {
        await _reloadCurrentQuestions();
      } else {
        state = state.copyWith(isLoading: false, error: result.error);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to delete question part: ${e.toString()}',
      );
    }
  }

  Future<void> createSolutionStep(
      String partId, Map<String, dynamic> stepData) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final createStepUseCase = _ref.read(createSolutionStepUseCaseProvider);
      final result = await createStepUseCase(partId, stepData);

      if (result.isSuccess) {
        await _reloadCurrentQuestions();
      } else {
        state = state.copyWith(isLoading: false, error: result.error);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to create solution step: ${e.toString()}',
      );
    }
  }

  Future<void> createDirectSolutionStep(
      String questionId, Map<String, dynamic> stepData) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final createDirectStepUseCase =
          _ref.read(createDirectSolutionStepUseCaseProvider);
      final result = await createDirectStepUseCase(questionId, stepData);

      if (result.isSuccess) {
        await _reloadCurrentQuestions();
      } else {
        state = state.copyWith(isLoading: false, error: result.error);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to create direct solution step: ${e.toString()}',
      );
    }
  }

  Future<void> updateSolutionStep(
      String stepId, Map<String, dynamic> updateData) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final updateStepUseCase = _ref.read(updateSolutionStepUseCaseProvider);
      final result = await updateStepUseCase(stepId, updateData);

      if (result.isSuccess) {
        await _reloadCurrentQuestions();
      } else {
        state = state.copyWith(isLoading: false, error: result.error);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to update solution step: ${e.toString()}',
      );
    }
  }

  Future<void> deleteSolutionStep(String stepId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final deleteStepUseCase = _ref.read(deleteSolutionStepUseCaseProvider);
      final result = await deleteStepUseCase(stepId);

      if (result.isSuccess) {
        await _reloadCurrentQuestions();
      } else {
        state = state.copyWith(isLoading: false, error: result.error);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to delete solution step: ${e.toString()}',
      );
    }
  }

  Future<void> loadUsers({String? search, String? grade, String? role}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final getUsersUseCase = _ref.read(getUsersUseCaseProvider);
      final result = await getUsersUseCase(
        search: search,
        grade: grade,
        role: role,
      );

      if (result.isSuccess) {
        state = state.copyWith(
          users: result.data!.users,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: result.error,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load users: ${e.toString()}',
      );
    }
  }

  Future<void> updateUserRole(String userId, String newRole) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final updateUserUseCase = _ref.read(updateUserUseCaseProvider);
      final result = await updateUserUseCase(userId, role: newRole);

      if (result.isSuccess) {
        final updatedUsers = state.users.map((u) {
          return u.id == userId ? u.copyWith(role: newRole) : u;
        }).toList();

        state = state.copyWith(users: updatedUsers, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false, error: result.error);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to update user role: ${e.toString()}',
      );
    }
  }

  Future<void> updateUserEmailVerification(
      String userId, bool isVerified) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final updateUserUseCase = _ref.read(updateUserUseCaseProvider);
      final result =
          await updateUserUseCase(userId, isEmailVerified: isVerified);

      if (result.isSuccess) {
        final updatedUsers = state.users.map((u) {
          return u.id == userId ? u.copyWith(isEmailVerified: isVerified) : u;
        }).toList();

        state = state.copyWith(users: updatedUsers, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false, error: result.error);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to update user verification: ${e.toString()}',
      );
    }
  }

  Future<void> uploadImageForPath(
      String path, Uint8List imageData, String fileName) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final uploadImageUseCase = _ref.read(uploadImageUseCaseProvider);
      final result = await uploadImageUseCase(imageData, fileName);

      if (result.isSuccess) {
        _updateJsonWithImageUrl(
            state.currentPaperJson!, path, result.url!, 'paper');

        final updatedUploads = Map<String, String>.from(state.imageUploads);
        updatedUploads[path] = result.url!;

        state = state.copyWith(
          imageUploads: updatedUploads,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: result.error,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to upload image: ${e.toString()}',
      );
    }
  }

  Future<void> uploadImageForQuestionPath(
      String path, Uint8List imageData, String fileName) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final uploadImageUseCase = _ref.read(uploadImageUseCaseProvider);
      final result = await uploadImageUseCase(imageData, fileName);

      if (result.isSuccess) {
        _updateJsonWithImageUrl(
            state.currentQuestionsJson!, path, result.url!, 'questions');

        final updatedUploads =
            Map<String, String>.from(state.questionImageUploads);
        updatedUploads[path] = result.url!;

        state = state.copyWith(
          questionImageUploads: updatedUploads,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: result.error,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to upload question image: ${e.toString()}',
      );
    }
  }

  void loadPaperJson(String jsonString) {
    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      state = state.copyWith(
        currentPaperJson: json,
        imageUploads: {},
        error: null,
      );
    } catch (e) {
      state = state.copyWith(error: 'Invalid JSON: ${e.toString()}');
    }
  }

  void loadQuestionsJson(String jsonString) {
    try {
      final json = jsonDecode(jsonString);
      if (json is List) {
        state = state.copyWith(
          currentQuestionsJson: {'questions': json},
          questionImageUploads: {},
          error: null,
        );
      } else {
        state = state.copyWith(error: 'Questions JSON must be an array');
      }
    } catch (e) {
      state = state.copyWith(error: 'Invalid JSON: ${e.toString()}');
    }
  }

  List<String> getImageUploadPaths() {
    if (state.currentPaperJson == null) return [];
    return _extractImagePaths(state.currentPaperJson!);
  }

  List<String> getQuestionImagePaths() {
    if (state.currentQuestionsJson == null) return [];
    return _extractImagePaths(state.currentQuestionsJson!);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void clearCurrentPaper() {
    state = state.copyWith(
      currentPaperJson: null,
      imageUploads: {},
    );
  }

  void clearCurrentQuestions() {
    state = state.copyWith(
      currentQuestionsJson: null,
      questionImageUploads: {},
    );
  }

  void clearCurrentPaperQuestions() {
    state = state.copyWith(currentPaperQuestions: []);
  }

  Future<void> _reloadCurrentQuestions() async {
    if (state.currentPaperQuestions.isNotEmpty) {
      final paperId = state.currentPaperQuestions.first.paperId;
      await loadPaperQuestions(paperId);
    } else {
      state = state.copyWith(isLoading: false);
    }
  }

  List<String> _extractImagePaths(Map<String, dynamic> json) {
    final paths = <String>[];

    try {
      final questionsData = json['questions'];
      if (questionsData == null) return paths;

      List<dynamic> questions = [];
      if (questionsData is List) {
        questions = questionsData;
      } else if (questionsData is Map) {
        questions = [questionsData];
      }

      for (int i = 0; i < questions.length; i++) {
        final question = questions[i] as Map<String, dynamic>;

        final contextImages = question['contextImages'] as List? ?? [];
        if (contextImages.isEmpty) {
          paths.add('questions[$i].contextImages');
        }

        final partsData = question['parts'];
        List<dynamic> parts = [];

        if (partsData is List) {
          parts = partsData;
        } else if (partsData is Map) {
          parts = [partsData];
        }

        for (int j = 0; j < parts.length; j++) {
          final part = parts[j] as Map<String, dynamic>;

          final partImages = part['partImages'] as List? ?? [];
          if (partImages.isEmpty) {
            paths.add('questions[$i].parts[$j].partImages');
          }

          final solutionStepsData = part['solutionSteps'];
          List<dynamic> solutionSteps = [];

          if (solutionStepsData is List) {
            solutionSteps = solutionStepsData;
          } else if (solutionStepsData is Map) {
            solutionSteps = [solutionStepsData];
          }

          for (int k = 0; k < solutionSteps.length; k++) {
            final step = solutionSteps[k] as Map<String, dynamic>;

            final solutionImages = step['solutionImages'] as List? ?? [];
            if (solutionImages.isEmpty) {
              paths.add(
                  'questions[$i].parts[$j].solutionSteps[$k].solutionImages');
            }
          }
        }
      }
    } catch (e) {
      // Silently handle extraction errors
    }

    return paths;
  }

  void _updateJsonWithImageUrl(Map<String, dynamic> targetJson, String path,
      String url, String context) {
    try {
      final json = Map<String, dynamic>.from(targetJson);
      final pathParts = path.split('.');
      dynamic current = json;

      for (int i = 0; i < pathParts.length - 1; i++) {
        final part = pathParts[i];
        if (part.contains('[') && part.contains(']')) {
          final key = part.substring(0, part.indexOf('['));
          final index = int.parse(
              part.substring(part.indexOf('[') + 1, part.indexOf(']')));

          if (current[key] == null) {
            current[key] = [];
          }
          if (current[key] is! List) {
            return;
          }
          if (index >= current[key].length) {
            return;
          }

          current = current[key][index];
        } else {
          if (current[part] == null) {
            current[part] = {};
          }
          current = current[part];
        }

        if (current == null) {
          return;
        }
      }

      final finalPart = pathParts.last;
      if (current is Map<String, dynamic>) {
        if (current[finalPart] == null) {
          current[finalPart] = [];
        }
        if (current[finalPart] is List) {
          current[finalPart] = [url];
        }
      }

      if (context == 'paper') {
        state = state.copyWith(currentPaperJson: json);
      } else {
        state = state.copyWith(currentQuestionsJson: json);
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to update JSON with image URL');
    }
  }
}
