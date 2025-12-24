/// Application-wide constants
/// Contains all static strings, routes, and configuration values

class AppConstants {
  // App Info
  static const String appName = 'Online Learning';
  static const String appVersion = '1.0.0';

  // Hive Box Names
  static const String userBox = 'userBox';

  // Hive Keys
  static const String keyUserId = 'userId';
  static const String keyUserRole = 'userRole';
  static const String keyUserName = 'userName';
  static const String keyUserEmail = 'userEmail';
  static const String keyIsLoggedIn = 'isLoggedIn';

  // User Roles
  static const String roleStudent = 'STUDENT';
  static const String roleTeacher = 'TEACHER';

  // Firestore Collections
  static const String usersCollection = 'users';

  // Error Messages
  static const String errorGeneric = 'Something went wrong. Please try again.';
  static const String errorNoInternet = 'No internet connection.';
  static const String errorInvalidEmail = 'Please enter a valid email address.';
  static const String errorWeakPassword = 'Password must be at least 6 characters.';
  static const String errorEmailInUse = 'This email is already registered.';
  static const String errorUserNotFound = 'No user found with this email.';
  static const String errorWrongPassword = 'Incorrect password.';
  static const String errorEmptyFields = 'Please fill in all fields.';

  // Success Messages
  static const String successRegistration = 'Registration successful!';
  static const String successLogin = 'Login successful!';
  static const String successLogout = 'Logged out successfully.';

  // Validation
  static const int minPasswordLength = 6;
  static const int minNameLength = 2;
}
