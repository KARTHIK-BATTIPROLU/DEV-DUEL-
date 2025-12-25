import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/app_constants.dart';
import '../core/constants/route_constants.dart';
import '../presentation/screens/splash_screen.dart';
import '../presentation/screens/login_screen.dart';
import '../presentation/screens/register_screen.dart';
import '../presentation/screens/student_home_screen.dart';
import '../presentation/screens/teacher_home_screen.dart';
import '../services/auth_service.dart';
import '../services/hive_service.dart';

/// Application Router
/// Role-based navigation for Career Compass

class AppRouter {
  static final AuthService _authService = AuthService();

  static GoRouter get router => _router;

  static final GoRouter _router = GoRouter(
    initialLocation: RouteConstants.splash,
    debugLogDiagnostics: true,

    redirect: (context, state) {
      final isAuthenticated = _authService.isAuthenticated;
      final isLoggingIn = state.matchedLocation == RouteConstants.login;
      final isRegistering = state.matchedLocation == RouteConstants.register;
      final isSplash = state.matchedLocation == RouteConstants.splash;

      // Allow splash screen always
      if (isSplash) return null;

      // Not authenticated → go to login
      if (!isAuthenticated && !isLoggingIn && !isRegistering) {
        return RouteConstants.login;
      }

      // Authenticated but on login/register → redirect to home
      if (isAuthenticated && (isLoggingIn || isRegistering)) {
        final userRole = HiveService.getUserRole();
        if (userRole == AppConstants.roleStudent) {
          return RouteConstants.studentHome;
        } else if (userRole == AppConstants.roleTeacher) {
          return RouteConstants.teacherHome;
        }
      }

      // Role-based access control
      if (isAuthenticated) {
        final userRole = HiveService.getUserRole();

        // Student trying to access teacher area
        if (state.matchedLocation == RouteConstants.teacherHome &&
            userRole == AppConstants.roleStudent) {
          return RouteConstants.studentHome;
        }

        // Teacher trying to access student area
        if (state.matchedLocation == RouteConstants.studentHome &&
            userRole == AppConstants.roleTeacher) {
          return RouteConstants.teacherHome;
        }
      }

      return null;
    },

    routes: [
      GoRoute(
        path: RouteConstants.splash,
        name: RouteConstants.splashName,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RouteConstants.login,
        name: RouteConstants.loginName,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteConstants.register,
        name: RouteConstants.registerName,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: RouteConstants.studentHome,
        name: RouteConstants.studentHomeName,
        builder: (context, state) => const StudentHomeScreen(),
      ),
      GoRoute(
        path: RouteConstants.teacherHome,
        name: RouteConstants.teacherHomeName,
        builder: (context, state) => const TeacherHomeScreen(),
      ),
    ],

    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 80, color: Colors.red),
            const SizedBox(height: 16),
            Text('Page not found', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(RouteConstants.splash),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
}
