import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'routes/app_router.dart';
import 'services/hive_service.dart';
import 'services/auth_service.dart';
import 'providers/career_provider.dart';
import 'providers/theme_provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeApp();
}

Future<void> _initializeApp() async {
  try {
    debugPrint('🚀 [Main] Starting app initialization...');

    debugPrint('🔥 [Main] Initializing Firebase...');
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    debugPrint('✅ [Main] Firebase initialized');

    debugPrint('🔐 [Main] Initializing auth persistence...');
    await AuthService.ensurePersistenceInitialized();
    debugPrint('✅ [Main] Auth persistence initialized');

    debugPrint('📦 [Main] Initializing Hive...');
    await HiveService.init();
    debugPrint('✅ [Main] Hive initialized');

    debugPrint('🎉 [Main] App initialization complete!');
    runApp(const CareerCompassApp());
  } on FirebaseException catch (e) {
    debugPrint('❌ [Main] Firebase error: ${e.message}');
    runApp(InitializationErrorApp(error: 'Failed to initialize Firebase: ${e.message}'));
  } catch (e) {
    debugPrint('❌ [Main] App initialization error: $e');
    runApp(InitializationErrorApp(error: 'Failed to initialize app: $e'));
  }
}

class CareerCompassApp extends StatelessWidget {
  const CareerCompassApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Get initial role from Hive
    final initialRole = HiveService.getUserRole();
    
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CareerProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => ThemeProvider(initialRole)),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp.router(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            // Role-based theming: Teacher = Teal, Student = Purple
            theme: themeProvider.currentTheme,
            routerConfig: AppRouter.router,
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
                child: child ?? const SizedBox.shrink(),
              );
            },
          );
        },
      ),
    );
  }
}

class InitializationErrorApp extends StatelessWidget {
  final String error;
  const InitializationErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 24),
                const Text('Initialization Error', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Text(error, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                const SizedBox(height: 24),
                ElevatedButton(onPressed: () => _initializeApp(), child: const Text('Retry')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
