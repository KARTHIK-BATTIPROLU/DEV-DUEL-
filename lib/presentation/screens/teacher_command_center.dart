import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/route_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/hive_service.dart';
import '../../providers/theme_provider.dart';
import 'teacher_tabs/career_factory_tab.dart';
import 'teacher_tabs/review_hub_tab.dart';
import 'teacher_tabs/notice_board_tab.dart';
import 'teacher_tabs/analytics_tab.dart';
import 'teacher_tabs/assessment_lab_tab.dart';
import 'teacher_tabs/roadmap_architect_tab.dart';
import 'teacher_tabs/doubts_hub_tab.dart';
import 'teacher_tabs/resource_manager_tab.dart';
import 'class_students_screen.dart';
import '../../core/constants/app_constants.dart';

/// Teacher Command Center - Main hub for teacher management
/// 9 Tabs: Students, Careers, Roadmaps, Resources, Reviews, Doubts, Notices, Quizzes, Analytics
class TeacherCommandCenter extends StatefulWidget {
  const TeacherCommandCenter({super.key});

  @override
  State<TeacherCommandCenter> createState() => _TeacherCommandCenterState();
}

class _TeacherCommandCenterState extends State<TeacherCommandCenter>
    with SingleTickerProviderStateMixin {
  final _authService = AuthService();
  TeacherModel? _teacher;
  List<StudentModel> _students = [];
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 9, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    _teacher = HiveService.getTeacher();
    _students = await _authService.getAllStudents();
    setState(() => _isLoading = false);
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      // Clear theme role
      if (mounted) {
        context.read<ThemeProvider>().clearRole();
      }
      await _authService.signOut();
      if (mounted) context.go(RouteConstants.login);
    }
  }

  Map<int, List<StudentModel>> _groupStudentsByGrade() {
    final grouped = <int, List<StudentModel>>{};
    for (final grade in AppConstants.validGrades) {
      grouped[grade] = _students.where((s) => s.grade == grade).toList();
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Command Center'),
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
          IconButton(icon: const Icon(Icons.logout), onPressed: _handleLogout),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorWeight: 3,
          tabs: const [
            Tab(icon: Icon(Icons.people), text: 'Students'),
            Tab(icon: Icon(Icons.work), text: 'Careers'),
            Tab(icon: Icon(Icons.route), text: 'Roadmaps'),
            Tab(icon: Icon(Icons.library_books), text: 'Resources'),
            Tab(icon: Icon(Icons.rate_review), text: 'Reviews'),
            Tab(icon: Icon(Icons.help_center), text: 'Doubts'),
            Tab(icon: Icon(Icons.campaign), text: 'Notices'),
            Tab(icon: Icon(Icons.quiz), text: 'Quizzes'),
            Tab(icon: Icon(Icons.analytics), text: 'Analytics'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _StudentsTab(students: _students, groupedStudents: _groupStudentsByGrade()),
                const CareerFactoryTab(),
                const RoadmapArchitectTab(),
                const ResourceManagerTab(),
                const ReviewHubTab(),
                const DoubtsHubTab(),
                const NoticeBoardTab(),
                const AssessmentLabTab(),
                AnalyticsTab(students: _students),
              ],
            ),
    );
  }
}

/// Students Tab - Shows students grouped by grade
class _StudentsTab extends StatelessWidget {
  final List<StudentModel> students;
  final Map<int, List<StudentModel>> groupedStudents;

  const _StudentsTab({required this.students, required this.groupedStudents});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Row
          _buildStatsRow(),
          const SizedBox(height: 24),
          
          // Grade Cards
          const Text('Students by Grade', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...AppConstants.validGrades.map((grade) => _buildGradeCard(context, grade)),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    final activeGrades = groupedStudents.values.where((list) => list.isNotEmpty).length;
    
    return Row(
      children: [
        Expanded(child: _buildStatCard('Total Students', '${students.length}', Icons.people, Colors.blue)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('Active Grades', '$activeGrades', Icons.school, Colors.green)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('Avg/Grade', students.isEmpty ? '0' : '${(students.length / 6).toStringAsFixed(1)}', Icons.bar_chart, Colors.orange)),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildGradeCard(BuildContext context, int grade) {
    final gradeStudents = groupedStudents[grade] ?? [];
    final count = gradeStudents.length;
    final color = _getGradeColor(grade);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ClassStudentsScreen(grade: grade, students: gradeStudents)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [color, color.withOpacity(0.7)]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text('$grade', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Grade $grade', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  Text('$count ${count == 1 ? 'student' : 'students'}', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Color _getGradeColor(int grade) {
    switch (grade) {
      case 7: return Colors.teal;
      case 8: return Colors.blue;
      case 9: return Colors.indigo;
      case 10: return Colors.purple;
      case 11: return Colors.deepOrange;
      case 12: return Colors.red;
      default: return AppTheme.primaryColor;
    }
  }
}
