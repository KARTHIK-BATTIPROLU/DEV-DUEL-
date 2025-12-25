import 'package:hive_flutter/hive_flutter.dart';
import '../core/constants/app_constants.dart';
import '../models/user_model.dart';

/// Hive Service
/// Manages local storage for offline-first functionality

class HiveService {
  static Box? _userBox;

  static Future<void> init() async {
    await Hive.initFlutter();
    _userBox = await Hive.openBox(AppConstants.userBox);
  }

  static Box get userBox {
    if (_userBox == null || !_userBox!.isOpen) {
      throw Exception('Hive not initialized. Call HiveService.init() first.');
    }
    return _userBox!;
  }

  // Save student data
  static Future<void> saveStudentData(StudentModel student) async {
    await userBox.put(AppConstants.keyUserId, student.uid);
    await userBox.put(AppConstants.keyUserName, student.name);
    await userBox.put(AppConstants.keyUserEmail, student.email);
    await userBox.put(AppConstants.keyUserRole, student.role);
    await userBox.put(AppConstants.keyUserGrade, student.grade);
    await userBox.put(AppConstants.keyStudentId, student.studentId);
    await userBox.put(AppConstants.keyIsLoggedIn, true);
  }

  // Save teacher data
  static Future<void> saveTeacherData(TeacherModel teacher) async {
    await userBox.put(AppConstants.keyUserId, teacher.uid);
    await userBox.put(AppConstants.keyUserName, teacher.name);
    await userBox.put(AppConstants.keyUserEmail, teacher.email);
    await userBox.put(AppConstants.keyUserRole, teacher.role);
    await userBox.put(AppConstants.keyIsLoggedIn, true);
  }

  // Getters
  static String? getUserId() => userBox.get(AppConstants.keyUserId);
  static String? getUserName() => userBox.get(AppConstants.keyUserName);
  static String? getUserEmail() => userBox.get(AppConstants.keyUserEmail);
  static String? getUserRole() => userBox.get(AppConstants.keyUserRole);
  static int? getUserGrade() => userBox.get(AppConstants.keyUserGrade);
  static String? getStudentId() => userBox.get(AppConstants.keyStudentId);
  static bool isLoggedIn() => userBox.get(AppConstants.keyIsLoggedIn, defaultValue: false);

  // Get student model from cache
  static StudentModel? getStudent() {
    final uid = getUserId();
    final role = getUserRole();
    if (uid != null && role == AppConstants.roleStudent) {
      return StudentModel(
        uid: uid,
        name: getUserName() ?? '',
        email: getUserEmail() ?? '',
        grade: getUserGrade() ?? 7,
        studentId: getStudentId() ?? '',
      );
    }
    return null;
  }

  // Get teacher model from cache
  static TeacherModel? getTeacher() {
    final uid = getUserId();
    final role = getUserRole();
    if (uid != null && role == AppConstants.roleTeacher) {
      return TeacherModel(
        uid: uid,
        name: getUserName() ?? '',
        email: getUserEmail() ?? '',
      );
    }
    return null;
  }

  // Clear user data on logout
  static Future<void> clearUserData() async {
    await userBox.delete(AppConstants.keyUserId);
    await userBox.delete(AppConstants.keyUserName);
    await userBox.delete(AppConstants.keyUserEmail);
    await userBox.delete(AppConstants.keyUserRole);
    await userBox.delete(AppConstants.keyUserGrade);
    await userBox.delete(AppConstants.keyStudentId);
    await userBox.put(AppConstants.keyIsLoggedIn, false);
  }

  static Future<void> clearAll() async => await userBox.clear();
  static Future<void> close() async => await _userBox?.close();
}
