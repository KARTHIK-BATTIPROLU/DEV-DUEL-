import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/teacher_models.dart';
import '../../../services/teacher_service.dart';
import '../../../services/hive_service.dart';
import '../../../models/user_model.dart';

/// Assessment Lab Tab - Quiz Builder and Management
class AssessmentLabTab extends StatefulWidget {
  const AssessmentLabTab({super.key});

  @override
  State<AssessmentLabTab> createState() => _AssessmentLabTabState();
}

class _AssessmentLabTabState extends State<AssessmentLabTab> {
  final _teacherService = TeacherService();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Use StreamBuilder for real-time quiz list
        StreamBuilder<List<Quiz>>(
          stream: _teacherService.quizzesStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final quizzes = snapshot.data ?? [];
            if (quizzes.isEmpty) {
              return _buildEmptyState();
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: quizzes.length,
              itemBuilder: (context, index) => _QuizCard(
                quiz: quizzes[index],
                onEdit: () => _showQuizBuilder(quizzes[index]),
                onViewResults: () => _showQuizResults(quizzes[index]),
                onDelete: () => _deleteQuiz(quizzes[index].id),
              ),
            );
          },
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton.extended(
            onPressed: () => _showQuizBuilder(null),
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
          Icon(Icons.quiz, size: 64, color: AppTheme.textHint),
          const SizedBox(height: 16),
          const Text('No quizzes yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Text('Create your first assessment', style: TextStyle(color: AppTheme.textSecondary)),
        ],
      ),
    );
  }

  void _showQuizBuilder(Quiz? existingQuiz) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => QuizBuilderScreen(existingQuiz: existingQuiz)),
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

  Future<void> _deleteQuiz(String quizId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Quiz'),
        content: const Text('Are you sure you want to delete this quiz?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await _teacherService.deleteQuiz(quizId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: const Text('Quiz deleted'), backgroundColor: AppTheme.successColor),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.errorColor),
          );
        }
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
      decoration: AppTheme.elevatedCardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.secondaryColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Icon(Icons.quiz, color: AppTheme.secondaryColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(quiz.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                      Text('${quiz.questions.length} questions • ${quiz.timeLimitMinutes} min',
                          style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
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
                    PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 18, color: AppTheme.errorColor), const SizedBox(width: 8), Text('Delete', style: TextStyle(color: AppTheme.errorColor))])),
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
                Text(quiz.description, style: TextStyle(color: AppTheme.textSecondary)),
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
      decoration: BoxDecoration(color: AppTheme.secondaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
      child: Text(label, style: TextStyle(fontSize: 12, color: AppTheme.secondaryColor)),
    );
  }
}


/// Quiz Builder Screen - FIXED: Stable TextEditingControllers
class QuizBuilderScreen extends StatefulWidget {
  final Quiz? existingQuiz;

  const QuizBuilderScreen({super.key, this.existingQuiz});

  @override
  State<QuizBuilderScreen> createState() => _QuizBuilderScreenState();
}

class _QuizBuilderScreenState extends State<QuizBuilderScreen> {
  final _teacherService = TeacherService();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final List<_QuestionData> _questions = [];
  final Set<int> _targetGrades = {};
  int _timeLimit = 15;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingQuiz != null) {
      _titleController.text = widget.existingQuiz!.title;
      _descController.text = widget.existingQuiz!.description;
      _targetGrades.addAll(widget.existingQuiz!.targetGrades);
      _timeLimit = widget.existingQuiz!.timeLimitMinutes;
      // Initialize questions with stable controllers
      for (final q in widget.existingQuiz!.questions) {
        _questions.add(_QuestionData.fromQuestion(q));
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    for (final q in _questions) {
      q.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingQuiz == null ? 'Create Quiz' : 'Edit Quiz'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveQuiz,
            child: _isSaving
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Quiz Title', hintText: 'e.g., Career Awareness Quiz'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descController,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Description', hintText: 'Brief description of the quiz'),
            ),
            const SizedBox(height: 20),
            const Text('Target Grades', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
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
                  selectedColor: AppTheme.secondaryColor.withOpacity(0.2),
                  checkmarkColor: AppTheme.secondaryColor,
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Time Limit: ', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(width: 8),
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
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._questions.asMap().entries.map((entry) => _QuestionEditorCard(
              key: ValueKey(entry.value.id),
              index: entry.key,
              data: entry.value,
              onDelete: () => _deleteQuestion(entry.key),
              onCorrectChanged: (index) {
                setState(() => entry.value.correctIndex = index);
              },
            )),
            if (_questions.isEmpty)
              Container(
                padding: const EdgeInsets.all(40),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Icon(Icons.quiz_outlined, size: 48, color: AppTheme.textHint),
                    const SizedBox(height: 12),
                    Text('No questions added yet', style: TextStyle(color: AppTheme.textSecondary)),
                  ],
                ),
              ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  void _addQuestion() {
    setState(() {
      _questions.add(_QuestionData());
    });
  }

  void _deleteQuestion(int index) {
    setState(() {
      _questions[index].dispose();
      _questions.removeAt(index);
    });
  }

  Future<void> _saveQuiz() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Please enter a title'), backgroundColor: AppTheme.errorColor),
      );
      return;
    }
    if (_questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Please add at least one question'), backgroundColor: AppTheme.errorColor),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final teacher = HiveService.getTeacher();
      final questions = _questions.map((q) => QuizQuestion(
        question: q.questionController.text,
        options: q.optionControllers.map((c) => c.text).toList(),
        correctIndex: q.correctIndex,
      )).toList();

      final quiz = Quiz(
        id: widget.existingQuiz?.id ?? '',
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        targetGrades: _targetGrades.toList(),
        questions: questions,
        timeLimitMinutes: _timeLimit,
        isActive: true,
        createdAt: widget.existingQuiz?.createdAt ?? DateTime.now(),
        createdBy: teacher?.uid ?? '',
      );

      if (widget.existingQuiz != null) {
        await _teacherService.updateQuiz(quiz);
      } else {
        await _teacherService.createQuiz(quiz);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('Quiz saved successfully!'), backgroundColor: AppTheme.successColor),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.errorColor),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}


