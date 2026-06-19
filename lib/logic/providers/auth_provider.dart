import 'package:flutter/material.dart';
import '../../data/firebase/firebase_service.dart';
import '../../data/models/student_model.dart';

// සිසුන්ගේ Authentication සහ Profile කටයුතු පාලනය කරන State Management පන්තිය
class AuthProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService.instance;

  StudentModel? _currentStudent; // දැනට ලොග් වී සිටින සිසුවාගේ තොරතුරු
  bool _isLoading = false;      // Loading අවස්ථාවන් (Progress Indicator)
  String? _errorMessage;         // දෝෂ පණිවිඩ

  // Getters
  StudentModel? get currentStudent => _currentStudent;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentStudent != null;

  // ==========================================
  // 1. STUDENT LOGIN LOGIC (Firebase Auth)
  // ==========================================
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      StudentModel? student;

      // Fields හිස් නම් demo account ලෙස login කිරීම
      if (email.trim().isEmpty && password.isEmpty) {
        student = await _firebaseService.loginWithDemoAccount();
      } else {
        student = await _firebaseService.loginStudent(email, password);
      }

      if (student != null) {
        _currentStudent = student;
        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        _setError("Login කිරීමට නොහැකි විය. නැවත උත්සාහ කරන්න.");
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError(e.toString().replaceAll("Exception: ", ""));
      _setLoading(false);
      return false;
    }
  }

  // ==========================================
  // 2. SIGN UP LOGIC (Firebase Auth + Firestore)
  // ==========================================
  Future<bool> register(StudentModel student, String password) async {
    _setLoading(true);
    _clearError();

    try {
      // Input Validation
      if (student.name.trim().isEmpty ||
          student.email.trim().isEmpty ||
          password.trim().isEmpty ||
          student.school.trim().isEmpty ||
          student.grade.trim().isEmpty) {
        _setError("කරුණාකර සියලුම අත්‍යවශ්‍ය තොරතුරු ඇතුළත් කරන්න!");
        _setLoading(false);
        return false;
      }

      if (password.length < 6) {
        _setError("මුරපදය සඳහා අවම වශයෙන් අකුරු 6ක් තිබිය යුතුය!");
        _setLoading(false);
        return false;
      }

      // Firebase Auth + Firestore
      final uid = await _firebaseService.registerStudent(student, password);

      // ලියාපදිංචි වූ සැනින් ස්වයංක්‍රීයව ලොග් කර ගැනීම
      _currentStudent = student.copyWith(uid: uid);

      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll("Exception: ", ""));
      _setLoading(false);
      return false;
    }
  }

  // ==========================================
  // 3. EDIT PROFILE LOGIC (Firestore Update)
  // ==========================================
  Future<bool> updateProfile({
    required String name,
    required String school,
    required String grade,
    required int oLevelYear,
    String? phone,
    String? photoUrl,
  }) async {
    if (_currentStudent == null) return false;

    _setLoading(true);
    _clearError();

    try {
      if (name.trim().isEmpty || school.trim().isEmpty || grade.trim().isEmpty) {
        _setError("හිස්තැන් පැවතිය නොහැක!");
        _setLoading(false);
        return false;
      }

      final updatedStudent = _currentStudent!.copyWith(
        name: name.trim(),
        school: school.trim(),
        grade: grade.trim(),
        oLevelYear: oLevelYear,
        phone: phone != null ? phone.trim() : _currentStudent!.phone,
        photoUrl: photoUrl != null ? photoUrl.trim() : _currentStudent!.photoUrl,
      );

      await _firebaseService.updateStudentProfile(updatedStudent);
      _currentStudent = updatedStudent;
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError("දෝෂයක් සිදුවිය: ${e.toString()}");
      _setLoading(false);
      return false;
    }
  }

  // ==========================================
  // 4. GENERAL HELPER METHODS
  // ==========================================

  // ක්විස් එකක් කළ පසු Student Stats refresh කිරීම
  Future<void> refreshStudentStats() async {
    if (_currentStudent?.uid == null) return;

    final updatedData = await _firebaseService.getStudentByUid(_currentStudent!.uid!);
    if (updatedData != null) {
      _currentStudent = updatedData;
      notifyListeners();
    }
  }

  // ගිණුමෙන් ඉවත් වීම (Log Out)
  Future<void> logout() async {
    await _firebaseService.signOut();
    _currentStudent = null;
    _clearError();
    notifyListeners();
  }

  // Loading තත්ත්වය වෙනස් කිරීම
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // දෝෂ පණිවිඩ සටහන් කිරීම
  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  // පැරණි දෝෂ ඉවත් කිරීම
  void _clearError() {
    _errorMessage = null;
  }
}
