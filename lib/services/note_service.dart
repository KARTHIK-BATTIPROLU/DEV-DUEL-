import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/note_model.dart';

/// Note Service - Repository Layer for Career Notes
/// Firestore Schema: users/{userId}/my_notes/{noteId}
/// Implements sub-collection strategy for user-specific notes
class NoteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static final NoteService _instance = NoteService._internal();
  factory NoteService() => _instance;
  NoteService._internal();

  /// Get reference to user's notes sub-collection
  CollectionReference _notesRef(String oderId) {
    return _firestore.collection('users').doc(oderId).collection('my_notes');
  }

  // ============================================================
  // SAVE NOTE - From Career Detail Screen
  // ============================================================

  /// Save a new note to user's sub-collection
  /// Uses ServerTimestamp for consistent ordering
  Future<String> saveNote(NoteModel note) async {
    debugPrint('📝 [NoteService] Saving note for career: ${note.careerTitle}');
    try {
      final docRef = await _notesRef(note.oderId).add(note.toMap());
      // Update with generated Firestore Document ID
      await docRef.update({'id': docRef.id});
      debugPrint('✅ [NoteService] Note saved: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('❌ [NoteService] Error saving note: $e');
      rethrow;
    }
  }

  /// Update an existing note
  Future<void> updateNote(String oderId, String noteId, String content) async {
    debugPrint('📝 [NoteService] Updating note: $noteId');
    try {
      await _notesRef(oderId).doc(noteId).update({
        'noteContent': content,
        'timestamp': FieldValue.serverTimestamp(),
      });
      debugPrint('✅ [NoteService] Note updated');
    } catch (e) {
      debugPrint('❌ [NoteService] Error updating note: $e');
      rethrow;
    }
  }

  /// Delete a note
  Future<void> deleteNote(String oderId, String noteId) async {
    debugPrint('🗑️ [NoteService] Deleting note: $noteId');
    try {
      await _notesRef(oderId).doc(noteId).delete();
      debugPrint('✅ [NoteService] Note deleted');
    } catch (e) {
      debugPrint('❌ [NoteService] Error deleting note: $e');
      rethrow;
    }
  }

  // ============================================================
  // PROFILE SCREEN - All Notes Stream
  // ============================================================

  /// STREAM: All notes for a user (Profile Screen)
  /// Path: users/{userId}/my_notes
  /// Sorted by timestamp descending (newest first)
  Stream<List<NoteModel>> userNotesStream(String oderId) {
    debugPrint('🔄 [NoteService] Streaming notes for user: $oderId');
    return _notesRef(oderId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      debugPrint('📥 [NoteService] Received ${snapshot.docs.length} notes');
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return NoteModel.fromMap(data);
      }).toList();
    });
  }

  // ============================================================
  // DASHBOARD - Recent Notes (Limited)
  // ============================================================

  /// STREAM: Recent 3 notes for Dashboard quick-view
  /// Used in Student Home Screen "My Recent Notes" section
  Stream<List<NoteModel>> recentNotesStream(String oderId, {int limit = 3}) {
    debugPrint('🔄 [NoteService] Streaming recent $limit notes for user: $oderId');
    return _notesRef(oderId)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return NoteModel.fromMap(data);
      }).toList();
    });
  }

  // ============================================================
  // CAREER DETAIL - Notes for specific career
  // ============================================================

  /// STREAM: Notes for a specific career
  Stream<List<NoteModel>> notesForCareerStream(String oderId, String careerId) {
    debugPrint('🔄 [NoteService] Streaming notes for career: $careerId');
    return _notesRef(oderId).snapshots().map((snapshot) {
      final notes = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return NoteModel.fromMap(data);
      }).where((note) => note.careerId == careerId).toList();
      notes.sort((a, b) {
        final aTime = a.timestamp ?? DateTime.now();
        final bTime = b.timestamp ?? DateTime.now();
        return bTime.compareTo(aTime);
      });
      return notes;
    });
  }

  /// Get single note by ID
  Future<NoteModel?> getNoteById(String oderId, String noteId) async {
    try {
      final doc = await _notesRef(oderId).doc(noteId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return NoteModel.fromMap(data);
      }
      return null;
    } catch (e) {
      debugPrint('❌ [NoteService] Error fetching note: $e');
      return null;
    }
  }

  /// Get notes count for a user
  Future<int> getNotesCount(String oderId) async {
    try {
      final snapshot = await _notesRef(oderId).count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      debugPrint('❌ [NoteService] Error getting count: $e');
      return 0;
    }
  }
}
