import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:screenshot/screenshot.dart';
import '../../logic/providers/auth_provider.dart';
import '../../logic/providers/subject_provider.dart';
import '../../logic/providers/quiz_provider.dart';
import '../../logic/providers/theme_provider.dart';
import '../../logic/providers/settings_provider.dart';
import '../../data/firebase/firebase_service.dart';
import '../../data/models/subject_model.dart';
import 'choose_subject_screen.dart';
import 'profile_screen.dart';
import 'quiz_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Load subjects and highest scores when home screen is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SubjectProvider>().loadSubjects();
      final authProvider = context.read<AuthProvider>();
      if (authProvider.currentStudent?.uid != null) {
        context
            .read<QuizProvider>()
            .loadHighestScores(authProvider.currentStudent!.uid!);
      }
    });
  }

  static String _drawerLabel(String key, String lang) {
    const labels = {
      'en': {
        'account': 'Account',
        'notifications': 'Notification',
        'darkmode': 'Dark mode',
        'language': 'Language',
        'help': 'Help and support',
        'about': 'About',
        'logout': 'Log out',
        'delete': 'Delete Account',
      },
      'si': {
        'account': 'ගිණුම',
        'notifications': 'දැනුම්දීම්',
        'darkmode': 'දාර්ක් මෝඩ්',
        'language': 'භාෂාව',
        'help': 'උදවු සහ සහයෝගය',
        'about': 'ගැන',
        'logout': 'අවහර වීම',
        'delete': 'ගිණුම මකාදැමීම',
      },
      'ta': {
        'account': 'கணக்கு',
        'notifications': 'அறிவிப்புகள்',
        'darkmode': 'இருள் மோட்',
        'language': 'மொழி',
        'help': 'உதவி & ஆதரவு',
        'about': 'பற்றி',
        'logout': 'வெளியேறு',
        'delete': 'கணக்கை நீக்கு',
      },
    };
    return labels[lang]?[key] ?? labels['en']![key]!;
  }

  /// Decodes a Base64 or network image into an ImageProvider
  ImageProvider? _resolveImageProvider(String photoUrl) {
    if (photoUrl.isEmpty) return null;
    if (photoUrl.startsWith('data:image')) {
      try {
        final base64Data = photoUrl.split(',').last;
        return MemoryImage(base64Decode(base64Data));
      } catch (_) {
        return null;
      }
    }
    return NetworkImage(photoUrl);
  }

  /// Small circular avatar for header top-right
  Widget _buildMiniAvatar(dynamic student, {double size = 32}) {
    final photoUrl = student?.photoUrl ?? '';
    final provider = _resolveImageProvider(photoUrl);
    final initial = student?.name?.isNotEmpty == true
        ? student!.name[0].toUpperCase()
        : 'S';
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: Colors.white24,
      backgroundImage: provider,
      child: provider == null
          ? Text(initial,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold))
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final settingsProvider = context.watch<SettingsProvider>();
    final student = authProvider.currentStudent;
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    final List<Widget> pages = [
      _HomeDashboard(
        student: student,
        langCode: settingsProvider.langCode,
        onLanguageChanged: (code) => settingsProvider.setLanguage(code),
        onViewAllSubjects: () => setState(() => _selectedIndex = 1),
        isDark: isDark,
      ),
      ChooseSubjectScreen(
        isEmbedded: true,
        initialLangCode: settingsProvider.langCode,
        onLanguageChanged: (code) => settingsProvider.setLanguage(code),
      ),
      ProfileScreen(
        isEmbedded: true,
        initialLangCode: settingsProvider.langCode,
        onLanguageChanged: (code) => settingsProvider.setLanguage(code),
      ),
    ];

    final iconCol = isDark ? Colors.white70 : const Color(0xFF1E3C72);
    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF121212) : const Color(0xFFF4F6FC),
      appBar: AppBar(
        title: const Text('Quiz O-Level',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor:
            isDark ? const Color(0xFF1E1E1E) : const Color(0xFF1E3C72),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_selectedIndex == 2)
            // Dark Mode Switch for Profile page
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isDark ? Icons.dark_mode : Icons.dark_mode_outlined,
                  color: Colors.white,
                  size: 15,
                ),
                const SizedBox(width: 4),
                Text(
                  _drawerLabel('darkmode', settingsProvider.langCode),
                  style: const TextStyle(color: Colors.white, fontSize: 11),
                ),
                Transform.scale(
                  scale: 0.7,
                  child: Switch(
                    value: isDark,
                    onChanged: (_) => themeProvider.toggleTheme(),
                    activeThumbColor: Colors.amber,
                    activeTrackColor: Colors.amber.withValues(alpha: 0.3),
                    inactiveThumbColor: Colors.white70,
                    inactiveTrackColor: Colors.white24,
                  ),
                ),
              ],
            ),
          if (_selectedIndex != 2)
            // Language Picker for Home & Subject
            PopupMenuButton<String>(
              onSelected: (code) => settingsProvider.setLanguage(code),
              icon: const Icon(Icons.language, color: Colors.white),
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'si', child: Text('සිංහල (Sinhala)')),
                PopupMenuItem(value: 'en', child: Text('English')),
                PopupMenuItem(value: 'ta', child: Text('தமிழ் (Tamil)')),
              ],
            ),
          // Profile Icon (always visible, switches to Profile tab)
          IconButton(
            icon: const Icon(Icons.person_outline_rounded, color: Colors.white),
            onPressed: () {
              if (_selectedIndex != 2) {
                setState(() => _selectedIndex = 2);
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: Drawer(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color:
                    isDark ? const Color(0xFF121212) : const Color(0xFF1E3C72),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(Icons.school, size: 50, color: Colors.white),
                      _buildMiniAvatar(student),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('EduQuiz O-Level',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(authProvider.currentStudent?.email ?? '',
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.person_outline, color: iconCol),
              title: Text(_drawerLabel('account', settingsProvider.langCode)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            const ProfileScreen(isEmbedded: false)));
              },
            ),
            ListTile(
              leading: Icon(Icons.notifications_none_outlined, color: iconCol),
              title: Text(
                  _drawerLabel('notifications', settingsProvider.langCode)),
              onTap: () {
                Navigator.pop(context);
                SettingsScreen.showNotificationSettings(
                    context, settingsProvider.langCode);
              },
            ),
            ListTile(
              leading: Icon(Icons.dark_mode_outlined, color: iconCol),
              title: Text(_drawerLabel('darkmode', settingsProvider.langCode)),
              trailing: Switch(
                value: themeProvider.isDarkMode,
                onChanged: (_) => themeProvider.toggleTheme(),
              ),
              onTap: () => themeProvider.toggleTheme(),
            ),
            ListTile(
              leading: Icon(Icons.language, color: iconCol),
              title: Text(_drawerLabel('language', settingsProvider.langCode)),
              onTap: () {
                Navigator.pop(context);
                SettingsScreen.showLanguageSettings(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.headset_mic_outlined, color: iconCol),
              title: Text(_drawerLabel('help', settingsProvider.langCode)),
              onTap: () {
                Navigator.pop(context);
                SettingsScreen.showHelpSupport(
                    context, settingsProvider.langCode);
              },
            ),
            ListTile(
              leading: Icon(Icons.info_outline, color: iconCol),
              title: Text(_drawerLabel('about', settingsProvider.langCode)),
              onTap: () {
                Navigator.pop(context);
                showAboutDialog(
                  context: context,
                  applicationName: 'EduQuiz O-Level',
                  applicationVersion: '1.0.0',
                  applicationIcon: const Icon(Icons.school,
                      size: 50, color: Color(0xFF1E3C72)),
                  applicationLegalese: '© 2026 EduQuiz. All rights reserved.',
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.orange),
              title: Text(_drawerLabel('logout', settingsProvider.langCode),
                  style: const TextStyle(
                      color: Colors.orange, fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pop(context);
                SettingsScreen.showLogoutDialog(
                    context, settingsProvider.langCode);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: Text(_drawerLabel('delete', settingsProvider.langCode),
                  style: const TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pop(context);
                SettingsScreen.showDeleteAccountDialog(
                    context, settingsProvider.langCode);
              },
            ),
          ],
        ),
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        selectedItemColor:
            isDark ? Colors.lightBlueAccent : const Color(0xFF1E3C72),
        unselectedItemColor: Colors.grey,
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: 10,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.menu_book_rounded), label: 'Subjects'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded), label: 'Profile'),
        ],
      ),
    );
  }
}

