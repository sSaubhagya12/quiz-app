import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/student_model.dart';
import '../models/subject_model.dart';
import '../models/question_model.dart';
import '../models/quiz_result_model.dart';
import '../models/student_answer_model.dart';

// Firebase සේවා හසුරුවන ප්‍රධාන Helper පන්තිය (Singleton Pattern)
// SQLite DatabaseHelper ප්‍රතිස්ථාපනය කරයි
class FirebaseService {
  static final FirebaseService instance = FirebaseService._init();
  FirebaseService._init();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Offline Mode indicator for demo setup
  bool _isOfflineMode = false;
  bool get isOfflineMode => _isOfflineMode;

  // In-memory data for offline mode
  StudentModel? _offlineStudent;
  final List<SubjectModel> _offlineSubjects = [
    SubjectModel(
      id: 'religion',
      name: 'Religion',
      iconName: 'volunteer_activism',
      imageUrl: 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400&q=80',
      totalQuestions: 0,
      completedRate: 0.0,
    ),
    SubjectModel(
      id: 'sinhala',
      name: 'Sinhala',
      iconName: 'book',
      imageUrl: 'https://images.unsplash.com/photo-1506880018603-83d5b814b5a6?w=400&q=80',
      totalQuestions: 0,
      completedRate: 0.0,
    ),
    SubjectModel(
      id: 'english',
      name: 'English',
      iconName: 'language',
      imageUrl: 'https://images.unsplash.com/photo-1451226428352-cf66b8a0317a?w=400&q=80',
      totalQuestions: 0,
      completedRate: 0.0,
    ),
    SubjectModel(
      id: 'math',
      name: 'Mathematics',
      iconName: 'calculate',
      imageUrl: 'https://images.unsplash.com/photo-1509228468518-180dd4864904?w=400&q=80',
      totalQuestions: 3,
      completedRate: 0.0,
    ),
    SubjectModel(
      id: 'sci',
      name: 'Science',
      iconName: 'science',
      imageUrl: 'https://images.unsplash.com/photo-1507668077129-56e32842fceb?w=400&q=80',
      totalQuestions: 5,
      completedRate: 0.0,
    ),
    SubjectModel(
      id: 'history',
      name: 'History',
      iconName: 'history',
      imageUrl: 'https://images.unsplash.com/photo-1461360370896-922624d12aa1?w=400&q=80',
      totalQuestions: 0,
      completedRate: 0.0,
    ),
    SubjectModel(
      id: 'business',
      name: 'Business & Accounting Studies',
      iconName: 'analytics',
      imageUrl: 'https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=400&q=80',
      totalQuestions: 0,
      completedRate: 0.0,
    ),
    SubjectModel(
      id: 'geo',
      name: 'Geography',
      iconName: 'public',
      imageUrl: 'https://images.unsplash.com/photo-1524661135-423995f22d0b?w=400&q=80',
      totalQuestions: 0,
      completedRate: 0.0,
    ),
    SubjectModel(
      id: 'civic',
      name: 'Civic Education',
      iconName: 'gavel',
      imageUrl: 'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?w=400&q=80',
      totalQuestions: 0,
      completedRate: 0.0,
    ),
    SubjectModel(
      id: 'music',
      name: 'Music',
      iconName: 'music_note',
      imageUrl: 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=400&q=80',
      totalQuestions: 0,
      completedRate: 0.0,
    ),
    SubjectModel(
      id: 'dancing',
      name: 'Dancing',
      iconName: 'emoji_people',
      imageUrl: 'https://images.unsplash.com/photo-1508700115892-45ecd05ae2ad?w=400&q=80',
      totalQuestions: 0,
      completedRate: 0.0,
    ),
    SubjectModel(
      id: 'art',
      name: 'Art (Act)',
      iconName: 'palette',
      imageUrl: 'https://images.unsplash.com/photo-1513364776144-60967b0f800f?w=400&q=80',
      totalQuestions: 0,
      completedRate: 0.0,
    ),
    SubjectModel(
      id: 'ict',
      name: 'Information & Communication',
      iconName: 'computer',
      imageUrl: 'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?w=400&q=80',
      totalQuestions: 0,
      completedRate: 0.0,
    ),
    SubjectModel(
      id: 'agriculture',
      name: 'Agriculture & Food Technology',
      iconName: 'agriculture',
      imageUrl: 'https://images.unsplash.com/photo-1464226184884-fa280b87c3a9?w=400&q=80',
      totalQuestions: 0,
      completedRate: 0.0,
    ),
    SubjectModel(
      id: 'health',
      name: 'Health & Physical Education',
      iconName: 'fitness_center',
      imageUrl: 'https://images.unsplash.com/photo-1476480862126-209bfaa8edc8?w=400&q=80',
      totalQuestions: 0,
      completedRate: 0.0,
    ),
  ];

