// lib/core/routing/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navyblue_app/features/attempts/presentation/screens/attempt_screen.dart';
import 'package:navyblue_app/features/attempts/presentation/screens/user_attempts_screen.dart';
import 'package:navyblue_app/features/attempts/presentation/screens/active_attempts_screen.dart';
import 'package:navyblue_app/features/home/presentation/screens/home_screen.dart';
import 'package:navyblue_app/features/papers/presentation/screens/papers_screen.dart';
import '../../features/admin/presentation/screens/admin_dashboard_screen.dart';
import '../../features/auth/presentation/providers/auth_presentation_providers.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../constants/app_constants.dart';
import '../screens/more/more_screen.dart';
import '../screens/splash/splash_screen.dart';
import 'scaffold_with_bottom_nav.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _homeNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'home');
final _papersNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'papers');
final _moreNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'more');

enum AppRoute {
  splash,
  login,
  register,
  home,
  papers,
  more,
  attempt,
  userAttempts,
  admin,
}

// Store auth state to avoid ref.read in redirect
class AuthRouterState {
  final bool isLoggedIn;
  final bool isAdmin;
  final bool isInitialized;

  const AuthRouterState({
    required this.isLoggedIn,
    required this.isAdmin,
    required this.isInitialized,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthRouterState &&
          runtimeType == other.runtimeType &&
          isLoggedIn == other.isLoggedIn &&
          isAdmin == other.isAdmin &&
          isInitialized == other.isInitialized;

  @override
  int get hashCode =>
      isLoggedIn.hashCode ^ isAdmin.hashCode ^ isInitialized.hashCode;
}

class AuthRouterNotifier extends ChangeNotifier {
  AuthRouterState _state = const AuthRouterState(
    isLoggedIn: false,
    isAdmin: false,
    isInitialized: false,
  );

  AuthRouterState get state => _state;

  void updateState(AuthRouterState newState) {
    if (_state != newState) {
      _state = newState;
      print(
          'Auth router state updated: isLoggedIn=${newState.isLoggedIn}, isAdmin=${newState.isAdmin}, isInitialized=${newState.isInitialized}');
      notifyListeners(); // This triggers GoRouter to re-evaluate redirect
    }
  }
}

final authRouterNotifierProvider =
    ChangeNotifierProvider<AuthRouterNotifier>((ref) {
  final notifier = AuthRouterNotifier();

  // Listen to auth state changes and update the notifier
  ref.listen(authControllerProvider, (previous, next) {
    try {
      notifier.updateState(AuthRouterState(
        isLoggedIn: next.isLoggedIn,
        isAdmin: next.isAdmin,
        isInitialized: next.isInitialized,
      ));
    } catch (e) {
      print('Auth router state update error: $e');
      // Keep existing state on error
    }
  }, fireImmediately: true);

  return notifier;
});

final goRouterProvider = Provider<GoRouter>((ref) {
  // Get the auth notifier to use as refreshListenable
  final authNotifier = ref.watch(authRouterNotifierProvider);

  return GoRouter(
    initialLocation: AppConstants.splashRoute,
    navigatorKey: _rootNavigatorKey,
    debugLogDiagnostics: true,
    refreshListenable:
        authNotifier, // CRITICAL: Makes router refresh when auth changes
    redirect: (context, state) {
      try {
        // Use the notifier's cached state instead of reading directly
        final authState = authNotifier.state;
        final path = state.uri.path;

        print(
            'Router redirect: path=$path, isLoggedIn=${authState.isLoggedIn}, isAdmin=${authState.isAdmin}, isInitialized=${authState.isInitialized}');

        // Wait for initialization
        if (!authState.isInitialized) {
          return path == AppConstants.splashRoute
              ? null
              : AppConstants.splashRoute;
        }

        final isLoggedIn = authState.isLoggedIn;
        final isAdmin = authState.isAdmin;

        // After initialization, redirect away from splash
        if (path == AppConstants.splashRoute) {
          return isLoggedIn
              ? (isAdmin ? '/admin' : AppConstants.homeRoute)
              : AppConstants.loginRoute;
        }

        // Redirect to login if not logged in and not on auth routes
        if (!isLoggedIn && !_isAuthRoute(path)) {
          return AppConstants.loginRoute;
        }

        // Redirect logged-in users away from auth routes
        if (isLoggedIn && _isAuthRoute(path)) {
          return isAdmin ? '/admin' : AppConstants.homeRoute;
        }

        // Protect admin routes
        if (path.startsWith('/admin') && !isAdmin) {
          return isLoggedIn ? AppConstants.homeRoute : AppConstants.loginRoute;
        }

        return null;
      } catch (e) {
        print('Router redirect error: $e');
        return AppConstants.splashRoute;
      }
    },
    routes: [
      GoRoute(
        path: AppConstants.splashRoute,
        name: AppRoute.splash.name,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppConstants.loginRoute,
        name: AppRoute.login.name,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppConstants.registerRoute,
        name: AppRoute.register.name,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/admin',
        name: AppRoute.admin.name,
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            ScaffoldWithBottomNav(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            navigatorKey: _homeNavigatorKey,
            routes: [
              GoRoute(
                path: AppConstants.homeRoute,
                name: AppRoute.home.name,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _papersNavigatorKey,
            routes: [
              GoRoute(
                path: AppConstants.papersRoute,
                name: AppRoute.papers.name,
                builder: (context, state) => const PapersScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _moreNavigatorKey,
            routes: [
              GoRoute(
                path: '/more',
                name: AppRoute.more.name,
                builder: (context, state) => const MoreScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/attempt/:paperId',
        name: AppRoute.attempt.name,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final paperId = state.pathParameters['paperId']!;
          final mode = state.uri.queryParameters['mode'] ?? 'practice';
          final resumeAttemptId = state.uri.queryParameters['resume'];

          return AttemptScreen(
            paperId: paperId,
            mode: mode,
            resumeAttemptId: resumeAttemptId,
          );
        },
      ),
      GoRoute(
        path: '/user-attempts',
        name: AppRoute.userAttempts.name,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const UserAttemptsScreen(),
      ),
      GoRoute(
        path: '/user-attempts/in-progress',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ActiveAttemptsScreen(),
      ),
    ],
  );
});

bool _isAuthRoute(String path) {
  return path == AppConstants.loginRoute || path == AppConstants.registerRoute;
}
