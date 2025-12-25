import 'package:flutter/foundation.dart';
import '../models/career_model.dart';
import '../services/career_service.dart';

/// Career Provider - State management for career data
/// Implements deterministic filtering for career paths
class CareerProvider extends ChangeNotifier {
  final CareerService _careerService = CareerService();

  List<CareerModel> _careers = [];
  List<CareerModel> _filteredCareers = [];
  CareerModel? _selectedCareer;
  StreamTag? _selectedStream;
  bool _isLoading = false;
  int _userGrade = 10;

  // Getters
  List<CareerModel> get careers => _careers;

  /// Returns filtered careers based on selected stream
  /// If no stream selected (All), returns all careers
  /// If stream selected but no matches, returns empty list (not all careers)
  List<CareerModel> get filteredCareers => _filteredCareers;

  CareerModel? get selectedCareer => _selectedCareer;
  StreamTag? get selectedStream => _selectedStream;
  bool get isLoading => _isLoading;
  int get userGrade => _userGrade;

  /// Check if a specific stream is selected
  bool isStreamSelected(StreamTag? stream) => _selectedStream == stream;

  // Initialize
  void initialize() {
    _careers = _careerService.getAllCareers();
    _filteredCareers = List.from(_careers); // Start with all careers
    _selectedStream = null; // Default: All selected
    notifyListeners();
  }

  // Update user grade (triggers UI refresh)
  void updateUserGrade(int grade) {
    _userGrade = grade;
    notifyListeners();
  }

  /// Filter by stream - DETERMINISTIC FILTERING
  /// Uses .where((career) => career.streamTag == stream).toList()
  /// Default State: If 'All' (null) is selected, show every career
  void filterByStream(StreamTag? stream) {
    _selectedStream = stream;

    if (stream == null) {
      // 'All' selected - show every career
      _filteredCareers = List.from(_careers);
    } else {
      // Specific stream selected - filter deterministically
      _filteredCareers =
          _careers.where((career) => career.streamTag == stream).toList();
    }

    debugPrint(
        '🔍 [CareerProvider] Filter: ${stream?.shortName ?? "All"} -> ${_filteredCareers.length} careers');
    notifyListeners();
  }

  // Select a career
  void selectCareer(CareerModel career) {
    _selectedCareer = career;
    notifyListeners();
  }

  // Clear selection
  void clearSelection() {
    _selectedCareer = null;
    notifyListeners();
  }

  // Get grade-appropriate content
  Map<String, dynamic> getGradeContent(CareerModel career) {
    return _careerService.getGradeContent(career, _userGrade);
  }

  // Get UI style based on grade
  String getUIStyle() {
    if (_userGrade <= 8) return 'discovery'; // Gamified Interest Lab
    if (_userGrade <= 10) return 'bridge';   // Decision Matrix
    return 'execution';                       // Execution Dashboard
  }

  // Get phase name
  String getPhaseName() {
    if (_userGrade <= 8) return 'Interest Exploration';
    if (_userGrade <= 10) return 'Decision Support';
    return 'Career Preparation';
  }

  // Search careers
  void searchCareers(String query) {
    if (query.isEmpty) {
      _filteredCareers = _selectedStream == null 
          ? _careers 
          : _careerService.getCareersByStream(_selectedStream!);
    } else {
      _filteredCareers = _careers.where((c) =>
          c.title.toLowerCase().contains(query.toLowerCase()) ||
          c.shortDescription.toLowerCase().contains(query.toLowerCase()) ||
          c.streamTag.displayName.toLowerCase().contains(query.toLowerCase())
      ).toList();
    }
    notifyListeners();
  }
}
