import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/career_model.dart';
import '../../models/note_model.dart';
import '../../providers/career_provider.dart';
import '../../services/note_service.dart';
import 'simulation_screen.dart';

/// Career Detail Screen - 5-Tab Deep Clarity View with Notes
class CareerDetailScreen extends StatelessWidget {
  final CareerModel career;
  const CareerDetailScreen({super.key, required this.career});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: Text(career.title),
          backgroundColor: _getStreamColor(career.streamTag),
          foregroundColor: Colors.white,
          bottom: const TabBar(
            isScrollable: true,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(icon: Icon(Icons.explore), text: 'Discovery'),
              Tab(icon: Icon(Icons.timeline), text: 'Roadmap'),
              Tab(icon: Icon(Icons.analytics), text: 'Reality'),
              Tab(icon: Icon(Icons.library_books), text: 'Resources'),
              Tab(icon: Icon(Icons.note_add), text: 'My Notes'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _DiscoveryTab(career: career),
            _RoadmapTab(career: career),
            _RealityTab(career: career),
            _ResourcesTab(career: career),
            _NotesTab(career: career),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => Navigator.push(context, MaterialPageRoute(
            builder: (_) => SimulationScreen(career: career),
          )),
          backgroundColor: _getStreamColor(career.streamTag),
          icon: const Icon(Icons.play_arrow),
          label: const Text('Try Reality Task'),
        ),
      ),
    );
  }
}


// ============================================================
// TAB 5: MY NOTES - Save Career Insights
// ============================================================
class _NotesTab extends StatefulWidget {
  final CareerModel career;
  const _NotesTab({required this.career});

  @override
  State<_NotesTab> createState() => _NotesTabState();
}

class _NotesTabState extends State<_NotesTab> {
  final _noteService = NoteService();
  final _noteController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    final content = _noteController.text.trim();
    if (content.isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to save notes'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final note = NoteModel(
        id: '',
        oderId: user.uid,
        careerId: widget.career.id,
        careerTitle: widget.career.title,
        noteContent: content,
      );