class _HomeDashboard extends StatefulWidget {
  final dynamic student;
  final String langCode;
  final ValueChanged<String> onLanguageChanged;
  final VoidCallback onViewAllSubjects;
  final bool isDark;

  const _HomeDashboard({
    required this.student,
    required this.langCode,
    required this.onLanguageChanged,
    required this.onViewAllSubjects,
    required this.isDark,
  });

  @override
  State<_HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<_HomeDashboard> {
  bool _showAllContinueLearning = false;

  // =============================================
  // PDF Generation  –  සිංහල font support via Image rendering
  // =============================================
  Future<void> _generateAndDownloadPdf(
      BuildContext context, SubjectModel subject, String displayName) async {
    try {
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const Center(
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Color(0xFF1E3C72)),
                    SizedBox(height: 16),
                    Text('PDF සකස් කරමින්...\nGenerating PDF...',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ),
        );
      }

      final questions =
          await FirebaseService.instance.getQuestionsBySubject(subject.id!);

      if (!context.mounted) return;
      Navigator.pop(context); // close loading dialog

      if (questions.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No questions found for this subject.'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Load English font for header only
      final ttf = await PdfGoogleFonts.abhayaLibreRegular();
      final ttfBold = await PdfGoogleFonts.abhayaLibreBold();

      // Pre-render all questions to images using ScreenshotController
      final sc = ScreenshotController();
      final questionImages = <pw.Image>[];

      // Re-show loading dialogue with progress context if needed, but doing it fast
      for (int i = 0; i < questions.length; i++) {
        final q = questions[i];
        final optionLabels = ['A', 'B', 'C', 'D'];
        final options = [q.option1, q.option2, q.option3, q.option4];

        final widget = Directionality(
          textDirection: TextDirection.ltr,
          child: Material(
            color: Colors.white,
            child: Container(
              width: 320,
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          color: Color(0xFF1E3C72),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${i + 1}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          q.questionText,
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ...options.asMap().entries.map((opt) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 28, bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              optionLabels[opt.key],
                              style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              opt.value,
                              style: const TextStyle(
                                  fontSize: 11, color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 4),
                  const Divider(color: Colors.grey, thickness: 0.5, height: 1),
                ],
              ),
            ),
          ),
        );

        final imageBytes = await sc.captureFromWidget(widget, delay: Duration.zero);
        questionImages.add(pw.Image(pw.MemoryImage(imageBytes)));
      }

      // ── Build PDF ──────────────────────────────────────────────────
      final pdf = pw.Document();

      const questionsPerPage = 6;
      final pageCount = (questions.length / questionsPerPage).ceil();

      for (int page = 0; page < pageCount; page++) {
        final start = page * questionsPerPage;
        final end = (start + questionsPerPage).clamp(0, questions.length);
        final pageImages = questionImages.sublist(start, end);

        final col1 = <pw.Widget>[];
        final col2 = <pw.Widget>[];
        for (int i = 0; i < pageImages.length; i++) {
          if (i % 2 == 0) {
            col1.add(pageImages[i]);
          } else {
            col2.add(pageImages[i]);
          }
        }

        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            margin: const pw.EdgeInsets.symmetric(horizontal: 28, vertical: 28),
            build: (pw.Context ctx) {
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // ── Header ──
                  if (page == 0) ...[
                    pw.Container(
                      width: double.infinity,
                      padding: const pw.EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: pw.BoxDecoration(
                        color: const PdfColor.fromInt(0xFF1E3C72),
                        borderRadius: pw.BorderRadius.circular(8),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'EduQuiz O-Level',
                            style: pw.TextStyle(
                              font: ttf,
                              color: PdfColors.white,
                              fontSize: 10,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            displayName,
                            style: pw.TextStyle(
                              font: ttfBold,
                              color: PdfColors.white,
                              fontSize: 20,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            '${questions.length} Questions  •  Time Limit: 45 minutes',
                            style: pw.TextStyle(
                              font: ttf,
                              color: PdfColors.grey300,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    pw.SizedBox(height: 16),
                  ],

                  // ── 2-Column Questions Images ──
                  pw.Expanded(
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: col1,
                          ),
                        ),
                        pw.SizedBox(width: 16),
                        pw.Container(width: 0.5, color: PdfColors.grey300),
                        pw.SizedBox(width: 16),
                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: col2,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Footer ──
                  pw.Divider(color: PdfColors.grey300, thickness: 0.5),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'EduQuiz O-Level – $displayName',
                        style: pw.TextStyle(
                            font: ttf, fontSize: 9, color: PdfColors.grey),
                      ),
                      pw.Text(
                        'Page ${page + 1} / $pageCount',
                        style: pw.TextStyle(
                            font: ttf, fontSize: 9, color: PdfColors.grey),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        );
      }

      // ── Print / Save ──
      if (!context.mounted) return;
      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: '${displayName.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}_Quiz.pdf',
      );
    } catch (e) {
      if (context.mounted) {
        try {
          Navigator.of(context, rootNavigator: true).pop();
        } catch (_) {}
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF generation failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() {});
    }
  }

  // Show action dialog when subject card is tapped
  void _showSubjectActionDialog(BuildContext context, SubjectModel subject,
      String displayName, String studentId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: EdgeInsets.zero,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1E3C72), Color(0xFF2A5298)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'What would you like to do?',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Start Quiz Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => QuizScreen(
                          subject: subject,
                          studentId: studentId,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.play_circle_outline_rounded),
                  label: const Text('Start Quiz',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3C72),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ),
            // Download PDF Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _generateAndDownloadPdf(context, subject, displayName);
                  },
                  icon: const Icon(Icons.picture_as_pdf_rounded,
                      color: Color(0xFFE74C3C)),
                  label: const Text(
                    'Download Quiz PDF',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE74C3C)),
                  ),
                  style: OutlinedButton.styleFrom(
                    side:
                        const BorderSide(color: Color(0xFFE74C3C), width: 1.5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  // Forward all getters to widget for convenience
  String get langCode => widget.langCode;
  ValueChanged<String> get onLanguageChanged => widget.onLanguageChanged;
  VoidCallback get onViewAllSubjects => widget.onViewAllSubjects;
  bool get isDark => widget.isDark;

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

  @override
  Widget build(BuildContext context) {
    final subjectProvider = context.watch<SubjectProvider>();
    final quizProvider = context.watch<QuizProvider>();
    final authProvider = context.read<AuthProvider>();

    final hasOngoingQuiz =
        quizProvider.currentSubject != null && !quizProvider.isQuizCompleted;
    final subjects = subjectProvider.subjects;
    final highestScores = quizProvider.highestScores;

    // Dark mode colors
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1E3C72);

    // Continue Learning: always use all subjects
    final allContinueLearning = subjects;
    // Show first 5 initially; expand to all when _showAllContinueLearning is true
    const int initialCount = 5;
    final displayedContinue = _showAllContinueLearning
        ? allContinueLearning
        : allContinueLearning.take(initialCount).toList();
    final hasMore = allContinueLearning.length > initialCount;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

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
                      color: (hasOngoingQuiz
                              ? const Color(0xFFEB5757)
                              : const Color(0xFF1E3C72))
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
                            child: const Icon(Icons.help_outline_rounded,
                                color: Colors.white, size: 28),
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
                          const Icon(Icons.arrow_forward_ios_rounded,
                              color: Colors.white, size: 16),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 24),

            // 3. Continue Learning Section
            Text(
              _t('continue_learning'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            SizedBox(
              height: 160,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                // show more card only when not expanded AND there are hidden subjects
                itemCount: displayedContinue.length +
                    ((!_showAllContinueLearning && hasMore) ? 1 : 0),
                itemBuilder: (context, index) {
                  if (!_showAllContinueLearning &&
                      hasMore &&
                      index == displayedContinue.length) {
                    // "more" card — expands inline, no navigation
                    return Container(
                      width: 100,
                      margin: const EdgeInsets.only(right: 8, bottom: 8),
                      child: InkWell(
                        onTap: () =>
                            setState(() => _showAllContinueLearning = true),
                        borderRadius: BorderRadius.circular(14),
                        child: Card(
                          color: cardBg,
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
                                  color: const Color(0xFF1E3C72)
                                      .withValues(alpha: 0.1),
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
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  final subject = displayedContinue[index];
                  final highestResult = highestScores[subject.id];
                  final double calculatedRate = highestResult != null
                      ? (highestResult.score /
                              (highestResult.totalQuestions == 0
                                  ? 1
                                  : highestResult.totalQuestions))
                          .clamp(0.0, 1.0)
                      : 0.0;

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
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return Container(
                                          color: Colors.grey.shade100,
                                          child: const Center(
                                            child: SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(
                                                  strokeWidth: 2),
                                            ),
                                          ),
                                        );
                                      },
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Container(
                                        color: const Color(0xFF1E3C72)
                                            .withValues(alpha: 0.05),
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          child: LinearProgressIndicator(
                                            value: calculatedRate,
                                            minHeight: 5,
                                            backgroundColor:
                                                Colors.grey.shade200,
                                            color: const Color(0xFF27AE60),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${(calculatedRate * 100).toStringAsFixed(0)}% ${_t('complete')}',
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
                  child: Text('Loading subjects...',
                      style: TextStyle(color: Colors.grey)),
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
                          _showSubjectActionDialog(
                            context,
                            subject,
                            _getSubjectDisplayName(subject.name),
                            authProvider.currentStudent!.uid!,
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
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  color: Colors.grey.shade100,
                                  child: const Center(
                                    child: SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                color: const Color(0xFF1E3C72)
                                    .withValues(alpha: 0.05),
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
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 6),
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
