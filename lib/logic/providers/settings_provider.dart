import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  SharedPreferences? _prefs;

  // Language
  String _langCode = 'en';
  String get langCode => _langCode;

  // Notifications
  bool _vibrate = true;
  bool _silence = false;
  bool _generalNotifications = true;
  bool _hideNotifications = false;

  bool get vibrate => _vibrate;
  bool get silence => _silence;
  bool get generalNotifications => _generalNotifications;
  bool get hideNotifications => _hideNotifications;

  SettingsProvider() {
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    
    // Load saved settings
    _langCode = _prefs?.getString('langCode') ?? 'en';
    _vibrate = _prefs?.getBool('vibrate') ?? true;
    _silence = _prefs?.getBool('silence') ?? false;
    _generalNotifications = _prefs?.getBool('generalNotifications') ?? true;
    _hideNotifications = _prefs?.getBool('hideNotifications') ?? false;

    notifyListeners();
  }

  // --- Setters ---

  Future<void> setLanguage(String code) async {
    _langCode = code;
    await _prefs?.setString('langCode', code);
    notifyListeners();
  }

  Future<void> toggleVibrate(bool value) async {
    _vibrate = value;
    await _prefs?.setBool('vibrate', value);
    notifyListeners();
  }

  Future<void> toggleSilence(bool value) async {
    _silence = value;
    await _prefs?.setBool('silence', value);
    notifyListeners();
  }

  Future<void> toggleGeneralNotifications(bool value) async {
    _generalNotifications = value;
    await _prefs?.setBool('generalNotifications', value);
    notifyListeners();
  }

  Future<void> toggleHideNotifications(bool value) async {
    _hideNotifications = value;
    await _prefs?.setBool('hideNotifications', value);
    notifyListeners();
  }
}