/// Question Data - Holds stable controllers for each question
class _QuestionData {
  final String id;
  final TextEditingController questionController;
  final List<TextEditingController> optionControllers;
  int correctIndex;

  _QuestionData()
      : id = DateTime.now().microsecondsSinceEpoch.toString(),
        questionController = TextEditingController(),
        optionControllers = List.generate(4, (_) => TextEditingController()),
        correctIndex = 0;

  factory _QuestionData.fromQuestion(QuizQuestion q) {
    final data = _QuestionData();
    data.questionController.text = q.question;
    for (int i = 0; i < q.options.length && i < 4; i++) {
      data.optionControllers[i].text = q.options[i];
    }
    data.correctIndex = q.correctIndex;
    return data;
  }

  void dispose() {
    questionController.dispose();
    for (final c in optionControllers) {
      c.dispose();
    }
  }
}

/// Question Editor Card - Uses stable controllers (NO reverse typing)
class _QuestionEditorCard extends StatelessWidget {
  final int index;
  final _QuestionData data;
  final VoidCallback onDelete;
  final Function(int) onCorrectChanged;

  const _QuestionEditorCard({
    super.key,
    required this.index,
    required this.data,
    required this.onDelete,
    required this.onCorrectChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.outlineColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: AppTheme.secondaryColor,
                child: Text('${index + 1}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 8),
              const Text('Question', style: TextStyle(fontWeight: FontWeight.w600)),
              const Spacer(),
              IconButton(
                icon: Icon(Icons.delete, color: AppTheme.errorColor, size: 20),
                onPressed: onDelete,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: data.questionController,
            decoration: const InputDecoration(hintText: 'Enter your question here...', isDense: true),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          const Text('Options (select correct answer)', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
          const SizedBox(height: 8),
          ...List.generate(4, (i) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Radio<int>(
                  value: i,
                  groupValue: data.correctIndex,
                  onChanged: (v) => onCorrectChanged(v!),
                  activeColor: AppTheme.successColor,
                ),
                Expanded(
                  child: TextField(
                    controller: data.optionControllers[i],
                    decoration: InputDecoration(
                      hintText: 'Option ${i + 1}',
                      isDense: true,
                      fillColor: data.correctIndex == i ? AppTheme.successColor.withOpacity(0.1) : null,
                      filled: data.correctIndex == i,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: data.correctIndex == i ? AppTheme.successColor : AppTheme.outlineColor,
                        ),
                      ),
                    ),
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
    final teacherService = TeacherService();

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
                color: AppTheme.secondaryColor.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  Container(width: 40, height: 4, decoration: BoxDecoration(color: AppTheme.outlineColor, borderRadius: BorderRadius.circular(2))),
                  const SizedBox(height: 16),
                  Text(quiz.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<List<QuizAttempt>>(
                stream: teacherService.quizAttemptsStream(quiz.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final attempts = snapshot.data ?? [];
                  if (attempts.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.analytics_outlined, size: 48, color: AppTheme.textHint),
                          const SizedBox(height: 12),
                          Text('No attempts yet', style: TextStyle(color: AppTheme.textSecondary)),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: attempts.length,
                    itemBuilder: (context, index) {
                      final attempt = attempts[index];
                      final percentage = attempt.percentage.round();
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: AppTheme.cardDecoration,
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: _getScoreColor(percentage).withOpacity(0.1),
                              child: Text('${attempt.score}', style: TextStyle(color: _getScoreColor(percentage), fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Student ID: ${attempt.studentId.substring(0, 8)}...', style: const TextStyle(fontWeight: FontWeight.w600)),
                                  Text('${attempt.score}/${attempt.totalQuestions} correct', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('$percentage%', style: TextStyle(fontWeight: FontWeight.bold, color: _getScoreColor(percentage))),
                                Text('${(attempt.timeTakenSeconds / 60).toStringAsFixed(1)} min', style: TextStyle(fontSize: 11, color: AppTheme.textHint)),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
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
    if (percentage >= 80) return AppTheme.successColor;
    if (percentage >= 60) return AppTheme.warningColor;
    return AppTheme.errorColor;
  }
}
