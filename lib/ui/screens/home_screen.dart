import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../logic/providers/auth_provider.dart';
import '../../logic/providers/subject_provider.dart';
import '../../logic/providers/quiz_provider.dart';
import 'choose_subject_screen.dart';
import 'profile_screen.dart';
import 'quiz_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String _selectedLanguageCode = 'en'; // Default to English ('en') because of 'ENG' button

  @override
  void initState() {
    super.initState();
    // Load subjects when home screen is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SubjectProvider>().loadSubjects();
    });
  }

  void _onLanguageChanged(String langCode) {
    setState(() {
      _selectedLanguageCode = langCode;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final student = authProvider.currentStudent;

    final List<Widget> pages = [
      _HomeDashboard(
        student: student,
        langCode: _selectedLanguageCode,
        onLanguageChanged: _onLanguageChanged,
        onViewAllSubjects: () => setState(() => _selectedIndex = 1),
      ),
      const ChooseSubjectScreen(isEmbedded: true),
      const ProfileScreen(isEmbedded: true),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FC),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        selectedItemColor: const Color(0xFF1E3C72),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 10,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book_rounded), label: 'Subjects'),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
        ],
      ),
    );
  }
}

class _HomeDashboard extends StatelessWidget {
  final dynamic student;
  final String langCode;
  final ValueChanged<String> onLanguageChanged;
  final VoidCallback onViewAllSubjects;

  const _HomeDashboard({
    required this.student,
    required this.langCode,
    required this.onLanguageChanged,
    required this.onViewAllSubjects,
  });

  // Translation mapping
  static const Map<String, Map<String, String>> _translations = {
    'en': {
      'heading': 'Quiz O-Level',
      'ongoing': 'Ongoing Quiz',
      'time': 'Time',
      'ready_to_quiz': 'Are you ready to quiz?',
      'start_now': 'Start a new quiz now!',
      'continue_learning': 'Continue Learning',
      'more': 'more',
      'complete': 'Complete',
      'subjects': 'Subjects',
      'hello': 'Hello',
    },
    'si': {
      'heading': 'Quiz O-Level',
      'ongoing': 'දැනට පවතින ක්විස් එක',
      'time': 'වේලාව',
      'ready_to_quiz': 'ඔබ ක්විස් එකකට සූදානම්ද?',
      'start_now': 'දැන්ම අලුත් ක්විස් එකක් අරඹන්න!',
      'continue_learning': 'Continue Learning',
      'more': 'තවත් (more)',
      'complete': 'සම්පූර්ණයි',
      'subjects': 'විෂයන් (Subjects)',
      'hello': 'හෙලෝ',
    },
    'ta': {
      'heading': 'Quiz O-Level',
      'ongoing': 'நடந்து கொண்டிருக்கும் வினாடி வினா',
      'time': 'நேரம்',
      'ready_to_quiz': 'நீங்கள் வினாடி வினாவிற்கு தயாரா?',
      'start_now': 'இப்போது புதிய வினாடி வினாவைத் தொடங்கவும்!',
      'continue_learning': 'தொடர்ந்து கற்கவும் (Continue Learning)',
      'more': 'மேலும் (more)',
      'complete': 'முடிந்தது',
      'subjects': 'பாடங்கள் (Subjects)',
      'hello': 'வணக்கம்',
    }
  };

  String _t(String key) {
    return _translations[langCode]?[key] ?? key;
  }

