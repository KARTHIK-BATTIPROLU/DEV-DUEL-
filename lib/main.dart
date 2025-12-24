import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'routes/app_router.dart';
import 'services/hive_service.dart';
import 'services/auth_service.dart';
import 'firebase_options.dart';

/// Main entry point of the Online Learning App
/// Initializes Firebase and Hive before running the app
void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize app with error handling
  await _initializeApp();
}

/// Initialize Firebase and Hive with proper error handling
Future<void> _initializeApp() async {
  try {
    debugPrint('🚀 [Main] Starting app initialization...');

    // Initialize Firebase with platform-specific options
    debugPrint('🔥 [Main] Initializing Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('✅ [Main] Firebase initialized');

    // Initialize Firebase Auth persistence for web (MUST be done early)
    debugPrint('🔐 [Main] Initializing auth persistence...');
    await AuthService.ensurePersistenceInitialized();
    debugPrint('✅ [Main] Auth persistence initialized');

    // Initialize Hive for local storage
    debugPrint('📦 [Main] Initializing Hive...');
    await HiveService.init();
    debugPrint('✅ [Main] Hive initialized');

    debugPrint('🎉 [Main] App initialization complete!');

    // Run the app
    runApp(const OnlineLearningApp());
  } on FirebaseException catch (e) {
    // Handle Firebase initialization errors
    debugPrint('❌ [Main] Firebase initialization error: ${e.message}');
    runApp(InitializationErrorApp(
      error: 'Failed to initialize Firebase: ${e.message}',
    ));
  } catch (e) {
    // Handle other initialization errors
    debugPrint('❌ [Main] App initialization error: $e');
    runApp(InitializationErrorApp(
      error: 'Failed to initialize app: $e',
    ));
  }
}

/// Root widget of the application
/// Sets up theme, routing, and app configuration
class OnlineLearningApp extends StatelessWidget {
  const OnlineLearningApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      // App Configuration
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,

      // Theme Configuration
      theme: AppTheme.lightTheme,

      // Router Configuration using GoRouter
      routerConfig: AppRouter.router,

      // Builder for responsive design and error handling
      builder: (context, child) {
        // Apply responsive text scaling
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.noScaling,
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}

/// Error widget shown when app fails to initialize
class InitializationErrorApp extends StatelessWidget {
  final String error;

  const InitializationErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Initialization Error',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  error,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => _initializeApp(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


