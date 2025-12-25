import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/teacher_models.dart';
import '../models/career_model.dart';
import '../models/user_model.dart';

/// Teacher Service - Handles all teacher management operations
/// Career Factory, Student Oversight, Academy Management
class TeacherService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static final TeacherService _instance = TeacherService._internal();
  factory TeacherService() => _instance;
  TeacherService._internal();

  // Collection references
  CollectionReference get _careersRef => _firestore.collection('managed_careers');
  CollectionReference get _submissionsRef => _firestore.collection('submissions');
  CollectionReference get _careerNotesRef => _firestore.collection('career_notes');
  CollectionReference get _noticesRef => _firestore.collection('notices');
  CollectionReference get _opportunitiesRef => _firestore.collection('opportunities');
  CollectionReference get _quizzesRef => _firestore.collection('quizzes');
  CollectionReference get _quizAttemptsRef => _firestore.collection('quiz_attempts');
  CollectionReference get _studentActivityRef => _firestore.collection('student_activity');

  // ============================================================
  // CAREER FACTORY - CRUD Operations
  // ============================================================

  /// Create a new managed career
  Future<ManagedCareer> createCareer(ManagedCareer career) async {
    debugPrint('📝 [TeacherService] Creating career: ${career.title}');
    try {
      final docRef = _careersRef.doc(career.id);
      await docRef.set(career.toMap());
      debugPrint('✅ [TeacherService] Career created: ${career.id}');
      return career;
    } catch (e) {
      debugPrint('❌ [TeacherService] Error creating career: $e');
      rethrow;
    }
  }

  /// Update an existing career
  Future<void> updateCareer(ManagedCareer career) async {
    debugPrint('📝 [TeacherService] Updating career: ${career.id}');
    try {
      await _careersRef.doc(career.id).update(career.toMap());
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

  /// Get all managed careers
  Future<List<ManagedCareer>> getAllCareers() async {
    try {
      final snapshot = await _careersRef.orderBy('title').get();
      return snapshot.docs.map((doc) => ManagedCareer.fromMap(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('❌ [TeacherService] Error fetching careers: $e');
      return [];
    }
  }

  /// Stream of all careers (real-time)
  Stream<List<ManagedCareer>> careersStream() {
    return _careersRef.orderBy('title').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => ManagedCareer.fromMap(doc.data() as Map<String, dynamic>)).toList());
  }

  /// Get careers visible for a specific grade
  Future<List<ManagedCareer>> getCareersForGrade(int grade) async {
    try {
      final careers = await getAllCareers();
      return careers.where((c) => c.isActive && c.gradeVisibility.isVisibleForGrade(grade)).toList();
    } catch (e) {
      debugPrint('❌ [TeacherService] Error fetching careers for grade: $e');
      return [];
    }
  }

  /// Update grade visibility for a career
  Future<void> updateCareerVisibility(String careerId, GradeVisibility visibility) async {
    try {
      await _careersRef.doc(careerId).update({'gradeVisibility': visibility.toMap(), 'updatedAt': DateTime.now().toIso8601String()});
    } catch (e) {
      debugPrint('❌ [TeacherService] Error updating visibility: $e');
      rethrow;
    }
  }

  /// Toggle career active status
  Future<void> toggleCareerActive(String careerId, bool isActive) async {
    try {
      await _careersRef.doc(careerId).update({'isActive': isActive, 'updatedAt': DateTime.now().toIso8601String()});
    } catch (e) {
      debugPrint('❌ [TeacherService] Error toggling career: $e');
      rethrow;
    }
  }


  // ============================================================
  // STUDENT SUBMISSIONS & REVIEW
  // ============================================================

  /// Get all pending submissions
  Future<List<StudentSubmission>> getPendingSubmissions() async {
    try {
      final snapshot = await _submissionsRef
          .where('status', isEqualTo: SubmissionStatus.pending.name)
          .orderBy('submittedAt', descending: true)
          .get();
      return snapshot.docs.map((doc) => StudentSubmission.fromMap(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('❌ [TeacherService] Error fetching submissions: $e');
      return [];
    }
  }

  /// Stream of pending submissions (real-time)
  Stream<List<StudentSubmission>> pendingSubmissionsStream() {
    return _submissionsRef
        .where('status', isEqualTo: SubmissionStatus.pending.name)
        .orderBy('submittedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => StudentSubmission.fromMap(doc.data() as Map<String, dynamic>)).toList());
  }

  /// Get all submissions (with optional status filter)
  Future<List<StudentSubmission>> getSubmissions({SubmissionStatus? status}) async {
    try {
      Query query = _submissionsRef.orderBy('submittedAt', descending: true);
      if (status != null) {
        query = query.where('status', isEqualTo: status.name);
      }
      final snapshot = await query.get();
      return snapshot.docs.map((doc) => StudentSubmission.fromMap(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('❌ [TeacherService] Error fetching submissions: $e');
      return [];
    }
  }

  /// Review a submission (approve/reject/revision)
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
      debugPrint('✅ [TeacherService] Submission reviewed');
    } catch (e) {
      debugPrint('❌ [TeacherService] Error reviewing submission: $e');
      rethrow;
    }
  }

  // ============================================================
  // PERSONALIZED CAREER NOTES
  // ============================================================

  /// Add a career note for a student
  Future<CareerNote> addCareerNote(CareerNote note) async {
    try {
      final docRef = _careerNotesRef.doc(note.id);
      await docRef.set(note.toMap());
      debugPrint('✅ [TeacherService] Career note added');
      return note;
    } catch (e) {
      debugPrint('❌ [TeacherService] Error adding note: $e');
      rethrow;
    }
  }

  /// Get career notes for a student
  Future<List<CareerNote>> getCareerNotesForStudent(String studentId) async {
    try {
      final snapshot = await _careerNotesRef
          .where('studentId', isEqualTo: studentId)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map((doc) => CareerNote.fromMap(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('❌ [TeacherService] Error fetching notes: $e');
      return [];
    }
  }

  /// Stream of career notes for a student (real-time for student dashboard)
  Stream<List<CareerNote>> careerNotesStream(String studentId) {
    return _careerNotesRef
        .where('studentId', isEqualTo: studentId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => CareerNote.fromMap(doc.data() as Map<String, dynamic>)).toList());
  }

  /// Update a career note
  Future<void> updateCareerNote(String noteId, String newNote, List<String> recommendedCareers) async {
    try {
      await _careerNotesRef.doc(noteId).update({
        'note': newNote,
        'recommendedCareers': recommendedCareers,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('❌ [TeacherService] Error updating note: $e');
      rethrow;
    }
  }

  /// Delete a career note
  Future<void> deleteCareerNote(String noteId) async {
    try {
      await _careerNotesRef.doc(noteId).delete();
    } catch (e) {
      debugPrint('❌ [TeacherService] Error deleting note: $e');
      rethrow;
    }
  }


  // ============================================================
  // NOTICE BOARD
  // ============================================================

  /// Create a notice
  Future<Notice> createNotice(Notice notice) async {
    try {
      final docRef = _noticesRef.doc(notice.id);
      await docRef.set(notice.toMap());
      debugPrint('✅ [TeacherService] Notice created');
      return notice;
    } catch (e) {
      debugPrint('❌ [TeacherService] Error creating notice: $e');
      rethrow;
    }
  }

  /// Get all active notices
  Future<List<Notice>> getActiveNotices() async {
    try {
      final snapshot = await _noticesRef
          .where('isActive', isEqualTo: true)
          .orderBy('eventDate')
          .get();
      return snapshot.docs.map((doc) => Notice.fromMap(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('❌ [TeacherService] Error fetching notices: $e');
      return [];
    }
  }

  /// Stream of notices (real-time)
  Stream<List<Notice>> noticesStream() {
    return _noticesRef
        .where('isActive', isEqualTo: true)
        .orderBy('eventDate')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Notice.fromMap(doc.data() as Map<String, dynamic>)).toList());
  }

  /// Get notices for a specific grade
  Future<List<Notice>> getNoticesForGrade(int grade) async {
    try {
      final notices = await getActiveNotices();
      return notices.where((n) => n.targetGrades.isEmpty || n.targetGrades.contains(grade)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Update a notice
  Future<void> updateNotice(Notice notice) async {
    try {
      await _noticesRef.doc(notice.id).update(notice.toMap());
    } catch (e) {
      debugPrint('❌ [TeacherService] Error updating notice: $e');
      rethrow;
    }
  }

  /// Cancel/deactivate a notice
  Future<void> cancelNotice(String noticeId) async {
    try {
      await _noticesRef.doc(noticeId).update({'isActive': false});
    } catch (e) {
      debugPrint('❌ [TeacherService] Error canceling notice: $e');
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

  // ============================================================
  // OPPORTUNITIES (Scholarships, Competitions, etc.)
  // ============================================================

  /// Create an opportunity
  Future<Opportunity> createOpportunity(Opportunity opportunity) async {
    try {
      final docRef = _opportunitiesRef.doc(opportunity.id);
      await docRef.set(opportunity.toMap());
      debugPrint('✅ [TeacherService] Opportunity created');
      return opportunity;
    } catch (e) {
      debugPrint('❌ [TeacherService] Error creating opportunity: $e');
      rethrow;
    }
  }

  /// Get all active opportunities
  Future<List<Opportunity>> getActiveOpportunities() async {
    try {
      final snapshot = await _opportunitiesRef
          .where('isActive', isEqualTo: true)
          .orderBy('deadline')
          .get();
      return snapshot.docs.map((doc) => Opportunity.fromMap(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('❌ [TeacherService] Error fetching opportunities: $e');
      return [];
    }
  }

  /// Stream of opportunities (real-time)
  Stream<List<Opportunity>> opportunitiesStream() {
    return _opportunitiesRef
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Opportunity.fromMap(doc.data() as Map<String, dynamic>)).toList());
  }

  /// Get opportunities for a specific grade
  Future<List<Opportunity>> getOpportunitiesForGrade(int grade) async {
    try {
      final opportunities = await getActiveOpportunities();
      return opportunities.where((o) => o.targetGrades.isEmpty || o.targetGrades.contains(grade)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Update an opportunity
  Future<void> updateOpportunity(Opportunity opportunity) async {
    try {
      await _opportunitiesRef.doc(opportunity.id).update(opportunity.toMap());
    } catch (e) {
      debugPrint('❌ [TeacherService] Error updating opportunity: $e');
      rethrow;
    }
  }

  /// Delete an opportunity
  Future<void> deleteOpportunity(String opportunityId) async {
    try {
      await _opportunitiesRef.doc(opportunityId).delete();
    } catch (e) {
      debugPrint('❌ [TeacherService] Error deleting opportunity: $e');
      rethrow;
    }
  }


  // ============================================================
  // QUIZ / ASSESSMENT LAB
  // ============================================================

  /// Create a quiz
  Future<Quiz> createQuiz(Quiz quiz) async {
    try {
      final docRef = _quizzesRef.doc(quiz.id);
      await docRef.set(quiz.toMap());
      debugPrint('✅ [TeacherService] Quiz created');
      return quiz;
    } catch (e) {
      debugPrint('❌ [TeacherService] Error creating quiz: $e');
      rethrow;
    }
  }

  /// Get all quizzes
  Future<List<Quiz>> getAllQuizzes() async {
    try {
      final snapshot = await _quizzesRef.orderBy('createdAt', descending: true).get();
      return snapshot.docs.map((doc) => Quiz.fromMap(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('❌ [TeacherService] Error fetching quizzes: $e');
      return [];
    }
  }

  /// Get quizzes for a specific grade
  Future<List<Quiz>> getQuizzesForGrade(int grade) async {
    try {
      final quizzes = await getAllQuizzes();
      return quizzes.where((q) => q.isActive && (q.targetGrades.isEmpty || q.targetGrades.contains(grade))).toList();
    } catch (e) {
      return [];
    }
  }

  /// Update a quiz
  Future<void> updateQuiz(Quiz quiz) async {
    try {
      await _quizzesRef.doc(quiz.id).update(quiz.toMap());
    } catch (e) {
      debugPrint('❌ [TeacherService] Error updating quiz: $e');
      rethrow;
    }
  }

  /// Delete a quiz
  Future<void> deleteQuiz(String quizId) async {
    try {
      await _quizzesRef.doc(quizId).delete();
    } catch (e) {
      debugPrint('❌ [TeacherService] Error deleting quiz: $e');
      rethrow;
    }
  }

  /// Get quiz attempts for a specific quiz
  Future<List<QuizAttempt>> getQuizAttempts(String quizId) async {
    try {
      final snapshot = await _quizAttemptsRef
          .where('quizId', isEqualTo: quizId)
          .orderBy('attemptedAt', descending: true)
          .get();
      return snapshot.docs.map((doc) => QuizAttempt.fromMap(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('❌ [TeacherService] Error fetching attempts: $e');
      return [];
    }
  }

  /// Get quiz attempts for a specific student
  Future<List<QuizAttempt>> getStudentQuizAttempts(String studentId) async {
    try {
      final snapshot = await _quizAttemptsRef
          .where('studentId', isEqualTo: studentId)
          .orderBy('attemptedAt', descending: true)
          .get();
      return snapshot.docs.map((doc) => QuizAttempt.fromMap(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('❌ [TeacherService] Error fetching student attempts: $e');
      return [];
    }
  }

  // ============================================================
  // STUDENT ACTIVITY & ANALYTICS
  // ============================================================

  /// Get all student activities
  Future<List<StudentActivity>> getAllStudentActivities() async {
    try {
      final snapshot = await _studentActivityRef.orderBy('lastLoginAt', descending: true).get();
      return snapshot.docs.map((doc) => StudentActivity.fromMap(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('❌ [TeacherService] Error fetching activities: $e');
      return [];
    }
  }

  /// Get inactive students (>7 days)
  Future<List<StudentActivity>> getInactiveStudents() async {
    try {
      final activities = await getAllStudentActivities();
      return activities.where((a) => a.isInactive).toList();
    } catch (e) {
      return [];
    }
  }

  /// Get student activity by ID
  Future<StudentActivity?> getStudentActivity(String studentId) async {
    try {
      final doc = await _studentActivityRef.doc(studentId).get();
      if (doc.exists) {
        return StudentActivity.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      debugPrint('❌ [TeacherService] Error fetching activity: $e');
      return null;
    }
  }

  /// Update student activity (called when student performs actions)
  Future<void> updateStudentActivity(StudentActivity activity) async {
    try {
      await _studentActivityRef.doc(activity.studentId).set(activity.toMap(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('❌ [TeacherService] Error updating activity: $e');
    }
  }

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

  /// Record task completion
  Future<void> recordTaskCompletion(String studentId) async {
    try {
      await _studentActivityRef.doc(studentId).update({
        'tasksCompleted': FieldValue.increment(1),
      });
    } catch (e) {
      debugPrint('❌ [TeacherService] Error recording task: $e');
    }
  }

  // ============================================================
  // UTILITY METHODS
  // ============================================================

  /// Generate unique ID
  String generateId() => _firestore.collection('_').doc().id;
}
