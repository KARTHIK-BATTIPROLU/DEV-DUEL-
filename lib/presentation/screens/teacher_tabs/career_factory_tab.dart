import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/career_model.dart';
import '../../../models/teacher_models.dart';
import '../../../models/user_model.dart';
import '../../../services/teacher_service.dart';
import '../../../services/hive_service.dart';

/// Career Factory Tab - Manage careers with Firestore integration
class CareerFactoryTab extends StatefulWidget {
  const CareerFactoryTab({super.key});

  @override
  State<CareerFactoryTab> createState() => _CareerFactoryTabState();
}

class _CareerFactoryTabState extends State<CareerFactoryTab> {
  final _teacherService = TeacherService();
  StreamTag? _selectedStream;
  TeacherModel? _teacher;

  @override
  void initState() {
    super.initState();
    _teacher = HiveService.getTeacher();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildStreamFilter(),
          Expanded(
            child: StreamBuilder<List<ManagedCareer>>(
              stream: _teacherService.careersStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                
                final allCareers = snapshot.data ?? [];
                // Local filtering by stream
                final careers = _selectedStream == null
                    ? allCareers
                    : allCareers.where((c) => c.streamTag == _selectedStream).toList();
                
                if (careers.isEmpty) {
                  return _buildEmptyState();
                }
                
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: careers.length,
                  itemBuilder: (context, index) {
                    final career = careers[index];
                    return Dismissible(
                      key: Key(career.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      confirmDismiss: (_) => _confirmDelete(career),
                      onDismissed: (_) => _deleteCareer(career.id),
                      child: _CareerCard(
                        career: career,
                        onToggleActive: (active) => _toggleActive(career.id, active),
                        onVisibilityChanged: (v) => _updateVisibility(career.id, v),
                        onEdit: () => _editCareer(career),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addCareer,
        backgroundColor: AppTheme.teacherColor,
        icon: const Icon(Icons.add),
        label: const Text('Add Career'),
      ),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.work_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            _selectedStream == null ? 'No careers yet' : 'No ${_selectedStream!.shortName} careers',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text('Tap + to add a new career', style: TextStyle(color: Colors.grey[500])),
        ],
      ),
    );
  }

  Future<bool> _confirmDelete(ManagedCareer career) async {
    return await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Career?'),
        content: Text('Are you sure you want to delete "${career.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    ) ?? false;
  }

  Future<void> _deleteCareer(String careerId) async {
    try {
      await _teacherService.deleteCareer(careerId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Career deleted'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _toggleActive(String careerId, bool active) async {
    await _teacherService.toggleCareerActive(careerId, active);
  }

  Future<void> _updateVisibility(String careerId, GradeVisibility visibility) async {
    await _teacherService.updateCareerVisibility(careerId, visibility);
  }

  void _addCareer() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditCareerScreen(teacher: _teacher),
      ),
    );
  }

  void _editCareer(ManagedCareer career) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditCareerScreen(teacher: _teacher, career: career),
      ),
    );
  }
}

/// Career Card with expandable grade visibility controls
class _CareerCard extends StatefulWidget {
  final ManagedCareer career;
  final Function(bool) onToggleActive;
  final Function(GradeVisibility) onVisibilityChanged;
  final VoidCallback onEdit;

  const _CareerCard({
    required this.career,
    required this.onToggleActive,
    required this.onVisibilityChanged,
    required this.onEdit,
  });

  @override
  State<_CareerCard> createState() => _CareerCardState();
}