  final Map<String, List<QuestionModel>> _offlineQuestions = {
    'sci': [
      QuestionModel(
        id: 'sci_q1',
        subjectId: 'sci',
        questionText: 'බලයේ ජාත්‍යන්තර ඒකකය (SI Unit) කුමක්ද?',
        option1: 'Newton (නිව්ටන්)',
        option2: 'Joule (ජූල්)',
        option3: 'Watt (වොට්)',
        option4: 'Pascal (පැස්කල්)',
        correctOption: 1,
        explanation: 'බලය මනිනු ලබන්නේ නිව්ටන් (Newton - N) ඒකකයෙනි.',
      ),
      QuestionModel(
        id: 'sci_q2',
        subjectId: 'sci',
        questionText: 'ප්‍රභාසංස්ලේෂණය සඳහා අත්‍යවශ්‍ය නොවන සාධකය කුමක්ද?',
        option1: 'කාබන් ඩයොක්සයිඩ් වායුව',
        option2: 'සූර්යාලෝකය',
        option3: 'හරිතප්‍රද (Chlorophyll)',
        option4: 'ඔක්සිජන් වායුව',
        correctOption: 4,
        explanation: 'ප්‍රභාසංස්ලේෂණයේදී ඔක්සිජන් වායුව පිටකරන අතර, ක්‍රියාවලියට අත්‍යවශ්‍ය නොවේ.',
      ),
      QuestionModel(
        id: 'sci_q3',
        subjectId: 'sci',
        questionText: 'මිනිස් සිරුරේ අඩංගු ක්‍රෝමසෝම ගණන කොපමණද?',
        option1: '23ක්',
        option2: '46ක්',
        option3: '44ක්',
        option4: '48ක්',
        correctOption: 2,
        explanation: 'නිරෝගී මිනිස් සිරුරක ක්‍රෝමසෝම යුගල 23ක් = ක්‍රෝමසෝම 46ක්.',
      ),
      QuestionModel(
        id: 'sci_q4',
        subjectId: 'sci',
        questionText: 'ජලයේ (Water) රසායනික සූත්‍රය කුමක්ද?',
        option1: 'CO2',
        option2: 'NaCl',
        option3: 'H2O',
        option4: 'H2SO4',
        correctOption: 3,
        explanation: 'ජල අණුවක් H2 + O = H2O.',
      ),
      QuestionModel(
        id: 'sci_q5',
        subjectId: 'sci',
        questionText: 'ආලෝකය ගමන් කරන වේගවත්ම මාධ්‍යය කුමක්ද?',
        option1: 'රික්තය (Vacuum)',
        option2: 'ජලය',
        option3: 'වීදුරු',
        option4: 'වාතය',
        correctOption: 1,
        explanation: 'ආලෝකය රික්තයේ 3x10^8 m/s වේගයෙන් ගමන් කරයි.',
      ),
    ],
    'math': [
      QuestionModel(
        id: 'math_q1',
        subjectId: 'math',
        questionText: '3x + 5 = 20 සමීකරණයේ x හි අගය සොයන්න.',
        option1: 'x = 3',
        option2: 'x = 5',
        option3: 'x = 15',
        option4: 'x = 10',
        correctOption: 2,
        explanation: '3x = 15 → x = 5.',
      ),
      QuestionModel(
        id: 'math_q2',
        subjectId: 'math',
        questionText: 'රවුමක විෂ්කම්භය 14 cm නම් අරය (Radius) කොපමණද?',
        option1: '28 cm',
        option2: '14 cm',
        option3: '7 cm',
        option4: '3.5 cm',
        correctOption: 3,
        explanation: 'අරය = විෂ්කම්භය / 2 = 14 / 2 = 7 cm.',
      ),
      QuestionModel(
        id: 'math_q3',
        subjectId: 'math',
        questionText: 'ප්‍රථමක සංඛ්‍යාවක් (Prime Number) නොවන්නේ කුමක්ද?',
        option1: '2',
        option2: '3',
        option3: '5',
        option4: '9',
        correctOption: 4,
        explanation: '9 = 3×3 බැවින් ප්‍රථමක සංඛ්‍යාවක් නොවේ.',
      ),
    ],
  };

