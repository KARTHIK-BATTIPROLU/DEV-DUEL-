import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/career_model.dart';
import '../../../models/teacher_models.dart';
import '../../../services/teacher_service.dart';
import '../../../data/career_data.dart';

/// Career Factory Tab - Manage careers with grade visibility
class CareerFactoryTab extends StatefulWidget {
  const CareerFactoryTab({super.key});

  @override
  State<CareerFactoryTab> createState() => _CareerFactoryTabState();
}

class _CareerFactoryTabState extends State<CareerFactoryTab> {
  final _teacherService = TeacherService();
  List<CareerModel> _localCareers = [];
  Map<String, GradeVisibility> _visibilityMap = {};
  Map<String, bool> _activeMap = {};
  bool _isLoading = true;
  StreamTag? _selectedStream;

  @override
  void initState() {
    super.initState();
    _loadCareers();
  }

  void _loadCareers() {
    setState(() => _isLoading = true);
    _localCareers = CareerData.getAllCareers();
    // Initialize visibility for all careers (default: all grades visible)
    for (final career in _localCareers) {
      _visibilityMap[career.id] = GradeVisibility();
      _activeMap[career.id] = true;
    }
    setState(() => _isLoading = false);
  }

  List<CareerModel> get _filteredCareers {
    if (_selectedStream == null) return _localCareers;
    return _localCareers.where((c) => c.streamTag == _selectedStream).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        // Stream Filter
        _buildStreamFilter(),
        
        // Career List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _filteredCareers.length,
            itemBuilder: (context, index) {
              final career = _filteredCareers[index];
              return _CareerManagementCard(
                career: career,
                visibility: _visibilityMap[career.id]!,
                isActive: _activeMap[career.id]!,
                onVisibilityChanged: (visibility) {
                  setState(() => _visibilityMap[career.id] = visibility);
                },
                onActiveChanged: (active) {
                  setState(() => _activeMap[career.id] = active);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStreamFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('All', null),
            ...StreamTag.values.map((tag) => _buildFilterChip(tag.shortName, tag)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, StreamTag? tag) {
    final isSelected = _selectedStream == tag;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => setState(() => _selectedStream = isSelected ? null : tag),
        selectedColor: AppTheme.teacherColor.withOpacity(0.2),
        checkmarkColor: AppTheme.teacherColor,
      ),
    );
  }
}

/// Career Management Card with Grade Visibility Controls
class _CareerManagementCard extends StatefulWidget {
  final CareerModel career;
  final GradeVisibility visibility;
  final bool isActive;
  final Function(GradeVisibility) onVisibilityChanged;
  final Function(bool) onActiveChanged;

  const _CareerManagementCard({
    required this.career,
    required this.visibility,
    required this.isActive,
    required this.onVisibilityChanged,
    required this.onActiveChanged,
  });

  @override
  State<_CareerManagementCard> createState() => _CareerManagementCardState();
}

class _CareerManagementCardState extends State<_CareerManagementCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: widget.isActive ? null : Border.all(color: Colors.grey.withOpacity(0.3)),
        boxShadow: widget.isActive
            ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]
            : null,
      ),
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _getStreamColor(widget.career.streamTag).withOpacity(widget.isActive ? 0.1 : 0.05),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _getCareerIcon(widget.career.iconName),
                      color: widget.isActive ? _getStreamColor(widget.career.streamTag) : Colors.grey,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.career.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: widget.isActive ? null : Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: _getStreamColor(widget.career.streamTag).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                widget.career.streamTag.shortName,
                                style: TextStyle(fontSize: 10, color: _getStreamColor(widget.career.streamTag)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _getVisibleGradesText(),
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: widget.isActive,
                    onChanged: widget.onActiveChanged,
                    activeColor: AppTheme.teacherColor,
                  ),
                  Icon(_isExpanded ? Icons.expand_less : Icons.expand_more, color: Colors.grey),
                ],
              ),
            ),
          ),
          
          // Expanded Content - Grade Visibility Controls
          if (_isExpanded)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  const SizedBox(height: 8),
                  const Text('Grade Visibility', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 12),
                  _buildGradeToggles(),
                  const SizedBox(height: 16),
                  _buildContentPreview(),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGradeToggles() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildGradeToggle(7, widget.visibility.grade7, (v) => widget.onVisibilityChanged(widget.visibility.copyWith(grade7: v))),
        _buildGradeToggle(8, widget.visibility.grade8, (v) => widget.onVisibilityChanged(widget.visibility.copyWith(grade8: v))),
        _buildGradeToggle(9, widget.visibility.grade9, (v) => widget.onVisibilityChanged(widget.visibility.copyWith(grade9: v))),
        _buildGradeToggle(10, widget.visibility.grade10, (v) => widget.onVisibilityChanged(widget.visibility.copyWith(grade10: v))),
        _buildGradeToggle(11, widget.visibility.grade11, (v) => widget.onVisibilityChanged(widget.visibility.copyWith(grade11: v))),
        _buildGradeToggle(12, widget.visibility.grade12, (v) => widget.onVisibilityChanged(widget.visibility.copyWith(grade12: v))),
      ],
    );
  }

  Widget _buildGradeToggle(int grade, bool isVisible, Function(bool) onChanged) {
    final color = _getGradeColor(grade);
    return GestureDetector(
      onTap: () => onChanged(!isVisible),
      child: Container(
        width: 50,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isVisible ? color.withOpacity(0.1) : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isVisible ? color : Colors.grey[300]!),
        ),
        child: Column(
          children: [
            Text('$grade', style: TextStyle(fontWeight: FontWeight.bold, color: isVisible ? color : Colors.grey)),
            Icon(isVisible ? Icons.visibility : Icons.visibility_off, size: 16, color: isVisible ? color : Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildContentPreview() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Content by Grade Level:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          _buildContentRow('7-8', 'Discovery', 'Stories, Fun Facts', Colors.teal),
          _buildContentRow('9-10', 'Bridge', 'Streams, Foundation Topics', Colors.indigo),
          _buildContentRow('11-12', 'Execution', 'Exams, Colleges, Salary', Colors.deepOrange),
        ],
      ),
    );
  }

  Widget _buildContentRow(String grades, String phase, String content, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Container(
            width: 50,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
            child: Text(grades, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color), textAlign: TextAlign.center),
          ),
          const SizedBox(width: 8),
          Text('$phase: ', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
          Expanded(child: Text(content, style: TextStyle(fontSize: 11, color: Colors.grey[600]))),
        ],
      ),
    );
  }

  String _getVisibleGradesText() {
    final visible = <int>[];
    if (widget.visibility.grade7) visible.add(7);
    if (widget.visibility.grade8) visible.add(8);
    if (widget.visibility.grade9) visible.add(9);
    if (widget.visibility.grade10) visible.add(10);
    if (widget.visibility.grade11) visible.add(11);
    if (widget.visibility.grade12) visible.add(12);
    
    if (visible.length == 6) return 'All grades';
    if (visible.isEmpty) return 'Hidden';
    return 'Grades: ${visible.join(", ")}';
  }

  Color _getStreamColor(StreamTag tag) {
    switch (tag) {
      case StreamTag.mpc: return Colors.blue;
      case StreamTag.bipc: return Colors.green;
      case StreamTag.mec: return Colors.purple;
      case StreamTag.cec: return Colors.orange;
      case StreamTag.hec: return Colors.indigo;
      case StreamTag.vocational: return Colors.teal;
    }
  }

  Color _getGradeColor(int grade) {
    switch (grade) {
      case 7: return Colors.teal;
      case 8: return Colors.blue;
      case 9: return Colors.indigo;
      case 10: return Colors.purple;
      case 11: return Colors.deepOrange;
      case 12: return Colors.red;
      default: return Colors.grey;
    }
  }

  IconData _getCareerIcon(String iconName) {
    switch (iconName) {
      case 'computer': return Icons.computer;
      case 'medical_services': return Icons.medical_services;
      case 'account_balance': return Icons.account_balance;
      case 'gavel': return Icons.gavel;
      case 'web': return Icons.web;
      default: return Icons.work;
    }
  }
}
