import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/career_model.dart';

/// Simulation Screen - Reality Task Mini-Simulator
class SimulationScreen extends StatefulWidget {
  final CareerModel career;
  const SimulationScreen({super.key, required this.career});

  @override
  State<SimulationScreen> createState() => _SimulationScreenState();
}

class _SimulationScreenState extends State<SimulationScreen> {
  int _currentQuestion = 0;
  int _score = 0;
  bool _showResult = false;
  int? _selectedAnswer;
  bool _answered = false;

  RealityTask get task => widget.career.realityTask;
  List<TaskQuestion> get questions => task.questions;
  TaskQuestion get currentQ => questions[_currentQuestion];

  void _selectAnswer(int index) {
    if (_answered) return;
    setState(() {
      _selectedAnswer = index;
      _answered = true;
      if (index == currentQ.correctIndex) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestion < questions.length - 1) {
      setState(() {
        _currentQuestion++;
        _selectedAnswer = null;
        _answered = false;
      });
    } else {
      setState(() {
        _showResult = true;
      });
    }
  }

  void _restart() {
    setState(() {
      _currentQuestion = 0;
      _score = 0;
      _showResult = false;
      _selectedAnswer = null;
      _answered = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(task.taskTitle),
        backgroundColor: _getStreamColor(widget.career.streamTag),
        foregroundColor: Colors.white,
      ),
      body: _showResult ? _buildResultView() : _buildQuestionView(),
    );
  }

  Widget _buildQuestionView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress
          Row(
            children: [
              Text('Question ${_currentQuestion + 1}/${questions.length}', 
                style: const TextStyle(fontWeight: FontWeight.bold)),
              const Spacer(),
              Text('Score: $_score', style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: (_currentQuestion + 1) / questions.length,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation(_getStreamColor(widget.career.streamTag)),
          ),
          const SizedBox(height: 24),

          // Instructions (first question only)
          if (_currentQuestion == 0) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue),
                  const SizedBox(width: 12),
                  Expanded(child: Text(task.taskInstructions, style: const TextStyle(fontSize: 14))),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Question
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(currentQ.question, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 20),
                
                // Options
                ...currentQ.options.asMap().entries.map((entry) {
                  final index = entry.key;
                  final option = entry.value;
                  final isSelected = _selectedAnswer == index;
                  final isCorrect = index == currentQ.correctIndex;
                  
                  Color bgColor = Colors.grey[50]!;
                  Color borderColor = Colors.grey[300]!;
                  Color textColor = Colors.black87;
                  
                  if (_answered) {
                    if (isCorrect) {
                      bgColor = Colors.green.withOpacity(0.1);
                      borderColor = Colors.green;
                      textColor = Colors.green[800]!;
                    } else if (isSelected && !isCorrect) {
                      bgColor = Colors.red.withOpacity(0.1);
                      borderColor = Colors.red;
                      textColor = Colors.red[800]!;
                    }
                  } else if (isSelected) {
                    bgColor = _getStreamColor(widget.career.streamTag).withOpacity(0.1);
                    borderColor = _getStreamColor(widget.career.streamTag);
                  }
                  
                  return GestureDetector(
                    onTap: () => _selectAnswer(index),
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor, width: 2),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: isSelected ? borderColor : Colors.transparent,
                              shape: BoxShape.circle,
                              border: Border.all(color: borderColor, width: 2),
                            ),
                            child: Center(
                              child: Text(
                                String.fromCharCode(65 + index),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? Colors.white : borderColor,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Text(option, style: TextStyle(fontSize: 15, color: textColor))),
                          if (_answered && isCorrect)
                            const Icon(Icons.check_circle, color: Colors.green),
                          if (_answered && isSelected && !isCorrect)
                            const Icon(Icons.cancel, color: Colors.red),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          
          // Explanation
          if (_answered) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.withOpacity(0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lightbulb, color: Colors.amber),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Explanation', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber)),
                        const SizedBox(height: 4),
                        Text(currentQ.explanation, style: const TextStyle(fontSize: 14)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _nextQuestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getStreamColor(widget.career.streamTag),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(_currentQuestion < questions.length - 1 ? 'Next Question' : 'See Results'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResultView() {
    final percentage = (_score / questions.length * 100).round();
    final isPassing = percentage >= 60;
    
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Score Circle
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isPassing ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                border: Border.all(color: isPassing ? Colors.green : Colors.orange, width: 4),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('$percentage%', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: isPassing ? Colors.green : Colors.orange)),
                  Text('$_score/${questions.length}', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            Text(isPassing ? '🎉 Great Job!' : '💪 Keep Learning!', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(task.successOutcome, style: const TextStyle(fontSize: 15, height: 1.5), textAlign: TextAlign.center),
            ),
            const SizedBox(height: 24),
            
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _restart,
                    child: const Text('Try Again'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(backgroundColor: _getStreamColor(widget.career.streamTag)),
                    child: const Text('Done'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

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
}
