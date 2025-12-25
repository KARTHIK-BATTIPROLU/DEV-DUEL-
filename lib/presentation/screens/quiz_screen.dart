import 'package:flutter/material.dart';
import 'dart:async';
import '../../core/theme/app_theme.dart';
import '../../models/teacher_models.dart';
import '../../models/user_model.dart';
import '../../services/student_service.dart';
import '../../services/hive_service.dart';

/// Quiz List Screen - Shows available quizzes for student's grade
class QuizListScreen extends StatelessWidget {
  const QuizListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final student = HiveService.getStudent();
    final studentService = StudentService();
    final grade = student?.grade ?? 10;

    return Scaffold(
      appBar: AppBar(title: const Text('Quizzes'), automaticallyImplyLeading: false),
      body: StreamBuilder<List<Quiz>>(
        stream: studentService.quizzesForGradeStream(grade),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final quizzes = snapshot.data ?? [];
          if (quizzes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.quiz_outlined, size: 64, color: AppTheme.textHint),
                  const SizedBox(height: 16),
                  const Text('No quizzes available', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  Text('Check back later for new assessments', style: TextStyle(color: AppTheme.textSecondary)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: quizzes.length,
            itemBuilder: (context, index) => _QuizListCard(quiz: quizzes[index], student: student),
          );
        },
      ),
    );
  }
}

class _QuizListCard extends StatelessWidget {
  final Quiz quiz;
  final StudentModel? student;

  const _QuizListCard({required this.quiz, required this.student});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: AppTheme.elevatedCardDecoration,
      child: InkWell(
        onTap: () => _startQuiz(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.quiz, color: AppTheme.accentColor, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(quiz.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text('${quiz.questions.length} questions • ${quiz.timeLimitMinutes} min',
                            style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
              if (quiz.description.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(quiz.description, style: TextStyle(color: AppTheme.textSecondary, height: 1.4)),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _startQuiz(context),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start Quiz'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startQuiz(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => QuizTakingScreen(quiz: quiz, student: student)),
    );
  }
}


/// Quiz Taking Screen - Interactive quiz experience
class QuizTakingScreen extends StatefulWidget {
  final Quiz quiz;
  final StudentModel? student;

  const QuizTakingScreen({super.key, required this.quiz, required this.student});

  @override
  State<QuizTakingScreen> createState() => _QuizTakingScreenState();
}

class _QuizTakingScreenState extends State<QuizTakingScreen> {
  final _studentService = StudentService();
  int _currentQuestion = 0;
  final List<int> _answers = [];
  late Timer _timer;
  int _remainingSeconds = 0;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.quiz.timeLimitMinutes * 60;
    _answers.addAll(List.filled(widget.quiz.questions.length, -1));
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        _timer.cancel();
        _submitQuiz();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String get _formattedTime {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.quiz.questions[_currentQuestion];
    final progress = (_currentQuestion + 1) / widget.quiz.questions.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.quiz.title),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _showExitConfirmation(context),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _remainingSeconds < 60 ? AppTheme.errorColor : AppTheme.accentColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.timer, size: 16, color: Colors.white),
                const SizedBox(width: 4),
                Text(_formattedTime, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress Bar
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppTheme.outlineColor,
            valueColor: AlwaysStoppedAnimation(AppTheme.accentColor),
            minHeight: 4,
          ),

          // Question Counter
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Question ${_currentQuestion + 1} of ${widget.quiz.questions.length}',
                    style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
                Text('${(_answers.where((a) => a != -1).length)} answered',
                    style: TextStyle(color: AppTheme.accentColor, fontWeight: FontWeight.w500)),
              ],
            ),
          ),

          // Question Card
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
                    ),
                    child: Text(
                      question.question,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, height: 1.5),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Options
                  ...List.generate(question.options.length, (index) {
                    final isSelected = _answers[_currentQuestion] == index;
                    return GestureDetector(
                      onTap: () => setState(() => _answers[_currentQuestion] = index),
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.accentColor.withOpacity(0.1) : AppTheme.surfaceColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? AppTheme.accentColor : AppTheme.outlineColor,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: isSelected ? AppTheme.accentColor : Colors.transparent,
                                shape: BoxShape.circle,
                                border: Border.all(color: isSelected ? AppTheme.accentColor : AppTheme.outlineColor, width: 2),
                              ),
                              child: isSelected
                                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                                  : Center(child: Text(String.fromCharCode(65 + index), style: TextStyle(color: AppTheme.textSecondary))),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(question.options[index], style: TextStyle(fontSize: 15, color: isSelected ? AppTheme.accentColor : AppTheme.textPrimary)),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          // Navigation Buttons
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2))],
            ),
            child: Row(
              children: [
                if (_currentQuestion > 0)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => setState(() => _currentQuestion--),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Previous'),
                    ),
                  ),
                if (_currentQuestion > 0) const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _currentQuestion < widget.quiz.questions.length - 1
                        ? () => setState(() => _currentQuestion++)
                        : _submitQuiz,
                    icon: Icon(_currentQuestion < widget.quiz.questions.length - 1 ? Icons.arrow_forward : Icons.check),
                    label: Text(_currentQuestion < widget.quiz.questions.length - 1 ? 'Next' : 'Submit'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _currentQuestion < widget.quiz.questions.length - 1 ? AppTheme.primaryColor : AppTheme.successColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showExitConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Exit Quiz?'),
        content: const Text('Your progress will be lost. Are you sure you want to exit?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitQuiz() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);
    _timer.cancel();

    // Calculate score
    int score = 0;
    for (int i = 0; i < widget.quiz.questions.length; i++) {
      if (_answers[i] == widget.quiz.questions[i].correctIndex) {
        score++;
      }
    }

    final timeTaken = (widget.quiz.timeLimitMinutes * 60) - _remainingSeconds;

    try {
      if (widget.student != null) {
        await _studentService.submitQuizAttempt(
          quizId: widget.quiz.id,
          studentId: widget.student!.uid,
          score: score,
          totalQuestions: widget.quiz.questions.length,
          answers: _answers,
          timeTakenSeconds: timeTaken,
        );
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => QuizResultScreen(
              quiz: widget.quiz,
              score: score,
              answers: _answers,
              timeTaken: timeTaken,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.errorColor),
        );
        setState(() => _isSubmitting = false);
      }
    }
  }
}