      await _noteService.saveNote(note);
      _noteController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.cloud_done, color: Colors.white),
                SizedBox(width: 12),
                Text('Note saved & synced for offline use'),
              ],
            ),
            backgroundColor: const Color(0xFF003F75),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showAddNoteSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20, right: 20, top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.note_add, color: _getStreamColor(widget.career.streamTag)),
                const SizedBox(width: 12),
                Text('Add Note for ${widget.career.title}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _noteController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Write your career insight...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : () {
                  _saveNote();
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF003F75),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSaving
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Save Note'),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Please login to save notes'),
          ],
        ),
      );
    }

    return Scaffold(
      body: StreamBuilder<List<NoteModel>>(
        stream: _noteService.notesForCareerStream(user.uid, widget.career.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final notes = snapshot.data ?? [];

          if (notes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: _getStreamColor(widget.career.streamTag).withAlpha(25),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.note_alt_outlined, size: 48,
                        color: _getStreamColor(widget.career.streamTag)),
                  ),
                  const SizedBox(height: 16),
                  const Text('No notes yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text('Save your insights about ${widget.career.title}',
                      style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: notes.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) => _NoteCard(
              note: notes[index],
              onDelete: () => _noteService.deleteNote(user.uid, notes[index].id),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddNoteSheet,
        backgroundColor: _getStreamColor(widget.career.streamTag),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  final NoteModel note;
  final VoidCallback onDelete;
  const _NoteCard({required this.note, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
              const SizedBox(width: 4),
              Text(_formatDate(note.timestamp), style: TextStyle(fontSize: 12, color: Colors.grey[500])),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                onPressed: () => _confirmDelete(context),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(note.noteContent, style: const TextStyle(fontSize: 14, height: 1.5)),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () { Navigator.pop(ctx); onDelete(); },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Just now';
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}


// ============================================================
// TAB 1: DISCOVERY - Day in Life & Fun Facts
// ============================================================
class _DiscoveryTab extends StatelessWidget {
  final CareerModel career;
  const _DiscoveryTab({required this.career});

  @override
  Widget build(BuildContext context) {
    final discovery = career.discoveryContent;
    final grade = context.watch<CareerProvider>().userGrade;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_getStreamColor(career.streamTag), _getStreamColor(career.streamTag).withAlpha(180)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(_getCareerIcon(career.iconName), size: 40, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(career.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                          Text(career.streamTag.displayName, style: TextStyle(fontSize: 12, color: Colors.white.withAlpha(230))),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(career.shortDescription, style: TextStyle(fontSize: 14, color: Colors.white.withAlpha(240))),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Fun Fact
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.withAlpha(75)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('💡', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Fun Fact', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber)),
                      const SizedBox(height: 4),
                      Text(discovery.funFact, style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Day in Life
          const Text('📖 A Day in the Life', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12)),
            child: Text(discovery.dayInLife, style: const TextStyle(fontSize: 14, height: 1.6)),
          ),
          const SizedBox(height: 24),

          // Grade-specific content
          if (grade <= 8) _buildDiscoveryGradeContent(),
          if (grade >= 9 && grade <= 10) _buildBridgeGradeContent(),
          if (grade >= 11) _buildExecutionGradeContent(),
        ],
      ),
    );
  }

  Widget _buildDiscoveryGradeContent() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.green.withAlpha(25), borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(children: [
            Icon(Icons.lightbulb, color: Colors.green),
            SizedBox(width: 8),
            Text('For You (Grade 7-8)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
          ]),
          const SizedBox(height: 12),
          const Text('This is your exploration phase! Focus on:', style: TextStyle(fontSize: 14)),
          const SizedBox(height: 8),
          ...career.bridgeContent.keySkillsToStart.map((skill) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(children: [
              const Icon(Icons.check_circle, size: 16, color: Colors.green),
              const SizedBox(width: 8),
              Expanded(child: Text(skill, style: const TextStyle(fontSize: 13))),
            ]),
          )),
        ],
      ),
    );
  }

  Widget _buildBridgeGradeContent() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.blue.withAlpha(25), borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(children: [
            Icon(Icons.school, color: Colors.blue),
            SizedBox(width: 8),
            Text('For You (Grade 9-10)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
          ]),
          const SizedBox(height: 12),
          Text('Required Stream: ${career.bridgeContent.required11thStream}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          const Text('Foundation Topics to Master:', style: TextStyle(fontSize: 14)),
          const SizedBox(height: 8),
          ...career.bridgeContent.foundationTopics.map((topic) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Icons.book, size: 16, color: Colors.blue),
              const SizedBox(width: 8),
              Expanded(child: Text(topic, style: const TextStyle(fontSize: 13))),
            ]),
          )),
        ],
      ),
    );
  }

  Widget _buildExecutionGradeContent() {
    final exams = career.executionContent.entranceExams;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.purple.withAlpha(25), borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(children: [
            Icon(Icons.rocket_launch, color: Colors.purple),
            SizedBox(width: 8),
            Text('For You (Grade 11-12)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purple)),
          ]),
          const SizedBox(height: 12),
          const Text('Key Entrance Exams:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          ...exams.take(3).map((exam) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.purple.withAlpha(25), borderRadius: BorderRadius.circular(8)),
                child: Text('${exam.difficultyIndex}/10', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.purple)),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(exam.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text('${exam.month} | ${exam.eligibility}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ])),
            ]),
          )),
        ],
      ),
    );
  }
}


// ============================================================
// TAB 2: ROADMAP - Timeline View
// ============================================================
class _RoadmapTab extends StatelessWidget {
  final CareerModel career;
  const _RoadmapTab({required this.career});

