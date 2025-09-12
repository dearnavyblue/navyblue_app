// lib/features/auth/presentation/controllers/auth_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navyblue_app/brick/models/user.model.dart';
import 'package:navyblue_app/core/providers/connectivity_providers.dart';
import 'package:navyblue_app/core/services/connectivity_service.dart';
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
  }) {
    return AuthState(
      user: user ?? this.user,
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

    print('Auth initialization starting...');
    
    try {
      state = state.copyWith(isLoading: true);
      await _loadUserFromLocal();
      
      // Add connectivity listener AFTER initialization
      _setupConnectivityListener();
      
      // Don't wait for server sync
      unawaited(_syncUserWithServer());
      
      print('Auth controller initialized successfully');
    } catch (e) {
      print('Auth initialization error: $e');
      state = state.copyWith(
        isLoading: false,
        isInitialized: true,
        error: 'Initialization failed: ${e.toString()}',
        isOffline: true,
      );
    }
  }

    void _setupConnectivityListener() {
    _ref.listen(connectivityProvider, (previous, next) {
      next.whenData((isOnline) {
        if (isOnline && state.isOffline) {
          syncWhenOnline();
        } else if (!isOnline) {
          state = state.copyWith(isOffline: true);
        }
      });
    });
  }

  Future<void> _initialize() async {
    try {
      state = state.copyWith(isLoading: true);

      await _loadUserFromLocal();

      // Don't wait for server sync - do it in background
      unawaited(_syncUserWithServer());
    } catch (e) {
      print('Auth initialization error: $e');
      state = state.copyWith(
        isLoading: false,
        isInitialized: true,
        error: 'Initialization failed: ${e.toString()}',
        isOffline: true,
      );
    }
  }

  Future<void> _loadUserFromLocal() async {
    try {
      final users = await _repository.get<User>();
      final currentUser = users.isNotEmpty ? users.first : null;

      state = state.copyWith(
        user: currentUser,
        isLoading: false,
        isInitialized: true, // Mark as initialized after loading local data
        isOffline: true,
      );

      print(
          'Auth local load complete: isLoggedIn=${state.isLoggedIn}, isInitialized=${state.isInitialized}');
    } catch (e) {
      print('Auth local load error: $e');
      state = state.copyWith(
        isLoading: false,
        isInitialized: true, // Still mark as initialized even on error
        isOffline: true,
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
        state = state.copyWith(
          user: serverUser,
          isOffline: false,
        );

        await _syncPendingUserChangesToServer();
      } else {
        state = state.copyWith(isOffline: true);
      }
    } catch (e) {
      print('Auth server sync error: $e');
      state = state.copyWith(isOffline: true);
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
      state = state.copyWith(isOffline: true);
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    if (state.isOffline) {
      state = state.copyWith(
        isLoading: false,
        error: 'No internet connection available',
        isOffline: true,
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
          isInitialized: true, // Ensure initialized after login
          isOffline: false,
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
        isOffline: true,
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
        isOffline: true,
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
          isInitialized: true, // Ensure initialized after registration
          isOffline: false,
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
        isOffline: true,
      );
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);

    print('Starting logout process...');

    if (!state.isOffline) {
      try {
        final logoutUseCase = _ref.read(logoutUseCaseProvider);
        await logoutUseCase();
        print('Server logout completed');
      } catch (e) {
        print('Server logout failed, continuing with local logout: $e');
      }
    } else {
      print('Offline - skipping server logout');
    }

    // ALWAYS clear tokens locally - this is the critical part
    try {
      if (state.user != null) {
        // Create user with cleared tokens
        final clearedUser = state.user!.clearAuthTokens();

        // Update local storage
        await _repository.upsert<User>(clearedUser);

        // Update state with cleared user
        state = state.copyWith(
          user: clearedUser,
          isLoading: false,
          error: null,
        );

        print('Local logout completed. isLoggedIn: ${state.isLoggedIn}');
        print(
            'User tokens cleared: accessToken=${clearedUser.accessToken}, refreshToken=${clearedUser.refreshToken}');
      } else {
        state = state.copyWith(
          user: null,
          isLoading: false,
          error: null,
        );
        print('No user to clear, logout completed');
      }
    } catch (e) {
      print('Local token clearing failed, forcing logout: $e');
      // Force complete logout even if storage fails
      state = state.copyWith(
        user: null,
        isLoading: false,
        error: null,
      );
    }

    print('Logout process finished. Final isLoggedIn: ${state.isLoggedIn}');
  }

  Future<void> _clearAuthTokens() async {
    try {
      if (state.user != null) {
        final userWithoutTokens = state.user!.copyWith(
          accessToken: null,
          refreshToken: null,
          tokenExpiresAt: null,
          lastLoginAt: null,
        );
        await _repository.upsert<User>(userWithoutTokens);
      }
    } catch (e) {
      // Don't throw - logout should always succeed locally
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
