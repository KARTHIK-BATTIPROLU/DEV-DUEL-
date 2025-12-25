import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../core/constants/app_constants.dart';
import '../models/user_model.dart';
import 'hive_service.dart';

/// Authentication Service
/// Handles Firebase Auth and Firestore operations for students and teachers

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static final AuthService _instance = AuthService._internal();
  static bool _persistenceInitialized = false;
  static Completer<void>? _persistenceCompleter;

  factory AuthService() => _instance;
  AuthService._internal();

  static Future<void> ensurePersistenceInitialized() async {
    if (_persistenceInitialized) return;
    if (_persistenceCompleter != null) {
      await _persistenceCompleter!.future;
      return;
    }
    _persistenceCompleter = Completer<void>();
    try {
      if (kIsWeb) {
        await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
      }
      _persistenceInitialized = true;
      _persistenceCompleter!.complete();
    } catch (e) {
      _persistenceCompleter!.completeError(e);
      _persistenceCompleter = null;
      _persistenceInitialized = true;
    }
  }

  User? get currentUser => _auth.currentUser;
  bool get isAuthenticated => currentUser != null;
  Stream<User?> get authStateChanges => _auth.authStateChanges();


  // ==================== STUDENT REGISTRATION ====================

  Future<StudentModel> registerStudent({
    required String name,
    required String email,
    required String password,
    required int grade,
    required String studentId,
  }) async {
    debugPrint('📝 [AuthService] Registering student: $email');
    await ensurePersistenceInitialized();

    try {
      // Create Firebase Auth user
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      ).timeout(const Duration(seconds: 30));

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw Exception('Registration failed. Please try again.');
      }

      await firebaseUser.updateDisplayName(name);

      // Create student model
      final student = StudentModel(
        uid: firebaseUser.uid,
        name: name,
        email: email.trim(),
        grade: grade,
        studentId: studentId,
        createdAt: DateTime.now(),
      );

      // Save to Firestore: users/students/{uid}
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(AppConstants.studentsCollection)
          .collection(AppConstants.studentsCollection)
          .doc(firebaseUser.uid)
          .set(student.toMap())
          .timeout(const Duration(seconds: 15));

      // Cache locally
      await HiveService.saveStudentData(student);

      debugPrint('✅ [AuthService] Student registered: ${student.uid}');
      return student;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception(AppConstants.errorGeneric);
    }
  }

  // ==================== TEACHER REGISTRATION ====================

  Future<TeacherModel> registerTeacher({
    required String name,
    required String email,
    required String password,
  }) async {
    debugPrint('📝 [AuthService] Registering teacher: $email');
    await ensurePersistenceInitialized();

    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      ).timeout(const Duration(seconds: 30));

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw Exception('Registration failed. Please try again.');
      }

      await firebaseUser.updateDisplayName(name);

      final teacher = TeacherModel(
        uid: firebaseUser.uid,
        name: name,
        email: email.trim(),
        createdAt: DateTime.now(),
      );

      // Save to Firestore: users/teachers/{uid}
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(AppConstants.teachersCollection)
          .collection(AppConstants.teachersCollection)
          .doc(firebaseUser.uid)
          .set(teacher.toMap())
          .timeout(const Duration(seconds: 15));

      await HiveService.saveTeacherData(teacher);

      debugPrint('✅ [AuthService] Teacher registered: ${teacher.uid}');
      return teacher;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception(AppConstants.errorGeneric);
    }
  }


  // ==================== LOGIN ====================

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    debugPrint('🔐 [AuthService] Login: $email');
    await ensurePersistenceInitialized();

    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      ).timeout(const Duration(seconds: 30));

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw Exception('Login failed. Please try again.');
      }

      // Try to find user in students collection first
      final studentDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(AppConstants.studentsCollection)
          .collection(AppConstants.studentsCollection)
          .doc(firebaseUser.uid)
          .get()
          .timeout(const Duration(seconds: 15));

      if (studentDoc.exists && studentDoc.data() != null) {
        final student = StudentModel.fromMap(studentDoc.data()!);
        await HiveService.saveStudentData(student);
        debugPrint('✅ [AuthService] Student logged in: ${student.uid}');
        return student;
      }

      // Try teachers collection
      final teacherDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(AppConstants.teachersCollection)
          .collection(AppConstants.teachersCollection)
          .doc(firebaseUser.uid)
          .get()
          .timeout(const Duration(seconds: 15));

      if (teacherDoc.exists && teacherDoc.data() != null) {
        final teacher = TeacherModel.fromMap(teacherDoc.data()!);
        await HiveService.saveTeacherData(teacher);
        debugPrint('✅ [AuthService] Teacher logged in: ${teacher.uid}');
        return teacher;
      }

      // User not found in either collection
      await _auth.signOut();
      throw Exception('User profile not found. Please register again.');
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception(AppConstants.errorGeneric);
    }
  }

  // ==================== GET ALL STUDENTS (FOR TEACHERS) ====================

  Future<List<StudentModel>> getAllStudents() async {
    debugPrint('📚 [AuthService] Fetching all students...');
    try {
      // Query without orderBy to avoid composite index requirement
      final snapshot = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(AppConstants.studentsCollection)
          .collection(AppConstants.studentsCollection)
          .get()
          .timeout(const Duration(seconds: 15));

      debugPrint('📚 [AuthService] Found ${snapshot.docs.length} students');
      
      final students = snapshot.docs
          .map((doc) {
            debugPrint('📚 [AuthService] Student doc: ${doc.id} -> ${doc.data()}');
            return StudentModel.fromMap(doc.data());
          })
          .toList();
      
      // Sort locally instead of in Firestore query
      students.sort((a, b) {
        final gradeCompare = a.grade.compareTo(b.grade);
        if (gradeCompare != 0) return gradeCompare;
        return a.name.compareTo(b.name);
      });
      
      return students;
    } catch (e) {
      debugPrint('❌ [AuthService] Error fetching students: $e');
      return [];
    }
  }

  // ==================== SIGN OUT ====================

  Future<void> signOut() async {
    debugPrint('🚪 [AuthService] Signing out...');
    try {
      await HiveService.clearUserData();
      await _auth.signOut();
      debugPrint('✅ [AuthService] Signed out');
    } catch (e) {
      await HiveService.clearUserData();
    }
  }

  // ==================== SESSION VALIDATION ====================

  Future<bool> isSessionValid() async {
    if (currentUser == null) return false;
    try {
      await currentUser!.getIdToken(true).timeout(const Duration(seconds: 10));
      return true;
    } catch (e) {
      return false;
    }
  }

  // ==================== ERROR HANDLING ====================

  Exception _handleAuthException(FirebaseAuthException e) {
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
      case 'invalid-credential':
        return Exception('Invalid email or password.');
      case 'network-request-failed':
        return Exception(AppConstants.errorNoInternet);
      default:
        return Exception(e.message ?? AppConstants.errorGeneric);
    }
  }
}
