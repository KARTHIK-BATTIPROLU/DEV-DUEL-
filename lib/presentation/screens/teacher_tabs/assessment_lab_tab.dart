import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/teacher_models.dart';
import '../../../services/teacher_service.dart';

/// Assessment Lab Tab - Quiz Builder and Management
class AssessmentLabTab extends StatefulWidget {
  const AssessmentLabTab({super.key});

  @override
  State<AssessmentLabTab> createState() => _AssessmentLabTabState();
}

class _AssessmentLabTabState extends State<AssessmentLabTab> {
  final _teacherService = TeacherService();
  List<Quiz> _quizzes = [];
  bool _isLoading = true;

  // Sample quizzes for demonstration
  final List<Quiz> _sampleQuizzes = [
    Quiz(
      id: 'quiz1',
      title: 'Career Awareness Quiz',
      description: 'Test your knowledge about different career paths',
      targetGrades: [7, 8],
      questions: [
        QuizQuestion(question: 'What does a Software Engineer do?', options: ['Builds software', 'Treats patients', 'Teaches students', 'Designs buildings'], correctIndex: 0),
        QuizQuestion(question: 'Which stream is required for Medicine?', options: ['MPC', 'BiPC', 'Commerce', 'Arts'], correctIndex: 1),
      ],
      timeLimitMinutes: 10,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      createdBy: 'teacher1',
    ),
    Quiz(
      id: 'quiz2',
      title: 'Stream Selection Assessment',
      description: 'Evaluate your understanding of different academic streams',
      targetGrades: [9, 10],
      questions: [
        QuizQuestion(question: 'MPC stands for?', options: ['Maths Physics Chemistry', 'Medical Practice Course', 'Management Program Certificate', 'None'], correctIndex: 0),
        QuizQuestion(question: 'Which exam is for Engineering?', options: ['NEET', 'JEE', 'CLAT', 'CAT'], correctIndex: 1),
        QuizQuestion(question: 'BiPC is required for?', options: ['Engineering', 'Medicine', 'Law', 'Business'], correctIndex: 1),
      ],
      timeLimitMinutes: 15,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      createdBy: 'teacher1',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadQuizzes();
  }

  Future<void> _loadQuizzes() async {
    setState(() => _isLoading = true);
    // In production, fetch from Firestore
    _quizzes = _sampleQuizzes;
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _quizzes.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _quizzes.length,
                    itemBuilder: (context, index) => _QuizCard(
                      quiz: _quizzes[index],
                      onEdit: () => _showQuizBuilder(_quizzes[index]),
                      onViewResults: () => _showQuizResults(_quizzes[index]),
                      onDelete: () => _deleteQuiz(_quizzes[index].id),
                    ),
                  ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton.extended(
            onPressed: () => _showQuizBuilder(null),
            backgroundColor: AppTheme.teacherColor,
            icon: const Icon(Icons.add),
            label: const Text('Create Quiz'),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.quiz, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text('No quizzes yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Text('Create your first assessment', style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }

  void _showQuizBuilder(Quiz? existingQuiz) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _QuizBuilderScreen(
          existingQuiz: existingQuiz,
          onSave: (quiz) {
            setState(() {
              if (existingQuiz != null) {
                final index = _quizzes.indexWhere((q) => q.id == existingQuiz.id);
                if (index != -1) _quizzes[index] = quiz;
              } else {
                _quizzes.add(quiz);
              }
            });
          },
        ),
      ),
    );
  }

  void _showQuizResults(Quiz quiz) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => _QuizResultsSheet(quiz: quiz),
    );
  }

  void _deleteQuiz(String quizId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Quiz'),
        content: const Text('Are you sure you want to delete this quiz?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      setState(() => _quizzes.removeWhere((q) => q.id == quizId));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Quiz deleted')));
      }
    }
  }
}

/// Quiz Card Widget
class _QuizCard extends StatelessWidget {
  final Quiz quiz;
  final VoidCallback onEdit;
  final VoidCallback onViewResults;
  final VoidCallback onDelete;

