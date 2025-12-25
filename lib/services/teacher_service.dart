import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/teacher_models.dart';
import '../models/career_model.dart';

/// Teacher Service - REACTIVE Firestore Operations
/// Source of Truth for Teacher Dashboard
/// All operations use Streams for real-time sync
class TeacherService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static final TeacherService _instance = TeacherService._internal();
  factory TeacherService() => _instance;
  TeacherService._internal();

  // Collection references
  CollectionReference get _careersRef => _firestore.collection('careers');
  CollectionReference get _submissionsRef => _firestore.collection('submissions');
  CollectionReference get _careerNotesRef => _firestore.collection('career_notes');
  CollectionReference get _noticesRef => _firestore.collection('notices');
  CollectionReference get _opportunitiesRef => _firestore.collection('opportunities');
  CollectionReference get _quizzesRef => _firestore.collection('quizzes');
  CollectionReference get _quizAttemptsRef => _firestore.collection('quiz_attempts');
  CollectionReference get _studentActivityRef => _firestore.collection('student_activity');
  CollectionReference get _doubtsRef => _firestore.collection('doubts');

  // ============================================================
  // CAREER FACTORY - REACTIVE CRUD
  // ============================================================

  /// Create a new managed career
  Future<String> createCareer(ManagedCareer career) async {
    debugPrint('📝 [TeacherService] Creating career: ${career.title}');
    try {
      final docRef = await _careersRef.add(career.toMap());
      // Update with generated ID
      await docRef.update({'id': docRef.id});
      debugPrint('✅ [TeacherService] Career created: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('❌ [TeacherService] Error creating career: $e');
      rethrow;
    }
  }

  /// Update an existing career
  Future<void> updateCareer(String careerId, Map<String, dynamic> updates) async {
    debugPrint('📝 [TeacherService] Updating career: $careerId');
    try {
      updates['updatedAt'] = DateTime.now().toIso8601String();
      await _careersRef.doc(careerId).update(updates);
      debugPrint('✅ [TeacherService] Career updated');
    } catch (e) {
      debugPrint('❌ [TeacherService] Error updating career: $e');
      rethrow;
    }
  }

  /// Delete a career
  Future<void> deleteCareer(String careerId) async {
    debugPrint('🗑️ [TeacherService] Deleting career: $careerId');
    try {
      await _careersRef.doc(careerId).delete();
      debugPrint('✅ [TeacherService] Career deleted');
    } catch (e) {
      debugPrint('❌ [TeacherService] Error deleting career: $e');
      rethrow;
    }
  }

  /// STREAM: All careers (real-time)
  Stream<List<ManagedCareer>> careersStream() {
    return _careersRef.orderBy('title').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return ManagedCareer.fromMap(data);
      }).toList();
    });
  }

  /// STREAM: Careers visible for a specific grade (for Student Dashboard)
  Stream<List<ManagedCareer>> careersForGradeStream(int grade) {
    final gradeField = 'gradeVisibility.grade$grade';
    return _careersRef
        .where(gradeField, isEqualTo: true)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return ManagedCareer.fromMap(data);
      }).toList();
    });
  }

  /// Update grade visibility for a career (instant sync to students)
  Future<void> updateCareerVisibility(String careerId, GradeVisibility visibility) async {
    try {
      await _careersRef.doc(careerId).update({
        'gradeVisibility': visibility.toMap(),
        'updatedAt': DateTime.now().toIso8601String(),
      });
      debugPrint('✅ [TeacherService] Visibility updated - students will see changes instantly');
    } catch (e) {
      debugPrint('❌ [TeacherService] Error updating visibility: $e');
      rethrow;
    }
  }

  /// Toggle career active status
  Future<void> toggleCareerActive(String careerId, bool isActive) async {
    try {
      await _careersRef.doc(careerId).update({
        'isActive': isActive,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('❌ [TeacherService] Error toggling career: $e');
      rethrow;
    }
  }

  // ============================================================
  // DOUBTS / Q&A ENGINE - REACTIVE
  // ============================================================

  /// Student: Ask a doubt
  Future<String> askDoubt(Doubt doubt) async {
    debugPrint('❓ [TeacherService] Student asking doubt');
    try {
      final docRef = await _doubtsRef.add(doubt.toMap());
      await docRef.update({'id': docRef.id});
      debugPrint('✅ [TeacherService] Doubt submitted: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('❌ [TeacherService] Error submitting doubt: $e');
      rethrow;
    }
  }

  /// Teacher: Answer a doubt (sets isResolved: true)
  Future<void> answerDoubt({
    required String doubtId,
    required String answer,
    required String teacherId,
    required String teacherName,
  }) async {
    debugPrint('💬 [TeacherService] Teacher answering doubt: $doubtId');
    try {
      await _doubtsRef.doc(doubtId).update({
        'answer': answer,
        'answeredBy': teacherId,
        'answeredByName': teacherName,
        'isResolved': true,
        'answeredAt': DateTime.now().toIso8601String(),
      });
      debugPrint('✅ [TeacherService] Doubt answered - student will see instantly');
    } catch (e) {
      debugPrint('❌ [TeacherService] Error answering doubt: $e');
      rethrow;
    }
  }

  /// STREAM: All unresolved doubts (for Teacher's Doubts Hub)
  /// Note: Sorting done locally to avoid composite index requirement
  Stream<List<Doubt>> unresolvedDoubtsStream() {
    return _doubtsRef.snapshots().map((snapshot) {
      final doubts = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Doubt.fromMap(data);
      }).where((d) => !d.isResolved).toList();
      // Sort locally by createdAt descending
      doubts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return doubts;
    });
  }

  /// STREAM: All doubts (for Teacher)
  /// Note: Sorting done locally to avoid index issues
  Stream<List<Doubt>> allDoubtsStream() {
    return _doubtsRef.snapshots().map((snapshot) {
      final doubts = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Doubt.fromMap(data);
      }).toList();
      // Sort locally by createdAt descending
      doubts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return doubts;
    });
  }

  /// STREAM: Student's own doubts (for "My Doubts" page)
  /// Note: Sorting done locally to avoid composite index requirement
  Stream<List<Doubt>> studentDoubtsStream(String studentId) {
    return _doubtsRef.snapshots().map((snapshot) {
      final doubts = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Doubt.fromMap(data);
      }).where((d) => d.studentId == studentId).toList();
      // Sort locally by createdAt descending
      doubts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return doubts;
    });
  }

  // ============================================================
  // STUDENT SUBMISSIONS - REACTIVE
  // ============================================================

  /// Student: Submit a task/reflection
  Future<String> submitTask(StudentSubmission submission) async {
    debugPrint('📤 [TeacherService] Student submitting task');
    try {
      final docRef = await _submissionsRef.add(submission.toMap());
      await docRef.update({'id': docRef.id});
      debugPrint('✅ [TeacherService] Submission created: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('❌ [TeacherService] Error submitting task: $e');
      rethrow;
    }
  }

  /// STREAM: Pending submissions (for Teacher's Review Hub)
  /// Note: Sorting done locally to avoid composite index requirement
  Stream<List<StudentSubmission>> pendingSubmissionsStream() {
    return _submissionsRef.snapshots().map((snapshot) {
      final submissions = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return StudentSubmission.fromMap(data);
      }).where((s) => s.status == SubmissionStatus.pending).toList();
      submissions.sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
      return submissions;
    });
  }

  /// STREAM: All submissions with optional status filter
  /// Note: Sorting done locally to avoid composite index requirement
  Stream<List<StudentSubmission>> submissionsStream({SubmissionStatus? status}) {
    return _submissionsRef.snapshots().map((snapshot) {
      final submissions = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return StudentSubmission.fromMap(data);
      }).where((s) => status == null || s.status == status).toList();
      submissions.sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
      return submissions;
    });
  }

  /// STREAM: Student's own submissions
  /// Note: Sorting done locally to avoid composite index requirement
  Stream<List<StudentSubmission>> studentSubmissionsStream(String studentId) {
    return _submissionsRef.snapshots().map((snapshot) {
      final submissions = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return StudentSubmission.fromMap(data);
      }).where((s) => s.studentId == studentId).toList();
      submissions.sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
      return submissions;
    });
  }

  /// Teacher: Review a submission
  Future<void> reviewSubmission({
    required String submissionId,
    required SubmissionStatus newStatus,
    required String teacherComment,
    required String teacherId,
  }) async {
    try {
      await _submissionsRef.doc(submissionId).update({
        'status': newStatus.name,
        'teacherComment': teacherComment,
        'reviewedAt': DateTime.now().toIso8601String(),
        'reviewedBy': teacherId,
      });
      debugPrint('✅ [TeacherService] Submission reviewed - student notified instantly');
    } catch (e) {
      debugPrint('❌ [TeacherService] Error reviewing submission: $e');
      rethrow;
    }
  }

  // ============================================================
  // NOTICES - REACTIVE
  // ============================================================

  /// Create a notice
  Future<String> createNotice(Notice notice) async {
    try {
      final docRef = await _noticesRef.add(notice.toMap());
      await docRef.update({'id': docRef.id});
      debugPrint('✅ [TeacherService] Notice created: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('❌ [TeacherService] Error creating notice: $e');
      rethrow;
    }
  }

  /// Update a notice
  Future<void> updateNotice(String noticeId, Map<String, dynamic> updates) async {
    try {
      await _noticesRef.doc(noticeId).update(updates);
    } catch (e) {
      debugPrint('❌ [TeacherService] Error updating notice: $e');
      rethrow;
    }
  }

  /// Delete a notice
  Future<void> deleteNotice(String noticeId) async {
    try {
      await _noticesRef.doc(noticeId).delete();
    } catch (e) {
      debugPrint('❌ [TeacherService] Error deleting notice: $e');
      rethrow;
    }
  }

  /// STREAM: All active notices (for Teacher)
  /// Note: Sorting done locally to avoid composite index requirement
  Stream<List<Notice>> noticesStream() {
    return _noticesRef.snapshots().map((snapshot) {
      final notices = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Notice.fromMap(data);
      }).where((n) => n.isActive).toList();
      notices.sort((a, b) => a.eventDate.compareTo(b.eventDate));
      return notices;
    });
  }

  /// STREAM: Notices for a specific grade (for Student's Notice Tab)
  /// Note: Sorting done locally to avoid composite index requirement
  Stream<List<Notice>> noticesForGradeStream(int grade) {
    return _noticesRef.snapshots().map((snapshot) {
      final notices = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Notice.fromMap(data);
      }).where((notice) {
        return notice.isActive && (notice.targetGrades.isEmpty || notice.targetGrades.contains(grade));
      }).toList();
      notices.sort((a, b) => a.eventDate.compareTo(b.eventDate));
      return notices;
    });
  }

  // ============================================================
  // OPPORTUNITIES - REACTIVE
  // ============================================================

  /// Create an opportunity
  Future<String> createOpportunity(Opportunity opportunity) async {
    try {
      final docRef = await _opportunitiesRef.add(opportunity.toMap());
      await docRef.update({'id': docRef.id});
      return docRef.id;
    } catch (e) {
      debugPrint('❌ [TeacherService] Error creating opportunity: $e');
      rethrow;
    }
  }

  /// STREAM: All opportunities
  Stream<List<Opportunity>> opportunitiesStream() {
    return _opportunitiesRef
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Opportunity.fromMap(data);
      }).toList();
    });
  }

  /// STREAM: Opportunities for a specific grade
  Stream<List<Opportunity>> opportunitiesForGradeStream(int grade) {
    return _opportunitiesRef
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Opportunity.fromMap(data);
      }).where((opp) {
        return opp.targetGrades.isEmpty || opp.targetGrades.contains(grade);
      }).toList();
    });
  }

  // ============================================================
  // CAREER NOTES - REACTIVE
  // ============================================================

  /// Add a career note for a student
  Future<String> addCareerNote(CareerNote note) async {
    try {
      final docRef = await _careerNotesRef.add(note.toMap());
      await docRef.update({'id': docRef.id});
      return docRef.id;
    } catch (e) {
      debugPrint('❌ [TeacherService] Error adding note: $e');
      rethrow;
    }
  }

  /// STREAM: Career notes for a student (syncs to student dashboard)
  /// Note: Sorting done locally to avoid composite index requirement
  Stream<List<CareerNote>> careerNotesStream(String studentId) {
    return _careerNotesRef.snapshots().map((snapshot) {
      final notes = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return CareerNote.fromMap(data);
      }).where((n) => n.studentId == studentId).toList();
      notes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return notes;
    });
  }

  // ============================================================
  // QUIZZES - REACTIVE
  // ============================================================

  /// Create a quiz
  Future<String> createQuiz(Quiz quiz) async {
    try {
      final docRef = await _quizzesRef.add(quiz.toMap());
      await docRef.update({'id': docRef.id});
      return docRef.id;
    } catch (e) {
      debugPrint('❌ [TeacherService] Error creating quiz: $e');
      rethrow;
    }
  }

  /// Update a quiz
  Future<void> updateQuiz(Quiz quiz) async {
    try {
      await _quizzesRef.doc(quiz.id).update(quiz.toMap());
      debugPrint('✅ [TeacherService] Quiz updated');
    } catch (e) {
      debugPrint('❌ [TeacherService] Error updating quiz: $e');
      rethrow;
    }
  }

  /// Delete a quiz
  Future<void> deleteQuiz(String quizId) async {
    try {
      await _quizzesRef.doc(quizId).delete();
      debugPrint('✅ [TeacherService] Quiz deleted');
    } catch (e) {
      debugPrint('❌ [TeacherService] Error deleting quiz: $e');
      rethrow;
    }
  }

  /// STREAM: All quizzes
  Stream<List<Quiz>> quizzesStream() {
    return _quizzesRef.orderBy('createdAt', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Quiz.fromMap(data);
      }).toList();
    });
  }

  /// STREAM: Quizzes for a specific grade
  Stream<List<Quiz>> quizzesForGradeStream(int grade) {
    return _quizzesRef
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Quiz.fromMap(data);
      }).where((quiz) {
        return quiz.targetGrades.isEmpty || quiz.targetGrades.contains(grade);
      }).toList();
    });
  }

  /// Submit quiz attempt
  Future<String> submitQuizAttempt(QuizAttempt attempt) async {
    try {
      final docRef = await _quizAttemptsRef.add(attempt.toMap());
      await docRef.update({'id': docRef.id});
      return docRef.id;
    } catch (e) {
      debugPrint('❌ [TeacherService] Error submitting attempt: $e');
      rethrow;
    }
  }

  /// STREAM: Quiz attempts for a quiz
  /// Note: Sorting done locally to avoid composite index requirement
  Stream<List<QuizAttempt>> quizAttemptsStream(String quizId) {
    return _quizAttemptsRef.snapshots().map((snapshot) {
      final attempts = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return QuizAttempt.fromMap(data);
      }).where((a) => a.quizId == quizId).toList();
      attempts.sort((a, b) => b.attemptedAt.compareTo(a.attemptedAt));
      return attempts;
    });
  }

  // ============================================================
  // STUDENT ACTIVITY - REACTIVE
  // ============================================================

  /// Record student login
  Future<void> recordStudentLogin(String studentId, String studentName, int grade) async {
    try {
      await _studentActivityRef.doc(studentId).set({
        'studentId': studentId,
        'studentName': studentName,
        'grade': grade,
        'lastLoginAt': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('❌ [TeacherService] Error recording login: $e');
    }
  }

  /// Record career exploration
  Future<void> recordCareerExploration(String studentId, String careerId) async {
    try {
      await _studentActivityRef.doc(studentId).update({
        'careersExplored': FieldValue.increment(1),
        'exploredCareerIds': FieldValue.arrayUnion([careerId]),
      });
    } catch (e) {
      debugPrint('❌ [TeacherService] Error recording exploration: $e');
    }
  }

  /// STREAM: All student activities
  Stream<List<StudentActivity>> studentActivitiesStream() {
    return _studentActivityRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return StudentActivity.fromMap(data);
      }).toList();
    });
  }

  /// STREAM: Inactive students (>7 days)
  Stream<List<StudentActivity>> inactiveStudentsStream() {
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    return _studentActivityRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return StudentActivity.fromMap(data);
      }).where((activity) => activity.isInactive).toList();
    });
  }

  /// Get all student activities (non-stream version for initial load)
  Future<List<StudentActivity>> getAllStudentActivities() async {
    try {
      final snapshot = await _studentActivityRef.get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return StudentActivity.fromMap(data);
      }).toList();
    } catch (e) {
      debugPrint('❌ [TeacherService] Error fetching activities: $e');
      return [];
    }
  }

  // ============================================================
  // UTILITY
  // ============================================================

  String generateId() => _firestore.collection('_').doc().id;
}
