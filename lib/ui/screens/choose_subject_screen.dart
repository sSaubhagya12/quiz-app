import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../logic/providers/auth_provider.dart';
import '../../logic/providers/subject_provider.dart';
import '../../data/models/subject_model.dart';
import 'quiz_screen.dart';

class ChooseSubjectScreen extends StatefulWidget {
  final bool isEmbedded; // true = BottomNav inside HomeScreen, false = full page
  const ChooseSubjectScreen({super.key, this.isEmbedded = false});

  @override
  State<ChooseSubjectScreen> createState() => _ChooseSubjectScreenState();
}

class _ChooseSubjectScreenState extends State<ChooseSubjectScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SubjectProvider>().loadSubjects();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'science': return Icons.science_rounded;
      case 'calculate': return Icons.calculate_rounded;
      case 'book': return Icons.book_rounded;
      case 'history': return Icons.history_edu_rounded;
      case 'language': return Icons.language_rounded;
      case 'public': return Icons.public_rounded;
      case 'volunteer_activism': return Icons.volunteer_activism_rounded;
      case 'analytics': return Icons.analytics_rounded;
      case 'gavel': return Icons.gavel_rounded;
      case 'music_note': return Icons.music_note_rounded;
      case 'emoji_people': return Icons.emoji_people_rounded;
      case 'palette': return Icons.palette_rounded;
      case 'computer': return Icons.computer_rounded;
      case 'agriculture': return Icons.agriculture_rounded;
      case 'fitness_center': return Icons.fitness_center_rounded;
      default: return Icons.school_rounded;
    }
  }

  Color _getColor(int index) {
    final colors = [
      const Color(0xFF1E3C72),
      const Color(0xFF27AE60),
      const Color(0xFFF2994A),
      const Color(0xFF9B51E0),
      const Color(0xFFEB5757),
      const Color(0xFF2D9CDB),
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final subjectProvider = context.watch<SubjectProvider>();
    final authProvider = context.read<AuthProvider>();

    Widget body = SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'විෂයක් තෝරන්න',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3C72),
                  ),
                ),
                const Text(
                  'Choose a subject to start the quiz',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _searchController,
                  onChanged: subjectProvider.searchSubjects,
                  decoration: InputDecoration(
                    hintText: 'Search subjects...',
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF1E3C72)),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: subjectProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : subjectProvider.subjects.isEmpty
                    ? const Center(
                        child: Text(
                          'No subjects found.',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                        itemCount: subjectProvider.subjects.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: 1.1,
                        ),
                        itemBuilder: (context, index) {
                          final subject = subjectProvider.subjects[index];
                          final color = _getColor(index);
                          return _SubjectTile(
                            subject: subject,
                            icon: _getIcon(subject.iconName),
                            color: color,
                            onTap: () {
                              if (authProvider.currentStudent != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => QuizScreen(
                                      subject: subject,
                                      studentId: authProvider.currentStudent!.uid!,
                                    ),
                                  ),
                                );
                              }
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );

    if (!widget.isEmbedded) {
      return Scaffold(
        backgroundColor: const Color(0xFFF0F4FF),
        appBar: AppBar(
          title: const Text('Choose Subject', style: TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFF1E3C72),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: body,
      );
    }
    return body;
  }
}

class _SubjectTile extends StatelessWidget {
  final SubjectModel subject;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _SubjectTile({
    required this.subject,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: color.withValues(alpha: 0.15), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(height: 10),
            Text(
              subject.name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${subject.totalQuestions} Questions',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: LinearProgressIndicator(
                value: subject.completedRate,
                backgroundColor: Colors.grey.shade200,
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
