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
  final int _totalTimeLimit = 45 * 60; // 45 minutes in seconds
  String? _currentStudentId;

  bool _isQuizCompleted = false;
  QuizResultModel? _lastQuizResult;
  List<StudentAnswerModel> _reviewAnswers = [];
  bool _showReviewPanel = false;

  bool _isTimeOut = false;
  bool _timeOutNotified = false;

  Map<String, QuizResultModel> _highestScores = {};

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
  bool get isTimeOut => _isTimeOut;
  bool get timeOutNotified => _timeOutNotified;
  Map<String, QuizResultModel> get highestScores => _highestScores;

  void markTimeOutNotified() {
    _timeOutNotified = true;
    notifyListeners();
  }

  QuestionModel? get currentQuestion {
    if (_questions.isEmpty || _currentQuestionIndex >= _questions.length) return null;
    return _questions[_currentQuestionIndex];
  }

  String get formattedTime {
    final remaining = _totalTimeLimit - _secondsElapsed;
    if (remaining < 0) return "00:00";
    final minutes = (remaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (remaining % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  // ==========================================
  // 1. START QUIZ (Firestore)
  // ==========================================
  Future<void> startQuiz(SubjectModel subject, String studentId) async {
    // Resume logic: if returning to the same subject
    if (_currentSubject?.id == subject.id) {
      if (!_isQuizCompleted && _questions.isNotEmpty) {
        // Resume in-progress quiz
        _currentStudentId = studentId;
        _isLoading = false;
        notifyListeners();
        return;
      } else if (_isQuizCompleted && _isTimeOut && !_timeOutNotified) {
        // Time ran out while away, and they haven't seen the dialog
        _currentStudentId = studentId;
        _isLoading = false;
        notifyListeners();
        return;
      }
    }

    _isLoading = true;
    _currentSubject = subject;
    _currentStudentId = studentId;
    _questions = [];
    _currentQuestionIndex = 0;
    _selectedOption = -1;
    _studentAnswersMap.clear();
    _secondsElapsed = 0;
    _isQuizCompleted = false;
    _lastQuizResult = null;
    _reviewAnswers = [];
    _highestScores = {};
    _showReviewPanel = false;
    _isTimeOut = false;
    _timeOutNotified = false;
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

    // Save the current answer
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

  // Go back to previous question (restores saved answer)
  void previousQuestion() {
    if (_currentQuestionIndex <= 0) return;
    // Save any in-progress selection
    if (currentQuestion != null && _selectedOption != -1) {
      _studentAnswersMap[currentQuestion!.id!] = _selectedOption;
    }
    _currentQuestionIndex--;
    _selectedOption = _studentAnswersMap[currentQuestion!.id!] ?? -1;
    _errorMessage = null;
    notifyListeners();
  }

  // Jump to any question index (preview panel)
  void jumpToQuestion(int index) {
    if (index < 0 || index >= _questions.length) return;
    // Save any in-progress selection
    if (currentQuestion != null && _selectedOption != -1) {
      _studentAnswersMap[currentQuestion!.id!] = _selectedOption;
    }
    _currentQuestionIndex = index;
    _selectedOption = _studentAnswersMap[currentQuestion!.id!] ?? -1;
    _errorMessage = null;
    notifyListeners();
  }

  // Get saved answer for a question (returns -1 if unanswered)
  int getAnswerForQuestion(String questionId) {
    return _studentAnswersMap[questionId] ?? -1;
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
      _showReviewPanel = true;

      // Build review answers in-memory from the questions we already have
      // (No Firebase answers fetch needed - answers not stored remotely)
      _reviewAnswers = answersToSave.map((a) {
        final question = _questions.firstWhere(
          (q) => q.id == a.questionId,
          orElse: () => _questions[0],
        );
        return StudentAnswerModel(
          id: a.id,
          resultId: resultId,
          questionId: a.questionId,
          selectedOption: a.selectedOption,
          isCorrect: a.isCorrect,
          question: question,
        );
      }).toList();
      
      // Fetch highest scores for the Results Screen
      await loadHighestScores(studentId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = "ප්‍රතිඵල සුරක්ෂිත කිරීමේදී දෝෂයක්: ${e.toString()}";
      _isLoading = false;
      notifyListeners();
    }
  }

  // අතීත ප්‍රතිඵල (Highest Scores) පූරණය කිරීම (Profile Screen එකෙන්)
  Future<void> loadHighestScores(String studentId) async {
    try {
      _highestScores = await _firebaseService.getHighestScoresBySubject(studentId);
      notifyListeners();
    } catch (e) {
      debugPrint("Highest scores load failed: $e");
    }
  }

  // ==========================================
  // 5. CLEAR LAST RESULT (when user navigates away)
  // ==========================================
  void clearLastResult() {
    _lastQuizResult = null;
    _reviewAnswers = [];
    _showReviewPanel = false;
    notifyListeners();
  }

  // ==========================================
  // 6. REVIEW PANEL TOGGLE
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
      if (_secondsElapsed < _totalTimeLimit) {
        _secondsElapsed++;
        notifyListeners();
      } else {
        _stopTimer();
        if (_currentStudentId != null && !_isQuizCompleted) {
          _isTimeOut = true;
          _submitAndSaveQuiz(_currentStudentId!);
        }
      }
    });
  }

  // ==========================================
  // 7. CLEAR QUIZ STATE (Log out / Reset)
  // ==========================================
  void clearQuizState() {
    _stopTimer();
    _currentSubject = null;
    _questions = [];
    _currentQuestionIndex = 0;
    _selectedOption = -1;
    _studentAnswersMap.clear();
    _secondsElapsed = 0;
    _isQuizCompleted = false;
    _lastQuizResult = null;
    _reviewAnswers = [];
    _highestScores = {};
    _showReviewPanel = false;
    _isTimeOut = false;
    _timeOutNotified = false;
    _errorMessage = null;
    _currentStudentId = null;
    notifyListeners();
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
