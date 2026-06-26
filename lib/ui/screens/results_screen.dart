import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../logic/providers/quiz_provider.dart';
import '../../data/models/quiz_result_model.dart';
import '../widgets/emoji_rain.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _scoreAnimController;
  late Animation<double> _scoreAnim;

  @override
  void initState() {
    super.initState();
    _scoreAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _scoreAnim = CurvedAnimation(
        parent: _scoreAnimController, curve: Curves.easeOutCubic);
    _scoreAnimController.forward();
  }

  @override
  void dispose() {
    _scoreAnimController.dispose();
    super.dispose();
  }

  // ==========================================
  // Score-based config
  // ==========================================
  _ScoreConfig _getConfig(double pct) {
    if (pct < 40) {
      return _ScoreConfig(
        label: 'නැවතත් උත්සාහ කරන්න! 😢',
        subLabel: 'ඔබට තව ඉගෙනීමට ඕනෑ',
        emojis: const ['😢', '😔', '💔', '😞'],
        topColor1: const Color(0xFFEB5757),
        topColor2: const Color(0xFFFF8C8C),
        icon: Icons.refresh_rounded,
      );
    } else if (pct < 60) {
      return _ScoreConfig(
        label: 'හොඳයි! නැවත උත්සාහ කරන්න 💪',
        subLabel: 'ඔබ ඉදිරියට යනවා!',
        emojis: const ['💪', '😐', '📖', '🌱'],
        topColor1: const Color(0xFFf7971e),
        topColor2: const Color(0xFFffd200),
        icon: Icons.trending_up_rounded,
      );
    } else if (pct < 80) {
      return _ScoreConfig(
        label: 'හොඳ ලකුණු! 👍',
        subLabel: 'ඔබ ඉතා ඉදිරියෙහි!',
        emojis: const ['👍', '😊', '⭐', '🌟'],
        topColor1: const Color(0xFF2D9CDB),
        topColor2: const Color(0xFF56CCF2),
        icon: Icons.thumb_up_rounded,
      );
    } else {
      return _ScoreConfig(
        label: 'ඉතාමත් හොඳයි! 🎉',
        subLabel: 'ඔබ ඉතා දක්ෂයි!',
        emojis: const ['🎉', '🏆', '🌟', '✨', '🎊'],
        topColor1: const Color(0xFF27AE60),
        topColor2: const Color(0xFF2ECC71),
        icon: Icons.emoji_events_rounded,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final quizProvider = context.watch<QuizProvider>();
    final result = quizProvider.lastQuizResult;
    final hasRecentResult = result != null;
    
    final displayResult = result ??
        QuizResultModel(
          studentId: 'demo',
          subjectId: '',
          score: 0,
          totalQuestions: 1,
          timeSpent: 0,
          dateTaken: DateTime.now().toIso8601String(),
        );

    final percentage = (displayResult.score / displayResult.totalQuestions) * 100;
    final minutes = displayResult.timeSpent ~/ 60;
    final seconds = displayResult.timeSpent % 60;
    final wrongCount = displayResult.totalQuestions - displayResult.score;
    final config = _getConfig(percentage);
    final subjectName = quizProvider.currentSubject?.name ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Quiz Results',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1E3C72),
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Background emoji animation (only if recently finished a quiz)
          if (hasRecentResult)
            Positioned.fill(
              child: Opacity(
                opacity: 0.18,
                child: EmojiRain(emojis: config.emojis, count: 22),
              ),
            ),

          // Foreground content
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (hasRecentResult) ...[
                  // TOP RESULT CARD
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [config.topColor1, config.topColor2],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: config.topColor1.withValues(alpha: 0.45),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        )
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                      child: Column(
                        children: [
                          Icon(config.icon, size: 52, color: Colors.white),
                          const SizedBox(height: 8),
                          Text(
                            config.label,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          AnimatedBuilder(
                            animation: _scoreAnim,
                            builder: (context, _) {
                              final displayedPct = percentage * _scoreAnim.value;
                              return Text(
                                '${displayedPct.toStringAsFixed(0)}%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 64,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -2,
                                ),
                              );
                            },
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${displayResult.score} / ${displayResult.totalQuestions} correct',
                              style: const TextStyle(color: Colors.white, fontSize: 15),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (subjectName.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.25),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    subjectName,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // STATS ROW
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
                      const SizedBox(width: 10),
                      Expanded(
                        child: _InfoCard(
                          icon: Icons.check_circle_rounded,
                          label: 'Correct',
                          value: '${displayResult.score}',
                          color: const Color(0xFF27AE60),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _InfoCard(
                          icon: Icons.cancel_rounded,
                          label: 'Wrong',
                          value: '$wrongCount',
                          color: const Color(0xFFEB5757),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                ], // end if (hasRecentResult)

                const SizedBox(height: 8),

                // =====================
                // REVIEW PANEL
                // =====================
                if (quizProvider.showReviewPanel &&
                    quizProvider.reviewAnswers.isNotEmpty) ...[
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 8)
                      ],
                    ),
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Answer Review',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E3C72)),
                        ),
                        const SizedBox(height: 10),
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
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // =====================
                // OTHER SUBJECTS SCORES
                // =====================
                if (quizProvider.highestScores.isNotEmpty) ...[
                  const Text(
                    'ඔබගේ ඉහළම ලකුණු',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E3C72)),
                  ),
                  const SizedBox(height: 8),
                  ...quizProvider.highestScores.entries.map((entry) {
                    final r = entry.value;
                    final pct = (r.score / r.totalQuestions) * 100;
                    final isCurrentSubject = hasRecentResult && r.subjectId == displayResult.subjectId;
                    return _SubjectScoreRow(
                      subjectId: r.subjectId,
                      score: r.score,
                      total: r.totalQuestions,
                      percentage: pct,
                      isHighlighted: isCurrentSubject,
                    );
                  }),
                  const SizedBox(height: 16),
                ],

                // =====================
                // ACTION BUTTONS
                // =====================
                SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        Navigator.popUntil(context, (route) => route.isFirst),
                    icon: const Icon(Icons.home_rounded),
                    label: const Text('Back to Home',
                        style: TextStyle(fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E3C72),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.replay_rounded),
                    label: const Text('Try Again',
                        style: TextStyle(fontSize: 16)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1E3C72),
                      side: const BorderSide(color: Color(0xFF1E3C72)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ======================================================
// Config model for score tiers
// ======================================================
class _ScoreConfig {
  final String label;
  final String subLabel;
  final List<String> emojis;
  final Color topColor1;
  final Color topColor2;
  final IconData icon;

  const _ScoreConfig({
    required this.label,
    required this.subLabel,
    required this.emojis,
    required this.topColor1,
    required this.topColor2,
    required this.icon,
  });
}

// ======================================================
// Subject Score Row
// ======================================================
class _SubjectScoreRow extends StatelessWidget {
  final String subjectId;
  final int score;
  final int total;
  final double percentage;
  final bool isHighlighted;

  const _SubjectScoreRow({
    required this.subjectId,
    required this.score,
    required this.total,
    required this.percentage,
    required this.isHighlighted,
  });

  Color _barColor(double pct) {
    if (pct < 40) return const Color(0xFFEB5757);
    if (pct < 60) return const Color(0xFFf7971e);
    if (pct < 80) return const Color(0xFF2D9CDB);
    return const Color(0xFF27AE60);
  }

  String _friendlyName(String id) {
    final map = {
      'sinhala': 'සිංහල',
      'science': 'විද්‍යාව',
      'history': 'ඉතිහාසය',
      'maths': 'ගණිතය',
      'english': 'ඉංග්‍රීසි',
      'religion': 'ආගම',
      'geography': 'භූගෝලය',
      'civic': 'පුරවැසි',
      'art': 'කලා',
      'dance': 'නර්තන',
    };
    for (var key in map.keys) {
      if (id.toLowerCase().contains(key)) return map[key]!;
    }
    return id;
  }

  @override
  Widget build(BuildContext context) {
    final barColor = _barColor(percentage);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isHighlighted
            ? const Color(0xFF1E3C72).withValues(alpha: 0.07)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isHighlighted
              ? const Color(0xFF1E3C72).withValues(alpha: 0.3)
              : Colors.grey.withValues(alpha: 0.15),
        ),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04), blurRadius: 5)
        ],
      ),
      child: Row(
        children: [
          // Subject name
          SizedBox(
            width: 90,
            child: Text(
              _friendlyName(subjectId),
              style: TextStyle(
                fontWeight:
                    isHighlighted ? FontWeight.bold : FontWeight.w500,
                fontSize: 13,
                color: const Color(0xFF1E3C72),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Progress bar
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: percentage / 100,
                minHeight: 8,
                backgroundColor: Colors.grey.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation<Color>(barColor),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Percentage + fraction
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${percentage.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: barColor,
                ),
              ),
              Text(
                '$score/$total',
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ======================================================
// Info Card (Time / Correct / Wrong)
// ======================================================
class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoCard(
      {required this.icon,
      required this.label,
      required this.value,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05), blurRadius: 6)
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 18, color: color)),
          Text(label,
              style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }
}

// ======================================================
// Review Card
// ======================================================
class _ReviewCard extends StatelessWidget {
  final dynamic answer;
  final int index;

  const _ReviewCard({required this.answer, required this.index});

  String _getOptionText(dynamic question, int optionNum) {
    switch (optionNum) {
      case 1:
        return question.option1;
      case 2:
        return question.option2;
      case 3:
        return question.option3;
      case 4:
        return question.option4;
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCorrect = answer.isCorrect;
    final question = answer.question;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (isCorrect
                ? const Color(0xFF27AE60)
                : const Color(0xFFEB5757))
            .withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCorrect
              ? const Color(0xFF27AE60)
              : const Color(0xFFEB5757),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCorrect ? Icons.check_circle : Icons.cancel,
                color: isCorrect
                    ? const Color(0xFF27AE60)
                    : const Color(0xFFEB5757),
                size: 18,
              ),
              const SizedBox(width: 6),
              Text('Q${index + 1}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3C72))),
            ],
          ),
          const SizedBox(height: 6),
          Text(question?.questionText ?? '',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          if (!isCorrect)
            _OptionRow(
              label: 'ඔබගේ පිළිතුර',
              text: _getOptionText(question, answer.selectedOption),
              color: const Color(0xFFEB5757),
              icon: Icons.close,
            ),
          _OptionRow(
            label: 'නිවැරදි පිළිතුර',
            text: _getOptionText(question, question?.correctOption ?? 0),
            color: const Color(0xFF27AE60),
            icon: Icons.check,
          ),
          if (question?.explanation != null &&
              question!.explanation.isNotEmpty) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F4FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lightbulb_rounded,
                      size: 14, color: Color(0xFFF2994A)),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(question.explanation,
                        style: const TextStyle(
                            fontSize: 11, color: Colors.black87)),
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

  const _OptionRow(
      {required this.label,
      required this.text,
      required this.color,
      required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 5),
          Text('$label: ',
              style: TextStyle(
                  fontSize: 11,
                  color: color,
                  fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(text,
                style:
                    const TextStyle(fontSize: 11, color: Colors.black87)),
          ),
        ],
      ),
    );
  }
}