  @override
  Widget build(BuildContext context) {
    final nodes = career.roadmap.nodes;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Your Journey to Becoming a', style: TextStyle(fontSize: 14, color: Colors.grey)),
          Text(career.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),

          // Timeline
          ...nodes.asMap().entries.map((entry) {
            final index = entry.key;
            final node = entry.value;
            return _TimelineNode(node: node, isFirst: index == 0, isLast: index == nodes.length - 1, color: _getStreamColor(career.streamTag));
          }),

          const SizedBox(height: 24),

          // Plan B Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.withAlpha(75)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(children: [
                  Icon(Icons.alt_route, color: Colors.orange),
                  SizedBox(width: 8),
                  Text('Plan B: Alternative Paths', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                ]),
                const SizedBox(height: 8),
                Text(career.executionContent.planB.description, style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 12),
                ...career.executionContent.planB.alternativePaths.map((path) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Icon(Icons.arrow_right, size: 20, color: Colors.orange),
                    Expanded(child: Text(path, style: const TextStyle(fontSize: 13))),
                  ]),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineNode extends StatelessWidget {
  final RoadmapNode node;
  final bool isFirst;
  final bool isLast;
  final Color color;

  const _TimelineNode({required this.node, required this.isFirst, required this.isLast, required this.color});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 40,
            child: Column(children: [
              Container(
                width: 20, height: 20,
                decoration: BoxDecoration(
                  color: isFirst ? color : color.withAlpha(75),
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 2),
                ),
                child: isFirst ? const Icon(Icons.star, size: 12, color: Colors.white) : null,
              ),
              if (!isLast) Expanded(child: Container(width: 2, color: color.withAlpha(75))),
            ]),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isFirst ? color.withAlpha(25) : Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: isFirst ? Border.all(color: color.withAlpha(75)) : null,
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(node.title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isFirst ? color : null)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: color.withAlpha(25), borderRadius: BorderRadius.circular(8)),
                    child: Text(node.duration, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500)),
                  ),
                ]),
                const SizedBox(height: 8),
                Text(node.description, style: TextStyle(fontSize: 13, color: Colors.grey[700])),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}


// ============================================================
// TAB 3: REALITY CHECK - Hard Data
// ============================================================
class _RealityTab extends StatelessWidget {
  final CareerModel career;
  const _RealityTab({required this.career});

  @override
  Widget build(BuildContext context) {
    final reality = career.realityCheck;
    final financial = career.executionContent.financialReality;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Reality Check', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const Text('The honest truth about this career', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),

          // Key Metrics
          Row(children: [
            Expanded(child: _buildMetricCard('Avg Salary', reality.avgSalary, Icons.currency_rupee, Colors.green)),
            const SizedBox(width: 12),
            Expanded(child: _buildMetricCard('Job Stress', '${reality.jobStressIndex}/10', Icons.psychology, _getStressColor(reality.jobStressIndex))),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _buildMetricCard('Study Hours', '${reality.studyHoursDaily}h/day', Icons.schedule, Colors.blue)),
            const SizedBox(width: 12),
            Expanded(child: _buildMetricCard('Years to Master', '${reality.yearsToMaster} years', Icons.trending_up, Colors.purple)),
          ]),
          const SizedBox(height: 24),

