import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/route_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../models/user_model.dart';
import '../../models/teacher_models.dart';
import '../../providers/career_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/auth_service.dart';
import '../../services/hive_service.dart';
import '../../services/student_service.dart';
import 'career_explorer_screen.dart';

/// Student Home Screen - Professional 2025 UI
class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  final _authService = AuthService();
  final _studentService = StudentService();
  StudentModel? _student;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadStudent();
  }

  void _loadStudent() {
    _student = HiveService.getStudent();
    if (_student != null) {
      _studentService.recordLogin(_student!.uid, _student!.name, _student!.grade);
    }
    setState(() {});
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
      if (mounted) context.read<ThemeProvider>().clearRole();
      await _authService.signOut();
      if (mounted) context.go(RouteConstants.login);
    }
  }

  void _navigateToExplore() => setState(() => _currentIndex = 1);
  void _navigateToQuiz() => setState(() => _currentIndex = 1); // Navigate to explore for now

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CareerProvider()..initialize()..updateUserGrade(_student?.grade ?? 10),
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: [
            _HomeTab(student: _student, onLogout: _handleLogout, onExplore: _navigateToExplore, onQuiz: _navigateToQuiz),
            const CareerExplorerScreen(),
            _NoticesTab(student: _student),
            _DoubtsTab(student: _student),
            _ProfileTab(student: _student, onLogout: _handleLogout),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) => setState(() => _currentIndex = index),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
            NavigationDestination(icon: Icon(Icons.explore_outlined), selectedIcon: Icon(Icons.explore), label: 'Explore'),
            NavigationDestination(icon: Icon(Icons.campaign_outlined), selectedIcon: Icon(Icons.campaign), label: 'Notices'),
            NavigationDestination(icon: Icon(Icons.help_outline), selectedIcon: Icon(Icons.help), label: 'Doubts'),
            NavigationDestination(icon: Icon(Icons.person_outlined), selectedIcon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}

/// Home Tab - Professional Design
class _HomeTab extends StatelessWidget {
  final StudentModel? student;
  final VoidCallback onLogout;
  final VoidCallback onExplore;
  final VoidCallback onQuiz;

  const _HomeTab({required this.student, required this.onLogout, required this.onExplore, required this.onQuiz});

  String _getPhaseMessage(int grade) {
    if (grade <= 8) return 'Explore your interests and discover what excites you!';
    if (grade <= 10) return 'Time to think about your stream choice. We\'re here to help!';
    return 'Focus on your goals. Your career journey is taking shape!';
  }

  String _getPhaseName(int grade) {
    if (grade <= 8) return 'Discovery Phase';
    if (grade <= 10) return 'Bridge Phase';
    return 'Execution Phase';
  }

  IconData _getPhaseIcon(int grade) {
    if (grade <= 8) return Icons.explore;
    if (grade <= 10) return Icons.compare_arrows;
    return Icons.rocket_launch;
  }

