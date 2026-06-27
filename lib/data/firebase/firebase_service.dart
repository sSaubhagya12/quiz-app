import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/student_model.dart';
import '../models/subject_model.dart';
import '../models/question_model.dart';
import '../models/quiz_result_model.dart';
import '../models/student_answer_model.dart';

class FirebaseService {
  FirebaseService._();
  static final FirebaseService instance = FirebaseService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ==========================================
  // 1. STUDENT AUTHENTICATION (Login / SignUp)
  // ==========================================

  Future<String> registerStudent(StudentModel student, String password) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
        email: student.email, password: password);
    final uid = userCredential.user!.uid;

    final studentWithUid = student.copyWith(uid: uid);
    await _db
        .collection('users')
        .doc(uid)
        .set(studentWithUid.toMap(), SetOptions(merge: true));

    return uid;
  }

  Future<StudentModel?> loginStudent(String email, String password) async {
    final userCredential = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
    final uid = userCredential.user!.uid;

    final doc = await _db.collection('users').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return StudentModel.fromMap(doc.data()!, uid: uid);
    }
    return null;
  }

  Future<StudentModel?> getStudentByUid(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return StudentModel.fromMap(doc.data()!, uid: uid);
    }
    return null;
  }

  Future<void> updateStudentProfile(StudentModel student) async {
    if (student.uid == null) return;
    await _db.collection('users').doc(student.uid).update(student.toMap());
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  // ==========================================
  // 2. SUBJECTS (Home Page)
  // ==========================================

  Future<List<SubjectModel>> getSubjects({String? searchQuery}) async {
    final snap = await _db.collection('subjects').get();
    final all = snap.docs
        .map((doc) => SubjectModel.fromMap(doc.data(), id: doc.id))
        .toList();

    if (searchQuery != null && searchQuery.isNotEmpty) {
      return all
          .where(
              (s) => s.name.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    }
    return all;
  }

  Future<void> updateSubjectProgress(
      String subjectId, double completedRate) async {
    await _db
        .collection('subjects')
        .doc(subjectId)
        .update({'completedRate': completedRate});
  }

  // ==========================================
  // 3. QUESTIONS (Quiz Page)
  // ==========================================

  Future<List<QuestionModel>> getQuestionsBySubject(String subjectId) async {
    final snap = await _db
        .collection('subjects')
        .doc(subjectId)
        .collection('questions')
        .get();

    final qs = snap.docs
        .map((d) =>
            QuestionModel.fromMap(d.data(), id: d.id, subjectId: subjectId))
        .toList();

    qs.sort((a, b) {
      final numA =
          int.tryParse(a.id?.replaceAll(RegExp(r'[^0-9]'), '') ?? '0') ?? 0;
      final numB =
          int.tryParse(b.id?.replaceAll(RegExp(r'[^0-9]'), '') ?? '0') ?? 0;
      return numA.compareTo(numB);
    });
    return qs;
  }

  // ==========================================
  // 4. QUIZ RESULTS (Results & Review Pages)
  // ==========================================

  Future<String> saveQuizResult(
      QuizResultModel result, List<StudentAnswerModel> answers) async {
    final resultRef = _db
        .collection('users')
        .doc(result.studentId)
        .collection('results')
        .doc();
    final resultId = resultRef.id;

    final newResult = QuizResultModel(
      id: resultId,
      studentId: result.studentId,
      subjectId: result.subjectId,
      score: result.score,
      totalQuestions: result.totalQuestions,
      timeSpent: result.timeSpent,
      dateTaken: result.dateTaken,
    );

    final batch = _db.batch();
    batch.set(resultRef, newResult.toMap());

    for (var answer in answers) {
      final ansRef = resultRef.collection('answers').doc();
      final finalAnswer = StudentAnswerModel(
        id: ansRef.id,
        resultId: resultId,
        questionId: answer.questionId,
        selectedOption: answer.selectedOption,
        isCorrect: answer.isCorrect,
      );
      batch.set(ansRef, finalAnswer.toMap());
    }

    await batch.commit();

    // Update global subject progress if needed
    final resSnap = await _db
        .collection('users')
        .doc(result.studentId)
        .collection('results')
        .where('subjectId', isEqualTo: result.subjectId)
        .get();

    if (resSnap.docs.isNotEmpty) {
      double totalScore = 0;
      for (var d in resSnap.docs) {
        totalScore += (d.data()['score'] ?? 0) as double;
      }
      double newRate = totalScore / resSnap.docs.length;
      await updateSubjectProgress(result.subjectId, newRate);
    }

    return resultId;
  }

  Future<List<QuizResultModel>> getQuizResults(String uid) async {
    final snap = await _db
        .collection('users')
        .doc(uid)
        .collection('results')
        .orderBy('dateTaken', descending: true)
        .get();

    return snap.docs
        .map((doc) => QuizResultModel.fromMap(doc.data(), id: doc.id))
        .toList();
  }

  Future<Map<String, QuizResultModel>> getHighestScoresBySubject(
      String uid) async {
    final results = await getQuizResults(uid);
    final Map<String, QuizResultModel> highestScores = {};
    for (var r in results) {
      if (!highestScores.containsKey(r.subjectId) ||
          r.score > highestScores[r.subjectId]!.score) {
        highestScores[r.subjectId] = r;
      }
    }
    return highestScores;
  }

  Future<List<StudentAnswerModel>> getAnswersForQuizResult(
      String uid, String resultId) async {
    // 1. Fetch the result to get the subjectId
    final resDoc = await _db
        .collection('users')
        .doc(uid)
        .collection('results')
        .doc(resultId)
        .get();

    final subjectId = resDoc.data()?['subjectId'] as String? ?? '';

    // 2. Fetch the answers
    final snap = await _db
        .collection('users')
        .doc(uid)
        .collection('results')
        .doc(resultId)
        .collection('answers')
        .get();

    List<StudentAnswerModel> answers = [];
    for (var doc in snap.docs) {
      final data = doc.data();
      final String questionId = data['questionId'] as String? ?? '';

      QuestionModel? question;
      if (subjectId.isNotEmpty && questionId.isNotEmpty) {
        final qSnap = await _db
            .collection('subjects')
            .doc(subjectId)
            .collection('questions')
            .doc(questionId)
            .get();
        if (qSnap.exists && qSnap.data() != null) {
          question = QuestionModel.fromMap(qSnap.data()!,
              id: qSnap.id, subjectId: subjectId);
        }
      }

      answers.add(
          StudentAnswerModel.fromMap(data, id: doc.id, question: question));
    }
    return answers;
  }
}
