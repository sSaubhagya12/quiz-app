import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../logic/providers/auth_provider.dart';
import '../../logic/providers/theme_provider.dart';
import '../../logic/providers/settings_provider.dart';
import 'profile_screen.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  final String? initialSection;
  const SettingsScreen({super.key, this.initialSection});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  // ===================== Translations =====================
  static const _labels = {
    'en': {
      'settings': 'Settings',
      'account': 'Account',
      'notification': 'Notification',
      'darkmode': 'Dark mode',
      'language': 'Language',
      'help': 'Help and support',
      'about': 'About',
      'logout': 'Log out',
      'delete': 'Delete Account',
      'general_notif': 'General Notifications',
      'vibrate': 'Vibrate',
      'silence': 'Silence',
      'hide_notif': 'Hide Notifications',
      'close': 'Close',
      'cancel': 'Cancel',
      'logout_confirm': 'Are you sure you want to log out?',
      'delete_warning':
          'Warning: This action is permanent and will delete all your scores and progress. '
          'To verify it\'s you, please enter your email and password.',
      'email': 'Email',
      'password': 'Password',
      'delete_permanently': 'Delete Permanently',
    },
    'si': {
      'settings': 'සැකසුම්',
      'account': 'ගිණුම',
      'notification': 'දැනුම්දීම්',
      'darkmode': 'දාර්ක් මෝඩ්',
      'language': 'භාෂාව',
      'help': 'උදවු සහ සහයෝගය',
      'about': 'ගැන',
      'logout': 'අවහර වීම',
      'delete': 'ගිණුම මකාදැමීම',
      'general_notif': 'සාමාන්‍ය දැනුම්දීම්',
      'vibrate': 'කම්පනය',
      'silence': 'නිශ්ශබ්ද',
      'hide_notif': 'දැනුම්දීම් සඟවන්න',
      'close': 'වසන්න',
      'cancel': 'අවලංගු',
      'logout_confirm': 'ඔබ ඉවත් වීමට අදහස් කරනවාද?',
      'delete_warning':
          'අවවාදය: මෙය සදහටම ඔබගේ සියලුම ලකුණු සහ ප්‍රගතිය මකා දමයි. '
          'ඔබ බව තහවුරු කිරීමට ඊමේල් සහ මුරපදය ඇතුළු කරන්න.',
      'email': 'ඊමේල්',
      'password': 'මුරපදය',
      'delete_permanently': 'සදහටම මකන්න',
    },
    'ta': {
      'settings': 'அமைப்புகள்',
      'account': 'கணக்கு',
      'notification': 'அறிவிப்புகள்',
      'darkmode': 'இருள் மோட்',
      'language': 'மொழி',
      'help': 'உதவி & ஆதரவு',
      'about': 'பற்றி',
      'logout': 'வெளியேறு',
      'delete': 'கணக்கை நீக்கு',
      'general_notif': 'பொது அறிவிப்புகள்',
      'vibrate': 'அதிர்வு',
      'silence': 'அமைதி',
      'hide_notif': 'அறிவிப்புகளை மறை',
      'close': 'மூடு',
      'cancel': 'ரத்து',
      'logout_confirm': 'நீங்கள் வெளியேற விரும்புகிறீர்களா?',
      'delete_warning':
          'எச்சரிக்கை: இந்த செயல் நிரந்தரமானது மற்றும் உங்கள் அனைத்து மதிப்பெண்களையும் நீக்கும். '
          'உங்களை சரிபார்க்க மின்னஞ்சல் மற்றும் கடவுச்சொல் உள்ளிடுக.',
      'email': 'மின்னஞ்சல்',
      'password': 'கடவுச்சொல்',
      'delete_permanently': 'நிரந்தரமாக நீக்கு',
    },
  };

  String _t(String key, String lang) {
    return _labels[lang]?[key] ?? _labels['en']![key] ?? key;
  }

  // ===================== Dialogs =====================

  void _showNotificationSettings(BuildContext context, String lang) {
    showDialog(
      context: context,
      builder: (ctx) => Consumer<SettingsProvider>(
        builder: (context, settings, _) => AlertDialog(
          title: Text(_t('notification', lang)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                title: Text(_t('general_notif', lang)),
                value: settings.generalNotifications,
                onChanged: (val) => settings.toggleGeneralNotifications(val),
              ),
              SwitchListTile(
                title: Text(_t('vibrate', lang)),
                value: settings.vibrate,
                onChanged: (val) => settings.toggleVibrate(val),
              ),
              SwitchListTile(
                title: Text(_t('silence', lang)),
                value: settings.silence,
                onChanged: (val) => settings.toggleSilence(val),
              ),
              SwitchListTile(
                title: Text(_t('hide_notif', lang)),
                value: settings.hideNotifications,
                onChanged: (val) => settings.toggleHideNotifications(val),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(_t('close', lang)),
            )
          ],
        ),
      ),
    );
  }

  void _showLanguageSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          void pickLang(String code) {
            settings.setLanguage(code);
            Navigator.pop(ctx);
          }
          return AlertDialog(
            title: Text(_t('language', settings.langCode)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text('English'),
                  leading: Radio<String>(
                    value: 'en',
                    groupValue: settings.langCode,
                    onChanged: (v) => pickLang(v!),
                  ),
                  onTap: () => pickLang('en'),
                ),
                ListTile(
                  title: const Text('සිංහල'),
                  leading: Radio<String>(
                    value: 'si',
                    groupValue: settings.langCode,
                    onChanged: (v) => pickLang(v!),
                  ),
                  onTap: () => pickLang('si'),
                ),
                ListTile(
                  title: const Text('தமிழ்'),
                  leading: Radio<String>(
                    value: 'ta',
                    groupValue: settings.langCode,
                    onChanged: (v) => pickLang(v!),
                  ),
                  onTap: () => pickLang('ta'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showHelpSupport(BuildContext context, String lang) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(_t('help', lang)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'For any inquiries or issues regarding the EduQuiz O-Level app, please contact us at:',
            ),
            SizedBox(height: 12),
            Row(children: [
              Icon(Icons.email_outlined, size: 18, color: Color(0xFF1E3C72)),
              SizedBox(width: 8),
              Flexible(child: SelectableText('sathsaranisaubhagya2025@gmail.com', style: TextStyle(fontWeight: FontWeight.bold))),
            ]),
            SizedBox(height: 8),
            Row(children: [
              Icon(Icons.phone_outlined, size: 18, color: Color(0xFF1E3C72)),
              SizedBox(width: 8),
              SelectableText('+94740910955', style: TextStyle(fontWeight: FontWeight.bold)),
            ]),
            SizedBox(height: 12),
            Text('We are here to help you succeed in your O-Levels! 🎓'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(_labels['en']!['close']!),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, String lang) {
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    bool isDeleting = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(_t('delete', lang), style: const TextStyle(color: Colors.red)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_t('delete_warning', lang), style: const TextStyle(fontSize: 13)),
              const SizedBox(height: 16),
              TextField(
                controller: emailCtrl,
                decoration: InputDecoration(labelText: _t('email', lang), border: const OutlineInputBorder()),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passCtrl,
                decoration: InputDecoration(labelText: _t('password', lang), border: const OutlineInputBorder()),
                obscureText: true,
              ),
              if (isDeleting) ...[
                const SizedBox(height: 16),
                const Center(child: CircularProgressIndicator()),
              ],
            ],
          ),
          actions: [
            if (!isDeleting)
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(_t('cancel', lang)),
              ),
            if (!isDeleting)
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                onPressed: () async {
                  if (emailCtrl.text.isEmpty || passCtrl.text.isEmpty) return;
                  setState(() => isDeleting = true);
                  final messenger = ScaffoldMessenger.of(context);
                  final navigator = Navigator.of(context);
                  try {
                    await context.read<AuthProvider>().deleteAccount(emailCtrl.text.trim(), passCtrl.text);
                    navigator.pop();
                    navigator.pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  } catch (e) {
                    setState(() => isDeleting = false);
                    messenger.showSnackBar(
                      SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
                    );
                  }
                },
                child: Text(_t('delete_permanently', lang)),
              ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, String lang) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(_t('logout', lang)),
        content: Text(_t('logout_confirm', lang)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(_t('cancel', lang)),
          ),
          ElevatedButton(
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              if (context.mounted) {
                Navigator.pop(ctx);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: Text(_t('logout', lang)),
          ),
        ],
      ),
    );
  }

  // ===================== Build =====================

  @override
  void initState() {
    super.initState();
    // Trigger dialog after first frame if initialSection is given
    if (widget.initialSection != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _triggerInitial());
    }
  }

  void _triggerInitial() {
    final lang = context.read<SettingsProvider>().langCode;
    switch (widget.initialSection) {
      case 'notification': _showNotificationSettings(context, lang); break;
      case 'language':     _showLanguageSettings(context); break;
      case 'help':         _showHelpSupport(context, lang); break;
      case 'logout':       _showLogoutDialog(context, lang); break;
      case 'delete':       _showDeleteAccountDialog(context, lang); break;
      case 'about':
        showAboutDialog(
          context: context,
          applicationName: 'EduQuiz O-Level',
          applicationVersion: '1.0.0',
          applicationIcon: const Icon(Icons.school, size: 50, color: Color(0xFF1E3C72)),
          applicationLegalese: '© 2026 EduQuiz. All rights reserved.',
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final settings = context.watch<SettingsProvider>();
    final lang = settings.langCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(_t('settings', lang), style: const TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SettingsItem(
            icon: Icons.person_outline,
            title: _t('account', lang),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen(isEmbedded: false)),
              );
            },
          ),
          _SettingsItem(
            icon: Icons.notifications_none_outlined,
            title: _t('notification', lang),
            onTap: () => _showNotificationSettings(context, lang),
          ),
          _SettingsItem(
            icon: Icons.dark_mode_outlined,
            title: _t('darkmode', lang),
            trailing: Switch(
              value: themeProvider.isDarkMode,
              onChanged: (val) => themeProvider.toggleTheme(),
            ),
            onTap: () => themeProvider.toggleTheme(),
          ),
          _SettingsItem(
            icon: Icons.language,
            title: _t('language', lang),
            onTap: () => _showLanguageSettings(context),
          ),
          _SettingsItem(
            icon: Icons.headset_mic_outlined,
            title: _t('help', lang),
            onTap: () => _showHelpSupport(context, lang),
          ),
          _SettingsItem(
            icon: Icons.info_outline,
            title: _t('about', lang),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'EduQuiz O-Level',
                applicationVersion: '1.0.0',
                applicationIcon: const Icon(Icons.school, size: 50, color: Color(0xFF1E3C72)),
                applicationLegalese: '© 2026 EduQuiz. All rights reserved.',
              );
            },
          ),
          const SizedBox(height: 20),
          _SettingsItem(
            icon: Icons.logout,
            title: _t('logout', lang),
            onTap: () => _showLogoutDialog(context, lang),
          ),
          _SettingsItem(
            icon: Icons.delete_outline,
            title: _t('delete', lang),
            titleColor: Colors.red,
            iconColor: Colors.red,
            onTap: () => _showDeleteAccountDialog(context, lang),
          ),
        ],
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Widget? trailing;
  final Color? titleColor;
  final Color? iconColor;

  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.trailing,
    this.titleColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: ListTile(
        leading: Icon(icon, color: iconColor ?? Theme.of(context).colorScheme.primary),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.w600, color: titleColor),
        ),
        trailing: trailing ?? const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
