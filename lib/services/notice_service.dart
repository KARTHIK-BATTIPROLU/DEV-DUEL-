import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/notice_model.dart';

/// Notice Service - Repository Layer for Firestore Notice Operations
/// Handles all CRUD operations and reactive streams for the Notice Board
/// 
/// Collection: notices
/// Schema: NoticeModel (id, title, body, targetGrade, type, timestamp, createdBy)
class NoticeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static final NoticeService _instance = NoticeService._internal();
  factory NoticeService() => _instance;
  NoticeService._internal();

  /// Collection reference
  CollectionReference get _noticesRef => _firestore.collection('notices');

  // ============================================================
  // TEACHER: WRITE OPERATIONS (Source of Truth)
  // ============================================================

  /// Create a new notice - Called when Teacher clicks "Post" button
  /// Uses FieldValue.serverTimestamp() for consistent ordering
  Future<String> createNotice(NoticeModel notice) async {
    debugPrint('📢 [NoticeService] Creating notice: ${notice.title}');
    try {
      final docRef = await _noticesRef.add(notice.toMap());
      // Update with generated Firestore Document ID
      await docRef.update({'id': docRef.id});
      debugPrint('✅ [NoticeService] Notice uploaded to Cloud: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('❌ [NoticeService] Error creating notice: $e');
      rethrow;
    }
  }

  /// Update an existing notice
  Future<void> updateNotice(String noticeId, Map<String, dynamic> updates) async {
    debugPrint('📝 [NoticeService] Updating notice: $noticeId');
    try {
      // Don't overwrite timestamp on updates unless explicitly provided
      if (!updates.containsKey('timestamp')) {
        updates.remove('timestamp');
      }
      await _noticesRef.doc(noticeId).update(updates);
      debugPrint('✅ [NoticeService] Notice updated');
    } catch (e) {
      debugPrint('❌ [NoticeService] Error updating notice: $e');
      rethrow;
    }
  }

  /// Delete a notice - Instantly removes from all Student screens via StreamBuilder
  Future<void> deleteNotice(String noticeId) async {
    debugPrint('🗑️ [NoticeService] Deleting notice: $noticeId');
    try {
      await _noticesRef.doc(noticeId).delete();
      debugPrint('✅ [NoticeService] Notice deleted - removed from all student feeds');
    } catch (e) {
      debugPrint('❌ [NoticeService] Error deleting notice: $e');
      rethrow;
    }
  }

  // ============================================================
  // TEACHER: READ STREAMS (Dashboard View)
  // ============================================================

  /// STREAM: All notices for Teacher Dashboard
  /// Sorted by timestamp descending (newest first)
  Stream<List<NoticeModel>> allNoticesStream() {
    debugPrint('🔄 [NoticeService] Streaming all notices for teacher');
    return _noticesRef
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      debugPrint('📥 [NoticeService] Received ${snapshot.docs.length} notices');
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return NoticeModel.fromMap(data);
      }).toList();
    });
  }

  // ============================================================
  // STUDENT: REACTIVE LISTENER (Live Feed)
  // ============================================================

  /// STREAM: Notices filtered by student grade
  /// Listens ONLY to relevant notices using whereIn query
  /// Query: targetGrade IN [currentStudentGradeFilter, 'All']
  /// Sorted by timestamp descending (newest first)
  Stream<List<NoticeModel>> noticesForStudentStream(int studentGrade) {
    debugPrint('🔄 [NoticeService] Streaming notices for grade $studentGrade');
    
    // Get the grade filter string for this student
    final gradeFilter = TargetGradeExt.getTargetGradeFilter(studentGrade);
    debugPrint('🎯 [NoticeService] Grade filter: $gradeFilter');

    return _noticesRef
        .where('targetGrade', whereIn: [gradeFilter, 'All'])
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      debugPrint('📥 [NoticeService] Received ${snapshot.docs.length} notices for grade $studentGrade');
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return NoticeModel.fromMap(data);
      }).toList();
    });
  }

  /// Alternative stream without composite index requirement
  /// Uses local filtering instead of Firestore query
  Stream<List<NoticeModel>> noticesForStudentStreamLocal(int studentGrade) {
    debugPrint('🔄 [NoticeService] Streaming notices (local filter) for grade $studentGrade');
    
    return _noticesRef.snapshots().map((snapshot) {
      final notices = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return NoticeModel.fromMap(data);
      }).where((notice) => notice.isRelevantForGrade(studentGrade)).toList();
      
      // Sort locally by timestamp descending
      notices.sort((a, b) {
        final aTime = a.timestamp ?? DateTime.now();
        final bTime = b.timestamp ?? DateTime.now();
        return bTime.compareTo(aTime);
      });
      
      debugPrint('📥 [NoticeService] Filtered ${notices.length} notices for grade $studentGrade');
      return notices;
    });
  }

  // ============================================================
  // UTILITY METHODS
  // ============================================================

  /// Get a single notice by ID
  Future<NoticeModel?> getNoticeById(String noticeId) async {
    try {
      final doc = await _noticesRef.doc(noticeId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return NoticeModel.fromMap(data);
      }
      return null;
    } catch (e) {
      debugPrint('❌ [NoticeService] Error fetching notice: $e');
      return null;
    }
  }

  /// Get notices count for analytics
  Future<int> getNoticesCount() async {
    try {
      final snapshot = await _noticesRef.count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      debugPrint('❌ [NoticeService] Error getting count: $e');
      return 0;
    }
  }
}
