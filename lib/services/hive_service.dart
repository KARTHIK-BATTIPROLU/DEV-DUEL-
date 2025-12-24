import 'package:hive_flutter/hive_flutter.dart';
import '../core/constants/app_constants.dart';
import '../models/user_model.dart';

/// Hive Helper Service
/// Manages all local storage operations using Hive
/// Handles user data persistence for offline-first functionality

class HiveService {
  static Box? _userBox;

  /// Initialize Hive and open required boxes
  /// Must be called before any Hive operations
  static Future<void> init() async {
    await Hive.initFlutter();
    _userBox = await Hive.openBox(AppConstants.userBox);
  }

  /// Get the user box instance
  static Box get userBox {
    if (_userBox == null || !_userBox!.isOpen) {
      throw Exception('Hive userBox is not initialized. Call HiveService.init() first.');
    }
    return _userBox!;
  }

  // ==================== USER DATA OPERATIONS ====================

  /// Save complete user data to local storage
  static Future<void> saveUserData(UserModel user) async {
    await userBox.put(AppConstants.keyUserId, user.uid);
    await userBox.put(AppConstants.keyUserName, user.name);
    await userBox.put(AppConstants.keyUserEmail, user.email);
    await userBox.put(AppConstants.keyUserRole, user.role);
    await userBox.put(AppConstants.keyIsLoggedIn, true);
  }

  /// Get stored user ID
  static String? getUserId() {
    return userBox.get(AppConstants.keyUserId);
  }

  /// Get stored user name
  static String? getUserName() {
    return userBox.get(AppConstants.keyUserName);
  }

  /// Get stored user email
  static String? getUserEmail() {
    return userBox.get(AppConstants.keyUserEmail);
  }

  /// Get stored user role (STUDENT or TEACHER)
  static String? getUserRole() {
    return userBox.get(AppConstants.keyUserRole);
  }

  /// Check if user is logged in locally
  static bool isLoggedIn() {
    return userBox.get(AppConstants.keyIsLoggedIn, defaultValue: false);
  }

  /// Get complete user model from local storage
  static UserModel? getUser() {
    final userId = getUserId();
    final userName = getUserName();
    final userEmail = getUserEmail();
    final userRole = getUserRole();

    if (userId != null && userRole != null) {
      return UserModel(
        uid: userId,
        name: userName ?? '',
        email: userEmail ?? '',
        role: userRole,
      );
    }
    return null;
  }

  /// Clear all user data (used on logout)
  static Future<void> clearUserData() async {
    await userBox.delete(AppConstants.keyUserId);
    await userBox.delete(AppConstants.keyUserName);
    await userBox.delete(AppConstants.keyUserEmail);
    await userBox.delete(AppConstants.keyUserRole);
    await userBox.put(AppConstants.keyIsLoggedIn, false);
  }

  /// Clear all data from all boxes
  static Future<void> clearAll() async {
    await userBox.clear();
  }

  /// Close all Hive boxes
  static Future<void> close() async {
    await _userBox?.close();
  }
}
