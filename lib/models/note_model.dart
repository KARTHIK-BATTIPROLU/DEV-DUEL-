// Note Model - Career Insights saved by students
// Firestore Schema: users/{userId}/my_notes/{noteId}

import 'package:cloud_firestore/cloud_firestore.dart';

/// NoteModel - Student's saved career insights
/// Stored in sub-collection: users/{userId}/my_notes/{noteId}
class NoteModel {
  final String id;
  final String oderId;
  final String careerId;
  final String careerTitle;
  final String noteContent;
  final DateTime? timestamp;

  NoteModel({
    required this.id,
    required this.oderId,
    required this.careerId,
    required this.careerTitle,
    required this.noteContent,
    this.timestamp,
  });

  /// Convert to Firestore Map (for writing)
  /// Uses FieldValue.serverTimestamp() for consistent ordering
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': oderId,
      'careerId': careerId,
      'careerTitle': careerTitle,
      'noteContent': noteContent,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }

  /// Create from Firestore Document
  factory NoteModel.fromMap(Map<String, dynamic> map) {
    DateTime? timestamp;
    if (map['timestamp'] != null) {
      if (map['timestamp'] is Timestamp) {
        timestamp = (map['timestamp'] as Timestamp).toDate();
      } else if (map['timestamp'] is String) {
        timestamp = DateTime.tryParse(map['timestamp']);
      }
    }

    return NoteModel(
      id: map['id'] ?? '',
      oderId: map['userId'] ?? '',
      careerId: map['careerId'] ?? '',
      careerTitle: map['careerTitle'] ?? '',
      noteContent: map['noteContent'] ?? '',
      timestamp: timestamp ?? DateTime.now(),
    );
  }

  NoteModel copyWith({
    String? id,
    String? oderId,
    String? careerId,
    String? careerTitle,
    String? noteContent,
    DateTime? timestamp,
  }) {
    return NoteModel(
      id: id ?? this.id,
      oderId: oderId ?? this.oderId,
      careerId: careerId ?? this.careerId,
      careerTitle: careerTitle ?? this.careerTitle,
      noteContent: noteContent ?? this.noteContent,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
