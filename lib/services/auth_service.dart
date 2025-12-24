import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../core/constants/app_constants.dart';
import '../models/user_model.dart';
import 'hive_service.dart';

/// Authentication Service
/// Handles all Firebase Authentication and Firestore user operations
/// Manages login, registration, and session state
/// Supports offline-first with Hive local storage

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Singleton pattern for consistent auth state
  static final AuthService _instance = AuthService._internal();
  static bool _persistenceInitialized = false;
  static Completer<void>? _persistenceCompleter;

  factory AuthService() => _instance;
  AuthService._internal();

  /// Initialize auth persistence for web - MUST be called before auth operations
  /// Returns immediately if already initialized
  static Future<void> ensurePersistenceInitialized() async {
    if (_persistenceInitialized) return;

    // Use completer to handle concurrent calls
    if (_persistenceCompleter != null) {
      await _persistenceCompleter!.future;
      return;
    }

    _persistenceCompleter = Completer<void>();

    try {
      if (kIsWeb) {
        debugPrint('🔧 [AuthService] Setting web persistence...');
        await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
        debugPrint('✅ [AuthService] Web persistence set to LOCAL');
      }
      _persistenceInitialized = true;
      _persistenceCompleter!.complete();
    } catch (e) {
      debugPrint('⚠️ [AuthService] Failed to set persistence: $e');
      _persistenceCompleter!.completeError(e);
      _persistenceCompleter = null;
      // Don't rethrow - persistence failure shouldn't block auth
      _persistenceInitialized = true; // Mark as initialized to prevent retry loops
    }
  }

  /// Get current Firebase user
  User? get currentUser => _auth.currentUser;

  /// Check if user is authenticated with Firebase
  bool get isAuthenticated => currentUser != null;

  /// Stream of auth state changes - useful for reactive UI updates
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Stream of user changes (includes token refreshes)
  Stream<User?> get userChanges => _auth.userChanges();

  // ==================== AUTHENTICATION METHODS ====================

  /// Register new user with email and password
  /// Creates user in Firebase Auth and saves profile to Firestore
  /// Returns UserModel on success, throws exception on failure
  Future<UserModel> registerWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    debugPrint('📝 [AuthService] Starting registration for: $email');

    // Ensure persistence is initialized before any auth operation
    await ensurePersistenceInitialized();

    try {
      // Step 1: Create user in Firebase Auth
      debugPrint('📝 [AuthService] Step 1: Creating Firebase Auth user...');
      final UserCredential credential = await _auth
          .createUserWithEmailAndPassword(
            email: email.trim(),
            password: password,
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw TimeoutException('Registration timed out. Please try again.');
            },
          );

      final User? firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw Exception('Registration failed. Please try again.');
      }
      debugPrint('✅ [AuthService] Firebase Auth user created: ${firebaseUser.uid}');

      // Step 2: Update display name
      debugPrint('📝 [AuthService] Step 2: Updating display name...');
      await firebaseUser.updateDisplayName(name).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          debugPrint('⚠️ [AuthService] Display name update timed out, continuing...');
        },
      );

      // Step 3: Create user model
      final UserModel user = UserModel(
        uid: firebaseUser.uid,
        name: name,
        email: email.trim(),
        role: role,
        createdAt: DateTime.now(),
      );

      // Step 4: Save user profile to Firestore with timeout
      debugPrint('📝 [AuthService] Step 3: Saving profile to Firestore...');
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(firebaseUser.uid)
          .set(user.toMap())
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              throw TimeoutException('Failed to save profile. Please try again.');
            },
          );
      debugPrint('✅ [AuthService] Firestore profile saved');

      // Step 5: Save user data locally in Hive
      debugPrint('📝 [AuthService] Step 4: Saving to Hive...');
      await HiveService.saveUserData(user);
      debugPrint('✅ [AuthService] Hive data saved');

      debugPrint('🎉 [AuthService] Registration complete!');
      return user;
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ [AuthService] FirebaseAuthException: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } on FirebaseException catch (e) {
      debugPrint('❌ [AuthService] FirebaseException: ${e.code} - ${e.message}');
      throw Exception('Failed to save profile: ${e.message}');
    } on TimeoutException catch (e) {
      debugPrint('❌ [AuthService] TimeoutException: $e');
      throw Exception(e.message ?? 'Operation timed out. Please try again.');
    } catch (e) {
      debugPrint('❌ [AuthService] Unexpected error: $e');
      if (e is Exception) rethrow;
      throw Exception(AppConstants.errorGeneric);
    }
  }

  /// Login user with email and password
  /// Fetches user profile from Firestore and caches locally
  /// Returns UserModel on success, throws exception on failure
  Future<UserModel> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    debugPrint('🔐 [AuthService] Starting login for: $email');

    // Ensure persistence is initialized before any auth operation
    await ensurePersistenceInitialized();

    try {
      // Step 1: Sign in with Firebase Auth
      debugPrint('🔐 [AuthService] Step 1: Signing in with Firebase...');
      final UserCredential credential = await _auth
          .signInWithEmailAndPassword(
            email: email.trim(),
            password: password,
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw TimeoutException('Login timed out. Please check your connection.');
            },
          );

      final User? firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw Exception('Login failed. Please try again.');
      }
      debugPrint('✅ [AuthService] Firebase sign-in successful: ${firebaseUser.uid}');

      // Step 2: Fetch user profile from Firestore
      debugPrint('🔐 [AuthService] Step 2: Fetching profile from Firestore...');
      final UserModel? user = await getUserProfile(firebaseUser.uid);

      if (user == null) {
        debugPrint('⚠️ [AuthService] User profile not found in Firestore');
        // Create a basic profile if it doesn't exist (edge case recovery)
        final basicUser = UserModel(
          uid: firebaseUser.uid,
          name: firebaseUser.displayName ?? 'User',
          email: firebaseUser.email ?? email,
          role: AppConstants.roleStudent, // Default role
          createdAt: DateTime.now(),
        );

        // Try to create the profile
        try {
          await _firestore
              .collection(AppConstants.usersCollection)
              .doc(firebaseUser.uid)
              .set(basicUser.toMap())
              .timeout(const Duration(seconds: 10));
          debugPrint('✅ [AuthService] Created missing Firestore profile');
        } catch (e) {
          debugPrint('⚠️ [AuthService] Could not create profile: $e');
        }

        await HiveService.saveUserData(basicUser);
        debugPrint('🎉 [AuthService] Login complete with basic profile');
        return basicUser;
      }

      // Step 3: Cache user data locally in Hive
      debugPrint('🔐 [AuthService] Step 3: Saving to Hive...');
      await HiveService.saveUserData(user);
      debugPrint('✅ [AuthService] Hive data saved');

      debugPrint('🎉 [AuthService] Login complete!');
      return user;
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ [AuthService] FirebaseAuthException: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } on FirebaseException catch (e) {
      debugPrint('❌ [AuthService] FirebaseException: ${e.code} - ${e.message}');
      throw Exception('Network error: ${e.message}');
    } on TimeoutException catch (e) {
      debugPrint('❌ [AuthService] TimeoutException: $e');
      throw Exception(e.message ?? 'Operation timed out. Please try again.');
    } catch (e) {
      debugPrint('❌ [AuthService] Unexpected error: $e');
      if (e is Exception) rethrow;
      throw Exception(AppConstants.errorGeneric);
    }
  }

  /// Get user profile from Firestore with timeout protection
  /// Returns null if profile doesn't exist or on error
  Future<UserModel?> getUserProfile(String uid) async {
    debugPrint('📖 [AuthService] Fetching profile for: $uid');
    try {
      final DocumentSnapshot doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .get()
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              debugPrint('⚠️ [AuthService] Firestore read timed out');
              throw TimeoutException('Failed to load profile');
            },
          );

      if (doc.exists && doc.data() != null) {
        debugPrint('✅ [AuthService] Profile found in Firestore');
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      debugPrint('⚠️ [AuthService] Profile not found in Firestore');
      return null;
    } on FirebaseException catch (e) {
      debugPrint('❌ [AuthService] Error fetching profile: ${e.message}');
      return null;
    } on TimeoutException {
      debugPrint('❌ [AuthService] Profile fetch timed out');
      return null;
    } catch (e) {
      debugPrint('❌ [AuthService] Error fetching profile: $e');
      return null;
    }
  }

  /// Sign out user
  /// Clears local data and signs out from Firebase
  Future<void> signOut() async {
    debugPrint('🚪 [AuthService] Signing out...');
    try {
      await HiveService.clearUserData();
      await _auth.signOut().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          debugPrint('⚠️ [AuthService] Sign out timed out');
        },
      );
      debugPrint('✅ [AuthService] Sign out complete');
    } catch (e) {
      debugPrint('⚠️ [AuthService] Sign out error: $e');
      // Still clear local data even if Firebase sign out fails
      await HiveService.clearUserData();
    }
  }

  /// Get current user with profile data
  /// First checks local cache, then fetches from Firestore if needed
  /// Implements offline-first approach
  Future<UserModel?> getCurrentUserWithProfile() async {
    // Try to get from local cache first (offline-first)
    final UserModel? cachedUser = HiveService.getUser();
    if (cachedUser != null) {
      debugPrint('📱 [AuthService] Using cached user data');
      return cachedUser;
    }

    // If not cached, fetch from Firestore
    if (currentUser != null) {
      debugPrint('☁️ [AuthService] Fetching from Firestore...');
      final UserModel? user = await getUserProfile(currentUser!.uid);
      if (user != null) {
        await HiveService.saveUserData(user);
      }
      return user;
    }

    return null;
  }

  /// Reload current user to get latest auth state
  /// Useful after email verification or profile updates
  Future<void> reloadUser() async {
    await currentUser?.reload();
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim()).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw TimeoutException('Request timed out. Please try again.');
        },
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } on TimeoutException catch (e) {
      throw Exception(e.message ?? 'Operation timed out');
    }
  }

  /// Check if the current session is valid
  /// Useful for validating token on app restart
  Future<bool> isSessionValid() async {
    if (currentUser == null) return false;

    try {
      debugPrint('🔍 [AuthService] Validating session...');
      // Force token refresh to validate session with timeout
      await currentUser!.getIdToken(true).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          debugPrint('⚠️ [AuthService] Session validation timed out');
          throw TimeoutException('Session validation timed out');
        },
      );
      debugPrint('✅ [AuthService] Session is valid');
      return true;
    } catch (e) {
      debugPrint('❌ [AuthService] Session validation failed: $e');
      return false;
    }
  }

  // ==================== HELPER METHODS ====================

  /// Handle Firebase Auth exceptions and return user-friendly messages
  Exception _handleAuthException(FirebaseAuthException e) {
    debugPrint('🔥 [AuthService] Firebase Auth Error: ${e.code} - ${e.message}');

    switch (e.code) {
      case 'weak-password':
        return Exception(AppConstants.errorWeakPassword);
      case 'email-already-in-use':
        return Exception(AppConstants.errorEmailInUse);
      case 'user-not-found':
        return Exception(AppConstants.errorUserNotFound);
      case 'wrong-password':
        return Exception(AppConstants.errorWrongPassword);
      case 'invalid-email':
        return Exception(AppConstants.errorInvalidEmail);
      case 'user-disabled':
        return Exception('This account has been disabled.');
      case 'too-many-requests':
        return Exception('Too many attempts. Please try again later.');
      case 'operation-not-allowed':
        return Exception('This operation is not allowed.');
      case 'invalid-credential':
        return Exception('Invalid email or password.');
      case 'network-request-failed':
        return Exception('Network error. Please check your connection.');
      case 'requires-recent-login':
        return Exception('Please log in again to continue.');
      default:
        return Exception(e.message ?? AppConstants.errorGeneric);
    }
  }
}