  final List<QuizResultModel> _offlineResults = [];
  final Map<String, List<StudentAnswerModel>> _offlineAnswers = {};

  // ==========================================
  // 1. STUDENT AUTHENTICATION (Login / SignUp)
  // ==========================================

  // නව සිසුවෙකු ලියාපදිංචි කිරීම (Firebase Auth + Firestore)
  Future<String> registerStudent(StudentModel student, String password) async {
    if (_isOfflineMode) {
      _offlineStudent = student.copyWith(uid: 'offline_student_uid');
      return 'offline_student_uid';
    }

    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: student.email.trim(),
        password: password,
      );
      final uid = credential.user!.uid;
      await _db.collection('users').doc(uid).set(student.toMap());
      return uid;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw Exception('මෙම ඊමේල් ලිපිනය දැනටමත් ලියාපදිංචි කර ඇත!');
      } else if (e.code == 'weak-password') {
        throw Exception('මුරපදය ශක්තිමත් නොවේ. අවම අකුරු 6ක් භාවිතා කරන්න!');
      }
      throw Exception('ලියාපදිංචි වීමේදී දෝෂයක් සිදුවිය: ${e.message}');
    } catch (e) {
      // Auto fallback to offline
      _isOfflineMode = true;
      _offlineStudent = student.copyWith(uid: 'offline_student_uid');
      return 'offline_student_uid';
    }
  }

  // Email/Password ලොගින් (Firebase Auth)
  Future<StudentModel?> loginStudent(String email, String password) async {
    if (_isOfflineMode) {
      return _offlineStudent ?? StudentModel(
        uid: 'offline_student_uid',
        name: 'Demo Student',
        email: email,
        school: 'ආදර්ශ මහා විද්‍යාලය',
        grade: '11 ශ්‍රේණිය',
        oLevelYear: 2026,
        xp: 100,
        avgScore: 80.0,
      );
    }

    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final uid = credential.user!.uid;
      return await getStudentByUid(uid);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception('ඊමේල් ලිපිනයට අදාළ ගිණුමක් නොමැත!');
      } else if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        throw Exception('ඊමේල් හෝ මුරපදය වැරදිය!');
      }
      throw Exception('ලොගිනය ව්‍යර්ථ විය: ${e.message}');
    } catch (e) {
      // Config or network error fallback
      _isOfflineMode = true;
      return StudentModel(
        uid: 'offline_student_uid',
        name: 'Demo Student (Offline Bypass)',
        email: email,
        school: 'ආදර්ශ මහා විද්‍යාලය',
        grade: '11 ශ්‍රේණිය',
        oLevelYear: 2026,
        xp: 120,
        avgScore: 78.5,
      );
    }
  }

  // Auto-login with demo account (Fields are empty)
  Future<StudentModel?> loginWithDemoAccount() async {
    const demoEmail = 'demo@quiz.app';
    const demoPassword = 'demo123456';

    if (_isOfflineMode) {
      _offlineStudent = StudentModel(
        uid: 'offline_demo_uid',
        name: 'Demo Student (Offline Bypass)',
        email: demoEmail,
        school: 'ආදර්ශ මහා විද්‍යාලය',
        grade: '11 ශ්‍රේණිය',
        oLevelYear: 2026,
        xp: 150,
        avgScore: 75.0,
      );
      return _offlineStudent;
    }

    try {
      // Try signing in first
      final credential = await _auth.signInWithEmailAndPassword(
        email: demoEmail,
        password: demoPassword,
      );
      return await getStudentByUid(credential.user!.uid);
    } catch (e) {
      // Any error (config not ready, network, user-not-found) triggers offline bypass instantly
      _isOfflineMode = true;
      _offlineStudent = StudentModel(
        uid: 'offline_demo_uid',
        name: 'Demo Student (Offline Bypass)',
        email: demoEmail,
        school: 'ආදර්ශ මහා විද්‍යාලය',
        grade: '11 ශ්‍රේණිය',
        oLevelYear: 2026,
        xp: 150,
        avgScore: 75.0,
      );
      return _offlineStudent;
    }
  }

  // UID අනුව Student profile ලබාගැනීම
  Future<StudentModel?> getStudentByUid(String uid) async {
    if (_isOfflineMode) {
      return _offlineStudent;
    }
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return StudentModel.fromMap(doc.data()!, uid: uid);
      }
    } catch (_) {
      _isOfflineMode = true;
      return _offlineStudent;
    }
    return null;
  }

  // Email අනුව student check කිරීම (signup duplicate check)
  Future<bool> emailExists(String email) async {
    if (_isOfflineMode) return false;
    try {
      final methods = await _auth.fetchSignInMethodsForEmail(email.trim());
      return methods.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  // සිසුවා ලොග් අවුට් කිරීම
  Future<void> signOut() async {
    if (!_isOfflineMode) {
      await _auth.signOut();
    }
    _offlineStudent = null;
    _isOfflineMode = false;
  }

  // දැනට ලොග් ව ිසිටින user UID ලබා ගැනීම
  String? get currentUid => _isOfflineMode ? _offlineStudent?.uid : _auth.currentUser?.uid;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ==========================================
  // 2. STUDENT PROFILE UPDATE
  // ==========================================

  Future<void> updateStudentProfile(StudentModel student) async {
    if (_isOfflineMode) {
      _offlineStudent = student;
      return;
    }
    if (student.uid == null) throw Exception('UID නොමැත!');
    await _db.collection('users').doc(student.uid).update(student.toMap());
  }

  Future<void> updateStudentStats(String uid, int additionalXp, double newAvgScore) async {
    if (_isOfflineMode) {
      if (_offlineStudent != null) {
        _offlineStudent = _offlineStudent!.copyWith(
          xp: (_offlineStudent!.xp ?? 0) + additionalXp,
          avgScore: newAvgScore,
        );
      }
      return;
    }
    await _db.collection('users').doc(uid).update({
      'xp': FieldValue.increment(additionalXp),
      'avgScore': newAvgScore,
    });
  }

  // ==========================================
  // 3. SUBJECTS (Home & Choose Subject Pages)
  // ==========================================

  // Firestore සිට විෂය ලැයිස්තුව ලබාගැනීම
  Future<List<SubjectModel>> getSubjects({String? searchQuery}) async {
    if (_isOfflineMode) {
      final all = _offlineSubjects;
      if (searchQuery != null && searchQuery.isNotEmpty) {
        return all.where((s) => s.name.toLowerCase().contains(searchQuery.toLowerCase())).toList();
      }
      return all;
    }

    try {
      final snap = await _db.collection('subjects').get();
      if (snap.docs.isEmpty) {
        await _seedSubjectsAndQuestions();
        final newSnap = await _db.collection('subjects').get();
        final all = newSnap.docs.map((d) => SubjectModel.fromMap(d.data(), id: d.id)).toList();
        if (searchQuery != null && searchQuery.isNotEmpty) {
          return all.where((s) => s.name.toLowerCase().contains(searchQuery.toLowerCase())).toList();
        }
        return all;
      }

      var all = snap.docs.map((d) => SubjectModel.fromMap(d.data(), id: d.id)).toList();
      // Firestore හි ඇති විෂයන් ප්‍රමාණය 15 ට වඩා අඩු නම්, ඉතිරි ඒවා seed කිරීම
      if (all.length < 15) {
        await _seedMissingSubjects(all);
        final newSnap = await _db.collection('subjects').get();
        all = newSnap.docs.map((d) => SubjectModel.fromMap(d.data(), id: d.id)).toList();
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        return all.where((s) => s.name.toLowerCase().contains(searchQuery.toLowerCase())).toList();
      }
      return all;
    } catch (_) {
      _isOfflineMode = true;
      return getSubjects(searchQuery: searchQuery);
    }
  }

  // Firestore හි නොමැති විෂයන් seed කිරීමට සහායක ක්‍රමවේදයක්
  Future<void> _seedMissingSubjects(List<SubjectModel> existing) async {
    final batch = _db.batch();
    final existingNames = existing.map((s) => s.name.toLowerCase()).toSet();

    final subjectsToSeed = [
      {'name': 'Religion', 'iconName': 'volunteer_activism', 'imageUrl': 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400&q=80', 'totalQuestions': 0, 'completedRate': 0.0},
      {'name': 'Sinhala', 'iconName': 'book', 'imageUrl': 'https://images.unsplash.com/photo-1506880018603-83d5b814b5a6?w=400&q=80', 'totalQuestions': 0, 'completedRate': 0.0},
      {'name': 'English', 'iconName': 'language', 'imageUrl': 'https://images.unsplash.com/photo-1451226428352-cf66b8a0317a?w=400&q=80', 'totalQuestions': 0, 'completedRate': 0.0},
      {'name': 'Mathematics', 'iconName': 'calculate', 'imageUrl': 'https://images.unsplash.com/photo-1509228468518-180dd4864904?w=400&q=80', 'totalQuestions': 3, 'completedRate': 0.0},
      {'name': 'Science', 'iconName': 'science', 'imageUrl': 'https://images.unsplash.com/photo-1507668077129-56e32842fceb?w=400&q=80', 'totalQuestions': 5, 'completedRate': 0.0},
      {'name': 'History', 'iconName': 'history', 'imageUrl': 'https://images.unsplash.com/photo-1461360370896-922624d12aa1?w=400&q=80', 'totalQuestions': 0, 'completedRate': 0.0},
      {'name': 'Business & Accounting Studies', 'iconName': 'analytics', 'imageUrl': 'https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=400&q=80', 'totalQuestions': 0, 'completedRate': 0.0},
      {'name': 'Geography', 'iconName': 'public', 'imageUrl': 'https://images.unsplash.com/photo-1524661135-423995f22d0b?w=400&q=80', 'totalQuestions': 0, 'completedRate': 0.0},
      {'name': 'Civic Education', 'iconName': 'gavel', 'imageUrl': 'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?w=400&q=80', 'totalQuestions': 0, 'completedRate': 0.0},
      {'name': 'Music', 'iconName': 'music_note', 'imageUrl': 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=400&q=80', 'totalQuestions': 0, 'completedRate': 0.0},
      {'name': 'Dancing', 'iconName': 'emoji_people', 'imageUrl': 'https://images.unsplash.com/photo-1508700115892-45ecd05ae2ad?w=400&q=80', 'totalQuestions': 0, 'completedRate': 0.0},
      {'name': 'Art (Act)', 'iconName': 'palette', 'imageUrl': 'https://images.unsplash.com/photo-1513364776144-60967b0f800f?w=400&q=80', 'totalQuestions': 0, 'completedRate': 0.0},
      {'name': 'Information & Communication', 'iconName': 'computer', 'imageUrl': 'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?w=400&q=80', 'totalQuestions': 0, 'completedRate': 0.0},
      {'name': 'Agriculture & Food Technology', 'iconName': 'agriculture', 'imageUrl': 'https://images.unsplash.com/photo-1464226184884-fa280b87c3a9?w=400&q=80', 'totalQuestions': 0, 'completedRate': 0.0},
      {'name': 'Health & Physical Education', 'iconName': 'fitness_center', 'imageUrl': 'https://images.unsplash.com/photo-1476480862126-209bfaa8edc8?w=400&q=80', 'totalQuestions': 0, 'completedRate': 0.0},
    ];

    for (var sub in subjectsToSeed) {
      if (!existingNames.contains((sub['name'] as String).toLowerCase())) {
        final ref = _db.collection('subjects').doc();
        batch.set(ref, sub);
      }
    }
    await batch.commit();
  }

  Future<void> updateSubjectProgress(String subjectId, double completedRate) async {
    if (_isOfflineMode) {
      final idx = _offlineSubjects.indexWhere((s) => s.id == subjectId);
      if (idx != -1) {
        _offlineSubjects[idx] = _offlineSubjects[idx].copyWith(completedRate: completedRate);
      }
      return;
    }
    await _db.collection('subjects').doc(subjectId).update({'completedRate': completedRate});
  }

  // ==========================================
  // 4. QUESTIONS (Quiz Page)
  // ==========================================

  Future<List<QuestionModel>> getQuestionsBySubject(String subjectId) async {
    if (_isOfflineMode) {
      return _offlineQuestions[subjectId] ?? [];
    }

    try {
      final snap = await _db
          .collection('subjects')
          .doc(subjectId)
          .collection('questions')
          .get();

      return snap.docs
          .map((d) => QuestionModel.fromMap(d.data(), id: d.id, subjectId: subjectId))
          .toList();
    } catch (_) {
      _isOfflineMode = true;
      return getQuestionsBySubject(subjectId);
    }
  }

  // ==========================================
  // 5. QUIZ RESULTS (Results & Review Pages)
  // ==========================================

  Future<String> saveQuizResult(QuizResultModel result, List<StudentAnswerModel> answers) async {
    if (_isOfflineMode) {
      final mockResultId = 'offline_res_${DateTime.now().millisecondsSinceEpoch}';
      final newResult = QuizResultModel(
        id: mockResultId,
        studentId: result.studentId,
        subjectId: result.subjectId,
        score: result.score,
        totalQuestions: result.totalQuestions,
        timeSpent: result.timeSpent,
        dateTaken: result.dateTaken,
      );
      _offlineResults.add(newResult);
      
      final List<StudentAnswerModel> updatedAnswers = answers.map((a) => StudentAnswerModel(
        id: a.id,
        resultId: mockResultId,
        questionId: a.questionId,
        selectedOption: a.selectedOption,
        isCorrect: a.isCorrect,
        question: a.question,
      )).toList();
      _offlineAnswers[mockResultId] = updatedAnswers;

      // Update student stats locally
      int totalCorrect = 0;
      int totalQs = 0;
      for (var res in _offlineResults) {
        totalCorrect += res.score;
        totalQs += res.totalQuestions;
      }
      final double newAvgScore = totalQs > 0 ? (totalCorrect / totalQs) * 100 : 0.0;
      final int gainedXp = result.score * 50;

      await updateStudentStats(result.studentId, gainedXp, newAvgScore);
      await updateSubjectProgress(result.subjectId, result.score / result.totalQuestions);

      return mockResultId;
    }

    try {
      final batch = _db.batch();
      final resultRef = _db
          .collection('users')
          .doc(result.studentId)
          .collection('results')
          .doc();

      batch.set(resultRef, result.toMap());

      for (var answer in answers) {
        final answerRef = resultRef.collection('answers').doc();
        batch.set(answerRef, {
          'resultId': resultRef.id,
          'questionId': answer.questionId,
          'selectedOption': answer.selectedOption,
          'isCorrect': answer.isCorrect,
        });
      }

      await batch.commit();

      final allResultsSnap = await _db
          .collection('users')
          .doc(result.studentId)
          .collection('results')
          .get();

      int totalCorrect = 0;
      int totalQs = 0;
      for (var doc in allResultsSnap.docs) {
        final data = doc.data();
        totalCorrect += (data['score'] as num?)?.toInt() ?? 0;
        totalQs += (data['totalQuestions'] as num?)?.toInt() ?? 0;
      }
      final double newAvgScore = totalQs > 0 ? (totalCorrect / totalQs) * 100 : 0.0;
      final int gainedXp = result.score * 50;

      await updateStudentStats(result.studentId, gainedXp, newAvgScore);

      double bestAccuracy = 0.0;
      for (var doc in allResultsSnap.docs) {
        final data = doc.data();
        if (data['subjectId'] == result.subjectId) {
          final int s = (data['score'] as num?)?.toInt() ?? 0;
          final int t = (data['totalQuestions'] as num?)?.toInt() ?? 1;
          final double acc = s / t;
          if (acc > bestAccuracy) bestAccuracy = acc;
        }
      }
      await updateSubjectProgress(result.subjectId, bestAccuracy);

      return resultRef.id;
    } catch (_) {
      _isOfflineMode = true;
      return saveQuizResult(result, answers);
    }
  }

  Future<List<QuizResultModel>> getStudentQuizHistory(String studentId) async {
    if (_isOfflineMode) {
      return _offlineResults;
    }
    try {
      final snap = await _db
          .collection('users')
          .doc(studentId)
          .collection('results')
          .orderBy('dateTaken', descending: true)
          .get();

      return snap.docs
          .map((d) => QuizResultModel.fromMap(d.data(), id: d.id))
          .toList();
    } catch (_) {
      _isOfflineMode = true;
      return _offlineResults;
    }
  }

  Future<List<StudentAnswerModel>> getAnswersForQuizResult(String uid, String resultId) async {
    if (_isOfflineMode) {
      final answers = _offlineAnswers[resultId] ?? [];
      // Attach mock questions to review
      final List<StudentAnswerModel> detailedAnswers = [];
      for (var a in answers) {
        QuestionModel? question;
        for (var key in _offlineQuestions.keys) {
          final found = _offlineQuestions[key]!.where((q) => q.id == a.questionId);
          if (found.isNotEmpty) {
            question = found.first;
            break;
          }
        }
        detailedAnswers.add(StudentAnswerModel(
          id: a.id,
          resultId: a.resultId,
          questionId: a.questionId,
          selectedOption: a.selectedOption,
          isCorrect: a.isCorrect,
          question: question,
        ));
      }
      return detailedAnswers;
    }

    try {
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
        final subjectSnap = await _db.collection('subjects').get();
        for (var subDoc in subjectSnap.docs) {
          final qDoc = await _db
              .collection('subjects')
              .doc(subDoc.id)
              .collection('questions')
              .doc(questionId)
              .get();
          if (qDoc.exists && qDoc.data() != null) {
            question = QuestionModel.fromMap(qDoc.data()!, id: qDoc.id, subjectId: subDoc.id);
            break;
          }
        }

        answers.add(StudentAnswerModel.fromMap(data, id: doc.id, question: question));
      }
      return answers;
    } catch (_) {
      _isOfflineMode = true;
      return getAnswersForQuizResult(uid, resultId);
    }
  }

  // ==========================================
  // 6. DATA SEEDING (First-time Firestore setup)
  // ==========================================
  Future<void> _seedSubjectsAndQuestions() async {
    final batch = _db.batch();

    final subjects = [
      {'name': 'Religion', 'iconName': 'volunteer_activism', 'imageUrl': 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400&q=80', 'totalQuestions': 0, 'completedRate': 0.0},
      {'name': 'Sinhala', 'iconName': 'book', 'imageUrl': 'https://images.unsplash.com/photo-1506880018603-83d5b814b5a6?w=400&q=80', 'totalQuestions': 0, 'completedRate': 0.0},
      {'name': 'English', 'iconName': 'language', 'imageUrl': 'https://images.unsplash.com/photo-1451226428352-cf66b8a0317a?w=400&q=80', 'totalQuestions': 0, 'completedRate': 0.0},
      {'name': 'Mathematics', 'iconName': 'calculate', 'imageUrl': 'https://images.unsplash.com/photo-1509228468518-180dd4864904?w=400&q=80', 'totalQuestions': 3, 'completedRate': 0.0},
      {'name': 'Science', 'iconName': 'science', 'imageUrl': 'https://images.unsplash.com/photo-1507668077129-56e32842fceb?w=400&q=80', 'totalQuestions': 5, 'completedRate': 0.0},
      {'name': 'History', 'iconName': 'history', 'imageUrl': 'https://images.unsplash.com/photo-1461360370896-922624d12aa1?w=400&q=80', 'totalQuestions': 0, 'completedRate': 0.0},
      {'name': 'Business & Accounting Studies', 'iconName': 'analytics', 'imageUrl': 'https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=400&q=80', 'totalQuestions': 0, 'completedRate': 0.0},
      {'name': 'Geography', 'iconName': 'public', 'imageUrl': 'https://images.unsplash.com/photo-1524661135-423995f22d0b?w=400&q=80', 'totalQuestions': 0, 'completedRate': 0.0},
      {'name': 'Civic Education', 'iconName': 'gavel', 'imageUrl': 'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?w=400&q=80', 'totalQuestions': 0, 'completedRate': 0.0},
      {'name': 'Music', 'iconName': 'music_note', 'imageUrl': 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=400&q=80', 'totalQuestions': 0, 'completedRate': 0.0},
      {'name': 'Dancing', 'iconName': 'emoji_people', 'imageUrl': 'https://images.unsplash.com/photo-1508700115892-45ecd05ae2ad?w=400&q=80', 'totalQuestions': 0, 'completedRate': 0.0},
      {'name': 'Art (Act)', 'iconName': 'palette', 'imageUrl': 'https://images.unsplash.com/photo-1513364776144-60967b0f800f?w=400&q=80', 'totalQuestions': 0, 'completedRate': 0.0},
      {'name': 'Information & Communication', 'iconName': 'computer', 'imageUrl': 'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?w=400&q=80', 'totalQuestions': 0, 'completedRate': 0.0},
      {'name': 'Agriculture & Food Technology', 'iconName': 'agriculture', 'imageUrl': 'https://images.unsplash.com/photo-1464226184884-fa280b87c3a9?w=400&q=80', 'totalQuestions': 0, 'completedRate': 0.0},
      {'name': 'Health & Physical Education', 'iconName': 'fitness_center', 'imageUrl': 'https://images.unsplash.com/photo-1476480862126-209bfaa8edc8?w=400&q=80', 'totalQuestions': 0, 'completedRate': 0.0},
    ];

    final Map<String, String> subjectIds = {};
    for (var sub in subjects) {
      final ref = _db.collection('subjects').doc();
      batch.set(ref, sub);
      subjectIds[sub['name'] as String] = ref.id;
    }

    await batch.commit();

    final String scienceId = subjectIds['Science']!;
    final scienceQuestions = [
      {
        'subjectId': scienceId,
        'questionText': 'බලයේ ජාත්‍යන්තර ඒකකය (SI Unit) කුමක්ද?',
        'option1': 'Newton (නිව්ටන්)',
        'option2': 'Joule (ජූල්)',
        'option3': 'Watt (වොට්)',
        'option4': 'Pascal (පැස්කල්)',
        'correctOption': 1,
        'explanation': 'බලය මනිනු ලබන්නේ නිව්ටන් (Newton - N) ඒකකයෙනි.'
      },
      {
        'subjectId': scienceId,
        'questionText': 'ප්‍රභාසංස්ලේෂණය සඳහා අත්‍යවශ්‍ය නොවන සාධකය කුමක්ද?',
        'option1': 'කාබන් ඩයොක්සයිඩ් වායුව',
        'option2': 'සූර්යාලෝකය',
        'option3': 'හරිතප්‍රද (Chlorophyll)',
        'option4': 'ඔක්සිජන් වායුව',
        'correctOption': 4,
        'explanation': 'ප්‍රභාසංස්ලේෂණයේදී ඔක්සිජන් වායුව පිටකරන අතර, ක්‍රියාවලියට අත්‍යවශ්‍ය නොවේ.'
      },
      {
        'subjectId': scienceId,
        'questionText': 'මිනිස් සිරුරේ අඩංගු ක්‍රෝමසෝම ගණන කොපමණද?',
        'option1': '23ක්',
        'option2': '46ක්',
        'option3': '44ක්',
        'option4': '48ක්',
        'correctOption': 2,
        'explanation': 'නිරෝගී මිනිස් සිරුරක ක්‍රෝමසෝම යුගල 23ක් = ක්‍රෝමසෝම 46ක්.'
      },
      {
        'subjectId': scienceId,
        'questionText': 'ජලයේ (Water) ਰසායනික සූත්‍රය කුමක්ද?',
        'option1': 'CO2',
        'option2': 'NaCl',
        'option3': 'H2O',
        'option4': 'H2SO4',
        'correctOption': 3,
        'explanation': 'ජල අණුවක් H2 + O = H2O.'
      },
      {
        'subjectId': scienceId,
        'questionText': 'ආලෝකය ගමන් කරන වේගවත්ම මාධ්‍යය කුමක්ද?',
        'option1': 'රික්තය (Vacuum)',
        'option2': 'ජලය',
        'option3': 'වීදුරු',
        'option4': 'වාතය',
        'correctOption': 1,
        'explanation': 'ආලෝකය රික්තයේ 3x10^8 m/s වේගයෙන් ගමන් කරයි.'
      },
    ];

    final batch2 = _db.batch();
    for (var q in scienceQuestions) {
      final ref = _db.collection('subjects').doc(scienceId).collection('questions').doc();
      batch2.set(ref, q);
    }

    final String mathId = subjectIds['Mathematics']!;
    final mathQuestions = [
      {
        'subjectId': mathId,
        'questionText': '3x + 5 = 20 සමීකරණයේ x හි අගය සොයන්න.',
        'option1': 'x = 3',
        'option2': 'x = 5',
        'option3': 'x = 15',
        'option4': 'x = 10',
        'correctOption': 2,
        'explanation': '3x = 15 → x = 5.'
      },
      {
        'subjectId': mathId,
        'questionText': 'රවුමක විෂ්කම්භය 14 cm නම් අරය (Radius) කොපමණද?',
        'option1': '28 cm',
        'option2': '14 cm',
        'option3': '7 cm',
        'option4': '3.5 cm',
        'correctOption': 3,
        'explanation': 'අරය = විෂ්කම්භය / 2 = 14 / 2 = 7 cm.'
      },
      {
        'subjectId': mathId,
        'questionText': 'ප්‍රථමක සංඛ්‍යාවක් (Prime Number) නොවන්නේ කුමක්ද?',
        'option1': '2',
        'option2': '3',
        'option3': '5',
        'option4': '9',
        'correctOption': 4,
        'explanation': '9 = 3×3 බැවින් ප්‍රථමක සංඛ්‍යාවක් නොවේ.'
      },
    ];

    for (var q in mathQuestions) {
      final ref = _db.collection('subjects').doc(mathId).collection('questions').doc();
      batch2.set(ref, q);
    }

    await batch2.commit();
  }
}
