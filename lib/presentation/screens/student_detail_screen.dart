import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/user_model.dart';
import '../../services/mentorship_service.dart';
import '../../services/hive_service.dart';

/// Brand Colors
const Color kDeepCorporateBlue = Color(0xFF003F75);
const Color kTechBlue = Color(0xFF2884BD);

/// Student Detail Screen - Detailed view with mentorship features
class StudentDetailScreen extends StatefulWidget {
  final StudentModel student;
  final Color gradeColor;

  const StudentDetailScreen({
    super.key,
    required this.student,
    required this.gradeColor,
  });

  @override
  State<StudentDetailScreen> createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends State<StudentDetailScreen> {
  final _mentorshipService = MentorshipService();
  TeacherModel? _teacher;
  MentorshipStats? _stats;

  @override
  void initState() {
    super.initState();
    _teacher = HiveService.getTeacher();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final stats = await _mentorshipService.getStudentStats(widget.student.uid);
    if (mounted) setState(() => _stats = stats);
  }

  String get phaseLabel {
    if (widget.student.grade <= 8) return 'Interest Exploration';
    if (widget.student.grade <= 10) return 'Decision Support';
    return 'Career Preparation';
  }

  String get phaseDescription {
    if (widget.student.grade <= 8) return 'Exploration phase - discovering interests.';
    if (widget.student.grade <= 10) return 'Preparing for stream choices.';
    return 'Focused on entrance exams and career prep.';
  }

  IconData get phaseIcon {
    if (widget.student.grade <= 8) return Icons.explore;
    if (widget.student.grade <= 10) return Icons.fork_right;
    return Icons.rocket_launch;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoCard(),
                  const SizedBox(height: 20),
                  _buildPhaseCard(),
                  const SizedBox(height: 20),
                  _buildQuickStats(),
                  const SizedBox(height: 20),
                  _buildMentoringActions(context),
                  const SizedBox(height: 20),
                  _buildMentorNotesSection(),
                  const SizedBox(height: 20),
                  _buildAssignedTasksSection(),
                  const SizedBox(height: 20),
                  _buildPrivateSessionsSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: kDeepCorporateBlue,
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [kDeepCorporateBlue, kDeepCorporateBlue.withOpacity(0.8)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 8))],
                  ),
                  child: Center(
                    child: Text(
                      widget.student.name.isNotEmpty ? widget.student.name[0].toUpperCase() : '?',
                      style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: kDeepCorporateBlue),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(widget.student.name, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                  child: Text('Grade ${widget.student.grade}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person, color: kDeepCorporateBlue, size: 22),
              const SizedBox(width: 8),
              const Text('Student Information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          _buildInfoRow(Icons.badge, 'Student ID', widget.student.studentId),
          const Divider(height: 24),
          _buildInfoRow(Icons.email, 'Email', widget.student.email),
          const Divider(height: 24),
          _buildInfoRow(Icons.school, 'Grade', '${widget.student.grade}'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: kDeepCorporateBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: kDeepCorporateBlue, size: 18),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPhaseCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [kTechBlue.withOpacity(0.1), kTechBlue.withOpacity(0.05)]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kTechBlue.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: kTechBlue, borderRadius: BorderRadius.circular(12)),
            child: Icon(phaseIcon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(phaseLabel, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kTechBlue)),
                Text(phaseDescription, style: TextStyle(fontSize: 13, color: Colors.grey[700])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(child: _buildStatCard(Icons.note, '${_stats?.totalNotes ?? 0}', 'Notes', Colors.blue)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard(Icons.task_alt, '${_stats?.completedTasks ?? 0}/${_stats?.totalTasks ?? 0}', 'Tasks', Colors.green)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard(Icons.event, '${_stats?.totalSessions ?? 0}', 'Sessions', Colors.orange)),
      ],
    );
  }

  Widget _buildStatCard(IconData icon, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)]),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildMentoringActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.psychology, color: kDeepCorporateBlue, size: 22),
              const SizedBox(width: 8),
              const Text('Mentoring Actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          _buildActionButton(Icons.note_add, 'Add Mentor Note', kTechBlue, () => _showAddNoteDialog()),
          const SizedBox(height: 12),
          _buildActionButton(Icons.assignment, 'Assign Task', Colors.green, () => _showAssignTaskDialog()),
          const SizedBox(height: 12),
          _buildActionButton(Icons.event, 'Schedule Session', Colors.orange, () => _showScheduleSessionDialog()),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 12),
            Text(label, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: color)),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, color: color, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildMentorNotesSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.note, color: kDeepCorporateBlue, size: 22),
              const SizedBox(width: 8),
              const Text('Mentor Notes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const Spacer(),
              TextButton.icon(onPressed: _showAddNoteDialog, icon: const Icon(Icons.add, size: 18), label: const Text('Add')),
            ],
          ),
          const SizedBox(height: 12),
          StreamBuilder<List<MentorNote>>(
            stream: _mentorshipService.mentorNotesStream(widget.student.uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final notes = snapshot.data ?? [];
              if (notes.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      Icon(Icons.edit_note, color: Colors.grey[400], size: 24),
                      const SizedBox(width: 12),
                      Text('No notes yet. Add your first note.', style: TextStyle(color: Colors.grey[500], fontStyle: FontStyle.italic)),
                    ],
                  ),
                );
              }
              return Column(
                children: notes.take(3).map((note) => _buildNoteCard(note)).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNoteCard(MentorNote note) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: kTechBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(note.teacherName, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: kTechBlue)),
              const Spacer(),
              Text(_formatDate(note.createdAt), style: TextStyle(fontSize: 10, color: Colors.grey[600])),
              IconButton(
                icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                onPressed: () => _deleteNote(note.id),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(note.content, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildAssignedTasksSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.assignment, color: Colors.green, size: 22),
              const SizedBox(width: 8),
              const Text('Assigned Tasks', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const Spacer(),
              TextButton.icon(onPressed: _showAssignTaskDialog, icon: const Icon(Icons.add, size: 18), label: const Text('Assign')),
            ],
          ),
          const SizedBox(height: 12),
          StreamBuilder<List<AssignedTask>>(
            stream: _mentorshipService.assignedTasksStream(widget.student.uid),
            builder: (context, snapshot) {
              final tasks = snapshot.data ?? [];
              if (tasks.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      Icon(Icons.task, color: Colors.grey[400], size: 24),
                      const SizedBox(width: 12),
                      Text('No tasks assigned yet.', style: TextStyle(color: Colors.grey[500], fontStyle: FontStyle.italic)),
                    ],
                  ),
                );
              }
              return Column(children: tasks.take(3).map((task) => _buildTaskCard(task)).toList());
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(AssignedTask task) {
    final statusColor = task.isCompleted ? Colors.green : (task.isOverdue ? Colors.red : Colors.orange);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: statusColor.withOpacity(0.3))),
      child: Row(
        children: [
          Icon(task.isCompleted ? Icons.check_circle : Icons.pending, color: statusColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(task.description, style: TextStyle(fontSize: 12, color: Colors.grey[600]), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          IconButton(icon: const Icon(Icons.delete, size: 18, color: Colors.red), onPressed: () => _deleteTask(task.id), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
        ],
      ),
    );
  }

  Widget _buildPrivateSessionsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.event, color: Colors.orange, size: 22),
              const SizedBox(width: 8),
              const Text('Scheduled Sessions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const Spacer(),
              TextButton.icon(onPressed: _showScheduleSessionDialog, icon: const Icon(Icons.add, size: 18), label: const Text('Schedule')),
            ],
          ),
          const SizedBox(height: 12),
          StreamBuilder<List<PrivateSession>>(
            stream: _mentorshipService.privateSessionsStream(widget.student.uid),
            builder: (context, snapshot) {
              final sessions = snapshot.data ?? [];
              if (sessions.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: Colors.grey[400], size: 24),
                      const SizedBox(width: 12),
                      Text('No sessions scheduled.', style: TextStyle(color: Colors.grey[500], fontStyle: FontStyle.italic)),
                    ],
                  ),
                );
              }
              return Column(children: sessions.take(3).map((s) => _buildSessionCard(s)).toList());
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSessionCard(PrivateSession session) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(8)),
            child: Column(
              children: [
                Text('${session.eventDate.day}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                Text(_getMonthAbbr(session.eventDate.month), style: const TextStyle(color: Colors.white, fontSize: 10)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(session.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text('${session.eventTime}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ),
          IconButton(icon: const Icon(Icons.cancel, size: 18, color: Colors.red), onPressed: () => _cancelSession(session.id), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
        ],
      ),
    );
  }

  // ============================================================
  // DIALOGS
  // ============================================================

  void _showAddNoteDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.note_add, color: kTechBlue),
            const SizedBox(width: 8),
            const Text('Add Mentor Note'),
          ],
        ),
        content: TextField(
          controller: controller,
          maxLines: 4,
          decoration: const InputDecoration(hintText: 'Write your note here...', border: OutlineInputBorder()),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () { controller.dispose(); Navigator.pop(ctx); }, child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isEmpty) return;
              await _mentorshipService.addMentorNote(
                studentId: widget.student.uid,
                content: controller.text.trim(),
                teacherId: _teacher?.uid ?? '',
                teacherName: _teacher?.name ?? 'Teacher',
              );
              controller.dispose();
              if (ctx.mounted) Navigator.pop(ctx);
              _loadStats();
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Note added!'), backgroundColor: Colors.green));
            },
            style: ElevatedButton.styleFrom(backgroundColor: kTechBlue),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAssignTaskDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    DateTime? dueDate;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Row(children: [Icon(Icons.assignment, color: Colors.green), SizedBox(width: 8), Text('Assign Task')]),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Task Title *', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(controller: descController, maxLines: 3, decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today),
                  title: Text(dueDate != null ? _formatDate(dueDate!) : 'Set Due Date (optional)'),
                  onTap: () async {
                    final picked = await showDatePicker(context: ctx, initialDate: DateTime.now().add(const Duration(days: 7)), firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
                    if (picked != null) setDialogState(() => dueDate = picked);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () { titleController.dispose(); descController.dispose(); Navigator.pop(ctx); }, child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.trim().isEmpty) return;
                await _mentorshipService.assignTask(
                  studentId: widget.student.uid,
                  studentName: widget.student.name,
                  title: titleController.text.trim(),
                  description: descController.text.trim(),
                  teacherId: _teacher?.uid ?? '',
                  teacherName: _teacher?.name ?? 'Teacher',
                  dueDate: dueDate,
                );
                titleController.dispose();
                descController.dispose();
                if (ctx.mounted) Navigator.pop(ctx);
                _loadStats();
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Task assigned!'), backgroundColor: Colors.green));
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Assign'),
            ),
          ],
        ),
      ),
    );
  }

  void _showScheduleSessionDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final linkController = TextEditingController();
    DateTime sessionDate = DateTime.now().add(const Duration(days: 1));
    TimeOfDay sessionTime = const TimeOfDay(hour: 10, minute: 0);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Row(children: [Icon(Icons.event, color: Colors.orange), SizedBox(width: 8), Text('Schedule Session')]),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Session Title *', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(controller: descController, maxLines: 2, decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(controller: linkController, decoration: const InputDecoration(labelText: 'Meeting Link (optional)', hintText: 'https://meet.google.com/...', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today),
                  title: Text(_formatDate(sessionDate)),
                  onTap: () async {
                    final picked = await showDatePicker(context: ctx, initialDate: sessionDate, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
                    if (picked != null) setDialogState(() => sessionDate = picked);
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.access_time),
                  title: Text(sessionTime.format(ctx)),
                  onTap: () async {
                    final picked = await showTimePicker(context: ctx, initialTime: sessionTime);
                    if (picked != null) setDialogState(() => sessionTime = picked);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () { titleController.dispose(); descController.dispose(); linkController.dispose(); Navigator.pop(ctx); }, child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.trim().isEmpty) return;
                await _mentorshipService.schedulePrivateSession(
                  studentId: widget.student.uid,
                  studentName: widget.student.name,
                  title: titleController.text.trim(),
                  description: descController.text.trim(),
                  sessionDate: sessionDate,
                  sessionTime: sessionTime.format(ctx),
                  meetingLink: linkController.text.trim().isNotEmpty ? linkController.text.trim() : null,
                  teacherId: _teacher?.uid ?? '',
                  teacherName: _teacher?.name ?? 'Teacher',
                );
                titleController.dispose();
                descController.dispose();
                linkController.dispose();
                if (ctx.mounted) Navigator.pop(ctx);
                _loadStats();
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Session scheduled!'), backgroundColor: Colors.green));
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text('Schedule'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteNote(String noteId) async {
    await _mentorshipService.deleteMentorNote(studentId: widget.student.uid, noteId: noteId);
    _loadStats();
  }

  Future<void> _deleteTask(String taskId) async {
    await _mentorshipService.deleteTask(studentId: widget.student.uid, taskId: taskId);
    _loadStats();
  }

  Future<void> _cancelSession(String sessionId) async {
    await _mentorshipService.cancelSession(sessionId);
    _loadStats();
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _getMonthAbbr(int month) {
    const months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
    return months[month - 1];
  }
}