          // Salary Growth
          const Text('💰 Salary Growth', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12)),
            child: Column(children: [
              _buildSalaryRow('Entry Level', financial.entrySalary, 0.3),
              const SizedBox(height: 12),
              _buildSalaryRow('5 Years', financial.fiveYearSalary, 0.6),
              const SizedBox(height: 12),
              _buildSalaryRow('10 Years', financial.tenYearSalary, 1.0),
            ]),
          ),
          const SizedBox(height: 24),

          // Work-Life Balance
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.blue.withAlpha(25), borderRadius: BorderRadius.circular(12)),
            child: Row(children: [
              const Icon(Icons.balance, color: Colors.blue, size: 32),
              const SizedBox(width: 16),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Work-Life Balance', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(reality.workLifeBalance, style: const TextStyle(fontSize: 16)),
              ])),
            ]),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.green.withAlpha(25), borderRadius: BorderRadius.circular(12)),
            child: Row(children: [
              const Icon(Icons.work, color: Colors.green, size: 32),
              const SizedBox(width: 16),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Job Availability', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(reality.jobAvailability, style: const TextStyle(fontSize: 16)),
              ])),
            ]),
          ),
          const SizedBox(height: 24),

          // Top Colleges
          const Text('🏫 Top Colleges', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...career.executionContent.topColleges.take(5).map((college) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.withAlpha(50)),
            ),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.amber.withAlpha(25), borderRadius: BorderRadius.circular(8)),
                child: Text('${college.rating}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber)),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(college.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text('${college.location} | ${college.avgFees}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ])),
            ]),
          )),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: color.withAlpha(25), borderRadius: BorderRadius.circular(12)),
      child: Column(children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ]),
    );
  }

  Widget _buildSalaryRow(String label, String value, double progress) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
      ]),
      const SizedBox(height: 4),
      LinearProgressIndicator(value: progress, backgroundColor: Colors.grey[200], valueColor: const AlwaysStoppedAnimation(Colors.green)),
    ]);
  }

  Color _getStressColor(int stress) {
    if (stress <= 4) return Colors.green;
    if (stress <= 6) return Colors.orange;
    return Colors.red;
  }
}


// ============================================================
// TAB 4: RESOURCES - Learning Materials
// ============================================================
class _ResourcesTab extends StatelessWidget {
  final CareerModel career;
  const _ResourcesTab({required this.career});

  @override
  Widget build(BuildContext context) {
    final resources = career.resourceLibrary;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Resource Library', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const Text('Curated learning materials', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),

          if (resources.courses.isNotEmpty) ...[
            _buildResourceSection('📚 Courses', resources.courses, Colors.blue),
            const SizedBox(height: 20),
          ],
          if (resources.videos.isNotEmpty) ...[
            _buildResourceSection('🎬 Videos', resources.videos, Colors.red),
            const SizedBox(height: 20),
          ],
          if (resources.articles.isNotEmpty) ...[
            _buildResourceSection('📰 Articles', resources.articles, Colors.green),
            const SizedBox(height: 20),
          ],
          if (resources.ncertChapters.isNotEmpty) ...[
            _buildResourceSection('📖 NCERT Chapters', resources.ncertChapters, Colors.orange),
            const SizedBox(height: 20),
          ],

          const Text('🔗 Quick Links', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: [
            _buildQuickLink('IBM SkillsBuild', 'https://skillsbuild.org/', Colors.blue),
            _buildQuickLink('Skill India', 'https://skillindia.gov.in/', Colors.green),
            _buildQuickLink('Khan Academy', 'https://khanacademy.org/', Colors.teal),
            _buildQuickLink('NCERT', 'https://ncert.nic.in/', Colors.orange),
            _buildQuickLink('SWAYAM', 'https://swayam.gov.in/', Colors.purple),
          ]),
        ],
      ),
    );
  }

  Widget _buildResourceSection(String title, List<ResourceLink> resources, Color color) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 12),
      ...resources.map((resource) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withAlpha(50)),
        ),
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withAlpha(25), borderRadius: BorderRadius.circular(8)),
            child: Icon(_getResourceIcon(resource.type), color: color, size: 20),
          ),
          title: Text(resource.title, style: const TextStyle(fontWeight: FontWeight.w500)),
          subtitle: Text(resource.source, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          trailing: const Icon(Icons.open_in_new, size: 18),
          onTap: () => _launchUrl(resource.url),
        ),
      )),
    ]);
  }

  Widget _buildQuickLink(String title, String url, Color color) {
    return ActionChip(
      avatar: Icon(Icons.link, size: 16, color: color),
      label: Text(title),
      backgroundColor: color.withAlpha(25),
      onPressed: () => _launchUrl(url),
    );
  }

  IconData _getResourceIcon(String type) {
    switch (type.toLowerCase()) {
      case 'course': return Icons.school;
      case 'video': return Icons.play_circle;
      case 'article': return Icons.article;
      case 'chapter': return Icons.menu_book;
      default: return Icons.link;
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

// ============================================================
// HELPER FUNCTIONS
// ============================================================
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
