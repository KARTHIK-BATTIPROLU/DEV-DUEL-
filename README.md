# Career Compass - Online Learning App
## Project Description
Career Compass is a sophisticated Flutter application designed to bridge the informational gap between classroom learning and professional success. By leveraging a grade-adaptive UI, the app tailors its experience to the specific developmental needs of students across three distinct phases: Discovery (Grades 7-8), Bridge (Grades 9-10), and Execution (Grades 11-12). This ensures that guidance is always age-appropriate and actionable.

Built with a robust Firebase backend and a Hive-powered offline-first architecture, Career Compass provides uninterrupted access to extensive career repositories, stream-specific roadmaps (MPC, BiPC, etc.), and "Reality Checks" that offer honest insights into professional life. The platform fosters a collaborative ecosystem through a dedicated Teacher Command Center, real-time notice boards, and a mentorship-driven doubt-resolution system.

With integrated career aptitude quizzes and personal insight tracking, the app empowers students to move beyond academic requirements toward intentional career choices. Whether online or offline, it serves as a persistent digital mentor, helping students explore their potential, visualize their roadmap, and execute their professional goals with confidence and clarity.

## 📱 Features

### Student Features
- **Grade-Adaptive UI**: Different interfaces for Discovery (7-8), Bridge (9-10), and Execution (11-12) phases
- **Career Explorer**: Browse careers filtered by stream (MPC, BiPC, MEC, CEC, HEC, Vocational)
- **Career Details**: 4-tab deep dive with Discovery, Roadmap, Reality Check, and Resources
- **My Career Notes**: Save personal insights about careers with offline sync
- **Notices Board**: Real-time announcements from teachers
- **Doubts System**: Ask questions and get answers from mentors
- **Quizzes**: Career aptitude assessments
- **Profile**: User identity card with saved notes

### Teacher Features
- **Command Center**: Comprehensive dashboard for student management
- **Notice Board**: Post announcements to specific grade groups
- **Doubts Hub**: Answer student questions
- **Career Factory**: Manage career content
- **Analytics**: Track student engagement

## 🏗️ Architecture

```
lib/
├── core/
│   ├── constants/
│   │   ├── app_constants.dart
│   │   └── route_constants.dart
│   ├── theme/
│   │   └── app_theme.dart
│   └── utils/
│       └── validators.dart
├── models/
│   ├── user_model.dart
│   ├── career_model.dart
│   ├── teacher_models.dart
│   ├── notice_model.dart
│   └── note_model.dart
├── services/
│   ├── auth_service.dart
│   ├── hive_service.dart
│   ├── student_service.dart
│   ├── teacher_service.dart
│   ├── career_service.dart
│   ├── notice_service.dart
│   ├── note_service.dart
│   └── mentorship_service.dart
├── providers/
│   ├── career_provider.dart
│   └── theme_provider.dart
├── routes/
│   └── app_router.dart
├── presentation/
│   ├── screens/
│   │   ├── student_home_screen.dart
│   │   ├── career_explorer_screen.dart
│   │   ├── career_detail_screen.dart
│   │   ├── teacher_home_screen.dart
│   │   └── ...
│   └── widgets/
├── data/
│   └── career_data.dart
└── main.dart
```

## 🔥 Firebase Collections

```
Firestore Schema:
├── users/
│   ├── students/students/{studentId}
│   ├── teachers/teachers/{teacherId}
│   └── {userId}/my_notes/{noteId}    # Personal career notes
├── notices/                           # Global announcements
├── doubts/                            # Student questions
├── careers/                           # Career content
├── career_notes/                      # Teacher notes for students
├── quizzes/
├── quiz_attempts/
├── submissions/
├── resources/
└── student_activity/
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.x (stable)
- Firebase project
- Android Studio / VS Code

### Installation

```bash
# Clone and navigate
cd online_learning_app

# Install dependencies
flutter pub get

# Run the app
flutter run -d chrome    # Web
flutter run              # Mobile
```

### Firebase Setup

1. Create Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Enable Authentication (Email/Password)
3. Enable Cloud Firestore
4. Configure with FlutterFire CLI:
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```

## 🔐 Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // User's personal notes - only owner can read/write
    match /users/{userId}/my_notes/{noteId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Other collections - authenticated users
    match /{collection}/{docId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
  }
}
```

## 🎨 Color Palette

| Color | Hex | Usage |
|-------|-----|-------|
| Corporate Blue | `#003F75` | Primary, Headers, Buttons |
| Teal Accent | `#0FACB0` | Badges, Highlights |
| Surface | `#F5F7FA` | Backgrounds |
| Success | `#22C55E` | Positive states |
| Warning | `#F59E0B` | Pending states |
| Error | `#EF4444` | Errors, Delete |

## 📱 Student Navigation

| Tab | Icon | Description |
|-----|------|-------------|
| Home | 🏠 | Dashboard with recent notes & quick actions |
| Explore | 🧭 | Career explorer with stream filtering |
| Quizzes | 📝 | Career aptitude tests |
| Notices | 📢 | Teacher announcements |
| Doubts | ❓ | Ask & track questions |
| Profile | 👤 | Identity card & saved notes |

## 💾 Offline Support

- Firestore persistence enabled for offline data sync
- Hive local storage for user session
- Notes sync automatically when online

## 📦 Key Dependencies

```yaml
firebase_core: ^3.12.1
firebase_auth: ^5.7.0
cloud_firestore: ^5.6.12
hive_flutter: ^1.1.0
go_router: ^14.8.1
provider: ^6.1.2
url_launcher: ^6.3.1
```

## 🛠️ Build Commands

```bash
flutter analyze              # Code analysis
flutter test                 # Run tests
flutter build apk --release  # Android APK
flutter build web --release  # Web build
```

## 📄 License

MIT License