class _CareerCardState extends State<_CareerCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: widget.career.isActive ? null : Border.all(color: Colors.grey.withOpacity(0.3)),
        boxShadow: widget.career.isActive
            ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]
            : null,
      ),
      child: Column(
        children: [
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
                      color: _getStreamColor(widget.career.streamTag).withOpacity(widget.career.isActive ? 0.1 : 0.05),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _getCareerIcon(widget.career.iconName),
                      color: widget.career.isActive ? _getStreamColor(widget.career.streamTag) : Colors.grey,
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
                            color: widget.career.isActive ? null : Colors.grey,
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
                            Text(_getVisibleGradesText(), style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: widget.onEdit,
                    color: Colors.grey,
                  ),
                  Switch(
                    value: widget.career.isActive,
                    onChanged: widget.onToggleActive,
                    activeColor: AppTheme.teacherColor,
                  ),
                  Icon(_isExpanded ? Icons.expand_less : Icons.expand_more, color: Colors.grey),
                ],
              ),
            ),
          ),
          if (_isExpanded) _buildExpandedContent(),
        ],
      ),
    );
  }

  Widget _buildExpandedContent() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          const SizedBox(height: 8),
          Text(widget.career.shortDescription, style: TextStyle(fontSize: 13, color: Colors.grey[700])),
          const SizedBox(height: 12),
          const Text('Grade Visibility', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 12),
          _buildGradeToggles(),
          const SizedBox(height: 16),
          _buildContentPreview(),
        ],
      ),
    );
  }

  Widget _buildGradeToggles() {
    final v = widget.career.gradeVisibility;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildGradeToggle(7, v.grade7, (val) => widget.onVisibilityChanged(v.copyWith(grade7: val))),
        _buildGradeToggle(8, v.grade8, (val) => widget.onVisibilityChanged(v.copyWith(grade8: val))),
        _buildGradeToggle(9, v.grade9, (val) => widget.onVisibilityChanged(v.copyWith(grade9: val))),
        _buildGradeToggle(10, v.grade10, (val) => widget.onVisibilityChanged(v.copyWith(grade10: val))),
        _buildGradeToggle(11, v.grade11, (val) => widget.onVisibilityChanged(v.copyWith(grade11: val))),
        _buildGradeToggle(12, v.grade12, (val) => widget.onVisibilityChanged(v.copyWith(grade12: val))),
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
      decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8)),
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
    final v = widget.career.gradeVisibility;
    final visible = <int>[];
    if (v.grade7) visible.add(7);
    if (v.grade8) visible.add(8);
    if (v.grade9) visible.add(9);
    if (v.grade10) visible.add(10);
    if (v.grade11) visible.add(11);
    if (v.grade12) visible.add(12);
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
      case 'science': return Icons.science;
      case 'architecture': return Icons.architecture;
      case 'psychology': return Icons.psychology;
      case 'business': return Icons.business;
      case 'engineering': return Icons.engineering;
      default: return Icons.work;
    }
  }
}


/// Add/Edit Career Screen with proper form handling
class AddEditCareerScreen extends StatefulWidget {
  final TeacherModel? teacher;
  final ManagedCareer? career;

  const AddEditCareerScreen({super.key, this.teacher, this.career});

  @override
  State<AddEditCareerScreen> createState() => _AddEditCareerScreenState();
}

