import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/teacher_models.dart';
import '../../../services/teacher_service.dart';
import '../../../services/hive_service.dart';

/// Notice Board Tab - Manage notices and events
class NoticeBoardTab extends StatefulWidget {
  const NoticeBoardTab({super.key});

  @override
  State<NoticeBoardTab> createState() => _NoticeBoardTabState();
}

class _NoticeBoardTabState extends State<NoticeBoardTab> with SingleTickerProviderStateMixin {
  final _teacherService = TeacherService();
  late TabController _tabController;
  
  // Sample data
  final List<Notice> _notices = [
    Notice(
      id: '1',
      title: 'Career Guidance Webinar',
      description: 'Join us for an interactive session on choosing the right stream after 10th grade.',
      type: NoticeType.webinar,
      eventDate: DateTime.now().add(const Duration(days: 3)),
      eventTime: '4:00 PM',
      meetingLink: 'https://meet.google.com/abc-xyz',
      targetGrades: [9, 10],
      createdAt: DateTime.now(),
      createdBy: 'teacher1',
    ),
    Notice(
      id: '2',
      title: 'JEE Preparation Workshop',
      description: 'Tips and strategies for JEE Main preparation by IIT alumni.',
      type: NoticeType.workshop,
      eventDate: DateTime.now().add(const Duration(days: 7)),
      eventTime: '10:00 AM',
      targetGrades: [11, 12],
      createdAt: DateTime.now(),
      createdBy: 'teacher1',
    ),
    Notice(
      id: '3',
      title: 'Career Talk: Life as a Doctor',
      description: 'Dr. Sharma from AIIMS will share insights about medical career.',
      type: NoticeType.careerTalk,
      eventDate: DateTime.now().add(const Duration(days: 5)),
      eventTime: '3:00 PM',
      targetGrades: [],
      createdAt: DateTime.now(),
      createdBy: 'teacher1',
    ),
  ];

  final List<Opportunity> _opportunities = [
    Opportunity(
      id: '1',
      title: 'NTSE Scholarship',
      description: 'National Talent Search Examination for Class 10 students.',
      type: OpportunityType.scholarship,
      eligibility: 'Class 10 students with 75%+ marks',
      deadline: DateTime.now().add(const Duration(days: 30)),
      applicationLink: 'https://ncert.nic.in/ntse',
      targetGrades: [10],
      createdAt: DateTime.now(),
      createdBy: 'teacher1',
    ),
    Opportunity(
      id: '2',
      title: 'Science Olympiad',
      description: 'National Science Olympiad for grades 7-12.',
      type: OpportunityType.olympiad,
      eligibility: 'All students',
      deadline: DateTime.now().add(const Duration(days: 45)),
      targetGrades: [7, 8, 9, 10, 11, 12],
      createdAt: DateTime.now(),
      createdBy: 'teacher1',
    ),
    Opportunity(
      id: '3',
      title: 'Google Summer Internship',
      description: 'Virtual internship program for aspiring developers.',
      type: OpportunityType.internship,
      eligibility: 'Class 11-12 with coding knowledge',
      deadline: DateTime.now().add(const Duration(days: 60)),
      applicationLink: 'https://google.com/internships',
      targetGrades: [11, 12],
      createdAt: DateTime.now(),
      createdBy: 'teacher1',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
        // Sub-tabs
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            labelColor: AppTheme.teacherColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppTheme.teacherColor,
            tabs: const [
              Tab(text: 'Events & Notices'),
              Tab(text: 'Opportunities'),
            ],
          ),
        ),
        
        // Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildNoticesView(),
              _buildOpportunitiesView(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNoticesView() {
    return Stack(
      children: [
        ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _notices.length,
          itemBuilder: (context, index) => _NoticeCard(notice: _notices[index]),
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton.extended(
            onPressed: () => _showCreateNoticeDialog(),
            backgroundColor: AppTheme.teacherColor,
            icon: const Icon(Icons.add),
            label: const Text('Add Notice'),
          ),
        ),
      ],
    );
  }

