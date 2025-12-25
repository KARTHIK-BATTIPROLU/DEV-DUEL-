import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/user_model.dart';
import '../../../models/teacher_models.dart';
import '../../../services/teacher_service.dart';
import '../../../core/constants/app_constants.dart';

/// Analytics Tab - Student engagement, activity tracking, and inactivity alerts
class AnalyticsTab extends StatefulWidget {
  final List<StudentModel> students;

  const AnalyticsTab({super.key, required this.students});

  @override
  State<AnalyticsTab> createState() => _AnalyticsTabState();
}

class _AnalyticsTabState extends State<AnalyticsTab> with SingleTickerProviderStateMixin {
  final _teacherService = TeacherService();
  late TabController _subTabController;
  List<StudentActivity> _activities = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _subTabController = TabController(length: 3, vsync: this);
    _loadActivities();
  }

  @override
  void dispose() {
    _subTabController.dispose();
    super.dispose();
  }

  Future<void> _loadActivities() async {
    setState(() => _isLoading = true);
    _activities = await _teacherService.getAllStudentActivities();
    setState(() => _isLoading = false);
  }

  List<StudentActivity> get _inactiveStudents => _activities.where((a) => a.isInactive).toList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _subTabController,
            labelColor: AppTheme.teacherColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppTheme.teacherColor,
            tabs: [
              const Tab(text: 'Overview'),
              Tab(text: 'Inactive (${_inactiveStudents.length})'),
              const Tab(text: 'Activity Log'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _subTabController,
            children: [
              _OverviewTab(students: widget.students, activities: _activities),
              _InactiveStudentsTab(inactiveStudents: _inactiveStudents),
              _ActivityLogTab(activities: _activities),
            ],
          ),
        ),
      ],
    );
  }
}

/// Overview Tab
class _OverviewTab extends StatelessWidget {
  final List<StudentModel> students;
  final List<StudentActivity> activities;

  const _OverviewTab({required this.students, required this.activities});

  @override
  Widget build(BuildContext context) {
    final gradeDistribution = _calculateGradeDistribution();
    final totalCareersExplored = activities.fold<int>(0, (sum, a) => sum + a.careersExplored);
    final totalTasksCompleted = activities.fold<int>(0, (sum, a) => sum + a.tasksCompleted);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOverviewCards(totalCareersExplored, totalTasksCompleted),
          const SizedBox(height: 24),
          const Text('Students by Grade', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildGradeDistributionChart(gradeDistribution),
          const SizedBox(height: 24),
          const Text('Learning Phases', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildPhaseBreakdown(gradeDistribution),
        ],
      ),
    );
  }

  Widget _buildOverviewCards(int careersExplored, int tasksCompleted) {
    return Row(
      children: [
        Expanded(child: _buildStatCard('Students', '${students.length}', Icons.people, Colors.blue)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('Careers Explored', '$careersExplored', Icons.explore, Colors.green)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('Tasks Done', '$tasksCompleted', Icons.task_alt, Colors.orange)),
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

  Map<int, int> _calculateGradeDistribution() {
    final distribution = <int, int>{};
    for (final grade in AppConstants.validGrades) {
      distribution[grade] = students.where((s) => s.grade == grade).length;
    }
    return distribution;
  }

  Widget _buildGradeDistributionChart(Map<int, int> distribution) {
    final maxCount = distribution.values.isEmpty ? 1 : distribution.values.reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: AppConstants.validGrades.map((grade) {
          final count = distribution[grade] ?? 0;
          final percentage = maxCount > 0 ? count / maxCount : 0.0;
          final color = _getGradeColor(grade);

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                SizedBox(width: 60, child: Text('Grade $grade', style: const TextStyle(fontWeight: FontWeight.w500))),
                Expanded(
                  child: Stack(
                    children: [
                      Container(height: 24, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12))),
                      FractionallySizedBox(
                        widthFactor: percentage,
                        child: Container(
                          height: 24,
                          decoration: BoxDecoration(gradient: LinearGradient(colors: [color, color.withOpacity(0.7)]), borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(width: 30, child: Text('$count', style: TextStyle(fontWeight: FontWeight.bold, color: color))),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPhaseBreakdown(Map<int, int> distribution) {
    final discoveryCount = (distribution[7] ?? 0) + (distribution[8] ?? 0);
    final bridgeCount = (distribution[9] ?? 0) + (distribution[10] ?? 0);
    final executionCount = (distribution[11] ?? 0) + (distribution[12] ?? 0);
    final total = students.length;

    return Row(
      children: [
        Expanded(child: _buildPhaseCard('Discovery', '7-8', discoveryCount, total, Colors.teal, Icons.explore)),
        const SizedBox(width: 12),
        Expanded(child: _buildPhaseCard('Bridge', '9-10', bridgeCount, total, Colors.indigo, Icons.compare_arrows)),
        const SizedBox(width: 12),
        Expanded(child: _buildPhaseCard('Execution', '11-12', executionCount, total, Colors.deepOrange, Icons.rocket_launch)),
      ],
    );
  }

  Widget _buildPhaseCard(String phase, String grades, int count, int total, Color color, IconData icon) {
    final percentage = total > 0 ? (count / total * 100).toStringAsFixed(0) : '0';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(phase, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
          Text('Grades $grades', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
          const SizedBox(height: 4),
          Text('$count ($percentage%)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        ],
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

/// Inactive Students Tab - Students who haven't logged in for >7 days
class _InactiveStudentsTab extends StatelessWidget {
  final List<StudentActivity> inactiveStudents;

  const _InactiveStudentsTab({required this.inactiveStudents});

  @override
  Widget build(BuildContext context) {
    if (inactiveStudents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 64, color: Colors.green[300]),
            const SizedBox(height: 16),
            const Text('All students are active!', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            Text('No students inactive for more than 7 days', style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: inactiveStudents.length,
      itemBuilder: (context, index) {
        final activity = inactiveStudents[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.red.withOpacity(0.1),
                child: Text(activity.studentName.isNotEmpty ? activity.studentName[0] : '?', style: const TextStyle(color: Colors.red)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(activity.studentName, style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text('Grade ${activity.grade}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: Text('${activity.daysSinceLastLogin} days', style: const TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 4),
                  Text('since last login', style: TextStyle(fontSize: 10, color: Colors.grey[500])),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Activity Log Tab - Recent student activities
class _ActivityLogTab extends StatelessWidget {
  final List<StudentActivity> activities;

  const _ActivityLogTab({required this.activities});

  @override
  Widget build(BuildContext context) {
    if (activities.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text('No activity data yet', style: TextStyle(fontSize: 16)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: activities.length,
      itemBuilder: (context, index) {
        final activity = activities[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: _getGradeColor(activity.grade).withOpacity(0.1),
                child: Text(activity.studentName.isNotEmpty ? activity.studentName[0] : '?',
                    style: TextStyle(color: _getGradeColor(activity.grade), fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(activity.studentName, style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text('Grade ${activity.grade}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildMiniStat(Icons.explore, '${activity.careersExplored}', Colors.blue),
                      const SizedBox(width: 8),
                      _buildMiniStat(Icons.task_alt, '${activity.tasksCompleted}', Colors.green),
                      const SizedBox(width: 8),
                      _buildMiniStat(Icons.quiz, '${activity.quizzesAttempted}', Colors.orange),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMiniStat(IconData icon, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 2),
          Text(value, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Color _getGradeColor(int grade) {
    if (grade <= 8) return Colors.teal;
    if (grade <= 10) return Colors.indigo;
    return Colors.deepOrange;
  }
}