class _AddEditCareerScreenState extends State<AddEditCareerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _teacherService = TeacherService();
  
  // Controllers - properly managed
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _dayInLifeController;
  late final TextEditingController _funFactController;
  late final TextEditingController _streamRequiredController;
  late final TextEditingController _avgSalaryController;
  late final TextEditingController _entrySalaryController;
  late final TextEditingController _fiveYearSalaryController;
  
  StreamTag _selectedStream = StreamTag.mpc;
  String _selectedIcon = 'work';
  GradeVisibility _gradeVisibility = GradeVisibility();
  bool _isLoading = false;

  bool get _isEditing => widget.career != null;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    final c = widget.career;
    _titleController = TextEditingController(text: c?.title ?? '');
    _descriptionController = TextEditingController(text: c?.shortDescription ?? '');
    _dayInLifeController = TextEditingController(text: c?.discoveryContent.dayInLife ?? '');
    _funFactController = TextEditingController(text: c?.discoveryContent.funFact ?? '');
    _streamRequiredController = TextEditingController(text: c?.bridgeContent.required11thStream ?? '');
    _avgSalaryController = TextEditingController(text: c?.realityCheck.avgSalary ?? '');
    _entrySalaryController = TextEditingController(text: c?.executionContent.financialReality.entrySalary ?? '');
    _fiveYearSalaryController = TextEditingController(text: c?.executionContent.financialReality.fiveYearSalary ?? '');
    
    if (c != null) {
      _selectedStream = c.streamTag;
      _selectedIcon = c.iconName;
      _gradeVisibility = c.gradeVisibility;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _dayInLifeController.dispose();
    _funFactController.dispose();
    _streamRequiredController.dispose();
    _avgSalaryController.dispose();
    _entrySalaryController.dispose();
    _fiveYearSalaryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Career' : 'Add Career'),
        backgroundColor: AppTheme.teacherColor,
        foregroundColor: Colors.white,
        actions: [
          if (_isLoading)
            const Center(child: Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
            ))
          else
            IconButton(icon: const Icon(Icons.check), onPressed: _saveCareer),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildBasicInfoSection(),
            const SizedBox(height: 24),
            _buildGradeVisibilitySection(),
            const SizedBox(height: 24),
            _buildDiscoverySection(),
            const SizedBox(height: 24),
            _buildBridgeSection(),
            const SizedBox(height: 24),
            _buildExecutionSection(),
            const SizedBox(height: 32),
            _buildSaveButton(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Basic Information', Icons.info, Colors.blue),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Career Title *', border: OutlineInputBorder()),
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Short Description *', border: OutlineInputBorder()),
              maxLines: 2,
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<StreamTag>(
                    value: _selectedStream,
                    decoration: const InputDecoration(labelText: 'Stream Tag *', border: OutlineInputBorder()),
                    items: StreamTag.values.map((tag) => DropdownMenuItem(
                      value: tag,
                      child: Text(tag.shortName),
                    )).toList(),
                    onChanged: (v) => setState(() => _selectedStream = v!),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedIcon,
                    decoration: const InputDecoration(labelText: 'Icon', border: OutlineInputBorder()),
                    items: _iconOptions.map((icon) => DropdownMenuItem(
                      value: icon,
                      child: Row(
                        children: [
                          Icon(_getIconData(icon), size: 20),
                          const SizedBox(width: 8),
                          Text(icon),
                        ],
                      ),
                    )).toList(),
                    onChanged: (v) => setState(() => _selectedIcon = v!),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradeVisibilitySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Grade Visibility', Icons.visibility, Colors.purple),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [7, 8, 9, 10, 11, 12].map((grade) {
                final isVisible = _gradeVisibility.isVisibleForGrade(grade);
                return FilterChip(
                  label: Text('Grade $grade'),
                  selected: isVisible,
                  onSelected: (v) => setState(() {
                    _gradeVisibility = _gradeVisibility.copyWith(
                      grade7: grade == 7 ? v : null,
                      grade8: grade == 8 ? v : null,
                      grade9: grade == 9 ? v : null,
                      grade10: grade == 10 ? v : null,
                      grade11: grade == 11 ? v : null,
                      grade12: grade == 12 ? v : null,
                    );
                  }),
                  selectedColor: _getGradeColor(grade).withOpacity(0.2),
                  checkmarkColor: _getGradeColor(grade),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscoverySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Discovery (Grades 7-8)', Icons.explore, Colors.teal),
            const SizedBox(height: 16),
            TextFormField(
              controller: _dayInLifeController,
              decoration: const InputDecoration(
                labelText: 'A Day in the Life',
                hintText: 'Describe a typical day for this career...',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _funFactController,
              decoration: const InputDecoration(
                labelText: 'Fun Fact',
                hintText: 'An interesting fact about this career...',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
              textInputAction: TextInputAction.next,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBridgeSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Bridge (Grades 9-10)', Icons.compare_arrows, Colors.indigo),
            const SizedBox(height: 16),
            TextFormField(
              controller: _streamRequiredController,
              decoration: const InputDecoration(
                labelText: 'Required 11th Stream',
                hintText: 'e.g., MPC with Computer Science',
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.next,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExecutionSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Execution (Grades 11-12)', Icons.rocket_launch, Colors.deepOrange),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _entrySalaryController,
                    decoration: const InputDecoration(labelText: 'Entry Salary', hintText: '₹4-6 LPA', border: OutlineInputBorder()),
                    textInputAction: TextInputAction.next,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _fiveYearSalaryController,
                    decoration: const InputDecoration(labelText: '5-Year Salary', hintText: '₹12-18 LPA', border: OutlineInputBorder()),
                    textInputAction: TextInputAction.next,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _avgSalaryController,
              decoration: const InputDecoration(labelText: 'Average Salary', hintText: '₹8-15 LPA', border: OutlineInputBorder()),
              textInputAction: TextInputAction.done,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveCareer,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.teacherColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(_isEditing ? 'Update Career' : 'Create Career', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Future<void> _saveCareer() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      final now = DateTime.now();
      final career = ManagedCareer(
        id: widget.career?.id ?? '',
        title: _titleController.text.trim(),
        streamTag: _selectedStream,
        shortDescription: _descriptionController.text.trim(),
        iconName: _selectedIcon,
        gradeVisibility: _gradeVisibility,
        isActive: widget.career?.isActive ?? true,
        createdAt: widget.career?.createdAt ?? now,
        updatedAt: now,
        createdBy: widget.teacher?.uid ?? '',
        discoveryContent: DiscoveryContent(
          dayInLife: _dayInLifeController.text.trim(),
          funFact: _funFactController.text.trim(),
          visualAids: widget.career?.discoveryContent.visualAids ?? [],
          introVideos: widget.career?.discoveryContent.introVideos ?? [],
        ),
        bridgeContent: BridgeContent(
          required11thStream: _streamRequiredController.text.trim(),
          foundationTopics: widget.career?.bridgeContent.foundationTopics ?? [],
          streamComparison: widget.career?.bridgeContent.streamComparison ?? StreamComparison(comparedStream: '', pros: [], cons: []),
          keySkillsToStart: widget.career?.bridgeContent.keySkillsToStart ?? [],
        ),
        executionContent: ExecutionContent(
          entranceExams: widget.career?.executionContent.entranceExams ?? [],
          topColleges: widget.career?.executionContent.topColleges ?? [],
          financialReality: FinancialReality(
            entrySalary: _entrySalaryController.text.trim(),
            fiveYearSalary: _fiveYearSalaryController.text.trim(),
            tenYearSalary: widget.career?.executionContent.financialReality.tenYearSalary ?? '',
            growthData: widget.career?.executionContent.financialReality.growthData ?? [],
          ),
          planB: widget.career?.executionContent.planB ?? PlanB(title: '', description: '', alternativePaths: []),
        ),
        realityTask: widget.career?.realityTask ?? RealityTask(
          taskTitle: '',
          taskInstructions: '',
          taskType: TaskType.logicPuzzle,
          questions: [],
          successOutcome: '',
        ),
        realityCheck: RealityCheck(
          avgSalary: _avgSalaryController.text.trim(),
          jobStressIndex: widget.career?.realityCheck.jobStressIndex ?? 5,
          studyHoursDaily: widget.career?.realityCheck.studyHoursDaily ?? 4,
          yearsToMaster: widget.career?.realityCheck.yearsToMaster ?? 5,
          workLifeBalance: widget.career?.realityCheck.workLifeBalance ?? 'Moderate',
          jobAvailability: widget.career?.realityCheck.jobAvailability ?? 'Moderate',
        ),
        resourceLibrary: widget.career?.resourceLibrary ?? ResourceLibrary(courses: [], videos: [], articles: [], ncertChapters: []),
        roadmap: widget.career?.roadmap ?? CareerRoadmap(nodes: []),
      );

      if (_isEditing) {
        await _teacherService.updateCareer(career.id, career.toMap());
      } else {
        await _teacherService.createCareer(career);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? 'Career updated!' : 'Career created!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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

  IconData _getIconData(String name) {
    switch (name) {
      case 'computer': return Icons.computer;
      case 'medical_services': return Icons.medical_services;
      case 'account_balance': return Icons.account_balance;
      case 'gavel': return Icons.gavel;
      case 'web': return Icons.web;
      case 'science': return Icons.science;
      case 'architecture': return Icons.architecture;
      case 'psychology': return Icons.psychology;
      case 'business': return Icons.business;
      case 'engineering': return Icons.engineering;
      default: return Icons.work;
    }
  }

  static const _iconOptions = [
    'work', 'computer', 'medical_services', 'account_balance', 'gavel',
    'web', 'science', 'architecture', 'psychology', 'business', 'engineering',
  ];
}
