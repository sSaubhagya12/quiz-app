// NOTE: This file is kept for legacy reference only.
// The app has migrated to Firebase (see firebase_service.dart).
// sqflite is no longer a dependency. All methods below are no-op stubs.
import 'dart:async';
import '../models/student_model.dart';
import '../models/subject_model.dart';
import '../models/question_model.dart';
import '../models/quiz_result_model.dart';
import '../models/student_answer_model.dart';

// Legacy SQLite helper — replaced by FirebaseService. Stub only.
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  DatabaseHelper._init();

  Future<int> registerStudent(StudentModel student) async => 0;
  Future<StudentModel?> loginStudent(String email, String password) async => null;
  Future<StudentModel?> getStudentById(int id) async => null;
  Future<StudentModel?> getStudentByEmail(String email) async => null;
  Future<int> updateStudentProfile(StudentModel student) async => 0;
  Future<void> updateStudentStats(int studentId, int additionalXp, double newAvgScore) async {}
  Future<List<SubjectModel>> getSubjects({String? searchQuery}) async => [];
  Future<int> updateSubjectProgress(int subjectId, double completedRate) async => 0;
  Future<List<QuestionModel>> getQuestionsBySubject(int subjectId) async => [];
  Future<int> saveQuizResult(QuizResultModel result, List<StudentAnswerModel> answers) async => 0;
  Future<List<QuizResultModel>> getStudentQuizHistory(int studentId) async => [];
  Future<List<StudentAnswerModel>> getAnswersForQuizResult(int resultId) async => [];
}
