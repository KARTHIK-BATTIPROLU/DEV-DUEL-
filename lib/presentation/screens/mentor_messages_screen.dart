import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/mentorship_service.dart';

/// Brand Colors
const Color kDeepCorporateBlue = Color(0xFF003F75);
const Color kTechBlue = Color(0xFF2884BD);

/// Mentor Messages Screen - Student view of mentor communications
class MentorMessagesScreen extends StatefulWidget {
  final String studentId;
  const MentorMessagesScreen({super.key, required this.studentId});

  @override
  State<MentorMessagesScreen> createState() => _MentorMessagesScreenState();
}

class _MentorMessagesScreenState extends State<MentorMessagesScreen> with SingleTickerProviderStateMixin {
  final _mentorshipService = MentorshipService();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages from Mentor'),
        backgroundColor: kDeepCorporateBlue,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.message), text: 'Notes'),
            Tab(icon: Icon(Icons.assignment), text: 'Tasks'),
            Tab(icon: Icon(Icons.event), text: 'Sessions'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _NotesTab(studentId: widget.studentId),
          _TasksTab(studentId: widget.studentId),
          _SessionsTab(studentId: widget.studentId),
        ],
      ),
    );
  }
}


/// Notes Tab - Messages from mentor
class _NotesTab extends StatelessWidget {
  final String studentId;
  const _NotesTab({required this.studentId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<MentorNote>>(
      stream: MentorshipService().mentorNotesStream(studentId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: kTechBlue));
        }
        final notes = snapshot.data ?? [];
        if (notes.isEmpty) {
          return _buildEmptyState(Icons.message_outlined, 'No messages yet', 'Your mentor will send you notes here');
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: notes.length,
          itemBuilder: (context, index) => _NoteCard(note: notes[index]),
        );
      },
    );
  }
}

class _NoteCard extends StatelessWidget {
  final MentorNote note;
  const _NoteCard({required this.note});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kTechBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kTechBlue.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: kDeepCorporateBlue,
                child: Text(note.teacherName.isNotEmpty ? note.teacherName[0] : 'T', style: const TextStyle(color: Colors.white, fontSize: 12)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(note.teacherName, style: const TextStyle(fontWeight: FontWeight.bold, color: kDeepCorporateBlue)),
                    Text(_formatDate(note.createdAt), style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
            child: Text(note.content, style: const TextStyle(fontSize: 14, height: 1.5)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]} ${date.year}, ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

/// Tasks Tab - Assigned tasks from mentor
class _TasksTab extends StatelessWidget {
  final String studentId;
  const _TasksTab({required this.studentId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<AssignedTask>>(
      stream: MentorshipService().assignedTasksStream(studentId),
      builder: (context, snapshot) {
        final tasks = snapshot.data ?? [];
        if (tasks.isEmpty) {
          return _buildEmptyState(Icons.assignment_outlined, 'No tasks assigned', 'Your mentor will assign tasks here');
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: tasks.length,
          itemBuilder: (context, index) => _TaskCard(task: tasks[index]),
        );
      },
    );
  }
}

class _TaskCard extends StatelessWidget {
  final AssignedTask task;
  const _TaskCard({required this.task});

  @override
  Widget build(BuildContext context) {
    final statusColor = task.isCompleted ? Colors.green : (task.isOverdue ? Colors.red : Colors.orange);
    final statusText = task.isCompleted ? 'Completed' : (task.isOverdue ? 'Overdue' : 'Pending');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.3)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Icon(task.isCompleted ? Icons.check_circle : Icons.pending, color: statusColor),
                const SizedBox(width: 8),
                Expanded(child: Text(task.title, style: TextStyle(fontWeight: FontWeight.bold, color: statusColor))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(12)),
                  child: Text(statusText, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task.description, style: TextStyle(color: Colors.grey[700])),
                if (task.dueDate != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text('Due: ${_formatDate(task.dueDate!)}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    ],
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.person, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text('Assigned by: ${task.teacherName}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  ],
                ),
                if (!task.isCompleted) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _markComplete(context, task),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      child: const Text('Mark as Complete'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _markComplete(BuildContext context, AssignedTask task) async {
    await MentorshipService().updateTaskStatus(studentId: task.studentId, taskId: task.id, status: 'completed');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Task marked as complete!'), backgroundColor: Colors.green));
    }
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}


/// Sessions Tab - Private sessions scheduled by mentor
class _SessionsTab extends StatelessWidget {
  final String studentId;
  const _SessionsTab({required this.studentId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<PrivateSession>>(
      stream: MentorshipService().privateSessionsStream(studentId),
      builder: (context, snapshot) {
        final sessions = snapshot.data ?? [];
        if (sessions.isEmpty) {
          return _buildEmptyState(Icons.event_outlined, 'No sessions scheduled', 'Your mentor will schedule sessions here');
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: sessions.length,
          itemBuilder: (context, index) => _SessionCard(session: sessions[index]),
        );
      },
    );
  }
}

class _SessionCard extends StatelessWidget {
  final PrivateSession session;
  const _SessionCard({required this.session});

  @override
  Widget build(BuildContext context) {
    final isUpcoming = session.eventDate.isAfter(DateTime.now());

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(8)),
                  child: Column(
                    children: [
                      Text('${session.eventDate.day}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                      Text(_getMonthAbbr(session.eventDate.month), style: const TextStyle(color: Colors.white, fontSize: 11)),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(session.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 14, color: Colors.orange),
                          const SizedBox(width: 4),
                          Text(session.eventTime, style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ],
                  ),
                ),
                if (isUpcoming)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(12)),
                    child: const Text('Upcoming', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (session.description.isNotEmpty) ...[
                  Text(session.description, style: TextStyle(color: Colors.grey[700])),
                  const SizedBox(height: 12),
                ],
                Row(
                  children: [
                    Icon(Icons.person, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text('With: ${session.createdByName}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  ],
                ),
                if (session.meetingLink != null && session.meetingLink!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _joinMeeting(context, session.meetingLink!),
                      icon: const Icon(Icons.video_call),
                      label: const Text('Join Meeting'),
                      style: ElevatedButton.styleFrom(backgroundColor: kTechBlue),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _joinMeeting(BuildContext context, String link) async {
    final uri = Uri.parse(link);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open meeting link'), backgroundColor: Colors.red));
      }
    }
  }

  String _getMonthAbbr(int month) {
    const months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
    return months[month - 1];
  }
}

Widget _buildEmptyState(IconData icon, String title, String subtitle) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 64, color: Colors.grey[400]),
        const SizedBox(height: 16),
        Text(title, style: TextStyle(fontSize: 18, color: Colors.grey[600])),
        const SizedBox(height: 8),
        Text(subtitle, style: TextStyle(color: Colors.grey[500])),
      ],
    ),
  );
}
