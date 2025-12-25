import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../data/career_data.dart';
import '../models/career_model.dart';

/// Career Service - Handles career data operations
class CareerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  static final CareerService _instance = CareerService._internal();
  factory CareerService() => _instance;
  CareerService._internal();

  // Get all careers (from local data)
  List<CareerModel> getAllCareers() => CareerData.getAllCareers();

  // Get careers by stream
  List<CareerModel> getCareersByStream(StreamTag stream) => 
      CareerData.getCareersByStream(stream);

  // Get career by ID
  CareerModel? getCareerById(String id) {
    try {
      return getAllCareers().firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get careers relevant to a grade
  List<CareerModel> getCareersForGrade(int grade) {
    // All careers are relevant, but we'll show grade-appropriate content
    return getAllCareers();
  }

  // Get recommended careers based on interests (deterministic logic)
  List<CareerModel> getRecommendedCareers({
    required List<String> interests,
    required int grade,
  }) {
    final careers = getAllCareers();
    
    // Simple deterministic matching
    final Map<String, List<StreamTag>> interestToStream = {
      'technology': [StreamTag.mpc, StreamTag.vocational],
      'science': [StreamTag.mpc, StreamTag.bipc],
      'medicine': [StreamTag.bipc],
      'business': [StreamTag.mec, StreamTag.cec],
      'finance': [StreamTag.mec, StreamTag.cec],
      'law': [StreamTag.hec],
      'arts': [StreamTag.hec, StreamTag.vocational],
      'design': [StreamTag.hec, StreamTag.vocational],
      'helping': [StreamTag.bipc, StreamTag.hec],
    };

    final Set<StreamTag> matchedStreams = {};
    for (final interest in interests) {
      final streams = interestToStream[interest.toLowerCase()];
      if (streams != null) {
        matchedStreams.addAll(streams);
      }
    }

    if (matchedStreams.isEmpty) {
      return careers.take(5).toList();
    }

    return careers
        .where((c) => matchedStreams.contains(c.streamTag))
        .toList();
  }

  // Seed careers to Firestore (one-time operation)
  Future<void> seedCareersToFirestore() async {
    debugPrint('🌱 [CareerService] Seeding careers to Firestore...');
    
    final batch = _firestore.batch();
    final careersRef = _firestore.collection('careers');

    for (final career in getAllCareers()) {
      final docRef = careersRef.doc(career.id);
      batch.set(docRef, career.toMap());
    }

    await batch.commit();
    debugPrint('✅ [CareerService] Seeded ${getAllCareers().length} careers');
  }

  // Get grade-specific content from a career
  Map<String, dynamic> getGradeContent(CareerModel career, int grade) {
    if (grade <= 8) {
      return {
        'phase': 'Discovery',
        'content': career.discoveryContent,
        'focus': 'Explore and understand what this career is about',
      };
    } else if (grade <= 10) {
      return {
        'phase': 'Bridge',
        'content': career.bridgeContent,
        'focus': 'Understand the path and make informed stream choices',
      };
    } else {
      return {
        'phase': 'Execution',
        'content': career.executionContent,
        'focus': 'Prepare for entrance exams and plan your journey',
      };
    }
  }
}
