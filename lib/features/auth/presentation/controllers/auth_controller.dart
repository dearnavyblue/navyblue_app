// lib/features/auth/presentation/controllers/auth_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navyblue_app/brick/models/user.model.dart';
import 'package:navyblue_app/core/providers/connectivity_providers.dart';
import '../../domain/providers/auth_use_case_providers.dart';
import '../../../../brick/repository.dart';

class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;
  final bool isInitialized;
  final bool isOffline;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isInitialized = false,
    this.isOffline = false,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
    bool? isInitialized,
    bool? isOffline,
    bool clearUser = false, // Add flag to explicitly clear user
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isInitialized: isInitialized ?? this.isInitialized,
      isOffline: isOffline ?? this.isOffline,
    );
  }

  bool get isLoggedIn {
    // Return false if not initialized yet
    if (!isInitialized) return false;
    if (user == null) return false;

    // User must have valid tokens to be considered logged in
    return user!.accessToken != null &&
        user!.tokenExpiresAt != null &&
        user!.isTokenValid;
  }

  bool get isAdmin {
    // Return false if not initialized yet
    if (!isInitialized) return false;
    return user?.isAdmin ?? false;
  }
}

class AuthController extends StateNotifier<AuthState> {
  final Ref _ref;
  final Repository _repository = Repository.instance;
  bool _initializationStarted = false;

  AuthController(this._ref) : super(const AuthState());

  Future<void> initialize() async {
    if (_initializationStarted) return;
    _initializationStarted = true;

    try {
      state = state.copyWith(isLoading: true);
      _setupConnectivityListener();
      await _loadUserFromLocal();
      unawaited(_syncUserWithServer());
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isInitialized: true,
        error: 'Initialization failed: ${e.toString()}',
      );
    }
  }

  void _setupConnectivityListener() {
    _ref.listen(connectivityProvider, (previous, next) {
      next.whenData((isOnline) {
        // Check if we're transitioning from offline to online BEFORE updating state
        final wasOffline = state.isOffline;

        // Always sync state with connectivity
        state = state.copyWith(isOffline: !isOnline);

        // Sync when coming back online (transitioning from offline to online)
        if (isOnline && wasOffline) {
          syncWhenOnline();
        }
      });
    });
  }

  @override
  set state(AuthState newState) {
    if (newState.isOffline != state.isOffline) {
      print(
          'AuthController: isOffline changed from ${state.isOffline} to ${newState.isOffline}');
      print('Stack trace: ${StackTrace.current}');
    }
    super.state = newState;
  }

  Future<void> _loadUserFromLocal() async {
    try {
      final users = await _repository.get<User>();
      final currentUser = users.isNotEmpty ? users.first : null;

      state = state.copyWith(
        user: currentUser,
        isLoading: false,
        isInitialized: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isInitialized: true,
      );
    }
  }

  Future<void> _syncUserWithServer() async {
    if (state.isOffline) return;

    try {
      final getCurrentUserUseCase = _ref.read(getCurrentUserUseCaseProvider);
      final serverUser = await getCurrentUserUseCase();

      if (serverUser != null) {
        await _repository.upsert<User>(serverUser);
        state = state.copyWith(user: serverUser);
        await _syncPendingUserChangesToServer();
      }
    } catch (e) {
      // Don't set offline state based on API failures
    }
  }

  Future<void> _syncPendingUserChangesToServer() async {
    try {
      final localUsers = await _repository.get<User>();
      final pendingUsers = localUsers.where((u) => u.needsSync).toList();

      for (final user in pendingUsers) {
        try {
          final syncedUser = user.copyWith(needsSync: false);
          await _repository.upsert<User>(syncedUser);

          if (state.user?.id == user.id) {
            state = state.copyWith(user: syncedUser);
          }
        } catch (e) {
          continue;
        }
      }
    } catch (e) {
      // Don't set offline state based on sync failures
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    if (state.isOffline) {
      state = state.copyWith(
        isLoading: false,
        error: 'No internet connection available',
      );
      return;
    }

    try {
      final loginUseCase = _ref.read(loginUseCaseProvider);
      final result = await loginUseCase(email: email, password: password);

      if (result.isSuccess) {
        await _repository.upsert<User>(result.user!);
        state = state.copyWith(
          user: result.user,
          isLoading: false,
          isInitialized: true,
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
        error: 'Login failed: ${e.toString()}',
      );
    }
  }

  Future<void> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String grade,
    required String province,
    required String syllabus,
    String? schoolName,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    if (state.isOffline) {
      state = state.copyWith(
        isLoading: false,
        error: 'No internet connection available',
      );
      return;
    }

    try {
      final registerUseCase = _ref.read(registerUseCaseProvider);
      final result = await registerUseCase(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        grade: grade,
        province: province,
        syllabus: syllabus,
        schoolName: schoolName,
      );

      if (result.isSuccess) {
        await _repository.upsert<User>(result.user!);
        state = state.copyWith(
          user: result.user,
          isLoading: false,
          isInitialized: true,
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
        error: 'Registration failed: ${e.toString()}',
      );
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);

    if (!state.isOffline) {
      try {
        final logoutUseCase = _ref.read(logoutUseCaseProvider);
        await logoutUseCase();
      } catch (e) {
        // Continue with local logout even if server logout fails
        print('Server logout failed: $e');
      }
    }

    try {
      // Delete user from local storage completely
      if (state.user != null) {
        await _repository.delete<User>(state.user!);
      }

      // CRITICAL: Set user to NULL (not a cleared user object)
      // This ensures isLoggedIn returns false
      state = const AuthState(
        user: null,
        isLoading: false,
        error: null,
        isInitialized: true,
        isOffline: false,
      );

      print(
          '✓ Logout complete - user set to null, isLoggedIn: ${state.isLoggedIn}');
    } catch (e) {
      print('Local logout error: $e');
      // Even if deletion fails, clear the user from state
      state = const AuthState(
        user: null,
        isLoading: false,
        error: null,
        isInitialized: true,
        isOffline: false,
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  Future<void> syncWhenOnline() async {
    if (state.isOffline) {
      await _syncUserWithServer();
    }
  }
}

// Helper function for non-blocking async calls
void unawaited(Future<void> future) {
  future.catchError((error) {
    print('Background operation failed: $error');
  });
}