  const _QuizCard({required this.quiz, required this.onEdit, required this.onViewResults, required this.onDelete});

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
              color: AppTheme.teacherColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
            ),
            child: Row(
              children: [
                const Icon(Icons.quiz, color: AppTheme.teacherColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(quiz.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                      Text('${quiz.questions.length} questions • ${quiz.timeLimitMinutes} min',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit': onEdit(); break;
                      case 'results': onViewResults(); break;
                      case 'delete': onDelete(); break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text('Edit')])),
                    const PopupMenuItem(value: 'results', child: Row(children: [Icon(Icons.analytics, size: 18), SizedBox(width: 8), Text('Results')])),
                    const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 18, color: Colors.red), SizedBox(width: 8), Text('Delete', style: TextStyle(color: Colors.red))])),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(quiz.description, style: TextStyle(color: Colors.grey[700])),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: quiz.targetGrades.isEmpty
                      ? [_buildGradeChip('All Grades')]
                      : quiz.targetGrades.map((g) => _buildGradeChip('Grade $g')).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradeChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
      child: Text(label, style: const TextStyle(fontSize: 12, color: Colors.blue)),
    );
  }
}

/// Quiz Builder Screen
class _QuizBuilderScreen extends StatefulWidget {
  final Quiz? existingQuiz;
  final Function(Quiz) onSave;

  const _QuizBuilderScreen({this.existingQuiz, required this.onSave});

  @override
  State<_QuizBuilderScreen> createState() => _QuizBuilderScreenState();
}

class _QuizBuilderScreenState extends State<_QuizBuilderScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final List<QuizQuestion> _questions = [];
  final Set<int> _targetGrades = {};
  int _timeLimit = 15;

  @override
  void initState() {
    super.initState();
    if (widget.existingQuiz != null) {
      _titleController.text = widget.existingQuiz!.title;
      _descController.text = widget.existingQuiz!.description;
      _questions.addAll(widget.existingQuiz!.questions);
      _targetGrades.addAll(widget.existingQuiz!.targetGrades);
      _timeLimit = widget.existingQuiz!.timeLimitMinutes;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingQuiz == null ? 'Create Quiz' : 'Edit Quiz'),
        backgroundColor: AppTheme.teacherColor,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _saveQuiz,
            child: const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Quiz Title', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descController,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            const Text('Target Grades', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [7, 8, 9, 10, 11, 12].map((grade) {
                final isSelected = _targetGrades.contains(grade);
                return FilterChip(
                  label: Text('Grade $grade'),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) _targetGrades.add(grade);
                      else _targetGrades.remove(grade);
                    });
                  },
                  selectedColor: AppTheme.teacherColor.withOpacity(0.2),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Time Limit: ', style: TextStyle(fontWeight: FontWeight.w600)),
                DropdownButton<int>(
                  value: _timeLimit,
                  items: [5, 10, 15, 20, 30, 45, 60].map((m) => DropdownMenuItem(value: m, child: Text('$m min'))).toList(),
                  onChanged: (v) => setState(() => _timeLimit = v!),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Questions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ElevatedButton.icon(
                  onPressed: _addQuestion,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Question'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.teacherColor),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._questions.asMap().entries.map((entry) => _QuestionEditor(
              index: entry.key,
              question: entry.value,
              onUpdate: (q) => setState(() => _questions[entry.key] = q),
              onDelete: () => setState(() => _questions.removeAt(entry.key)),
            )),
            if (_questions.isEmpty)
              Container(
                padding: const EdgeInsets.all(32),
                alignment: Alignment.center,
                child: Text('No questions added yet', style: TextStyle(color: Colors.grey[500])),
              ),
          ],
        ),
      ),
    );
  }

  void _addQuestion() {
    setState(() {
      _questions.add(QuizQuestion(question: '', options: ['', '', '', ''], correctIndex: 0));
    });
  }

  void _saveQuiz() {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a title')));
      return;
    }
    if (_questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please add at least one question')));
      return;
    }

    final quiz = Quiz(
      id: widget.existingQuiz?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text,
      description: _descController.text,
      targetGrades: _targetGrades.toList(),
      questions: _questions,
      timeLimitMinutes: _timeLimit,
      createdAt: widget.existingQuiz?.createdAt ?? DateTime.now(),
      createdBy: 'teacher1',
    );

    widget.onSave(quiz);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Quiz saved successfully!')));
  }
}

