import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/route_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../services/hive_service.dart';

/// Splash Screen
/// Entry point of the application
/// Checks authentication state and redirects appropriately

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _checkAuthState();
  }

  /// Initialize splash screen animations
  void _initAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
      ),
    );

    _animationController.forward();
  }

  /// Check Firebase auth state and redirect based on user role
  /// Handles offline scenarios and session validation
  Future<void> _checkAuthState() async {
    try {
      // Small delay for splash screen visibility
      await Future.delayed(const Duration(seconds: 2));

      final authService = AuthService();

      // Check if user is authenticated with Firebase
      if (authService.isAuthenticated) {
        // Validate session is still valid (handles expired tokens)
        final isSessionValid = await authService.isSessionValid();
        
        if (!isSessionValid) {
          // Session expired - clear local data and redirect to login
          await authService.signOut();
          if (mounted) context.go(RouteConstants.login);
          return;
        }

        // User is logged in - check role from Hive (offline-first)
        String? userRole = HiveService.getUserRole();

        // If role not in cache, fetch from Firestore
        if (userRole == null) {
          final user = await authService.getCurrentUserWithProfile();
          userRole = user?.role;
        }

        if (!mounted) return;

        // Navigate based on user role
        if (userRole == AppConstants.roleStudent) {
          context.go(RouteConstants.studentDashboard);
        } else if (userRole == AppConstants.roleTeacher) {
          context.go(RouteConstants.teacherDashboard);
        } else {
          // Role not found - sign out and go to login
          await authService.signOut();
          if (mounted) context.go(RouteConstants.login);
        }
      } else {
        // Check if we have cached data (offline scenario)
        final cachedRole = HiveService.getUserRole();
        final isLoggedIn = HiveService.isLoggedIn();
        
        if (isLoggedIn && cachedRole != null) {
          // User was logged in but Firebase session expired
          // Clear stale data and redirect to login
          await HiveService.clearUserData();
        }
        
        // User not logged in - navigate to login
        if (mounted) context.go(RouteConstants.login);
      }
    } catch (e) {
      debugPrint('Splash screen error: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to initialize app. Please try again.';
        });
      }
    }
  }

  /// Retry initialization on error
  void _retryInit() {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    _checkAuthState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryColor,
              AppTheme.primaryDark,
            ],
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: _buildContent(),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // App Logo
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.school_rounded,
            size: 70,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 32),

        // App Name
        const Text(
          AppConstants.appName,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),

        // Tagline
        Text(
          'Learn Anytime, Anywhere',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withOpacity(0.9),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 60),

        // Loading or Error State
        if (_isLoading) ...[
          const SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading...',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
        ] else if (_errorMessage != null) ...[
          const Icon(
            Icons.error_outline,
            color: Colors.white,
            size: 48,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _retryInit,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppTheme.primaryColor,
            ),
            child: const Text('Retry'),
          ),
        ],
      ],
    );
  }
}
