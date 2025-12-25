// Notice Model - Firestore Schema for Notice Board
// Persistent collection with live reactive streams

import 'package:cloud_firestore/cloud_firestore.dart';

/// Notice Type Enum - Matches requirement spec
enum NoticeType {
  webinar,
  session,
  workshop,
  alert,
}

extension NoticeTypeExt on NoticeType {
  String get displayName {
    switch (this) {
      case NoticeType.webinar:
        return 'Webinar';
      case NoticeType.session:
        return 'Session';
      case NoticeType.workshop:
        return 'Workshop';
      case NoticeType.alert:
        return 'Alert';
    }
  }

  String get icon {
    switch (this) {
      case NoticeType.webinar:
        return 'video_call';
      case NoticeType.session:
        return 'groups';
      case NoticeType.workshop:
        return 'build';
      case NoticeType.alert:
        return 'warning';
    }
  }
}

/// Target Grade Filter - Matches requirement spec
enum TargetGrade {
  grade7_8,
  grade9_10,
  grade11_12,
  all,
}

extension TargetGradeExt on TargetGrade {
  String get displayName {
    switch (this) {
      case TargetGrade.grade7_8:
        return '7-8';
      case TargetGrade.grade9_10:
        return '9-10';
      case TargetGrade.grade11_12:
        return '11-12';
      case TargetGrade.all:
        return 'All';
    }
  }

  String get firestoreValue {
    switch (this) {
      case TargetGrade.grade7_8:
        return '7-8';
      case TargetGrade.grade9_10:
        return '9-10';
      case TargetGrade.grade11_12:
        return '11-12';
      case TargetGrade.all:
        return 'All';
    }
  }

  /// Check if a student grade matches this target
  bool matchesGrade(int studentGrade) {
    switch (this) {
      case TargetGrade.grade7_8:
        return studentGrade >= 7 && studentGrade <= 8;
      case TargetGrade.grade9_10:
        return studentGrade >= 9 && studentGrade <= 10;
      case TargetGrade.grade11_12:
        return studentGrade >= 11 && studentGrade <= 12;
      case TargetGrade.all:
        return true;
    }
  }

  static TargetGrade fromString(String value) {
    switch (value) {
      case '7-8':
        return TargetGrade.grade7_8;
      case '9-10':
        return TargetGrade.grade9_10;
      case '11-12':
        return TargetGrade.grade11_12;
      default:
        return TargetGrade.all;
    }
  }

  /// Get the target grade filter for a student's grade
  static String getTargetGradeFilter(int studentGrade) {
    if (studentGrade >= 7 && studentGrade <= 8) return '7-8';
    if (studentGrade >= 9 && studentGrade <= 10) return '9-10';
    if (studentGrade >= 11 && studentGrade <= 12) return '11-12';
    return 'All';
  }
}

/// Notice Model - Firestore Document Schema
/// Collection: notices
class NoticeModel {
  final String id; // Firestore Document ID
  final String title; // Heading
  final String body; // Details
  final String targetGrade; // Filter: '7-8', '9-10', '11-12', or 'All'
  final String type; // Enum: 'Webinar', 'Session', 'Workshop', 'Alert'
  final DateTime? timestamp; // FieldValue.serverTimestamp() for sorting
  final String createdBy; // Teacher UID

  NoticeModel({
    required this.id,
    required this.title,
    required this.body,
    required this.targetGrade,
    required this.type,
    this.timestamp,
    required this.createdBy,
  });

  /// Convert to Firestore Map (for writing)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'targetGrade': targetGrade,
      'type': type,
      'timestamp': FieldValue.serverTimestamp(),
      'createdBy': createdBy,
    };
  }

  /// Create from Firestore Document
  factory NoticeModel.fromMap(Map<String, dynamic> map) {
    DateTime? timestamp;
    if (map['timestamp'] != null) {
      if (map['timestamp'] is Timestamp) {
        timestamp = (map['timestamp'] as Timestamp).toDate();
      } else if (map['timestamp'] is String) {
        timestamp = DateTime.tryParse(map['timestamp']);
      }
    }

    return NoticeModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      targetGrade: map['targetGrade'] ?? 'All',
      type: map['type'] ?? 'Alert',
      timestamp: timestamp ?? DateTime.now(),
      createdBy: map['createdBy'] ?? '',
    );
  }

  /// Get NoticeType enum from string
  NoticeType get noticeType {
    switch (type.toLowerCase()) {
      case 'webinar':
        return NoticeType.webinar;
      case 'session':
        return NoticeType.session;
      case 'workshop':
        return NoticeType.workshop;
      default:
        return NoticeType.alert;
    }
  }

  /// Get TargetGrade enum
  TargetGrade get targetGradeEnum => TargetGradeExt.fromString(targetGrade);

  /// Check if notice is relevant for a student grade
  bool isRelevantForGrade(int studentGrade) {
    if (targetGrade == 'All') return true;
    return targetGradeEnum.matchesGrade(studentGrade);
  }

  NoticeModel copyWith({
    String? id,
    String? title,
    String? body,
    String? targetGrade,
    String? type,
    DateTime? timestamp,
    String? createdBy,
  }) {
    return NoticeModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      targetGrade: targetGrade ?? this.targetGrade,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      createdBy: createdBy ?? this.createdBy,
    );
  }
}
