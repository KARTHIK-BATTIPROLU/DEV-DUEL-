import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/app_constants.dart';
import '../core/constants/route_constants.dart';
import '../presentation/screens/splash_screen.dart';
import '../presentation/screens/login_screen.dart';
import '../presentation/screens/register_screen.dart';
import '../presentation/screens/student_dashboard_screen.dart';
import '../presentation/screens/teacher_dashboard_screen.dart';
import '../services/auth_service.dart';
import '../services/hive_service.dart';

/// Application Router Configuration
/// Uses GoRouter for declarative routing with Navigator 2.0
/// Includes route guards for authentication protection

class AppRouter {
  static final AuthService _authService = AuthService();

  /// Create and configure the router
  static GoRouter get router => _router;

  static final GoRouter _router = GoRouter(
    initialLocation: RouteConstants.splash,
    debugLogDiagnostics: true,

    // Global redirect for route protection
    redirect: (context, state) {
      final isAuthenticated = _authService.isAuthenticated;
      final isLoggingIn = state.matchedLocation == RouteConstants.login;
      final isRegistering = state.matchedLocation == RouteConstants.register;
      final isSplash = state.matchedLocation == RouteConstants.splash;

      // Allow splash screen always (it handles its own routing)
      if (isSplash) return null;

      // If not authenticated and trying to access protected routes
      if (!isAuthenticated && !isLoggingIn && !isRegistering) {
        return RouteConstants.login;
      }

      // If authenticated and trying to access login/register
      if (isAuthenticated && (isLoggingIn || isRegistering)) {
        // Redirect to appropriate dashboard based on role
        final userRole = HiveService.getUserRole();
        if (userRole == AppConstants.roleStudent) {
          return RouteConstants.studentDashboard;
        } else if (userRole == AppConstants.roleTeacher) {
          return RouteConstants.teacherDashboard;
        }
      }

      // Check role-based access for dashboards
      if (isAuthenticated) {
        final userRole = HiveService.getUserRole();
        
        // Prevent student from accessing teacher dashboard
        if (state.matchedLocation == RouteConstants.teacherDashboard &&
            userRole == AppConstants.roleStudent) {
          return RouteConstants.studentDashboard;
        }
        
        // Prevent teacher from accessing student dashboard
        if (state.matchedLocation == RouteConstants.studentDashboard &&
            userRole == AppConstants.roleTeacher) {
          return RouteConstants.teacherDashboard;
        }
      }

      return null; // No redirect needed
    },

    routes: [
      // Splash Screen - Entry point
      GoRoute(
        path: RouteConstants.splash,
        name: RouteConstants.splashName,
        builder: (context, state) => const SplashScreen(),
      ),

      // Login Screen
      GoRoute(
        path: RouteConstants.login,
        name: RouteConstants.loginName,
        builder: (context, state) => const LoginScreen(),
      ),

      // Register Screen
      GoRoute(
        path: RouteConstants.register,
        name: RouteConstants.registerName,
        builder: (context, state) => const RegisterScreen(),
      ),

      // Student Dashboard (Protected)
      GoRoute(
        path: RouteConstants.studentDashboard,
        name: RouteConstants.studentDashboardName,
        builder: (context, state) => const StudentDashboardScreen(),
      ),

      // Teacher Dashboard (Protected)
      GoRoute(
        path: RouteConstants.teacherDashboard,
        name: RouteConstants.teacherDashboardName,
        builder: (context, state) => const TeacherDashboardScreen(),
      ),
    ],

    // Error page for unknown routes
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              state.uri.toString(),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
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