/// Question Editor Widget
class _QuestionEditor extends StatelessWidget {
  final int index;
  final QuizQuestion question;
  final Function(QuizQuestion) onUpdate;
  final VoidCallback onDelete;

  const _QuestionEditor({required this.index, required this.question, required this.onUpdate, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(radius: 14, backgroundColor: AppTheme.teacherColor, child: Text('${index + 1}', style: const TextStyle(color: Colors.white, fontSize: 12))),
              const SizedBox(width: 8),
              const Text('Question', style: TextStyle(fontWeight: FontWeight.w600)),
              const Spacer(),
              IconButton(icon: const Icon(Icons.delete, color: Colors.red, size: 20), onPressed: onDelete),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: TextEditingController(text: question.question),
            decoration: const InputDecoration(hintText: 'Enter question', border: OutlineInputBorder(), isDense: true),
            onChanged: (v) => onUpdate(QuizQuestion(question: v, options: question.options, correctIndex: question.correctIndex)),
          ),
          const SizedBox(height: 12),
          ...List.generate(4, (i) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Radio<int>(
                  value: i,
                  groupValue: question.correctIndex,
                  onChanged: (v) => onUpdate(QuizQuestion(question: question.question, options: question.options, correctIndex: v!)),
                  activeColor: Colors.green,
                ),
                Expanded(
                  child: TextField(
                    controller: TextEditingController(text: question.options[i]),
                    decoration: InputDecoration(
                      hintText: 'Option ${i + 1}',
                      border: const OutlineInputBorder(),
                      isDense: true,
                      fillColor: question.correctIndex == i ? Colors.green.withOpacity(0.1) : null,
                      filled: question.correctIndex == i,
                    ),
                    onChanged: (v) {
                      final newOptions = List<String>.from(question.options);
                      newOptions[i] = v;
                      onUpdate(QuizQuestion(question: question.question, options: newOptions, correctIndex: question.correctIndex));
                    },
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

/// Quiz Results Sheet
class _QuizResultsSheet extends StatelessWidget {
  final Quiz quiz;

  const _QuizResultsSheet({required this.quiz});

  @override
  Widget build(BuildContext context) {
    // Sample results for demonstration
    final sampleResults = [
      {'name': 'Rahul Sharma', 'grade': 10, 'score': 3, 'total': quiz.questions.length},
      {'name': 'Priya Patel', 'grade': 9, 'score': 2, 'total': quiz.questions.length},
      {'name': 'Amit Kumar', 'grade': 10, 'score': 3, 'total': quiz.questions.length},
    ];

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.teacherColor.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
                  const SizedBox(height: 16),
                  Text(quiz.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('${sampleResults.length} attempts', style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: sampleResults.length,
                itemBuilder: (context, index) {
                  final result = sampleResults[index];
                  final percentage = ((result['score'] as int) / (result['total'] as int) * 100).round();
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: _getScoreColor(percentage).withOpacity(0.1),
                          child: Text((result['name'] as String)[0], style: TextStyle(color: _getScoreColor(percentage))),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(result['name'] as String, style: const TextStyle(fontWeight: FontWeight.w600)),
                              Text('Grade ${result['grade']}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('${result['score']}/${result['total']}', style: TextStyle(fontWeight: FontWeight.bold, color: _getScoreColor(percentage))),
                            Text('$percentage%', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getScoreColor(int percentage) {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 60) return Colors.orange;
    return Colors.red;
  }
}
