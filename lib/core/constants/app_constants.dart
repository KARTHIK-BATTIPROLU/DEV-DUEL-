/// Application-wide constants
/// Career Awareness & Mentorship Platform

class AppConstants {
  // App Info
  static const String appName = 'Career Compass';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Discover Your Path';

  // Hive Box Names
  static const String userBox = 'userBox';

  // Hive Keys
  static const String keyUserId = 'userId';
  static const String keyUserRole = 'userRole';
  static const String keyUserName = 'userName';
  static const String keyUserEmail = 'userEmail';
  static const String keyUserGrade = 'userGrade';
  static const String keyStudentId = 'studentId';
  static const String keyIsLoggedIn = 'isLoggedIn';

  // User Roles
  static const String roleStudent = 'student';
  static const String roleTeacher = 'teacher';

  // Firestore Collections
  static const String usersCollection = 'users';
  static const String studentsCollection = 'students';
  static const String teachersCollection = 'teachers';

  // Grade Range
  static const int minGrade = 7;
  static const int maxGrade = 12;
  static const List<int> validGrades = [7, 8, 9, 10, 11, 12];

  // Error Messages
  static const String errorGeneric = 'Something went wrong. Please try again.';
  static const String errorNoInternet = 'No internet connection.';
  static const String errorInvalidEmail = 'Please enter a valid email address.';
  static const String errorWeakPassword = 'Password must be at least 6 characters.';
  static const String errorEmailInUse = 'This email is already registered.';
  static const String errorUserNotFound = 'No user found with this email.';
  static const String errorWrongPassword = 'Incorrect password.';
  static const String errorEmptyFields = 'Please fill in all fields.';
  static const String errorInvalidGrade = 'Grade must be between 7 and 12.';
  static const String errorEmptyStudentId = 'Student ID is required.';

  // Success Messages
  static const String successRegistration = 'Registration successful!';
  static const String successLogin = 'Welcome back!';
  static const String successLogout = 'Logged out successfully.';

  // Validation
  static const int minPasswordLength = 6;
  static const int minNameLength = 2;
}
