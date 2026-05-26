import 'dart:async';
import 'package:flutter/material.dart';
import '../../data/database/database_helper.dart';
import '../../data/models/question_model.dart';
import '../../data/models/subject_model.dart';
import '../../data/models/quiz_result_model.dart';
import '../../data/models/student_answer_model.dart';

// ක්විස් එක පැවැත්වීම සහ එහි ප්‍රතිඵල සමාලෝචනය (Review) පාලනය කරන State Management පන්තිය
class QuizProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  SubjectModel? _currentSubject;
  List<QuestionModel> _questions = [];
  int _currentQuestionIndex = 0;
  
  // සිසුවා වත්මන් ප්‍රශ්නය සඳහා තෝරාගත් පිළිතුර (1, 2, 3, හෝ 4. තවම තෝරා නැත්නම් -1)
  int _selectedOption = -1; 
  
  // සිසුවා සියලුම ප්‍රශ්න සඳහා ලබාදුන් පිළිතුරු තාවකාලිකව තබාගන්නා Map එකක් (Key: Question ID, Value: Selected Option)
  final Map<int, int> _studentAnswersMap = {};

  bool _isLoading = false;
  String? _errorMessage;

  // Timer එක සඳහා විචල්‍යයන්
  Timer? _timer;
  int _secondsElapsed = 0; // ක්විස් එකට ගතවූ මුළු කාලය තත්පර වලින්

  // ප්‍රතිඵල විස්තර
  bool _isQuizCompleted = false;
  QuizResultModel? _lastQuizResult;
  List<StudentAnswerModel> _reviewAnswers = []; // Review එක සඳහා answers + questions
  bool _showReviewPanel = false; // "Review Answer" බටන් එක ක්ලික් කළවිට එම පේජ් එකේදීම පැනලය පෙන්වීමට

  // Getters මඟින් පිටතට දත්ත ලබාදීම
  SubjectModel? get currentSubject => _currentSubject;
  List<QuestionModel> get questions => _questions;
  int get currentQuestionIndex => _currentQuestionIndex;
  int get selectedOption => _selectedOption;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get secondsElapsed => _secondsElapsed;
  bool get isQuizCompleted => _isQuizCompleted;
  QuizResultModel? get lastQuizResult => _lastQuizResult;
  List<StudentAnswerModel> get reviewAnswers => _reviewAnswers;
  bool get showReviewPanel => _showReviewPanel;

  // වත්මන් ප්‍රශ්නය ලබාගැනීම
  QuestionModel? get currentQuestion {
    if (_questions.isEmpty || _currentQuestionIndex >= _questions.length) return null;
    return _questions[_currentQuestionIndex];
  }

  // ගතවූ කාලය විනාඩි සහ තත්පර ලෙස සකස් කර පෙන්වීම (Format: MM:SS)
  String get formattedTime {
    final minutes = (_secondsElapsed ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsElapsed % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  // ==========================================
  // 1. START QUIZ LOGIC (ක්විස් එක ආරම්භ කිරීම)
  // ==========================================
  Future<void> startQuiz(SubjectModel subject) async {
    _isLoading = true;
    _currentSubject = subject;
    _questions = [];
    _currentQuestionIndex = 0;
    _selectedOption = -1;
    _studentAnswersMap.clear();
    _secondsElapsed = 0;
    _isQuizCompleted = false;
    _lastQuizResult = null;
    _reviewAnswers = [];
    _showReviewPanel = false;
    _errorMessage = null;
    notifyListeners();

    try {
      // දත්ත ගබඩාවෙන් විෂයට අදාළ ප්‍රශ්න Load කිරීම
      _questions = await _dbHelper.getQuestionsBySubject(subject.id!);

      if (_questions.isEmpty) {
        _errorMessage = "මෙම විෂය සඳහා ප්‍රශ්න ඇතුළත් කර නොමැත!";
      } else {
        _startTimer();
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = "ක්විස් එක ආරම්භ කිරීමේදී දෝෂයක්: ${e.toString()}";
      _isLoading = false;
      notifyListeners();
    }
  }

  // ==========================================
  // 2. OPTION SELECTION LOGIC (පිළිතුරක් තෝරා ගැනීම)
  // ==========================================
  void selectOption(int optionIndex) {
    _selectedOption = optionIndex;
    notifyListeners();
  }

  // ==========================================
  // 3. NAVIGATION LOGIC (ඊළඟ ප්‍රශ්නයට යාම / අවසන් කිරීම)
  // ==========================================
  Future<void> nextQuestion(int studentId) async {
    if (currentQuestion == null) return;

    // සිසුවා පිළිතුරක් තෝරා නොමැති නම් ඊළඟ ප්‍රශ්නයට යාම වැළැක්වීම
    if (_selectedOption == -1) {
      _errorMessage = "කරුණාකර පිළිතුරක් තෝරා ගන්න!";
      notifyListeners();
      return;
    }

    _errorMessage = null;

    // සිසුවා තෝරාගත් පිළිතුර Map එකෙහි සුරක්ෂිත කිරීම
    _studentAnswersMap[currentQuestion!.id!] = _selectedOption;

    if (_currentQuestionIndex < _questions.length - 1) {
      // ඊළඟ ප්‍රශ්නයට යාම
      _currentQuestionIndex++;
      // පෙර පිළිතුරක් ඇත්නම් එය පෙන්වීම හෝ නව ප්‍රශ්නයක් බැවින් -1 කිරීම
      _selectedOption = _studentAnswersMap[currentQuestion!.id!] ?? -1;
      notifyListeners();
    } else {
      // මෙය අවසන් ප්‍රශ්නය නම්, ක්විස් එක අවසන් කර ප්‍රතිඵල සුරක්ෂිත කිරීම
      _stopTimer();
      await _submitAndSaveQuiz(studentId);
    }
  }

  // ==========================================
  // 4. SUBMIT & SAVE QUIZ LOGIC (ප්‍රතිඵල දත්ත ගබඩාවට සුරැකීම)
  // ==========================================
  Future<void> _submitAndSaveQuiz(int studentId) async {
    _isLoading = true;
    notifyListeners();

    try {
      int correctAnswersCount = 0;
      List<StudentAnswerModel> answersToSave = [];

      // ලකුණු ගණනය කිරීම සහ StudentAnswerModel ලැයිස්තුව සැකසීම
      for (var question in _questions) {
        final selected = _studentAnswersMap[question.id!] ?? -1;
        final isCorrect = selected == question.correctOption;

        if (isCorrect) correctAnswersCount++;

        // තාවකාලික StudentAnswerModel වස්තුවක් සැකසීම (Result ID එක පසුව SQLite මඟින් ලැබේ)
        answersToSave.add(
          StudentAnswerModel(
            resultId: 0, 
            questionId: question.id!,
            selectedOption: selected,
            isCorrect: isCorrect,
          ),
        );
      }

      // QuizResultModel වස්තුව සැකසීම
      final newResult = QuizResultModel(
        studentId: studentId,
        subjectId: _currentSubject!.id!,
        score: correctAnswersCount,
        totalQuestions: _questions.length,
        timeSpent: _secondsElapsed,
        dateTaken: DateTime.now().toIso8601String(),
      );

      // දත්ත ගබඩාවේ සුරක්ෂිත කිරීම (Transaction එකක් මඟින්)
      final resultId = await _dbHelper.saveQuizResult(newResult, answersToSave);

      // දත්ත සාර්ථකව සුරැකීමෙන් පසු Local States යාවත්කාලීන කිරීම
      _lastQuizResult = QuizResultModel(
        id: resultId,
        studentId: studentId,
        subjectId: _currentSubject!.id!,
        score: correctAnswersCount,
        totalQuestions: _questions.length,
        timeSpent: _secondsElapsed,
        dateTaken: newResult.dateTaken,
      );

      _isQuizCompleted = true;
      
      // "Review Answers" සඳහා දත්ත ගබඩාවෙන් JOIN කරන ලද දත්ත සජීවීව ලබාගැනීම
      _reviewAnswers = await _dbHelper.getAnswersForQuizResult(resultId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = "ප්‍රතිඵල සුරක්ෂිත කිරීමේදී දෝෂයක්: ${e.toString()}";
      _isLoading = false;
      notifyListeners();
    }
  }

  // ==========================================
  // 5. REVIEW ANSWERS TOGGLE (එම පිටුවේදීම පිළිතුරු සමාලෝචනය කිරීම)
  // ==========================================
  // "Review Answer" ක්ලික් කළ විට Same Page Panel එක පෙන්වීමට/නොපෙන්වීමට
  void toggleReviewPanel() {
    _showReviewPanel = !_showReviewPanel;
    notifyListeners();
  }

  // ==========================================
  // 6. TIMER HELPER METHODS (කාල ගණක යන්ත්‍රයේ සහායක ක්‍රම)
  // ==========================================
  void _startTimer() {
    _secondsElapsed = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _secondsElapsed++;
      notifyListeners();
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }
}
