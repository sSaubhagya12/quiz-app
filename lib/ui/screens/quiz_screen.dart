import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../logic/providers/quiz_provider.dart';
import '../../data/models/subject_model.dart';
import 'results_screen.dart';

class QuizScreen extends StatefulWidget {
  final SubjectModel subject;
  final String studentId;

  const QuizScreen({super.key, required this.subject, required this.studentId});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuizProvider>().startQuiz(widget.subject);
    });
  }

  @override
  Widget build(BuildContext context) {
    final quizProvider = context.watch<QuizProvider>();

    // If quiz just completed, go to results
    if (quizProvider.isQuizCompleted && quizProvider.lastQuizResult != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ResultsScreen()),
        );
      });
    }

    if (quizProvider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (quizProvider.errorMessage != null && quizProvider.questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.subject.name, style: const TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFF1E3C72),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.info_outline, size: 60, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                quizProvider.errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Back'),
              ),
            ],
          ),
        ),
      );
    }

    final question = quizProvider.currentQuestion;
    if (question == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final total = quizProvider.questions.length;
    final current = quizProvider.currentQuestionIndex + 1;
    final progress = current / total;

    final options = [
      question.option1,
      question.option2,
      question.option3,
      question.option4,
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E3C72),
        title: Text(widget.subject.name, style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                const Icon(Icons.timer_rounded, color: Colors.white70, size: 18),
                const SizedBox(width: 4),
                Text(
                  quizProvider.formattedTime,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress bar
              Row(
                children: [
                  Text(
                    'Question $current of $total',
                    style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1E3C72)),
                  ),
                  const Spacer(),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey.shade200,
                  color: const Color(0xFF1E3C72),
                  minHeight: 8,
                ),
              ),

              const SizedBox(height: 24),

              // Question card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E3C72), Color(0xFF2A5298)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1E3C72).withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Text(
                  question.questionText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Error message
              if (quizProvider.errorMessage != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Text(
                    quizProvider.errorMessage!,
                    style: TextStyle(color: Colors.red.shade700, fontSize: 13),
                  ),
                ),

              // Options
              Expanded(
                child: ListView.builder(
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    final optionNumber = index + 1;
                    final isSelected = quizProvider.selectedOption == optionNumber;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GestureDetector(
                        onTap: () => quizProvider.selectOption(optionNumber),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF1E3C72) : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected ? const Color(0xFF1E3C72) : Colors.grey.shade200,
                              width: isSelected ? 2 : 1,
                            ),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.white : const Color(0xFF1E3C72).withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    String.fromCharCode(65 + index), // A, B, C, D
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isSelected ? const Color(0xFF1E3C72) : const Color(0xFF1E3C72),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  options[index],
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: isSelected ? Colors.white : Colors.black87,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 22),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Next button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: quizProvider.isLoading
                      ? null
                      : () => quizProvider.nextQuestion(widget.studentId),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3C72),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 4,
                  ),
                  child: quizProvider.isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          current == total ? 'Submit Quiz ✓' : 'Next Question →',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
