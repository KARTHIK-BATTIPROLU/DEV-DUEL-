import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../core/constants/app_constants.dart';

/// Theme Provider - Role-based theming
/// Teacher = Teal AppBar, Student = Purple AppBar
class ThemeProvider extends ChangeNotifier {
  String? _userRole;

  ThemeProvider(String? initialRole) : _userRole = initialRole;

  String? get userRole => _userRole;

  /// Get current theme based on role
  ThemeData get currentTheme {
    if (_userRole == AppConstants.roleTeacher) {
      return AppTheme.teacherTheme;
    }
    return AppTheme.studentTheme;
  }

  /// Update role and notify listeners to rebuild with new theme
  void setRole(String? role) {
    if (_userRole != role) {
      _userRole = role;
      debugPrint('🎨 [ThemeProvider] Role changed to: $role');
      notifyListeners();
    }
  }

  /// Check if current user is teacher
  bool get isTeacher => _userRole == AppConstants.roleTeacher;

  /// Check if current user is student
  bool get isStudent => _userRole == AppConstants.roleStudent;

  /// Clear role on logout
  void clearRole() {
    _userRole = null;
    notifyListeners();
  }
}
