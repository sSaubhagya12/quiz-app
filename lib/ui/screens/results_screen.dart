import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../logic/providers/quiz_provider.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final quizProvider = context.watch<QuizProvider>();
    final result = quizProvider.lastQuizResult;

    if (result == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final percentage = (result.score / result.totalQuestions) * 100;
    final minutes = result.timeSpent ~/ 60;
    final seconds = result.timeSpent % 60;
    final isPass = percentage >= 50;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Quiz Results', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1E3C72),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Result Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isPass
                      ? [const Color(0xFF27AE60), const Color(0xFF2ECC71)]
                      : [const Color(0xFFEB5757), const Color(0xFFFF8C8C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: (isPass ? const Color(0xFF27AE60) : const Color(0xFFEB5757)).withValues(alpha: 0.4),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  )
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    isPass ? Icons.emoji_events_rounded : Icons.refresh_rounded,
                    size: 60,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isPass ? 'ජය ගත්තා! 🎉' : 'නැවත උත්සාහ කරන්න!',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${percentage.toStringAsFixed(0)}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 56,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${result.score} / ${result.totalQuestions} correct',
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Stats Row
            Row(
              children: [
                Expanded(
                  child: _InfoCard(
                    icon: Icons.timer_rounded,
                    label: 'Time Taken',
                    value: '${minutes}m ${seconds}s',
                    color: const Color(0xFF2D9CDB),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _InfoCard(
                    icon: Icons.check_circle_rounded,
                    label: 'Correct',
                    value: '${result.score}',
                    color: const Color(0xFF27AE60),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _InfoCard(
                    icon: Icons.cancel_rounded,
                    label: 'Wrong',
                    value: '${result.totalQuestions - result.score}',
                    color: const Color(0xFFEB5757),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Review Answers Section
            if (quizProvider.reviewAnswers.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Answer Review',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3C72),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: quizProvider.toggleReviewPanel,
                    icon: Icon(
                      quizProvider.showReviewPanel ? Icons.visibility_off : Icons.visibility,
                      size: 18,
                    ),
                    label: Text(quizProvider.showReviewPanel ? 'Hide' : 'Show'),
                  ),
                ],
              ),
              if (quizProvider.showReviewPanel)
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: quizProvider.reviewAnswers.length,
                  itemBuilder: (context, index) {
                    final answer = quizProvider.reviewAnswers[index];
                    return _ReviewCard(answer: answer, index: index);
                  },
                ),
            ],

            const SizedBox(height: 20),

            // Action buttons
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Go back to HomeScreen
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                icon: const Icon(Icons.home_rounded),
                label: const Text('Back to Home', style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3C72),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.replay_rounded),
                label: const Text('Try Again', style: TextStyle(fontSize: 16)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF1E3C72),
                  side: const BorderSide(color: Color(0xFF1E3C72)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6)],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: color)),
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final dynamic answer;
  final int index;

  const _ReviewCard({required this.answer, required this.index});

  String _getOptionText(dynamic question, int optionNum) {
    switch (optionNum) {
      case 1: return question.option1;
      case 2: return question.option2;
      case 3: return question.option3;
      case 4: return question.option4;
      default: return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCorrect = answer.isCorrect;
    final question = answer.question;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCorrect ? const Color(0xFF27AE60) : const Color(0xFFEB5757),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCorrect ? Icons.check_circle : Icons.cancel,
                color: isCorrect ? const Color(0xFF27AE60) : const Color(0xFFEB5757),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Q${index + 1}',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E3C72)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            question?.questionText ?? '',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          if (!isCorrect) ...[
            _OptionRow(
              label: 'Your Answer',
              text: _getOptionText(question, answer.selectedOption),
              color: const Color(0xFFEB5757),
              icon: Icons.close,
            ),
            const SizedBox(height: 4),
          ],
          _OptionRow(
            label: 'Correct Answer',
            text: _getOptionText(question, question?.correctOption ?? 0),
            color: const Color(0xFF27AE60),
            icon: Icons.check,
          ),
          if (question?.explanation != null && question!.explanation.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F4FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lightbulb_rounded, size: 16, color: Color(0xFFF2994A)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      question.explanation,
                      style: const TextStyle(fontSize: 12, color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _OptionRow extends StatelessWidget {
  final String label;
  final String text;
  final Color color;
  final IconData icon;

  const _OptionRow({required this.label, required this.text, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 6),
        Text('$label: ', style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold)),
        Expanded(
          child: Text(text, style: const TextStyle(fontSize: 12, color: Colors.black87)),
        ),
      ],
    );
  }
}