  String _getSubjectDisplayName(String subjectName) {
    switch (subjectName.toLowerCase()) {
      case 'religion':
        if (langCode == 'si') return 'ආගම';
        if (langCode == 'ta') return 'சமயம்';
        return 'Religion';
      case 'sinhala':
        if (langCode == 'si') return 'සිංහල';
        if (langCode == 'ta') return 'சிங்களம்';
        return 'Sinhala';
      case 'english':
        if (langCode == 'si') return 'ඉංග්‍රීසි';
        if (langCode == 'ta') return 'ஆங்கிலம்';
        return 'English';
      case 'mathematics':
      case 'math':
        if (langCode == 'si') return 'ගණිතය';
        if (langCode == 'ta') return 'கணிதம்';
        return 'Mathematics';
      case 'science':
      case 'sci':
        if (langCode == 'si') return 'විද්‍යාව';
        if (langCode == 'ta') return 'அறிவியல்';
        return 'Science';
      case 'history':
        if (langCode == 'si') return 'ඉතිහාසය';
        if (langCode == 'ta') return 'வரலாறு';
        return 'History';
      case 'business & accounting studies':
      case 'business':
        if (langCode == 'si') return 'ව්‍යාපාර හා ගිණුම්කරණය';
        if (langCode == 'ta') return 'வணிகமும் கணக்கீடும்';
        return 'Business & Accounts';
      case 'geography':
      case 'geo':
        if (langCode == 'si') return 'භූගෝල විද්‍යාව';
        if (langCode == 'ta') return 'புவியியல்';
        return 'Geography';
      case 'civic education':
      case 'civic':
        if (langCode == 'si') return 'පුරවැසි අධ්‍යාපනය';
        if (langCode == 'ta') return 'குடிமையியல் கல்வி';
        return 'Civic Education';
      case 'music':
        if (langCode == 'si') return 'සංගීතය';
        if (langCode == 'ta') return 'சங்கீதம்';
        return 'Music';
      case 'dancing':
        if (langCode == 'si') return 'නර්තනය';
        if (langCode == 'ta') return 'நடனம்';
        return 'Dancing';
      case 'art (act)':
      case 'art':
        if (langCode == 'si') return 'නාට්‍ය හා රංග කලාව';
        if (langCode == 'ta') return 'சித்திரமும் நாடகமும்';
        return 'Art & Drama';
      case 'information & communication':
      case 'ict':
        if (langCode == 'si') return 'තොරතුරු තාක්ෂණය';
        if (langCode == 'ta') return 'தகவல் தொழில்நுட்பம்';
        return 'ICT';
      case 'agriculture & food technology':
      case 'agriculture':
        if (langCode == 'si') return 'කෘෂිකර්ම හා ආහාර';
        if (langCode == 'ta') return 'விவசாயம்';
        return 'Agriculture';
      case 'health & physical education':
      case 'health':
        if (langCode == 'si') return 'සෞඛ්‍ය හා ශාරීරික';
        if (langCode == 'ta') return 'சுகாதாரமும் உடற்கல்வியும்';
        return 'Health & PE';
      default:
        return subjectName;
    }
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

  @override
  Widget build(BuildContext context) {
    final subjectProvider = context.watch<SubjectProvider>();
    final quizProvider = context.watch<QuizProvider>();
    final authProvider = context.read<AuthProvider>();

    final hasOngoingQuiz = quizProvider.currentSubject != null && !quizProvider.isQuizCompleted;
    final subjects = subjectProvider.subjects;

    // Filtered subjects for "Continue Learning" (either in-progress or some recommended fallbacks)
    final continueLearningSubjects = subjects.where((s) => s.completedRate > 0.0).toList();
    if (continueLearningSubjects.isEmpty && subjects.isNotEmpty) {
      // Show first 3 subjects as fallback
      continueLearningSubjects.addAll(subjects.take(3));
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header Section (Title, ENG language button, User Profile icon)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.menu_rounded, color: Color(0xFF1E3C72), size: 28),
                    const SizedBox(width: 8),
                    Text(
                      _t('heading'),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E3C72),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    // Language picker (ENG button)
                    PopupMenuButton<String>(
                      onSelected: onLanguageChanged,
                      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(
                          value: 'si',
                          child: Text('සිංහල (Sinhala)'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'en',
                          child: Text('English'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'ta',
                          child: Text('Tamil (sri lanka)'),
                        ),
                      ],
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 4,
                            )
                          ],
                          border: Border.all(color: const Color(0xFF1E3C72).withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              langCode == 'en'
                                  ? 'ENG'
                                  : langCode == 'si'
                                      ? 'සිංහල'
                                      : 'தமிழ்',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E3C72),
                                fontSize: 13,
                              ),
                            ),
                            const Icon(Icons.arrow_drop_down, color: Color(0xFF1E3C72), size: 18),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // User icon
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ProfileScreen(isEmbedded: false),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E3C72).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person_outline_rounded,
                          color: Color(0xFF1E3C72),
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 2. Ongoing Quiz / "Are you ready to quiz?" Section
            GestureDetector(
              onTap: () {
                if (hasOngoingQuiz) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => QuizScreen(
                        subject: quizProvider.currentSubject!,
                        studentId: authProvider.currentStudent!.uid!,
                      ),
                    ),
                  );
                } else {
                  onViewAllSubjects();
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: hasOngoingQuiz
                        ? [const Color(0xFFEB5757), const Color(0xFFC0392B)]
                        : [const Color(0xFF1E3C72), const Color(0xFF2A5298)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: (hasOngoingQuiz ? const Color(0xFFEB5757) : const Color(0xFF1E3C72))
                          .withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: hasOngoingQuiz
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${_t('ongoing')}: ${_getSubjectDisplayName(quizProvider.currentSubject!.name)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${_t('time')}: ${quizProvider.formattedTime}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.help_outline_rounded, color: Colors.white, size: 28),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _t('ready_to_quiz'),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  _t('start_now'),
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 16),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 24),

            // 3. Continue Learning Section
            Text(
              _t('continue_learning'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3C72),
              ),
            ),
            const SizedBox(height: 12),

            SizedBox(
              height: 160,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: continueLearningSubjects.length + 1, // +1 for the "more" card
                itemBuilder: (context, index) {
                  if (index == continueLearningSubjects.length) {
                    // Rightmost "more" card
                    return Container(
                      width: 100,
                      margin: const EdgeInsets.only(right: 8, bottom: 8),
                      child: InkWell(
                        onTap: onViewAllSubjects,
                        borderRadius: BorderRadius.circular(14),
                        child: Card(
                          color: Colors.white,
                          elevation: 3,
                          shadowColor: Colors.black.withValues(alpha: 0.1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E3C72).withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.arrow_forward_rounded,
                                  color: Color(0xFF1E3C72),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _t('more'),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E3C72),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  final subject = continueLearningSubjects[index];
                  return Container(
                    width: 140,
                    margin: const EdgeInsets.only(right: 12, bottom: 8),
                    child: Card(
                      color: Colors.white,
                      elevation: 3,
                      shadowColor: Colors.black.withValues(alpha: 0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Photo
                            Expanded(
                              flex: 5,
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: Image.network(
                                      subject.imageUrl ??
                                          'https://images.unsplash.com/photo-1509228468518-180dd4864904?w=400&q=80',
                                      fit: CoverAnchor.center.fit,
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return Container(
                                          color: Colors.grey.shade100,
                                          child: const Center(
                                            child: SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(strokeWidth: 2),
                                            ),
                                          ),
                                        );
                                      },
                                      errorBuilder: (context, error, stackTrace) => Container(
                                        color: const Color(0xFF1E3C72).withValues(alpha: 0.05),
                                        child: Center(
                                          child: Icon(
                                            _getIcon(subject.iconName),
                                            color: const Color(0xFF1E3C72),
                                            size: 24,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Subject name and progress bar
                            Expanded(
                              flex: 5,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _getSubjectDisplayName(subject.name),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1E3C72),
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(4),
                                          child: LinearProgressIndicator(
                                            value: subject.completedRate,
                                            minHeight: 5,
                                            backgroundColor: Colors.grey.shade200,
                                            color: const Color(0xFF27AE60),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${(subject.completedRate * 100).toStringAsFixed(0)}% ${_t('complete')}',
                                          style: const TextStyle(
                                            fontSize: 9,
                                            color: Colors.grey,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // 4. Subjects Section (All 15 subjects grid)
            Text(
              _t('subjects'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3C72),
              ),
            ),
            const SizedBox(height: 12),

            if (subjectProvider.isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (subjects.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Text('Loading subjects...', style: TextStyle(color: Colors.grey)),
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: subjects.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 1.15,
                ),
                itemBuilder: (context, index) {
                  final subject = subjects[index];
                  return Card(
                    color: Colors.white,
                    elevation: 3,
                    shadowColor: Colors.black.withValues(alpha: 0.08),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Top half: Photo
                          Expanded(
                            flex: 6,
                            child: Image.network(
                              subject.imageUrl ??
                                  'https://images.unsplash.com/photo-1509228468518-180dd4864904?w=400&q=80',
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  color: Colors.grey.shade100,
                                  child: const Center(
                                    child: SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: const Color(0xFF1E3C72).withValues(alpha: 0.05),
                                child: Center(
                                  child: Icon(
                                    _getIcon(subject.iconName),
                                    color: const Color(0xFF1E3C72),
                                    size: 28,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Bottom half: Name
                          Expanded(
                            flex: 4,
                            child: Container(
                              color: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                              alignment: Alignment.center,
                              child: Text(
                                _getSubjectDisplayName(subject.name),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E3C72),
                                  height: 1.2,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

// Helper alignment enum for continue learning
enum CoverAnchor {
  center;
  BoxFit get fit => BoxFit.cover;
}
