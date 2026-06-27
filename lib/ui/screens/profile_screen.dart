import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../logic/providers/auth_provider.dart';
import '../../logic/providers/theme_provider.dart';
import '../../data/models/student_model.dart';
import '../../logic/providers/quiz_provider.dart';
import '../../main.dart';
import 'results_screen.dart';

class ProfileScreen extends StatefulWidget {
  final bool isEmbedded;
  final String? initialLangCode;
  final ValueChanged<String>? onLanguageChanged;

  const ProfileScreen({
    super.key,
    this.isEmbedded = false,
    this.initialLangCode,
    this.onLanguageChanged,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late String _langCode;

  @override
  void initState() {
    super.initState();
    _langCode = widget.initialLangCode ?? 'en';
  }

  @override
  void didUpdateWidget(covariant ProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialLangCode != null && widget.initialLangCode != oldWidget.initialLangCode) {
      _langCode = widget.initialLangCode!;
    }
  }

  String _t(String key) {
    final translations = {
      'en': {
        'profile': 'profile',
        'dark_mode': 'Dark mode',
        'edit_profile': 'EDIT PROFILE',
        'personal_info': 'Personal Information',
        'email': 'Email',
        'phone': 'Phone',
        'academic_summary': 'Academic Summary',
        'school': 'School',
        'olevel_year': 'O-Level year',
        'quiz_result': 'Quiz result',
        'take_photo': 'Take Photo',
        'choose_photo': 'Choose Photo',
        'delete_photo': 'Delete Photo',
        'view_photo': 'View Photo',
        'select_avatar': 'Select Profile Avatar',
        'enter_url': 'Or Enter Image URL',
        'custom_url': 'Custom URL',
        'update': 'Update',
        'cancel': 'Cancel',
        'edit_profile_title': 'Edit Profile Details',
        'name': 'Name',
        'school_label': 'School Name',
        'grade_label': 'Grade',
        'save': 'Save',
        'logout': 'Logout',
      },
      'si': {
        'profile': 'Profile',
        'dark_mode': 'Dark mode',
        'edit_profile': 'PROFILE සංස්කරණය',
        'personal_info': 'පෞද්ගලික තොරතුරු',
        'email': 'විද්‍යුත් තැපෑල',
        'phone': 'දුරකතන අංකය',
        'academic_summary': 'අධ්‍යාපනික සාරාංශය',
        'school': 'පාසල',
        'olevel_year': 'ඕ/ල විභාග වසර',
        'quiz_result': 'ප්‍රශ්නාවලි ප්‍රතිඵල',
        'take_photo': 'පින්තූරයක් ගන්න',
        'choose_photo': 'පින්තූරයක් තෝරන්න',
        'delete_photo': 'පින්තූරය මකන්න',
        'view_photo': 'පින්තූරය බලන්න',
        'select_avatar': 'ප්‍රොෆයිල් පින්තූරයක් තෝරන්න',
        'enter_url': 'නැතහොත් වෙබ් ලිපිනයක් ඇතුළත් කරන්න',
        'custom_url': 'වෙබ් ලිපිනය',
        'update': 'යාවත්කාලීන කරන්න',
        'cancel': 'අවලංගු කරන්න',
        'edit_profile_title': 'Profile සංස්කරණය',
        'name': 'නම',
        'school_label': 'පාසලේ නම',
        'grade_label': 'ශ්‍රේණිය',
        'save': 'සුරකින්න',
        'logout': 'ගිණුමෙන් ඉවත් වන්න',
      },
      'ta': {
        'profile': 'Profile',
        'dark_mode': 'Dark mode',
        'edit_profile': 'சுயவிவரம் திருத்து',
        'personal_info': 'தனிப்பட்ட தகவல்',
        'email': 'மின்னஞ்சல்',
        'phone': 'தொலைபேசி',
        'academic_summary': 'கல்வி சுருக்கம்',
        'school': 'பள்ளி',
        'olevel_year': 'O/L தேர்வு ஆண்டு',
        'quiz_result': 'வினாடி வினா முடிவு',
        'take_photo': 'புகைப்படம் எடுங்கள்',
        'choose_photo': 'புகைப்படத்தைத் தேர்ந்தெடுக்கவும்',
        'delete_photo': 'புகைப்படத்தை நீக்கு',
        'view_photo': 'புகைப்படத்தைப் பார்க்கவும்',
        'select_avatar': 'சுயவிவரப் படத்தை மாற்றவும்',
        'enter_url': 'அல்லது URL ஐ உள்ளிடவும்',
        'custom_url': 'URL முகவரி',
        'update': 'புதுப்பி',
        'cancel': 'ரத்துசெய்',
        'edit_profile_title': 'சுயவிவரத்தைத் திருத்தவும்',
        'name': 'பெயர்',
        'school_label': 'பள்ளி பெயர்',
        'grade_label': 'வகுப்பு',
        'save': 'சேமி',
        'logout': 'வெளியேறு',
      }
    };
    return translations[_langCode]?[key] ?? key;
  }

  /// Picks an image from [source] (camera or gallery), converts it to
  /// Base64 and stores directly in Firestore — no Firebase Storage needed.
  Future<void> _pickAndUploadPhoto(
    BuildContext context,
    AuthProvider authProvider,
    StudentModel? student,
    ImageSource source,
  ) async {
    try {
      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 60,   // quality අඩු කළොත් file size අඩු වේ
        maxWidth: 600,       // max width 600px — Firestore limit සඳහා
      );

      if (pickedFile == null) return; // User cancelled
      if (!context.mounted) return;

      // Show processing indicator
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
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Processing...'),
                ],
              ),
            ),
          ),
        ),
      );

      // Read image bytes & convert to Base64
      final bytes = await pickedFile.readAsBytes();
      final base64String = 'data:image/jpeg;base64,${base64Encode(bytes)}';

      if (!context.mounted) return;
      Navigator.pop(context); // close progress dialog

      await authProvider.updateProfile(
        name: student?.name ?? '',
        school: student?.school ?? '',
        grade: student?.grade ?? '',
        oLevelYear: student?.oLevelYear ?? 2026,
        phone: student?.phone ?? '',
        photoUrl: base64String,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile photo updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        try { Navigator.of(context, rootNavigator: true).pop(); } catch (_) {}
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to process photo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
  Widget _buildMiniAvatar(StudentModel? student, {double size = 28}) {
    final photoUrl = student?.photoUrl ?? '';
    final provider = _resolveImageProvider(photoUrl);
    final initial = student?.name.isNotEmpty == true ? student!.name[0].toUpperCase() : 'S';
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: Colors.white24,
      backgroundImage: provider,
      child: provider == null
          ? Text(initial, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))
          : null,
    );
  }

  /// Large circular avatar for profile center
  Widget _buildMainAvatar(StudentModel? student, bool isDark, Color textColor) {
    final photoUrl = student?.photoUrl ?? '';
    final provider = _resolveImageProvider(photoUrl);
    final initial = student?.name.isNotEmpty == true ? student!.name[0].toUpperCase() : 'S';
    return CircleAvatar(
      radius: 54,
      backgroundColor: isDark ? const Color(0xFF2C2C2C) : Colors.grey.shade200,
      backgroundImage: provider,
      child: provider == null
          ? Text(initial, style: TextStyle(color: textColor, fontSize: 48, fontWeight: FontWeight.bold))
          : null,
    );
  }

  /// View Photo dialog — supports base64 data URIs and network URLs
  void _showViewPhotoDialogBase64(BuildContext context, String photoUrl) {
    final provider = _resolveImageProvider(photoUrl);
    if (provider == null) return;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.black87,
          insetPadding: const EdgeInsets.all(16),
          child: Stack(
            alignment: Alignment.topRight,
            children: [
              Center(
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image(
                      image: provider,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.broken_image,
                        color: Colors.white54,
                        size: 80,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, color: Colors.white, size: 22),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPhotoOptionsDialog(BuildContext context, AuthProvider authProvider, StudentModel? student) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 4),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera, color: Color(0xFF1E3C72)),
                title: Text(_t('take_photo')),
                onTap: () async {
                  Navigator.pop(ctx);
                  await _pickAndUploadPhoto(
                    context, authProvider, student, ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Color(0xFF1E3C72)),
                title: Text(_t('choose_photo')),
                onTap: () async {
                  Navigator.pop(ctx);
                  await _pickAndUploadPhoto(
                    context, authProvider, student, ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: Text(_t('delete_photo')),
                onTap: () async {
                  Navigator.pop(ctx);
                  await authProvider.updateProfile(
                    name: student?.name ?? '',
                    school: student?.school ?? '',
                    grade: student?.grade ?? '',
                    oLevelYear: student?.oLevelYear ?? 2026,
                    phone: student?.phone ?? '',
                    photoUrl: '',
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Profile photo deleted.'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.visibility, color: Colors.grey),
                title: Text(_t('view_photo')),
                onTap: () {
                  Navigator.pop(ctx);
                  if (student?.photoUrl.isNotEmpty == true) {
                    _showViewPhotoDialogBase64(context, student!.photoUrl);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No photo to view')),
                    );
                  }
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _showEditProfileDialog(BuildContext context, AuthProvider authProvider, StudentModel? student) {
    final nameController = TextEditingController(text: student?.name);
    final phoneController = TextEditingController(text: student?.phone);
    final schoolController = TextEditingController(text: student?.school);
    final gradeController = TextEditingController(text: student?.grade);
    final yearController = TextEditingController(text: '${student?.oLevelYear ?? 2026}');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(_t('edit_profile_title')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: _t('name')),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: phoneController,
                  decoration: InputDecoration(labelText: _t('phone')),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: schoolController,
                  decoration: InputDecoration(labelText: _t('school_label')),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: gradeController,
                  decoration: InputDecoration(labelText: _t('grade_label')),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: yearController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: _t('olevel_year')),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(_t('cancel')),
            ),
            ElevatedButton(
              onPressed: () async {
                final year = int.tryParse(yearController.text) ?? 2026;
                final success = await authProvider.updateProfile(
                  name: nameController.text.trim(),
                  school: schoolController.text.trim(),
                  grade: gradeController.text.trim(),
                  oLevelYear: year,
                  phone: phoneController.text.trim(),
                );
                if (success && context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: Text(_t('save')),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final student = authProvider.currentStudent;

    final isDark = themeProvider.isDarkMode;
    final cardBgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textPrimaryColor = isDark ? Colors.white : const Color(0xFF1E3C72);
    final textSecondaryColor = isDark ? Colors.white70 : Colors.black87;

    Widget bodyContent = SingleChildScrollView(
      child: Column(
        children: [
          // Custom Header matching wireframe
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1E3C72), Color(0xFF2A5298)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  const Icon(Icons.menu_rounded, color: Colors.white, size: 28),
                  const SizedBox(width: 8),
                  Text(
                    _t('profile'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  // Dark Mode Text + Toggle Switch
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
                        _t('dark_mode'),
                        style: const TextStyle(color: Colors.white, fontSize: 11),
                      ),
                      const SizedBox(width: 2),
                      Transform.scale(
                        scale: 0.7,
                        child: Switch(
                          value: isDark,
                          onChanged: (val) {
                            themeProvider.toggleTheme();
                          },
                          activeThumbColor: Colors.amber,
                          activeTrackColor: Colors.amber.withValues(alpha: 0.3),
                          inactiveThumbColor: Colors.white70,
                          inactiveTrackColor: Colors.white24,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 4),
                  // Top-Right profile icon
                  _buildMiniAvatar(student, size: 28),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                // Central Profile Avatar with camera/edit icon
                GestureDetector(
                  onTap: () => _showPhotoOptionsDialog(context, authProvider, student),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF1E3C72), width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: _buildMainAvatar(student, isDark, textPrimaryColor),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Color(0xFF1E3C72),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                // Large Username Display
                Text(
                  student?.name ?? 'Sathsarani Saubhagya',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 8),

                // EDIT PROFILE Capsule button
                SizedBox(
                  width: 170,
                  height: 38,
                  child: OutlinedButton(
                    onPressed: () => _showEditProfileDialog(context, authProvider, student),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: textPrimaryColor,
                      side: BorderSide(color: textPrimaryColor, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      _t('edit_profile'),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Personal Information Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardBgColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.person_outline_rounded, color: textPrimaryColor, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            _t('personal_info'),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: textPrimaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(
                              _t('email'),
                              style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500),
                            ),
                          ),
                          Expanded(
                            flex: 7,
                            child: Text(
                              student?.email ?? 'sathsarani.saubhagya2025@gmail.com',
                              style: TextStyle(fontSize: 13, color: textSecondaryColor, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 16, color: Colors.black12),
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(
                              _t('phone'),
                              style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500),
                            ),
                          ),
                          Expanded(
                            flex: 7,
                            child: Text(
                              student?.phone ?? '+94 74 0910955',
                              style: TextStyle(fontSize: 13, color: textSecondaryColor, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Academic Summary Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardBgColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.school_outlined, color: textPrimaryColor, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            _t('academic_summary'),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: textPrimaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(
                              _t('school'),
                              style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500),
                            ),
                          ),
                          Expanded(
                            flex: 7,
                            child: Text(
                              student?.school ?? 'A/Swarnapali Balika girls school',
                              style: TextStyle(fontSize: 13, color: textSecondaryColor, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 16, color: Colors.black12),
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(
                              _t('olevel_year'),
                              style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500),
                            ),
                          ),
                          Expanded(
                            flex: 7,
                            child: Text(
                              '${student?.oLevelYear ?? 2026}',
                              style: TextStyle(fontSize: 13, color: textSecondaryColor, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // QUIZ RESULT Capsule Button
                SizedBox(
                  width: 200,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (student?.uid != null) {
                        await context.read<QuizProvider>().loadHighestScores(student!.uid!);
                      }
                      if (context.mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ResultsScreen()),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E3C72),
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shadowColor: const Color(0xFF1E3C72).withValues(alpha: 0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: Text(
                      _t('quiz_result'),
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                // Logout Button
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: TextButton.icon(
                    onPressed: () async {
                      await authProvider.logout();
                      if (context.mounted) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const WelcomeOrLoginPage()),
                          (route) => false,
                        );
                      }
                    },
                    icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                    label: Text(_t('logout'), style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (!widget.isEmbedded) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF4F6FC),
        appBar: AppBar(
          title: Text(_t('profile'), style: const TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: isDark ? const Color(0xFF1E1E1E) : const Color(0xFF1E3C72),
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: bodyContent,
      );
    }
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF4F6FC),
      body: bodyContent,
    );
  }
}