  Widget _buildOpportunitiesView() {
    return Stack(
      children: [
        ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _opportunities.length,
          itemBuilder: (context, index) => _OpportunityCard(opportunity: _opportunities[index]),
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton.extended(
            onPressed: () => _showCreateOpportunityDialog(),
            backgroundColor: AppTheme.teacherColor,
            icon: const Icon(Icons.add),
            label: const Text('Add Opportunity'),
          ),
        ),
      ],
    );
  }

  void _showCreateNoticeDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    NoticeType selectedType = NoticeType.announcement;
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Create Notice'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<NoticeType>(
                  value: selectedType,
                  decoration: const InputDecoration(labelText: 'Type', border: OutlineInputBorder()),
                  items: NoticeType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.displayName))).toList(),
                  onChanged: (v) => setDialogState(() => selectedType = v!),
                ),
                const SizedBox(height: 12),
                ListTile(
                  title: const Text('Event Date'),
                  subtitle: Text('${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) setDialogState(() => selectedDate = date);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Notice created successfully!')),
                );
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateOpportunityDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    OpportunityType selectedType = OpportunityType.scholarship;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Create Opportunity'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<OpportunityType>(
                  value: selectedType,
                  decoration: const InputDecoration(labelText: 'Type', border: OutlineInputBorder()),
                  items: OpportunityType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.displayName))).toList(),
                  onChanged: (v) => setDialogState(() => selectedType = v!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Opportunity created successfully!')),
                );
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Notice Card Widget
class _NoticeCard extends StatelessWidget {
  final Notice notice;
  const _NoticeCard({required this.notice});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getTypeColor(notice.type).withOpacity(0.1),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Icon(_getTypeIcon(notice.type), color: _getTypeColor(notice.type)),
                const SizedBox(width: 8),
                Text(notice.type.displayName, style: TextStyle(fontWeight: FontWeight.w600, color: _getTypeColor(notice.type))),
                const Spacer(),
                if (notice.targetGrades.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
                    child: Text('Grades: ${notice.targetGrades.join(", ")}', style: const TextStyle(fontSize: 11)),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(notice.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text(notice.description, style: TextStyle(color: Colors.grey[700])),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text('${notice.eventDate.day}/${notice.eventDate.month}/${notice.eventDate.year}',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                    if (notice.eventTime != null) ...[
                      const SizedBox(width: 12),
                      Icon(Icons.access_time, size: 16, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Text(notice.eventTime!, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(NoticeType type) {
    switch (type) {
      case NoticeType.webinar: return Colors.blue;
      case NoticeType.workshop: return Colors.green;
      case NoticeType.careerTalk: return Colors.purple;
      case NoticeType.announcement: return Colors.orange;
      case NoticeType.deadline: return Colors.red;
    }
  }

  IconData _getTypeIcon(NoticeType type) {
    switch (type) {
      case NoticeType.webinar: return Icons.video_call;
      case NoticeType.workshop: return Icons.build;
      case NoticeType.careerTalk: return Icons.record_voice_over;
      case NoticeType.announcement: return Icons.campaign;
      case NoticeType.deadline: return Icons.alarm;
    }
  }
}

/// Opportunity Card Widget
class _OpportunityCard extends StatelessWidget {
  final Opportunity opportunity;
  const _OpportunityCard({required this.opportunity});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getTypeColor(opportunity.type).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(opportunity.type.displayName,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _getTypeColor(opportunity.type))),
                ),
                const Spacer(),
                if (opportunity.deadline != null)
                  Text('Deadline: ${opportunity.deadline!.day}/${opportunity.deadline!.month}',
                      style: TextStyle(fontSize: 12, color: Colors.red[400])),
              ],
            ),
            const SizedBox(height: 12),
            Text(opportunity.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(opportunity.description, style: TextStyle(color: Colors.grey[700])),
            if (opportunity.eligibility != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.check_circle, size: 16, color: Colors.green[400]),
                  const SizedBox(width: 4),
                  Expanded(child: Text(opportunity.eligibility!, style: TextStyle(fontSize: 13, color: Colors.grey[600]))),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getTypeColor(OpportunityType type) {
    switch (type) {
      case OpportunityType.scholarship: return Colors.green;
      case OpportunityType.competition: return Colors.blue;
      case OpportunityType.olympiad: return Colors.purple;
      case OpportunityType.internship: return Colors.orange;
      case OpportunityType.course: return Colors.teal;
    }
  }
}