/// Quiz Result Screen - Shows score and review
class QuizResultScreen extends StatelessWidget {
  final Quiz quiz;
  final int score;
  final List<int> answers;
  final int timeTaken;

  const QuizResultScreen({
    super.key,
    required this.quiz,
    required this.score,
    required this.answers,
    required this.timeTaken,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (score / quiz.questions.length * 100).round();
    final isPassed = percentage >= 60;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Results'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Score Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isPassed
                      ? [AppTheme.successColor, AppTheme.successColor.withOpacity(0.8)]
                      : [AppTheme.errorColor, AppTheme.errorColor.withOpacity(0.8)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Icon(isPassed ? Icons.emoji_events : Icons.refresh, size: 64, color: Colors.white),
                  const SizedBox(height: 16),
                  Text(isPassed ? 'Great Job!' : 'Keep Trying!',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 8),
                  Text('$score / ${quiz.questions.length}',
                      style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white)),
                  Text('$percentage%', style: TextStyle(fontSize: 20, color: Colors.white.withOpacity(0.9))),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Time: ${(timeTaken / 60).toStringAsFixed(1)} min',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Review Section
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Review Answers', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),

            ...List.generate(quiz.questions.length, (index) {
              final question = quiz.questions[index];
              final userAnswer = answers[index];
              final isCorrect = userAnswer == question.correctIndex;

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isCorrect ? AppTheme.successColor.withOpacity(0.3) : AppTheme.errorColor.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: isCorrect ? AppTheme.successColor : AppTheme.errorColor,
                          child: Icon(isCorrect ? Icons.check : Icons.close, size: 16, color: Colors.white),
                        ),
                        const SizedBox(width: 8),
                        Text('Question ${index + 1}', style: const TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(question.question, style: const TextStyle(fontSize: 15)),
                    const SizedBox(height: 12),
                    if (userAnswer != -1)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isCorrect ? AppTheme.successColor.withOpacity(0.1) : AppTheme.errorColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Text('Your answer: ', style: TextStyle(color: AppTheme.textSecondary)),
                            Expanded(
                              child: Text(question.options[userAnswer],
                                  style: TextStyle(fontWeight: FontWeight.w500, color: isCorrect ? AppTheme.successColor : AppTheme.errorColor)),
                            ),
                          ],
                        ),
                      ),
                    if (!isCorrect) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.successColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Text('Correct answer: ', style: TextStyle(color: AppTheme.textSecondary)),
                            Expanded(
                              child: Text(question.options[question.correctIndex],
                                  style: TextStyle(fontWeight: FontWeight.w500, color: AppTheme.successColor)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                child: const Text('Back to Home'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
