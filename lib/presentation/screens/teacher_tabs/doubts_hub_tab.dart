import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/teacher_models.dart';
import '../../../models/user_model.dart';
import '../../../services/teacher_service.dart';
import '../../../services/hive_service.dart';

/// Doubts Hub Tab - Answer student questions (LIVE STREAM)
class DoubtsHubTab extends StatefulWidget {
  const DoubtsHubTab({super.key});

  @override
  State<DoubtsHubTab> createState() => _DoubtsHubTabState();
}

class _DoubtsHubTabState extends State<DoubtsHubTab> with SingleTickerProviderStateMixin {
  final _teacherService = TeacherService();
  late TabController _tabController;
  TeacherModel? _teacher;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _teacher = HiveService.getTeacher();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            labelColor: AppTheme.teacherColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppTheme.teacherColor,
            tabs: const [
              Tab(text: 'Pending'),
              Tab(text: 'Answered'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _DoubtsListView(
                stream: _teacherService.unresolvedDoubtsStream(),
                emptyMessage: 'No pending doubts',
                emptySubMessage: 'All student questions have been answered!',
                teacher: _teacher,
              ),
              _DoubtsListView(
                stream: _teacherService.allDoubtsStream().map((doubts) => doubts.where((d) => d.isResolved).toList()),
                emptyMessage: 'No answered doubts yet',
                emptySubMessage: 'Answered doubts will appear here',
                teacher: _teacher,
                showAnswered: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DoubtsListView extends StatelessWidget {
  final Stream<List<Doubt>> stream;
  final String emptyMessage;
  final String emptySubMessage;
  final TeacherModel? teacher;
  final bool showAnswered;

  const _DoubtsListView({
    required this.stream,
    required this.emptyMessage,
    required this.emptySubMessage,
    required this.teacher,
    this.showAnswered = false,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Doubt>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final doubts = snapshot.data ?? [];
        if (doubts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(showAnswered ? Icons.check_circle : Icons.help_outline, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(emptyMessage, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                Text(emptySubMessage, style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: doubts.length,
          itemBuilder: (context, index) => _DoubtCard(
            doubt: doubts[index],
            teacher: teacher,
            showAnswered: showAnswered,
          ),
        );
      },
    );
  }
}

class _DoubtCard extends StatelessWidget {
  final Doubt doubt;
  final TeacherModel? teacher;
  final bool showAnswered;

  const _DoubtCard({required this.doubt, required this.teacher, this.showAnswered = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: doubt.isResolved ? Colors.green.withOpacity(0.3) : Colors.orange.withOpacity(0.3)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: doubt.isResolved ? Colors.green.withOpacity(0.05) : Colors.orange.withOpacity(0.05),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: _getGradeColor(doubt.studentGrade).withOpacity(0.1),
                  child: Text(doubt.studentName.isNotEmpty ? doubt.studentName[0] : '?',
                      style: TextStyle(color: _getGradeColor(doubt.studentGrade), fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(doubt.studentName, style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text('Grade ${doubt.studentGrade}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: doubt.isResolved ? Colors.green : Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    doubt.isResolved ? 'Answered' : 'Pending',
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),

          // Question
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (doubt.careerTitle != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text('Re: ${doubt.careerTitle}', style: const TextStyle(fontSize: 11, color: Colors.blue)),
                  ),
                  const SizedBox(height: 8),
                ],
                Text(doubt.question, style: const TextStyle(fontSize: 15, height: 1.4)),
                const SizedBox(height: 8),
                Text(_formatDate(doubt.createdAt), style: TextStyle(fontSize: 11, color: Colors.grey[500])),
              ],
            ),
          ),

          // Answer Section
          if (doubt.isResolved && doubt.answer != null)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.check_circle, size: 14, color: Colors.green),
                      const SizedBox(width: 6),
                      Text('Answered by ${doubt.answeredByName ?? 'Teacher'}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.green)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(doubt.answer!, style: const TextStyle(height: 1.4)),
                ],
              ),
            ),

          // Answer Button (for pending)
          if (!doubt.isResolved)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showAnswerDialog(context),
                  icon: const Icon(Icons.reply, size: 18),
                  label: const Text('Answer'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.teacherColor),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showAnswerDialog(BuildContext context) {
    final answerController = TextEditingController();
    final teacherService = TeacherService();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Answer Doubt'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(doubt.question, style: const TextStyle(fontStyle: FontStyle.italic)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: answerController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Type your answer...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (answerController.text.trim().isEmpty) return;
              try {
                await teacherService.answerDoubt(
                  doubtId: doubt.id,
                  answer: answerController.text.trim(),
                  teacherId: teacher?.uid ?? '',
                  teacherName: teacher?.name ?? 'Teacher',
                );
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Answer sent! Student will see it instantly.'), backgroundColor: Colors.green),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.teacherColor),
            child: const Text('Send Answer'),
          ),
        ],
      ),
    );
  }

  Color _getGradeColor(int grade) {
    if (grade <= 8) return Colors.teal;
    if (grade <= 10) return Colors.indigo;
    return Colors.deepOrange;
  }

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
