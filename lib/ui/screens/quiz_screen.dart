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
      context.read<QuizProvider>().startQuiz(widget.subject, widget.studentId);
    });
  }

  void _showPreviewPanel(BuildContext context, QuizProvider quizProvider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.65,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'ප්‍රශ්න පෙරදසුන',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3C72),
                  ),
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: quizProvider.questions.length,
                  itemBuilder: (ctx, idx) {
                    final q = quizProvider.questions[idx];
                    final answered = quizProvider.getAnswerForQuestion(q.id!);
                    final isCurrent = idx == quizProvider.currentQuestionIndex;
                    final isAnswered = answered != -1;

                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        quizProvider.jumpToQuestion(idx);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isCurrent
                              ? const Color(0xFF1E3C72)
                              : isAnswered
                                  ? const Color(0xFF1E3C72)
                                      .withValues(alpha: 0.08)
                                  : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isCurrent
                                ? const Color(0xFF1E3C72)
                                : isAnswered
                                    ? const Color(0xFF1E3C72)
                                        .withValues(alpha: 0.3)
                                    : Colors.grey.shade200,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: isCurrent
                                    ? Colors.white
                                    : isAnswered
                                        ? const Color(0xFF1E3C72)
                                        : Colors.grey.shade300,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${idx + 1}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isCurrent
                                        ? const Color(0xFF1E3C72)
                                        : isAnswered
                                            ? Colors.white
                                            : Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                q.questionText.length > 60
                                    ? '${q.questionText.substring(0, 60)}...'
                                    : q.questionText,
                                style: TextStyle(
                                  fontSize: 13,
                                  color:
                                      isCurrent ? Colors.white : Colors.black87,
                                ),
                              ),
                            ),
                            if (isAnswered && !isCurrent)
                              const Icon(Icons.check_circle_rounded,
                                  size: 16, color: Color(0xFF1E3C72)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final quizProvider = context.watch<QuizProvider>();

    if (quizProvider.isTimeOut && !quizProvider.timeOutNotified) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        quizProvider.markTimeOutNotified();
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Column(
              children: [
                Text('😢', style: TextStyle(fontSize: 40)),
                SizedBox(height: 8),
                Text('කාලය අවසන්!', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              ],
            ),
            content: const Text(
              'ඔබගේ ප්‍රශ්න පත්‍රය සඳහා ලබා දී තිබූ කාලය අවසන් වී ඇත.\nඔබ මෙතෙක් ලබාදුන් පිළිතුරු ඇගයීමට ලක් කෙරේ.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15),
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3C72),
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  if (quizProvider.isQuizCompleted && quizProvider.lastQuizResult != null) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const ResultsScreen()),
                    );
                  }
                },
                child: const Text('ප්‍රතිඵල බලන්න'),
              ),
            ],
          ),
        );
      });
    } else if (quizProvider.isQuizCompleted && quizProvider.lastQuizResult != null && !quizProvider.isTimeOut) {
      // If quiz just completed (normal flow)
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
          title: Text(widget.subject.name,
              style: const TextStyle(color: Colors.white)),
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
        title: Text(widget.subject.name,
            style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.grid_view_rounded, color: Colors.white70),
            tooltip: 'ප්‍රශ්න පෙරදසුන',
            onPressed: () => _showPreviewPanel(context, quizProvider),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                const Icon(Icons.timer_rounded,
                    color: Colors.white70, size: 18),
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
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E3C72)),
                  ),
                  const Spacer(),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style:
                        const TextStyle(color: Colors.grey, fontSize: 13),
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
                    style:
                        TextStyle(color: Colors.red.shade700, fontSize: 13),
                  ),
                ),

              // Options
              Expanded(
                child: ListView.builder(
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    final optionNumber = index + 1;
                    final isSelected =
                        quizProvider.selectedOption == optionNumber;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GestureDetector(
                        onTap: () => quizProvider.selectOption(optionNumber),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF1E3C72)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF1E3C72)
                                  : Colors.grey.shade200,
                              width: isSelected ? 2 : 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                  color:
                                      Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 6),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.white
                                      : const Color(0xFF1E3C72)
                                          .withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    String.fromCharCode(65 + index),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1E3C72),
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
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black87,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                const Icon(Icons.check_circle_rounded,
                                    color: Colors.white, size: 22),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Navigation row: Previous + Next
              Row(
                children: [
                  if (quizProvider.currentQuestionIndex > 0)
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: SizedBox(
                          height: 52,
                          child: OutlinedButton.icon(
                            onPressed: quizProvider.isLoading
                                ? null
                                : () => quizProvider.previousQuestion(),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF1E3C72),
                              side: const BorderSide(
                                  color: Color(0xFF1E3C72), width: 2),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                            ),
                            icon: const Icon(Icons.arrow_back_ios_rounded,
                                size: 16),
                            label: const Text('Previous',
                                style:
                                    TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                    ),
                  Expanded(
                    flex: quizProvider.currentQuestionIndex > 0 ? 2 : 1,
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: quizProvider.isLoading
                            ? null
                            : () =>
                                quizProvider.nextQuestion(widget.studentId),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E3C72),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          elevation: 4,
                        ),
                        child: quizProvider.isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : Text(
                                current == total
                                    ? 'Submit Quiz ✓'
                                    : 'Next Question →',
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
