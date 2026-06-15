import 'package:flutter/material.dart';
import '../../data/firebase/firebase_service.dart';
import '../../data/models/subject_model.dart';

// විෂයන් සහ ඒවායේ ප්‍රගතිය කළමනාකරණය කරන State Management පන්තිය (Firebase Version)
class SubjectProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService.instance;

  List<SubjectModel> _allSubjects = [];
  List<SubjectModel> _filteredSubjects = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<SubjectModel> get subjects => _filteredSubjects;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // ==========================================
  // 1. LOAD SUBJECTS (Firestore)
  // ==========================================
  Future<void> loadSubjects() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _allSubjects = await _firebaseService.getSubjects();
      _filteredSubjects = List.from(_allSubjects);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = "විෂයන් පූරණය කිරීමේදී දෝෂයක්: ${e.toString()}";
      _isLoading = false;
      notifyListeners();
    }
  }

  // ==========================================
  // 2. SEARCH & FILTER SUBJECTS
  // ==========================================
  void searchSubjects(String query) {
    if (query.trim().isEmpty) {
      _filteredSubjects = List.from(_allSubjects);
    } else {
      _filteredSubjects = _allSubjects
          .where((sub) => sub.name.toLowerCase().contains(query.trim().toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  // ==========================================
  // 3. REFRESH PROGRESS
  // ==========================================
  Future<void> refreshSubjectProgress() async {
    try {
      _allSubjects = await _firebaseService.getSubjects();
      _filteredSubjects = List.from(_allSubjects);
      notifyListeners();
    } catch (e) {
      debugPrint("ප්‍රගතිය යාවත්කාලීන කිරීමේදී දෝෂයක්: $e");
    }
  }
}
