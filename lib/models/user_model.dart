/// Base User Model
/// Represents common user properties

abstract class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role;
  final DateTime? createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.createdAt,
  });

  Map<String, dynamic> toMap();
}

/// Student Model
/// Represents a student user (Grade 7-12)

class StudentModel extends UserModel {
  final int grade;
  final String studentId;

  StudentModel({
    required super.uid,
    required super.name,
    required super.email,
    required this.grade,
    required this.studentId,
    super.createdAt,
  }) : super(role: 'student');

  factory StudentModel.fromMap(Map<String, dynamic> map) {
    return StudentModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      grade: map['grade'] ?? 7,
      studentId: map['studentId'] ?? '',
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] is DateTime
              ? map['createdAt']
              : DateTime.tryParse(map['createdAt'].toString()))
          : null,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'grade': grade,
      'studentId': studentId,
      'role': role,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  StudentModel copyWith({
    String? uid,
    String? name,
    String? email,
    int? grade,
    String? studentId,
    DateTime? createdAt,
  }) {
    return StudentModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      grade: grade ?? this.grade,
      studentId: studentId ?? this.studentId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Teacher Model
/// Represents a teacher/mentor user

class TeacherModel extends UserModel {
  TeacherModel({
    required super.uid,
    required super.name,
    required super.email,
    super.createdAt,
  }) : super(role: 'teacher');

  factory TeacherModel.fromMap(Map<String, dynamic> map) {
    return TeacherModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] is DateTime
              ? map['createdAt']
              : DateTime.tryParse(map['createdAt'].toString()))
          : null,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  TeacherModel copyWith({
    String? uid,
    String? name,
    String? email,
    DateTime? createdAt,
  }) {
    return TeacherModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
