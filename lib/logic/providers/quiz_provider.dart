import 'dart:async';
import 'package:flutter/material.dart';
import '../../data/firebase/firebase_service.dart';
import '../../data/models/question_model.dart';
import '../../data/models/subject_model.dart';
import '../../data/models/quiz_result_model.dart';
import '../../data/models/student_answer_model.dart';

// ක්විස් එක පැවැත්වීම සහ ප්‍රතිඵල (Firebase Version)
class QuizProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService.instance;

  SubjectModel? _currentSubject;
  List<QuestionModel> _questions = [];
  int _currentQuestionIndex = 0;
  int _selectedOption = -1;
  final Map<String, int> _studentAnswersMap = {}; // Key: Question ID (String)

  bool _isLoading = false;
  String? _errorMessage;

  Timer? _timer;
  int _secondsElapsed = 0;

  bool _isQuizCompleted = false;
  QuizResultModel? _lastQuizResult;
  List<StudentAnswerModel> _reviewAnswers = [];
  bool _showReviewPanel = false;

  // Getters
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

  QuestionModel? get currentQuestion {
    if (_questions.isEmpty || _currentQuestionIndex >= _questions.length) return null;
    return _questions[_currentQuestionIndex];
  }

  String get formattedTime {
    final minutes = (_secondsElapsed ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsElapsed % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  // ==========================================
  // 1. START QUIZ (Firestore)
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
      if (subject.id == null) {
        _errorMessage = "Invalid subject!";
        _isLoading = false;
        notifyListeners();
        return;
      }

      _questions = await _firebaseService.getQuestionsBySubject(subject.id!);

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
  // 2. OPTION SELECTION
  // ==========================================
  void selectOption(int optionIndex) {
    _selectedOption = optionIndex;
    notifyListeners();
  }

  // ==========================================
  // 3. NAVIGATION (Next Question / Submit)
  // ==========================================
  Future<void> nextQuestion(String studentId) async {
    if (currentQuestion == null) return;

    if (_selectedOption == -1) {
      _errorMessage = "කරුණාකර පිළිතුරක් තෝරා ගන්න!";
      notifyListeners();
      return;
    }

    _errorMessage = null;

    // Answer save (use question String ID as key)
    _studentAnswersMap[currentQuestion!.id!] = _selectedOption;

    if (_currentQuestionIndex < _questions.length - 1) {
      _currentQuestionIndex++;
      _selectedOption = _studentAnswersMap[currentQuestion!.id!] ?? -1;
      notifyListeners();
    } else {
      _stopTimer();
      await _submitAndSaveQuiz(studentId);
    }
  }

  // ==========================================
  // 4. SUBMIT & SAVE (Firestore)
  // ==========================================
  Future<void> _submitAndSaveQuiz(String studentId) async {
    _isLoading = true;
    notifyListeners();

    try {
      int correctAnswersCount = 0;
      List<StudentAnswerModel> answersToSave = [];

      for (var question in _questions) {
        final selected = _studentAnswersMap[question.id!] ?? -1;
        final isCorrect = selected == question.correctOption;

        if (isCorrect) correctAnswersCount++;

        answersToSave.add(
          StudentAnswerModel(
            resultId: '',
            questionId: question.id!,
            selectedOption: selected,
            isCorrect: isCorrect,
          ),
        );
      }

      final newResult = QuizResultModel(
        studentId: studentId,
        subjectId: _currentSubject!.id!,
        score: correctAnswersCount,
        totalQuestions: _questions.length,
        timeSpent: _secondsElapsed,
        dateTaken: DateTime.now().toIso8601String(),
      );

      // Firestore හි සුරක්ෂිත කිරීම
      final resultId = await _firebaseService.saveQuizResult(newResult, answersToSave);

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

      // Review answers Firestore වෙතින් ලබාගැනීම
      _reviewAnswers = await _firebaseService.getAnswersForQuizResult(studentId, resultId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = "ප්‍රතිඵල සුරක්ෂිත කිරීමේදී දෝෂයක්: ${e.toString()}";
      _isLoading = false;
      notifyListeners();
    }
  }

  // ==========================================
  // 5. REVIEW PANEL TOGGLE
  // ==========================================
  void toggleReviewPanel() {
    _showReviewPanel = !_showReviewPanel;
    notifyListeners();
  }

  // ==========================================
  // 6. TIMER
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
