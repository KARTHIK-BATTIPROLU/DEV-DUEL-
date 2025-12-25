import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Mentorship Service - Connects Teacher actions to specific Students
/// Handles mentor notes, assigned tasks, and private sessions
class MentorshipService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static final MentorshipService _instance = MentorshipService._internal();
  factory MentorshipService() => _instance;
  MentorshipService._internal();

  // ============================================================
  // MENTOR NOTES - Sub-collection under users/{studentId}/mentor_notes
  // ============================================================

  /// Add a mentor note for a student
  Future<String> addMentorNote({
    required String studentId,
    required String content,
    required String teacherId,
    required String teacherName,
  }) async {
    debugPrint('📝 [MentorshipService] Adding note for student: $studentId');
    try {
      final docRef = await _firestore
          .collection('users')
          .doc(studentId)
          .collection('mentor_notes')
          .add({
        'content': content,
        'teacherId': teacherId,
        'teacherName': teacherName,
        'timestamp': FieldValue.serverTimestamp(),
        'createdAt': DateTime.now().toIso8601String(),
      });
      debugPrint('✅ [MentorshipService] Note added: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('❌ [MentorshipService] Error adding note: $e');
      rethrow;
    }
  }

  /// Update a mentor note
  Future<void> updateMentorNote({
    required String studentId,
    required String noteId,
    required String content,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(studentId)
          .collection('mentor_notes')
          .doc(noteId)
          .update({
        'content': content,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('❌ [MentorshipService] Error updating note: $e');
      rethrow;
    }
  }

  /// Delete a mentor note
  Future<void> deleteMentorNote({
    required String studentId,
    required String noteId,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(studentId)
          .collection('mentor_notes')
          .doc(noteId)
          .delete();
    } catch (e) {
      debugPrint('❌ [MentorshipService] Error deleting note: $e');
      rethrow;
    }
  }

  /// STREAM: Mentor notes for a student (real-time)
  Stream<List<MentorNote>> mentorNotesStream(String studentId) {
    return _firestore
        .collection('users')
        .doc(studentId)
        .collection('mentor_notes')
        .snapshots()
        .map((snapshot) {
      final notes = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return MentorNote.fromMap(data);
      }).toList();
      notes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return notes;
    });
  }

  // ============================================================
  // ASSIGNED TASKS - Sub-collection under users/{studentId}/assigned_tasks
  // ============================================================

  /// Assign a task to a student
  Future<String> assignTask({
    required String studentId,
    required String studentName,
    required String title,
    required String description,
    required String teacherId,
    required String teacherName,
    DateTime? dueDate,
    String? careerId,
    String? careerTitle,
  }) async {
    debugPrint('📋 [MentorshipService] Assigning task to student: $studentId');
    try {
      final docRef = await _firestore
          .collection('users')
          .doc(studentId)
          .collection('assigned_tasks')
          .add({
        'title': title,
        'description': description,
        'teacherId': teacherId,
        'teacherName': teacherName,
        'studentId': studentId,
        'studentName': studentName,
        'careerId': careerId,
        'careerTitle': careerTitle,
        'dueDate': dueDate?.toIso8601String(),
        'status': 'pending',
        'createdAt': DateTime.now().toIso8601String(),
      });
      debugPrint('✅ [MentorshipService] Task assigned: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('❌ [MentorshipService] Error assigning task: $e');
      rethrow;
    }
  }

  /// Update task status
  Future<void> updateTaskStatus({
    required String studentId,
    required String taskId,
    required String status,
    String? studentResponse,
  }) async {
    try {
      final updates = <String, dynamic>{
        'status': status,
        'updatedAt': DateTime.now().toIso8601String(),
      };
      if (studentResponse != null) {
        updates['studentResponse'] = studentResponse;
        updates['completedAt'] = DateTime.now().toIso8601String();
      }
      await _firestore
          .collection('users')
          .doc(studentId)
          .collection('assigned_tasks')
          .doc(taskId)
          .update(updates);
    } catch (e) {
      debugPrint('❌ [MentorshipService] Error updating task: $e');
      rethrow;
    }
  }

  /// Delete an assigned task
  Future<void> deleteTask({
    required String studentId,
    required String taskId,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(studentId)
          .collection('assigned_tasks')
          .doc(taskId)
          .delete();
    } catch (e) {
      debugPrint('❌ [MentorshipService] Error deleting task: $e');
      rethrow;
    }
  }

  /// STREAM: Assigned tasks for a student (real-time)
  Stream<List<AssignedTask>> assignedTasksStream(String studentId) {
    return _firestore
        .collection('users')
        .doc(studentId)
        .collection('assigned_tasks')
        .snapshots()
        .map((snapshot) {
      final tasks = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return AssignedTask.fromMap(data);
      }).toList();
      tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return tasks;
    });
  }

  // ============================================================
  // PRIVATE SESSIONS - In notices collection with isPrivate flag
  // ============================================================

  /// Schedule a private session with a student
  Future<String> schedulePrivateSession({
    required String studentId,
    required String studentName,
    required String title,
    required String description,
    required DateTime sessionDate,
    required String sessionTime,
    String? meetingLink,
    required String teacherId,
    required String teacherName,
  }) async {
    debugPrint('📅 [MentorshipService] Scheduling session for student: $studentId');
    try {
      final docRef = await _firestore.collection('notices').add({
        'title': title,
        'description': description,
        'type': 'session',
        'eventDate': sessionDate.toIso8601String(),
        'eventTime': sessionTime,
        'meetingLink': meetingLink,
        'isPrivate': true,
        'targetStudentId': studentId,
        'targetStudentName': studentName,
        'targetGrades': [],
        'isActive': true,
        'createdAt': DateTime.now().toIso8601String(),
        'createdBy': teacherId,
        'createdByName': teacherName,
      });
      await docRef.update({'id': docRef.id});
      debugPrint('✅ [MentorshipService] Session scheduled: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('❌ [MentorshipService] Error scheduling session: $e');
      rethrow;
    }
  }

  /// STREAM: Private sessions for a specific student
  Stream<List<PrivateSession>> privateSessionsStream(String studentId) {
    return _firestore
        .collection('notices')
        .where('isPrivate', isEqualTo: true)
        .where('targetStudentId', isEqualTo: studentId)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      final sessions = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return PrivateSession.fromMap(data);
      }).toList();
      sessions.sort((a, b) => a.eventDate.compareTo(b.eventDate));
      return sessions;
    });
  }

  /// Cancel a private session
  Future<void> cancelSession(String sessionId) async {
    try {
      await _firestore.collection('notices').doc(sessionId).update({
        'isActive': false,
        'cancelledAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('❌ [MentorshipService] Error cancelling session: $e');
      rethrow;
    }
  }

  // ============================================================
  // STATISTICS
  // ============================================================

  /// Get mentorship stats for a student
  Future<MentorshipStats> getStudentStats(String studentId) async {
    try {
      final notesSnapshot = await _firestore
          .collection('users')
          .doc(studentId)
          .collection('mentor_notes')
          .get();

      final tasksSnapshot = await _firestore
          .collection('users')
          .doc(studentId)
          .collection('assigned_tasks')
          .get();

      final completedTasks = tasksSnapshot.docs
          .where((doc) => doc.data()['status'] == 'completed')
          .length;

      final sessionsSnapshot = await _firestore
          .collection('notices')
          .where('isPrivate', isEqualTo: true)
          .where('targetStudentId', isEqualTo: studentId)
          .get();

      return MentorshipStats(
        totalNotes: notesSnapshot.docs.length,
        totalTasks: tasksSnapshot.docs.length,
        completedTasks: completedTasks,
        totalSessions: sessionsSnapshot.docs.length,
      );
    } catch (e) {
      debugPrint('❌ [MentorshipService] Error getting stats: $e');
      return MentorshipStats.empty();
    }
  }
}

// ============================================================
// MODELS
// ============================================================

class MentorNote {
  final String id;
  final String content;
  final String teacherId;
  final String teacherName;
  final DateTime createdAt;
  final DateTime? updatedAt;

  MentorNote({
    required this.id,
    required this.content,
    required this.teacherId,
    required this.teacherName,
    required this.createdAt,
    this.updatedAt,
  });

  factory MentorNote.fromMap(Map<String, dynamic> map) => MentorNote(
    id: map['id'] ?? '',
    content: map['content'] ?? '',
    teacherId: map['teacherId'] ?? '',
    teacherName: map['teacherName'] ?? '',
    createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    updatedAt: map['updatedAt'] != null ? DateTime.tryParse(map['updatedAt']) : null,
  );
}

class AssignedTask {
  final String id;
  final String title;
  final String description;
  final String teacherId;
  final String teacherName;
  final String studentId;
  final String studentName;
  final String? careerId;
  final String? careerTitle;
  final DateTime? dueDate;
  final String status; // pending, in_progress, completed
  final String? studentResponse;
  final DateTime createdAt;
  final DateTime? completedAt;

  AssignedTask({
    required this.id,
    required this.title,
    required this.description,
    required this.teacherId,
    required this.teacherName,
    required this.studentId,
    required this.studentName,
    this.careerId,
    this.careerTitle,
    this.dueDate,
    required this.status,
    this.studentResponse,
    required this.createdAt,
    this.completedAt,
  });

  bool get isPending => status == 'pending';
  bool get isCompleted => status == 'completed';
  bool get isOverdue => dueDate != null && dueDate!.isBefore(DateTime.now()) && !isCompleted;

  factory AssignedTask.fromMap(Map<String, dynamic> map) => AssignedTask(
    id: map['id'] ?? '',
    title: map['title'] ?? '',
    description: map['description'] ?? '',
    teacherId: map['teacherId'] ?? '',
    teacherName: map['teacherName'] ?? '',
    studentId: map['studentId'] ?? '',
    studentName: map['studentName'] ?? '',
    careerId: map['careerId'],
    careerTitle: map['careerTitle'],
    dueDate: map['dueDate'] != null ? DateTime.tryParse(map['dueDate']) : null,
    status: map['status'] ?? 'pending',
    studentResponse: map['studentResponse'],
    createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    completedAt: map['completedAt'] != null ? DateTime.tryParse(map['completedAt']) : null,
  );
}

class PrivateSession {
  final String id;
  final String title;
  final String description;
  final DateTime eventDate;
  final String eventTime;
  final String? meetingLink;
  final String targetStudentId;
  final String targetStudentName;
  final String createdBy;
  final String createdByName;
  final bool isActive;
  final DateTime createdAt;

  PrivateSession({
    required this.id,
    required this.title,
    required this.description,
    required this.eventDate,
    required this.eventTime,
    this.meetingLink,
    required this.targetStudentId,
    required this.targetStudentName,
    required this.createdBy,
    required this.createdByName,
    required this.isActive,
    required this.createdAt,
  });

  bool get isUpcoming => eventDate.isAfter(DateTime.now());

  factory PrivateSession.fromMap(Map<String, dynamic> map) => PrivateSession(
    id: map['id'] ?? '',
    title: map['title'] ?? '',
    description: map['description'] ?? '',
    eventDate: DateTime.tryParse(map['eventDate'] ?? '') ?? DateTime.now(),
    eventTime: map['eventTime'] ?? '',
    meetingLink: map['meetingLink'],
    targetStudentId: map['targetStudentId'] ?? '',
    targetStudentName: map['targetStudentName'] ?? '',
    createdBy: map['createdBy'] ?? '',
    createdByName: map['createdByName'] ?? '',
    isActive: map['isActive'] ?? true,
    createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
  );
}

class MentorshipStats {
  final int totalNotes;
  final int totalTasks;
  final int completedTasks;
  final int totalSessions;

  MentorshipStats({
    required this.totalNotes,
    required this.totalTasks,
    required this.completedTasks,
    required this.totalSessions,
  });

  factory MentorshipStats.empty() => MentorshipStats(
    totalNotes: 0,
    totalTasks: 0,
    completedTasks: 0,
    totalSessions: 0,
  );

  int get pendingTasks => totalTasks - completedTasks;
}
