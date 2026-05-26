import 'package:flutter/material.dart';
import '../../data/database/database_helper.dart';
import '../../data/models/student_model.dart';

// සිසුන්ගේ Authentication සහ Profile කටයුතු පාලනය කරන State Management පන්තිය
class AuthProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  StudentModel? _currentStudent; // දැනට ලොග් වී සිටින සිසුවාගේ තොරතුරු
  bool _isLoading = false;      // Loading අවස්ථාවන් පෙන්වීමට (Progress Indicator සඳහා)
  String? _errorMessage;         // කිසියම් දෝෂයක් ඇති වුවහොත් එය UI එකෙහි පෙන්වීමට

  // Getters මඟින් පිටතට දත්ත ලබාදීම
  StudentModel? get currentStudent => _currentStudent;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentStudent != null;

  // ==========================================
  // 1. STUDENT LOGIN LOGIC (ඇතුළු වීමේ පිටුව)
  // ==========================================
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      // Input Validation (හිස්තැන් පරීක්ෂා කිරීම)
      if (email.trim().isEmpty || password.trim().isEmpty) {
        _setError("කරුණාකර ඊමේල් ලිපිනය සහ මුරපදය ඇතුළත් කරන්න!");
        _setLoading(false);
        return false;
      }

      // SQLite Authentication
      final student = await _dbHelper.loginStudent(email.trim(), password);

      if (student != null) {
        _currentStudent = student;
        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        _setError("ඇතුළත් කළ ඊමේල් ලිපිනය හෝ මුරපදය වැරදියි!");
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError("පද්ධතියේ දෝෂයක් පවතී: ${e.toString()}");
      _setLoading(false);
      return false;
    }
  }

  // ==========================================
  // 2. SIGN UP LOGIC (නව ගිණුමක් සෑදීමේ පිටුව)
  // ==========================================
  Future<bool> register(StudentModel student) async {
    _setLoading(true);
    _clearError();

    try {
      // Input Validation
      if (student.name.trim().isEmpty || 
          student.email.trim().isEmpty || 
          student.password.trim().isEmpty || 
          student.school.trim().isEmpty || 
          student.grade.trim().isEmpty) {
        _setError("කරුණාකර සියලුම අත්‍යවශ්‍ය තොරතුරු ඇතුළත් කරන්න!");
        _setLoading(false);
        return false;
      }

      if (student.password.length < 8) {
        _setError("මුරපදය සඳහා අවම වශයෙන් අකුරු 8ක් තිබිය යුතුය!");
        _setLoading(false);
        return false;
      }

      // SQLite හි තැන්පත් කිරීම
      await _dbHelper.registerStudent(student);
      
      // ලියාපදිංචි වූ සැනින් ස්වයංක්‍රීයව ලොග් කර ගැනීම
      final loggedInStudent = await _dbHelper.loginStudent(student.email, student.password);
      if (loggedInStudent != null) {
        _currentStudent = loggedInStudent;
      }

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
  // 3. EDIT PROFILE LOGIC (පැතිකඩ යාවත්කාලීන කිරීමේ පිටුව)
  // ==========================================
  Future<bool> updateProfile({
    required String name,
    required String school,
    required String grade,
    required int oLevelYear,
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

      // වත්මන් සිසුවාගේ දත්ත වෙනස් කර නව වස්තුවක් සාදා ගැනීම
      final updatedStudent = _currentStudent!.copyWith(
        name: name.trim(),
        school: school.trim(),
        grade: grade.trim(),
        oLevelYear: oLevelYear,
      );

      // දත්ත ගබඩාවේ Update කිරීම
      final rowsAffected = await _dbHelper.updateStudentProfile(updatedStudent);

      if (rowsAffected > 0) {
        _currentStudent = updatedStudent;
        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        _setError("තොරතුරු යාවත්කාලීන කිරීමට නොහැකි විය!");
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError("දෝෂයක් සිදුවිය: ${e.toString()}");
      _setLoading(false);
      return false;
    }
  }

  // ==========================================
  // 4. GENERAL HELPER METHODS (සාමාන්‍ය සහායක ක්‍රම)
  // ==========================================

  // සිසුවා ක්විස් එකක් කළ පසු, ඔහුගේ XP/Avg Score දත්ත ගබඩාවෙන් නැවත කියවා UI එක update කිරීමට
  Future<void> refreshStudentStats() async {
    if (_currentStudent == null) return;
    
    final updatedData = await _dbHelper.getStudentById(_currentStudent!.id!);
    if (updatedData != null) {
      _currentStudent = updatedData;
      notifyListeners();
    }
  }

  // ගිණුමෙන් ඉවත් වීම (Log Out)
  void logout() {
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
  }

  // පැරණි දෝෂ ඉවත් කිරීම
  void _clearError() {
    _errorMessage = null;
  }
}
