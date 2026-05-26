import 'package:flutter/material.dart';
import '../../data/database/database_helper.dart';
import '../../data/models/subject_model.dart';

// විෂයන් සහ ඒවායේ ප්‍රගතිය කළමනාකරණය කරන State Management පන්තිය
class SubjectProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  List<SubjectModel> _allSubjects = []; // දත්ත ගබඩාවෙන් ලබාගත් සියලුම විෂයන්
  List<SubjectModel> _filteredSubjects = []; // සෙවුම් පද (Search) අනුව පෙරන ලද විෂයන්
  bool _isLoading = false;
  String? _errorMessage;

  // Getters මඟින් පිටතට දත්ත ලබාදීම
  List<SubjectModel> get subjects => _filteredSubjects;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // ==========================================
  // 1. LOAD SUBJECTS LOGIC (විෂයන් දත්ත ගබඩාවෙන් කියවීම)
  // ==========================================
  Future<void> loadSubjects() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // දත්ත ගබඩාවෙන් සියලුම විෂයන් ලබාගැනීම
      _allSubjects = await _dbHelper.getSubjects();
      _filteredSubjects = List.from(_allSubjects);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = "විෂයන් පූරණය කිරීමේදී දෝෂයක් සිදුවිය: ${e.toString()}";
      _isLoading = false;
      notifyListeners();
    }
  }

  // ==========================================
  // 2. SEARCH & FILTER SUBJECTS (විෂයන් සෙවීම - Choose Subject Page)
  // ==========================================
  void searchSubjects(String query) {
    if (query.trim().isEmpty) {
      // සෙවුම් පදය හිස් නම් සියලුම විෂයන් පෙන්වීම
      _filteredSubjects = List.from(_allSubjects);
    } else {
      // සෙවුම් පදයට ගැලපෙන විෂයන් පමණක් පෙරීම (Case Insensitive search)
      _filteredSubjects = _allSubjects
          .where((sub) => sub.name.toLowerCase().contains(query.trim().toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  // ==========================================
  // 3. REFRESH PROGRESS (ප්‍රගති ප්‍රතිශතය යාවත්කාලීන කිරීම)
  // ==========================================
  // සිසුවා ක්විස් එකක් කළ පසු, අදාළ විෂයයේ Completed Rate එක යාවත්කාලීන කිරීම
  Future<void> refreshSubjectProgress() async {
    try {
      _allSubjects = await _dbHelper.getSubjects();
      _filteredSubjects = List.from(_allSubjects);
      notifyListeners();
    } catch (e) {
      debugPrint("ප්‍රගතිය යාවත්කාලීන කිරීමේදී දෝෂයක්: $e");
    }
  }
}
