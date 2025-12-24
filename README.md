# Online Learning App

A Flutter application for online education with clean architecture, Firebase authentication, and offline-first storage using Hive.

## 📱 Features

- **Multi-platform Support**: Android, iOS, and Web (PWA-ready)
- **Role-based Authentication**: Student and Teacher roles
- **Firebase Integration**: Authentication and Firestore
- **Offline-first**: Local storage with Hive
- **Clean Architecture**: Separated presentation, services, and models
- **Responsive Design**: Works on mobile and web
- **Material Design 3**: Modern UI components

## 🏗️ Architecture

```
lib/
├── core/
│   ├── constants/
│   │   ├── app_constants.dart      # App-wide constants
│   │   └── route_constants.dart    # Route path definitions
│   ├── theme/
│   │   └── app_theme.dart          # Theme configuration
│   └── utils/
│       └── validators.dart         # Form validation utilities
├── models/
│   └── user_model.dart             # User data model
├── services/
│   ├── auth_service.dart           # Firebase Auth service
│   └── hive_service.dart           # Local storage service
├── routes/
│   └── app_router.dart             # GoRouter configuration
├── presentation/
│   ├── screens/
│   │   ├── splash_screen.dart      # App entry point
│   │   ├── login_screen.dart       # User login
│   │   ├── register_screen.dart    # User registration
│   │   ├── student_dashboard_screen.dart
│   │   └── teacher_dashboard_screen.dart
│   └── widgets/
│       ├── custom_text_field.dart  # Reusable text input
│       ├── loading_button.dart     # Button with loading state
│       ├── role_selector.dart      # Role selection widget
│       └── dashboard_card.dart     # Dashboard feature card
├── firebase_options.dart           # Firebase configuration
└── main.dart                       # App entry point
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (stable channel)
- Firebase project with Authentication and Firestore enabled
- Android Studio / VS Code with Flutter extension

### Firebase Setup

1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com)

2. Enable Authentication:
   - Go to Authentication → Sign-in method
   - Enable Email/Password provider

3. Enable Firestore:
   - Go to Firestore Database
   - Create database in production/test mode
   - Set up security rules (see below)

4. Add your apps:
   - Android: Download `google-services.json` to `android/app/`
   - iOS: Download `GoogleService-Info.plist` to `ios/Runner/`
   - Web: Copy web configuration

5. Configure Firebase options:
   
   **Option A: Use FlutterFire CLI (Recommended)**
   ```bash
   # Install FlutterFire CLI
   dart pub global activate flutterfire_cli
   
   # Configure Firebase
   flutterfire configure
   ```

   **Option B: Manual Configuration**
   - Update `lib/firebase_options.dart` with your Firebase project values

### Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      // Users can read/write their own data
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### Installation

1. Navigate to the project:
   ```bash
   cd online_learning_app
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   # Android/iOS
   flutter run
   
   # Web
   flutter run -d chrome
   ```

## 📋 User Roles

### Student
- View enrolled courses
- Track learning progress
- Complete assignments and quizzes
- View progress statistics

### Teacher
- Create and manage courses
- Manage students
- Create assignments and quizzes
- View analytics and insights

## 🔐 Authentication Flow

1. **Splash Screen**
   - Check Firebase auth state
   - Load user role from Hive cache
   - Redirect based on role or login status

2. **Login**
   - Email/password authentication
   - Fetch user profile from Firestore
   - Cache user data in Hive
   - Navigate to appropriate dashboard

3. **Registration**
   - Create Firebase Auth account
   - Select role (Student/Teacher)
   - Save profile to Firestore
   - Cache locally and navigate

## 💾 Local Storage (Hive)

Stored data:
- `userId`: Firebase user ID
- `userRole`: STUDENT or TEACHER
- `userName`: User's display name
- `userEmail`: User's email
- `isLoggedIn`: Authentication state

## 🔧 Configuration

### App Constants
Edit `lib/core/constants/app_constants.dart`:
- App name and version
- Hive box names and keys
- User role definitions
- Error messages

### Theme
Edit `lib/core/theme/app_theme.dart`:
- Primary/secondary colors
- Text styles
- Component themes

### Routes
Edit `lib/core/constants/route_constants.dart`:
- Route paths
- Route names

## 📦 Dependencies

```yaml
dependencies:
  firebase_core: ^3.12.1
  firebase_auth: ^5.7.0
  cloud_firestore: ^5.6.12
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  go_router: ^14.8.1
  provider: ^6.1.2
```

## 🌐 Web/PWA Support

The app is PWA-ready with:
- Service worker for offline support
- Web manifest for installation
- Responsive design for all screen sizes
- Custom loading screen

Build for web:
```bash
flutter build web --release
```

## 📱 Build Commands

```bash
# Debug
flutter run

# Release APK
flutter build apk --release

# Release iOS
flutter build ios --release

# Release Web
flutter build web --release

# Analyze code
flutter analyze
```

## 📄 License

This project is licensed under the MIT License.