  @override
  Widget build(BuildContext context) {
    final grade = student?.grade ?? 10;
    final phaseColor = AppTheme.getPhaseColor(grade <= 8 ? 'discovery' : grade <= 10 ? 'bridge' : 'execution');
    final studentService = StudentService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Career Compass'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () {}),
          IconButton(icon: const Icon(Icons.logout), onPressed: onLogout),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            _WelcomeCard(student: student, grade: grade, phaseColor: phaseColor, message: _getPhaseMessage(grade)),
            const SizedBox(height: 24),

            // Phase Card
            _PhaseCard(grade: grade, phaseName: _getPhaseName(grade), phaseIcon: _getPhaseIcon(grade), phaseColor: phaseColor),
            const SizedBox(height: 24),

            // Teacher's Notes
            if (student != null) ...[
              const Text('Teacher\'s Notes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              _TeacherNotesSection(studentId: student!.uid, studentService: studentService),
              const SizedBox(height: 24),
            ],

            // Quick Actions
            const Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _QuickActionCard(title: 'Explore Careers', icon: Icons.explore, color: AppTheme.secondaryColor, onTap: onExplore)),
                const SizedBox(width: 16),
                Expanded(child: _QuickActionCard(title: 'Take a Quiz', icon: Icons.quiz, color: AppTheme.accentColor, onTap: onQuiz)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Welcome Card Component
class _WelcomeCard extends StatelessWidget {
  final StudentModel? student;
  final int grade;
  final Color phaseColor;
  final String message;

  const _WelcomeCard({required this.student, required this.grade, required this.phaseColor, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.gradientDecoration(phaseColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.white.withOpacity(0.2),
                child: Text(
                  student?.name.isNotEmpty == true ? student!.name[0].toUpperCase() : 'S',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hello, ${student?.name ?? 'Student'}!',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                      child: Text('Grade $grade', style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(message, style: TextStyle(fontSize: 15, color: Colors.white.withOpacity(0.95), height: 1.5)),
        ],
      ),
    );
  }
}

/// Phase Card Component
class _PhaseCard extends StatelessWidget {
  final int grade;
  final String phaseName;
  final IconData phaseIcon;
  final Color phaseColor;

  const _PhaseCard({required this.grade, required this.phaseName, required this.phaseIcon, required this.phaseColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.elevatedCardDecoration,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: phaseColor.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
            child: Icon(phaseIcon, color: phaseColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Your Current Phase', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                const SizedBox(height: 4),
                Text(phaseName, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: phaseColor)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Quick Action Card with Hover Animation
class _QuickActionCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({required this.title, required this.icon, required this.color, required this.onTap});

  @override
  State<_QuickActionCard> createState() => _QuickActionCardState();
}

class _QuickActionCardState extends State<_QuickActionCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.identity()..scale(_isHovered ? 1.02 : 1.0),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: widget.color.withOpacity(_isHovered ? 0.15 : 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: widget.color.withOpacity(0.3)),
            boxShadow: _isHovered
                ? [BoxShadow(color: widget.color.withOpacity(0.2), blurRadius: 12, offset: const Offset(0, 4))]
                : null,
          ),
          child: Column(
            children: [
              Icon(widget.icon, color: widget.color, size: 36),
              const SizedBox(height: 12),
              Text(widget.title, style: TextStyle(fontWeight: FontWeight.w600, color: widget.color, fontSize: 14), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

/// Teacher Notes Section
class _TeacherNotesSection extends StatelessWidget {
  final String studentId;
  final StudentService studentService;

  const _TeacherNotesSection({required this.studentId, required this.studentService});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<CareerNote>>(
      stream: studentService.myCareerNotesStream(studentId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final notes = snapshot.data ?? [];
        if (notes.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: AppTheme.cardDecoration,
            child: Row(
              children: [
                Icon(Icons.note_alt_outlined, color: AppTheme.textHint),
                const SizedBox(width: 12),
                Text('No personalized notes yet', style: TextStyle(color: AppTheme.textSecondary)),
              ],
            ),
          );
        }
        return Column(children: notes.take(2).map((note) => _NoteCard(note: note)).toList());
      },
    );
  }
}

/// Note Card Component
class _NoteCard extends StatelessWidget {
  final CareerNote note;
  const _NoteCard({required this.note});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.secondaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.secondaryColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person, size: 16, color: AppTheme.secondaryColor),
              const SizedBox(width: 8),
              Text(note.teacherName, style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.secondaryColor)),
              const Spacer(),
              Text(_formatDate(note.createdAt), style: TextStyle(fontSize: 11, color: AppTheme.textHint)),
            ],
          ),
          const SizedBox(height: 8),
          Text(note.note, style: const TextStyle(height: 1.5)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

/// Notices Tab
class _NoticesTab extends StatelessWidget {
  final StudentModel? student;
  const _NoticesTab({required this.student});

  @override
  Widget build(BuildContext context) {
    final studentService = StudentService();
    final grade = student?.grade ?? 10;

    return Scaffold(
      appBar: AppBar(title: const Text('Notices & Events'), automaticallyImplyLeading: false),
      body: StreamBuilder<List<Notice>>(
        stream: studentService.noticesForGradeStream(grade),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final notices = snapshot.data ?? [];
          if (notices.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.campaign_outlined, size: 64, color: AppTheme.textHint),
                  const SizedBox(height: 16),
                  const Text('No notices yet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  Text('Check back later for updates', style: TextStyle(color: AppTheme.textSecondary)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: notices.length,
            itemBuilder: (context, index) => _NoticeCard(notice: notices[index]),
          );
        },
      ),
    );
  }
}

class _NoticeCard extends StatelessWidget {
  final Notice notice;
  const _NoticeCard({required this.notice});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: AppTheme.elevatedCardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getTypeColor(notice.type).withOpacity(0.1),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Icon(_getTypeIcon(notice.type), color: _getTypeColor(notice.type), size: 20),
                const SizedBox(width: 8),
                Text(notice.type.displayName, style: TextStyle(fontWeight: FontWeight.w600, color: _getTypeColor(notice.type))),
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
                Text(notice.description, style: TextStyle(color: AppTheme.textSecondary, height: 1.5)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 14, color: AppTheme.textHint),
                    const SizedBox(width: 4),
                    Text('${notice.eventDate.day}/${notice.eventDate.month}/${notice.eventDate.year}',
                        style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                    if (notice.eventTime != null) ...[
                      const SizedBox(width: 12),
                      Icon(Icons.access_time, size: 14, color: AppTheme.textHint),
                      const SizedBox(width: 4),
                      Text(notice.eventTime!, style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
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
      case NoticeType.webinar: return AppTheme.secondaryColor;
      case NoticeType.workshop: return AppTheme.successColor;
      case NoticeType.careerTalk: return const Color(0xFF7B1FA2);
      case NoticeType.announcement: return AppTheme.warningColor;
      case NoticeType.deadline: return AppTheme.errorColor;
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

/// Doubts Tab
class _DoubtsTab extends StatefulWidget {
  final StudentModel? student;
  const _DoubtsTab({required this.student});

  @override
  State<_DoubtsTab> createState() => _DoubtsTabState();
}

class _DoubtsTabState extends State<_DoubtsTab> {
  final _studentService = StudentService();
  final _questionController = TextEditingController();

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  Future<void> _askDoubt() async {
    if (_questionController.text.trim().isEmpty || widget.student == null) return;
    try {
      await _studentService.askDoubt(
        studentId: widget.student!.uid,
        studentName: widget.student!.name,
        studentGrade: widget.student!.grade,
        question: _questionController.text.trim(),
      );
      _questionController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('Doubt submitted!'), backgroundColor: AppTheme.successColor),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.errorColor));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Doubts'), automaticallyImplyLeading: false),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: AppTheme.surfaceColor,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _questionController,
                    decoration: const InputDecoration(hintText: 'Ask a doubt about careers...', isDense: true),
                    maxLines: 2,
                    minLines: 1,
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _askDoubt,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentColor,
                    padding: const EdgeInsets.all(14),
                    minimumSize: const Size(50, 50),
                  ),
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: widget.student == null
                ? const Center(child: Text('Please login'))
                : StreamBuilder<List<Doubt>>(
                    stream: _studentService.myDoubtsStream(widget.student!.uid),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final doubts = snapshot.data ?? [];
                      if (doubts.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.help_outline, size: 64, color: AppTheme.textHint),
                              const SizedBox(height: 16),
                              const Text('No doubts yet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                              Text('Ask your first question above!', style: TextStyle(color: AppTheme.textSecondary)),
                            ],
                          ),
                        );
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.all(24),
                        itemCount: doubts.length,
                        itemBuilder: (context, index) => _DoubtCard(doubt: doubts[index]),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _DoubtCard extends StatelessWidget {
  final Doubt doubt;
  const _DoubtCard({required this.doubt});

  @override
  Widget build(BuildContext context) {
    final statusColor = doubt.isResolved ? AppTheme.successColor : AppTheme.warningColor;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.05),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(doubt.isResolved ? Icons.check_circle : Icons.pending, size: 16, color: statusColor),
                    const SizedBox(width: 8),
                    Text(doubt.isResolved ? 'Answered' : 'Pending', style: TextStyle(fontWeight: FontWeight.w600, color: statusColor)),
                    const Spacer(),
                    Text(_formatDate(doubt.createdAt), style: TextStyle(fontSize: 11, color: AppTheme.textHint)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(doubt.question, style: const TextStyle(fontSize: 15)),
              ],
            ),
          ),
          if (doubt.isResolved && doubt.answer != null)
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.person, size: 14, color: AppTheme.secondaryColor),
                      const SizedBox(width: 6),
                      Text(doubt.answeredByName ?? 'Teacher',
                          style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.secondaryColor, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(doubt.answer!, style: const TextStyle(height: 1.5)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

/// Profile Tab - Fixed Logout Button
class _ProfileTab extends StatelessWidget {
  final StudentModel? student;
  final VoidCallback onLogout;
  const _ProfileTab({required this.student, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile'), automaticallyImplyLeading: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Avatar
            CircleAvatar(
              radius: 50,
              backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
              child: Text(
                student?.name.isNotEmpty == true ? student!.name[0].toUpperCase() : 'S',
                style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
              ),
            ),
            const SizedBox(height: 16),
            Text(student?.name ?? 'Student', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('Grade ${student?.grade ?? '-'}', style: TextStyle(fontSize: 14, color: AppTheme.primaryColor, fontWeight: FontWeight.w500)),
            ),
            const SizedBox(height: 32),

            // Profile Items
            _ProfileItem(icon: Icons.badge, label: 'Student ID', value: student?.studentId ?? '-'),
            _ProfileItem(icon: Icons.email, label: 'Email', value: student?.email ?? '-'),
            _ProfileItem(icon: Icons.school, label: 'Grade', value: '${student?.grade ?? '-'}'),
            const SizedBox(height: 40),

            // Logout Button - FIXED: Constrained width
            Center(
              child: SizedBox(
                width: 200,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: onLogout,
                  icon: const Icon(Icons.logout, size: 20),
                  label: const Text('Logout'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.errorColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

/// Profile Item Component
class _ProfileItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileItem({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppTheme.primaryColor, size: 22),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}
