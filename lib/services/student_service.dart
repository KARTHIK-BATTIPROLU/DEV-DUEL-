import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/teacher_models.dart';
import '../models/career_model.dart';

/// Student Service - REACTIVE Firestore Operations
/// Live Listener for Student Dashboard
/// All data syncs instantly from Teacher's changes
class StudentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static final StudentService _instance = StudentService._internal();
  factory StudentService() => _instance;
  StudentService._internal();

  // Collection references
  CollectionReference get _careersRef => _firestore.collection('careers');
  CollectionReference get _submissionsRef => _firestore.collection('submissions');
  CollectionReference get _noticesRef => _firestore.collection('notices');
  CollectionReference get _opportunitiesRef => _firestore.collection('opportunities');
  CollectionReference get _doubtsRef => _firestore.collection('doubts');
  CollectionReference get _quizzesRef => _firestore.collection('quizzes');
  CollectionReference get _quizAttemptsRef => _firestore.collection('quiz_attempts');
  CollectionReference get _careerNotesRef => _firestore.collection('career_notes');
  CollectionReference get _studentActivityRef => _firestore.collection('student_activity');

  // ============================================================
  // CAREERS - LIVE STREAM (Updates instantly when teacher changes)
  // ============================================================

  /// STREAM: Careers visible for student's grade
  /// This is the CORE reactive query - updates instantly when teacher toggles visibility
  Stream<List<ManagedCareer>> careersForGradeStream(int grade) {
    debugPrint('🔄 [StudentService] Streaming careers for grade $grade');
    final gradeField = 'gradeVisibility.grade$grade';
    
    return _careersRef
        .where(gradeField, isEqualTo: true)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      debugPrint('📥 [StudentService] Received ${snapshot.docs.length} careers for grade $grade');
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return ManagedCareer.fromMap(data);
      }).toList();
    });
  }

  /// Get a single career by ID
  Future<ManagedCareer?> getCareerById(String careerId) async {
    try {
      final doc = await _careersRef.doc(careerId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return ManagedCareer.fromMap(data);
      }
      return null;
    } catch (e) {
      debugPrint('❌ [StudentService] Error fetching career: $e');
      return null;
    }
  }

  // ============================================================
  // DOUBTS - ASK & TRACK
  // ============================================================

  /// Ask a doubt (creates new document)
  Future<String> askDoubt({
    required String studentId,
    required String studentName,
    required int studentGrade,
    required String question,
    String? careerId,
    String? careerTitle,
  }) async {
    debugPrint('❓ [StudentService] Asking doubt');
    try {
      final doubt = Doubt(
        id: '',
        studentId: studentId,
        studentName: studentName,
        studentGrade: studentGrade,
        question: question,
        careerId: careerId,
        careerTitle: careerTitle,
        createdAt: DateTime.now(),
      );
      
      final docRef = await _doubtsRef.add(doubt.toMap());
      await docRef.update({'id': docRef.id});
      debugPrint('✅ [StudentService] Doubt submitted: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('❌ [StudentService] Error asking doubt: $e');
      rethrow;
    }
  }

  /// STREAM: My doubts (updates instantly when teacher answers)
  /// Note: Sorting done locally to avoid composite index requirement
  Stream<List<Doubt>> myDoubtsStream(String studentId) {
    debugPrint('🔄 [StudentService] Streaming doubts for student $studentId');
    return _doubtsRef.snapshots().map((snapshot) {
      final doubts = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Doubt.fromMap(data);
      }).where((d) => d.studentId == studentId).toList();
      // Sort locally
      doubts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return doubts;
    });
  }

  // ============================================================
  // SUBMISSIONS - SUBMIT & TRACK
  // ============================================================

  /// Submit a task/reflection/journal
  Future<String> submitTask({
    required String studentId,
    required String studentName,
    required int studentGrade,
    required String type, // reflection, journal, task_result
    required String title,
    required String content,
    String? careerId,
  }) async {
    debugPrint('📤 [StudentService] Submitting task: $type');
    try {
      final submission = StudentSubmission(
        id: '',
        studentId: studentId,
        studentName: studentName,
        studentGrade: studentGrade,
        type: type,
        title: title,
        content: content,
        careerId: careerId,
        submittedAt: DateTime.now(),
      );
      
      final docRef = await _submissionsRef.add(submission.toMap());
      await docRef.update({'id': docRef.id});
      debugPrint('✅ [StudentService] Task submitted: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('❌ [StudentService] Error submitting task: $e');
      rethrow;
    }
  }

  /// STREAM: My submissions (updates instantly when teacher reviews)
  /// Note: Sorting done locally to avoid composite index requirement
  Stream<List<StudentSubmission>> mySubmissionsStream(String studentId) {
    debugPrint('🔄 [StudentService] Streaming submissions for student $studentId');
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

  // ============================================================
  // NOTICES - LIVE STREAM
  // ============================================================

  /// STREAM: Notices for my grade (updates instantly when teacher posts)
  /// Note: Sorting done locally to avoid composite index requirement
  Stream<List<Notice>> noticesForGradeStream(int grade) {
    debugPrint('🔄 [StudentService] Streaming notices for grade $grade');
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
  // OPPORTUNITIES - LIVE STREAM
  // ============================================================

  /// STREAM: Opportunities for my grade
  Stream<List<Opportunity>> opportunitiesForGradeStream(int grade) {
    debugPrint('🔄 [StudentService] Streaming opportunities for grade $grade');
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

  /// Mark interest in an opportunity
  Future<void> markOpportunityInterest({
    required String studentId,
    required String opportunityId,
    required InterestStatus status,
  }) async {
    try {
      final interest = StudentOpportunityInterest(
        id: '${studentId}_$opportunityId',
        studentId: studentId,
        opportunityId: opportunityId,
        status: status,
        markedAt: DateTime.now(),
      );
      
      await _firestore
          .collection('opportunity_interests')
          .doc(interest.id)
          .set(interest.toMap());
    } catch (e) {
      debugPrint('❌ [StudentService] Error marking interest: $e');
      rethrow;
    }
  }

  // ============================================================
  // QUIZZES - LIVE STREAM
  // ============================================================

  /// STREAM: Quizzes for my grade
  Stream<List<Quiz>> quizzesForGradeStream(int grade) {
    debugPrint('🔄 [StudentService] Streaming quizzes for grade $grade');
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
  Future<String> submitQuizAttempt({
    required String quizId,
    required String studentId,
    required int score,
    required int totalQuestions,
    required List<int> answers,
    required int timeTakenSeconds,
  }) async {
    try {
      final attempt = QuizAttempt(
        id: '',
        quizId: quizId,
        studentId: studentId,
        score: score,
        totalQuestions: totalQuestions,
        answers: answers,
        attemptedAt: DateTime.now(),
        timeTakenSeconds: timeTakenSeconds,
      );
      
      final docRef = await _quizAttemptsRef.add(attempt.toMap());
      await docRef.update({'id': docRef.id});
      return docRef.id;
    } catch (e) {
      debugPrint('❌ [StudentService] Error submitting attempt: $e');
      rethrow;
    }
  }

  /// STREAM: My quiz attempts
  /// Note: Sorting done locally to avoid composite index requirement
  Stream<List<QuizAttempt>> myQuizAttemptsStream(String studentId) {
    return _quizAttemptsRef.snapshots().map((snapshot) {
      final attempts = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return QuizAttempt.fromMap(data);
      }).where((a) => a.studentId == studentId).toList();
      attempts.sort((a, b) => b.attemptedAt.compareTo(a.attemptedAt));
      return attempts;
    });
  }

  // ============================================================
  // CAREER NOTES - LIVE STREAM (Teacher's recommendations)
  // ============================================================

  /// STREAM: Career notes from teacher (updates instantly)
  /// Note: Sorting done locally to avoid composite index requirement
  Stream<List<CareerNote>> myCareerNotesStream(String studentId) {
    debugPrint('🔄 [StudentService] Streaming career notes for student $studentId');
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
  // ACTIVITY TRACKING
  // ============================================================

  /// Record login
  Future<void> recordLogin(String studentId, String studentName, int grade) async {
    try {
      await _studentActivityRef.doc(studentId).set({
        'studentId': studentId,
        'studentName': studentName,
        'grade': grade,
        'lastLoginAt': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('❌ [StudentService] Error recording login: $e');
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
      debugPrint('❌ [StudentService] Error recording exploration: $e');
    }
  }

  /// Record task completion
  Future<void> recordTaskCompletion(String studentId) async {
    try {
      await _studentActivityRef.doc(studentId).update({
        'tasksCompleted': FieldValue.increment(1),
      });
    } catch (e) {
      debugPrint('❌ [StudentService] Error recording task: $e');
    }
  }
}
