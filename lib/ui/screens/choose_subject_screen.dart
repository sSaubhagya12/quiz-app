import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../logic/providers/auth_provider.dart';
import '../../logic/providers/subject_provider.dart';
import '../../logic/providers/theme_provider.dart';
import '../../data/models/subject_model.dart';
import 'quiz_screen.dart';

// ==========================================
// Choose Subject Screen
// ==========================================
class ChooseSubjectScreen extends StatefulWidget {
  final bool isEmbedded;
  final String? initialLangCode;
  final ValueChanged<String>? onLanguageChanged;

  const ChooseSubjectScreen({
    super.key,
    this.isEmbedded = false,
    this.initialLangCode,
    this.onLanguageChanged,
  });

  @override
  State<ChooseSubjectScreen> createState() => _ChooseSubjectScreenState();
}

class _ChooseSubjectScreenState extends State<ChooseSubjectScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _langCode = 'en';

  // ── Translation map ──────────────────────────────────────────────────────────
  static const Map<String, Map<String, String>> _tr = {
    'en': {
      'heading': 'Quiz O-Level',
      'page_title': 'Choose Subject',
      'page_sub': 'Select a subject to start your quiz',
      'search_hint': 'Search subjects...',
      'questions': 'Questions',
      'time': 'Time',
      'no_subjects': 'No subjects found.',
      'start': 'Start Quiz',
    },
    'si': {
      'heading': 'Quiz O-Level',
      'page_title': 'විෂයක් තෝරන්න',
      'page_sub': 'ක්විස් ආරම්භ කිරීමට විෂයක් තෝරන්න',
      'search_hint': 'විෂයක් සොයන්න...',
      'questions': 'ප්‍රශ්න',
      'time': 'කාලය',
      'no_subjects': 'විෂය හමු නොවිණ.',
      'start': 'ක්විස් ආරම්භ කරන්න',
    },
    'ta': {
      'heading': 'Quiz O-Level',
      'page_title': 'பாடத்தை தேர்ந்தெடுக்கவும்',
      'page_sub': 'வினாடி வினாவை தொடங்க பாடத்தை தேர்வு செய்யவும்',
      'search_hint': 'பாடங்களை தேடவும்...',
      'questions': 'கேள்விகள்',
      'time': 'நேரம்',
      'no_subjects': 'பாடங்கள் காணவில்லை.',
      'start': 'வினாடி வினா தொடங்கவும்',
    },
  };

  String _t(String key) => _tr[_langCode]?[key] ?? key;

  // ── Subject display names per language ───────────────────────────────────────
  String _subjectName(String name) {
    if (_langCode == 'en') return name;
    const si = {
      'Religion': 'ආගම',
      'Sinhala': 'සිංහල',
      'English': 'ඉංග්‍රීසි',
      'Mathematics': 'ගණිතය',
      'Science': 'විද්‍යාව',
      'History': 'ඉතිහාසය',
      'Business & Accounting Studies': 'ව්‍යාපාර හා ගිණුම්කරණය',
      'Geography': 'භූගෝල විද්‍යාව',
      'Civic Education': 'පුරවැසි අධ්‍යාපනය',
      'Music': 'සංගීතය',
      'Dancing': 'නර්තනය',
      'Art (Act)': 'නාට්‍ය හා රංග කලාව',
      'Information & Communication': 'තොරතුරු තාක්ෂණය',
      'Agriculture & Food Technology': 'කෘෂිකර්ම හා ආහාර',
      'Health & Physical Education': 'සෞඛ්‍ය හා ශාරීරික',
    };
    const ta = {
      'Religion': 'சமயம்',
      'Sinhala': 'சிங்களம்',
      'English': 'ஆங்கிலம்',
      'Mathematics': 'கணிதம்',
      'Science': 'அறிவியல்',
      'History': 'வரலாறு',
      'Business & Accounting Studies': 'வணிகமும் கணக்கீடும்',
      'Geography': 'புவியியல்',
      'Civic Education': 'குடிமையியல் கல்வி',
      'Music': 'சங்கீதம்',
      'Dancing': 'நடனம்',
      'Art (Act)': 'சித்திரமும் நாடகமும்',
      'Information & Communication': 'தகவல் தொழில்நுட்பம்',
      'Agriculture & Food Technology': 'விவசாயம்',
      'Health & Physical Education': 'சுகாதாரமும் உடற்கல்வியும்',
    };
    if (_langCode == 'si') return si[name] ?? name;
    if (_langCode == 'ta') return ta[name] ?? name;
    return name;
  }

  // ── Icon mapping ─────────────────────────────────────────────────────────────
  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'science':
        return Icons.science_rounded;
      case 'calculate':
        return Icons.calculate_rounded;
      case 'book':
        return Icons.book_rounded;
      case 'history':
        return Icons.history_edu_rounded;
      case 'language':
        return Icons.language_rounded;
      case 'public':
        return Icons.public_rounded;
      case 'volunteer_activism':
        return Icons.volunteer_activism_rounded;
      case 'analytics':
        return Icons.analytics_rounded;
      case 'gavel':
        return Icons.gavel_rounded;
      case 'music_note':
        return Icons.music_note_rounded;
      case 'emoji_people':
        return Icons.emoji_people_rounded;
      case 'palette':
        return Icons.palette_rounded;
      case 'computer':
        return Icons.computer_rounded;
      case 'agriculture':
        return Icons.agriculture_rounded;
      case 'fitness_center':
        return Icons.fitness_center_rounded;
      default:
        return Icons.school_rounded;
    }
  }

  // ── Lifecycle ────────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _langCode = widget.initialLangCode ?? 'en';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SubjectProvider>().loadSubjects();
    });
  }

  @override
  void didUpdateWidget(ChooseSubjectScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialLangCode != null && widget.initialLangCode != _langCode) {
      setState(() => _langCode = widget.initialLangCode!);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }



  // ── Helpers ──────────────────────────────────────────────────────────────────
  bool _matchesSearch(SubjectModel s) {
    if (_searchQuery.isEmpty) return true;
    final q = _searchQuery.toLowerCase();
    return s.name.toLowerCase().contains(q) ||
        _subjectName(s.name).toLowerCase().contains(q);
  }

  // ── Build ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final subjectProvider = context.watch<SubjectProvider>();
    final authProvider = context.read<AuthProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;
    final allSubjects = subjectProvider.subjects;
    final filtered = allSubjects.where(_matchesSearch).toList();

    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF4F6FC);
    final textPrimary = isDark ? Colors.white : const Color(0xFF1E3C72);
    final searchFill = isDark ? const Color(0xFF2C2C2C) : Colors.white;

    Widget content = SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [


          // ── Page title + Search bar ───────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _t('page_title'),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _t('page_sub'),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 14),
                // Search bar
                TextField(
                  controller: _searchController,
                  style: TextStyle(color: textPrimary),
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    hintText: _t('search_hint'),
                    hintStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: Icon(Icons.search_rounded, color: textPrimary),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close_rounded,
                                color: Colors.grey),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: searchFill,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: textPrimary, width: 1.5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: textPrimary.withValues(alpha: 0.2),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: textPrimary, width: 1.8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // ── Subject grid ─────────────────────────────────────────────────────
          Expanded(
            child: subjectProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.search_off_rounded,
                                size: 56, color: Colors.grey.shade300),
                            const SizedBox(height: 12),
                            Text(_t('no_subjects'),
                                style: TextStyle(
                                    color: Colors.grey.shade500, fontSize: 15)),
                          ],
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                        itemCount: filtered.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: 0.78,
                        ),
                        itemBuilder: (context, index) {
                          final subject = filtered[index];
                          final isHighlighted = _searchQuery.isNotEmpty &&
                              _matchesSearch(subject);
                          return _SubjectCard(
                            subject: subject,
                            displayName: _subjectName(subject.name),
                            icon: _getIcon(subject.iconName),
                            questionsLabel: _t('questions'),
                            timeLabel: _t('time'),
                            isHighlighted: isHighlighted,
                            hasSearch: _searchQuery.isNotEmpty,
                            onTap: () {
                              final student = authProvider.currentStudent;
                              if (student != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => QuizScreen(
                                      subject: subject,
                                      studentId: student.uid!,
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

    // When used standalone (not embedded in HomeScreen bottom nav)
    if (!widget.isEmbedded) {
      return Scaffold(backgroundColor: bgColor, body: content);
    }
    return ColoredBox(color: bgColor, child: content);
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Subject Card Widget
// ──────────────────────────────────────────────────────────────────────────────
class _SubjectCard extends StatelessWidget {
  final SubjectModel subject;
  final String displayName;
  final IconData icon;
  final String questionsLabel;
  final String timeLabel;
  final bool isHighlighted;
  final bool hasSearch;
  final VoidCallback onTap;

  const _SubjectCard({
    required this.subject,
    required this.displayName,
    required this.icon,
    required this.questionsLabel,
    required this.timeLabel,
    required this.isHighlighted,
    required this.hasSearch,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // When searching: highlighted = full color, non-highlighted = faded
    final double cardOpacity = hasSearch && !isHighlighted ? 0.45 : 1.0;

    return AnimatedOpacity(
      opacity: cardOpacity,
      duration: const Duration(milliseconds: 200),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: isHighlighted && hasSearch
                ? Border.all(color: const Color(0xFF1E3C72), width: 2.5)
                : Border.all(color: Colors.transparent),
            boxShadow: [
              BoxShadow(
                color: isHighlighted && hasSearch
                    ? const Color(0xFF1E3C72).withValues(alpha: 0.25)
                    : Colors.black.withValues(alpha: 0.08),
                blurRadius: isHighlighted && hasSearch ? 14 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Top: Subject photo ────────────────────────────────────────────
              Expanded(
                flex: 5,
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  child: subject.imageUrl != null
                      ? Image.network(
                          subject.imageUrl!,
                          fit: BoxFit.cover,
                          loadingBuilder: (_, child, prog) {
                            if (prog == null) return child;
                            return Container(
                              color: const Color(0xFFF0F4FF),
                              child: Center(
                                child: Icon(icon,
                                    color: const Color(0xFF1E3C72)
                                        .withValues(alpha: 0.3),
                                    size: 32),
                              ),
                            );
                          },
                          errorBuilder: (_, __, ___) => Container(
                            color: const Color(0xFFF0F4FF),
                            child: Center(
                              child: Icon(icon,
                                  color: const Color(0xFF1E3C72), size: 32),
                            ),
                          ),
                        )
                      : Container(
                          color: const Color(0xFFF0F4FF),
                          child: Center(
                            child: Icon(icon,
                                color: const Color(0xFF1E3C72), size: 32),
                          ),
                        ),
                ),
              ),

              // ── Bottom: Subject info ──────────────────────────────────────────
              Expanded(
                flex: 5,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // Subject name
                      Text(
                        displayName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E3C72),
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Questions count
                      Row(
                        children: [
                          Icon(Icons.help_outline_rounded,
                              size: 13,
                              color: const Color(0xFF2A5298)
                                  .withValues(alpha: 0.8)),
                          const SizedBox(width: 4),
                          Text(
                            '30 $questionsLabel',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF2A5298),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Time
                      Row(
                        children: [
                          Icon(Icons.timer_outlined,
                              size: 13,
                              color: const Color(0xFF27AE60)
                                  .withValues(alpha: 0.9)),
                          const SizedBox(width: 4),
                          Text(
                            '$timeLabel 45:00',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF27AE60),
                              fontWeight: FontWeight.w600,
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
  }
}
