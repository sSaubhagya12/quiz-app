import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../logic/providers/auth_provider.dart';
import '../../logic/providers/theme_provider.dart';
import '../../data/models/student_model.dart';
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

  void _showPhotoOptionsDialog(BuildContext context, AuthProvider authProvider, StudentModel? student) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera, color: Color(0xFF1E3C72)),
                title: Text(_t('take_photo')),
                onTap: () {
                  Navigator.pop(context);
                  _showPresetAvatarsDialog(context, authProvider);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Color(0xFF1E3C72)),
                title: Text(_t('choose_photo')),
                onTap: () {
                  Navigator.pop(context);
                  _showPresetAvatarsDialog(context, authProvider);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: Text(_t('delete_photo')),
                onTap: () async {
                  Navigator.pop(context);
                  await authProvider.updateProfile(
                    name: student?.name ?? '',
                    school: student?.school ?? '',
                    grade: student?.grade ?? '',
                    oLevelYear: student?.oLevelYear ?? 2026,
                    phone: student?.phone ?? '',
                    photoUrl: '', // remove photo
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.visibility, color: Colors.grey),
                title: Text(_t('view_photo')),
                onTap: () {
                  Navigator.pop(context);
                  if (student?.photoUrl.isNotEmpty == true) {
                    _showViewPhotoDialog(context, student!.photoUrl);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No photo to view')),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPresetAvatarsDialog(BuildContext context, AuthProvider authProvider) {
    final student = authProvider.currentStudent;
    final customUrlController = TextEditingController();

    final presets = [
      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&q=80',
      'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&q=80',
      'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&q=80',
      'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200&q=80',
      'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=200&q=80',
      'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=200&q=80',
    ];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(_t('select_avatar')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: double.maxFinite,
                  height: 160,
                  child: GridView.builder(
                    itemCount: presets.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () async {
                          Navigator.pop(context);
                          await authProvider.updateProfile(
                            name: student?.name ?? '',
                            school: student?.school ?? '',
                            grade: student?.grade ?? '',
                            oLevelYear: student?.oLevelYear ?? 2026,
                            phone: student?.phone ?? '',
                            photoUrl: presets[index],
                          );
                        },
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(presets[index]),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Text(_t('enter_url'), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 6),
                TextField(
                  controller: customUrlController,
                  decoration: InputDecoration(
                    hintText: 'https://example.com/avatar.jpg',
                    labelText: _t('custom_url'),
                    border: const OutlineInputBorder(),
                  ),
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
                if (customUrlController.text.trim().isNotEmpty) {
                  Navigator.pop(context);
                  await authProvider.updateProfile(
                    name: student?.name ?? '',
                    school: student?.school ?? '',
                    grade: student?.grade ?? '',
                    oLevelYear: student?.oLevelYear ?? 2026,
                    phone: student?.phone ?? '',
                    photoUrl: customUrlController.text.trim(),
                  );
                }
              },
              child: Text(_t('update')),
            ),
          ],
         );
       },
     );
  }

  void _showViewPhotoDialog(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Stack(
            alignment: Alignment.topRight,
            children: [
              InteractiveViewer(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(url, fit: BoxFit.contain),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
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
                  // ENG Dropdown (Sinhala/Tamil support)
                  PopupMenuButton<String>(
                    onSelected: (lang) {
                      setState(() {
                        _langCode = lang;
                      });
                      if (widget.onLanguageChanged != null) {
                        widget.onLanguageChanged!(lang);
                      }
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(value: 'si', child: Text('සිංහල')),
                      const PopupMenuItem<String>(value: 'en', child: Text('English')),
                      const PopupMenuItem<String>(value: 'ta', child: Text('Tamil (sri lanka)')),
                    ],
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _langCode == 'en' ? 'ENG' : _langCode == 'si' ? 'සිංහල' : 'தமிழ்',
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                          const Icon(Icons.arrow_drop_down, color: Colors.white, size: 16),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
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
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: Colors.white24,
                    backgroundImage: student?.photoUrl.isNotEmpty == true
                        ? NetworkImage(student!.photoUrl)
                        : null,
                    child: student?.photoUrl.isNotEmpty != true
                        ? Text(
                            student?.name.isNotEmpty == true ? student!.name[0].toUpperCase() : 'S',
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          )
                        : null,
                  ),
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
                        child: CircleAvatar(
                          radius: 54,
                          backgroundColor: isDark ? const Color(0xFF2C2C2C) : Colors.grey.shade200,
                          backgroundImage: student?.photoUrl.isNotEmpty == true
                              ? NetworkImage(student!.photoUrl)
                              : null,
                          child: student?.photoUrl.isNotEmpty != true
                              ? Text(
                                  student?.name.isNotEmpty == true ? student!.name[0].toUpperCase() : 'S',
                                  style: TextStyle(color: textPrimaryColor, fontSize: 48, fontWeight: FontWeight.bold),
                                )
                              : null,
                        ),
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
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ResultsScreen()),
                      );
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
                        Navigator.of(context).popUntil((route) => route.isFirst);
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
        body: bodyContent,
      );
    }
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF4F6FC),
      body: bodyContent,
    );
  }
}
