import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/student_model.dart';
import '../models/subject_model.dart';
import '../models/question_model.dart';
import '../models/quiz_result_model.dart';
import '../models/student_answer_model.dart';

// SQLite දත්ත ගබඩාව හසුරුවන ප්‍රධාන Helper පන්තිය (Singleton Pattern)
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  // දත්ත ගබඩාව (Database) ලබාගැනීම
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('ol_quiz_database.db');
    return _database!;
  }

  // දත්ත ගබඩාව Initialize කිරීම
  Future<Database> _initDB(String filePath) async {
    // Web platform හි getDatabasesPath() null වන නිසා filename directly use කිරීම
    if (kIsWeb) {
      return await openDatabase(
        filePath,
        version: 1,
        onCreate: _createDB,
      );
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    // දත්ත ගබඩාව විවෘත කිරීම සහ Table නිර්මාණය කිරීම
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  // වගු (Tables) 5ක් නිර්මාණය කිරීමේ SQL කේතය
  FutureOr<void> _createDB(Database db, int version) async {
    // 1. Students Table (සිසුන්ගේ විස්තර)
    await db.execute('''
      CREATE TABLE students (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        school TEXT NOT NULL,
        grade TEXT NOT NULL,
        o_level_year INTEGER NOT NULL,
        xp INTEGER DEFAULT 0,
        avg_score REAL DEFAULT 0.0
      )
    ''');

    // 2. Subjects Table (විෂයන්ගේ විස්තර)
    await db.execute('''
      CREATE TABLE subjects (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        icon_name TEXT NOT NULL,
        total_questions INTEGER DEFAULT 0,
        completed_rate REAL DEFAULT 0.0
      )
    ''');

    // 3. Questions Table (ප්‍රශ්න සහ පිළිතුරු 4)
    await db.execute('''
      CREATE TABLE questions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        subject_id INTEGER NOT NULL,
        question_text TEXT NOT NULL,
        option_1 TEXT NOT NULL,
        option_2 TEXT NOT NULL,
        option_3 TEXT NOT NULL,
        option_4 TEXT NOT NULL,
        correct_option INTEGER NOT NULL,
        explanation TEXT NOT NULL,
        FOREIGN KEY (subject_id) REFERENCES subjects (id) ON DELETE CASCADE
      )
    ''');

    // 4. Quiz Results Table (ක්විස් එක අවසානයේ ලැබෙන ලකුණු විස්තර)
    await db.execute('''
      CREATE TABLE quiz_results (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        student_id INTEGER NOT NULL,
        subject_id INTEGER NOT NULL,
        score INTEGER NOT NULL,
        total_questions INTEGER NOT NULL,
        time_spent INTEGER NOT NULL,
        date_taken TEXT NOT NULL,
        FOREIGN KEY (student_id) REFERENCES students (id) ON DELETE CASCADE,
        FOREIGN KEY (subject_id) REFERENCES subjects (id) ON DELETE CASCADE
      )
    ''');

    // 5. Student Answers Table (සිසුවා තෝරාගත් පිළිතුරු - Review Answer සඳහා)
    await db.execute('''
      CREATE TABLE student_answers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        result_id INTEGER NOT NULL,
        question_id INTEGER NOT NULL,
        selected_option INTEGER NOT NULL,
        is_correct INTEGER NOT NULL,
        FOREIGN KEY (result_id) REFERENCES quiz_results (id) ON DELETE CASCADE,
        FOREIGN KEY (question_id) REFERENCES questions (id) ON DELETE CASCADE
      )
    ''');

    // දත්ත ගබඩාව ප්‍රථම වරට සෑදීමේදී ආදර්ශ දත්ත ඇතුළත් කිරීම (Seeding Data)
    await _seedInitialData(db);
  }

  // ==========================================
  // DATA SEEDING (ප්‍රශ්න සහ විෂයන් ඇතුළත් කිරීම)
  // ==========================================
  Future<void> _seedInitialData(Database db) async {
    // 1. විෂයන් 6ක් ඇතුළත් කිරීම (Figma Screen එකෙහි ඇති පරිදිම)
    final subjects = [
      {'name': 'Science', 'icon_name': 'science', 'total_questions': 5, 'completed_rate': 0.0},
      {'name': 'Mathematics', 'icon_name': 'calculate', 'total_questions': 3, 'completed_rate': 0.0},
      {'name': 'Sinhala', 'icon_name': 'book', 'total_questions': 0, 'completed_rate': 0.0},
      {'name': 'History', 'icon_name': 'history', 'total_questions': 0, 'completed_rate': 0.0},
      {'name': 'English', 'icon_name': 'language', 'total_questions': 0, 'completed_rate': 0.0},
      {'name': 'Geography', 'icon_name': 'public', 'total_questions': 0, 'completed_rate': 0.0},
    ];

    final Map<String, int> subjectIds = {};
    for (var sub in subjects) {
      int id = await db.insert('subjects', sub);
      subjectIds[sub['name'] as String] = id;
    }

    // 2. Science (විද්‍යාව) විෂයට අදාළව ප්‍රශ්න 5ක් ඇතුළත් කිරීම
    final int scienceId = subjectIds['Science']!;
    final scienceQuestions = [
      {
        'subject_id': scienceId,
        'question_text': 'බලයේ ජාත්‍යන්තර ඒකකය (SI Unit) කුමක්ද?',
        'option_1': 'Newton (නිව්ටන්)',
        'option_2': 'Joule (ජූල්)',
        'option_3': 'Watt (වොට්)',
        'option_4': 'Pascal (පැස්කල්)',
        'correct_option': 1,
        'explanation': 'බලය මනිනු ලබන්නේ නිව්ටන් (Newton - N) ඒකකයෙනි. ජූල් යනු ශක්තිය මනින ඒකකයයි. වොට් යනු ක්ෂමතාවයයි. පැස්කල් යනු පීඩනයයි.'
      },
      {
        'subject_id': scienceId,
        'question_text': 'ප්‍රභාසංස්ලේෂණය (Photosynthesis) සඳහා අත්‍යවශ්‍ය නොවන සාධකය කුමක්ද?',
        'option_1': 'කාබන් ඩයොක්සයිඩ් වායුව',
        'option_2': 'සූර්යාලෝකය',
        'option_3': 'හරිතප්‍රද (Chlorophyll)',
        'option_4': 'ඔක්සිජන් වායුව',
        'correct_option': 4,
        'explanation': 'ප්‍රභාසංස්ලේෂණයේදී ඔක්සිජන් වායුව පිටකරන අතර, එය ක්‍රියාවලිය සිදුවීමට අත්‍යවශ්‍ය සාධකයක් නොවේ.'
      },
      {
        'subject_id': scienceId,
        'question_text': 'මිනිස් සිරුරේ අඩංගු ක්‍රෝමසෝම (Chromosomes) ගණන කොපමණද?',
        'option_1': 'ක්‍රෝමසෝම 23ක්',
        'option_2': 'ක්‍රෝමසෝම 46ක්',
        'option_3': 'ක්‍රෝමසෝම 44ක්',
        'option_4': 'ක්‍රෝමසෝම 48ක්',
        'correct_option': 2,
        'explanation': 'නිරෝගී මිනිස් සිරුරක න්‍යෂ්ටියක් තුළ ක්‍රෝමසෝම යුගල 23ක්, එනම් මුළු ක්‍රෝමසෝම 46ක් අඩංගු වේ.'
      },
      {
        'subject_id': scienceId,
        'question_text': 'ජලයේ (Water) රසායනික සූත්‍රය කුමක්ද?',
        'option_1': 'CO2',
        'option_2': 'NaCl',
        'option_3': 'H2O',
        'option_4': 'H2SO4',
        'correct_option': 3,
        'explanation': 'ජල අණුවක් හයිඩ්‍රජන් පරමාණු දෙකකින් සහ ඔක්සිජන් පරමාණු එකකින් සමන්විත වන බැවින් රසායනික සූත්‍රය H2O වේ.'
      },
      {
        'subject_id': scienceId,
        'question_text': 'ආලෝකය ගමන් කරන වේගවත්ම මාධ්‍යය කුමක්ද?',
        'option_1': 'රික්තය (Vacuum)',
        'option_2': 'ජලය',
        'option_3': 'වීදුරු',
        'option_4': 'වාතය',
        'correct_option': 1,
        'explanation': 'ආලෝකය රික්තයක් තුළදී කිසිදු බාධාවකින් තොරව තත්පරයට මීටර් මිලියන 300ක (3x10^8 m/s) උපරිම වේගයෙන් ගමන් කරයි.'
      }
    ];

    for (var q in scienceQuestions) {
      await db.insert('questions', q);
    }

    // 3. Mathematics (ගණිතය) විෂයට අදාළව ප්‍රශ්න 3ක් ඇතුළත් කිරීම
    final int mathId = subjectIds['Mathematics']!;
    final mathQuestions = [
      {
        'subject_id': mathId,
        'question_text': '3x + 5 = 20 සමීකරණයේ x හි අගය සොයන්න.',
        'option_1': 'x = 3',
        'option_2': 'x = 5',
        'option_3': 'x = 15',
        'option_4': 'x = 10',
        'correct_option': 2,
        'explanation': '3x + 5 = 20  => 3x = 20 - 5  => 3x = 15  => x = 15 / 3  => x = 5.'
      },
      {
        'subject_id': mathId,
        'question_text': 'රවුමක විෂ්කම්භය 14 cm නම් එහි අරය (Radius) කොපමණද?',
        'option_1': '28 cm',
        'option_2': '14 cm',
        'option_3': '7 cm',
        'option_4': '3.5 cm',
        'correct_option': 3,
        'explanation': 'අරය යනු විෂ්කම්භයෙන් අඩකි. එමනිසා අරය = විෂ්කම්භය / 2 = 14 / 2 = 7 cm.'
      },
      {
        'subject_id': mathId,
        'question_text': 'පහත සංඛ්‍යා අතරින් ප්‍රථමක සංඛ්‍යාවක් (Prime Number) නොවන්නේ කුමක්ද?',
        'option_1': '2',
        'option_2': '3',
        'option_3': '5',
        'option_4': '9',
        'correct_option': 4,
        'explanation': 'ප්‍රථමක සංඛ්‍යාවක් යනු 1 සහ එම සංඛ්‍යාවෙන් පමණක් බෙදිය හැකි සංඛ්‍යාවන්ය. 9 යනු 1, 3 සහ 9 යන සංඛ්‍යා වලින් බෙදිය හැකි බැවින් එය ප්‍රථමක සංඛ්‍යාවක් නොවේ (එය භාජ්‍ය සංඛ්‍යාවකි).'
      }
    ];

    for (var q in mathQuestions) {
      await db.insert('questions', q);
    }
  }

  // ==========================================
  // 1. STUDENT AUTHENTICATION & PROFILE METHODS (Login/SignUp/Edit Profile)
  // ==========================================

  // නව සිසුවෙකු Register කිරීම (Sign Up Page)
  Future<int> registerStudent(StudentModel student) async {
    final db = await instance.database;
    // ඊමේල් ලිපිනය දැනටමත් පවතීදැයි පරීක්ෂා කිරීම
    final existing = await getStudentByEmail(student.email);
    if (existing != null) {
      throw Exception("මෙම ඊමේල් ලිපිනය දැනටමත් ලියාපදිංචි කර ඇත!");
    }
    return await db.insert('students', student.toMap());
  }

  // සිසුවා Login වීම (Login Page - Authentication)
  Future<StudentModel?> loginStudent(String email, String password) async {
    final db = await instance.database;
    final maps = await db.query(
      'students',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if (maps.isNotEmpty) {
      return StudentModel.fromMap(maps.first);
    }
    return null;
  }

  // ID එක අනුව සිසුවෙකුගේ විස්තර ලබාගැනීම
  Future<StudentModel?> getStudentById(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'students',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return StudentModel.fromMap(maps.first);
    }
    return null;
  }

  // Email එක අනුව සිසුවෙකුගේ විස්තර ලබාගැනීම
  Future<StudentModel?> getStudentByEmail(String email) async {
    final db = await instance.database;
    final maps = await db.query(
      'students',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (maps.isNotEmpty) {
      return StudentModel.fromMap(maps.first);
    }
    return null;
  }

  // සිසුවාගේ තොරතුරු වෙනස් කිරීම (Edit Profile Feature - Profile Page)
  Future<int> updateStudentProfile(StudentModel student) async {
    final db = await instance.database;
    return await db.update(
      'students',
      student.toMap(),
      where: 'id = ?',
      whereArgs: [student.id],
    );
  }

  // සිසුවාගේ XP ලකුණු සහ සාමාන්‍ය ලකුණු ප්‍රතිශතය යාවත්කාලීන කිරීම
  Future<void> updateStudentStats(int studentId, int additionalXp, double newAvgScore) async {
    final db = await instance.database;
    await db.rawUpdate('''
      UPDATE students 
      SET xp = xp + ?, avg_score = ?
      WHERE id = ?
    ''', [additionalXp, newAvgScore, studentId]);
  }

  // ==========================================
  // 2. SUBJECTS METHODS (Home Page & Choose Subject Page)
  // ==========================================

  // සියලුම විෂයන් ලැයිස්තුව ලබාගැනීම (Search filter ද ඇතුළත්ව - Choose Subject Page)
  Future<List<SubjectModel>> getSubjects({String? searchQuery}) async {
    final db = await instance.database;
    List<Map<String, dynamic>> results;

    if (searchQuery != null && searchQuery.isNotEmpty) {
      results = await db.query(
        'subjects',
        where: 'name LIKE ?',
        whereArgs: ['%$searchQuery%'],
      );
    } else {
      results = await db.query('subjects');
    }

    return results.map((map) => SubjectModel.fromMap(map)).toList();
  }

  // එක් විෂයක සම්පූර්ණ කිරීමේ ප්‍රතිශතය යාවත්කාලීන කිරීම (Progress Tracker)
  Future<int> updateSubjectProgress(int subjectId, double completedRate) async {
    final db = await instance.database;
    return await db.update(
      'subjects',
      {'completed_rate': completedRate},
      where: 'id = ?',
      whereArgs: [subjectId],
    );
  }

  // ==========================================
  // 3. QUESTIONS METHODS (Quiz Page)
  // ==========================================

  // විෂයට අදාළව ප්‍රශ්න ලබාගැනීම (Quiz Page)
  Future<List<QuestionModel>> getQuestionsBySubject(int subjectId) async {
    final db = await instance.database;
    final results = await db.query(
      'questions',
      where: 'subject_id = ?',
      whereArgs: [subjectId],
    );

    return results.map((map) => QuestionModel.fromMap(map)).toList();
  }

  // ==========================================
  // 4. QUIZ RESULTS & REVIEW METHODS (Results & Review Page)
  // ==========================================

  // ක්විස් එකක් අවසානයේ ප්‍රතිඵල සුරක්ෂිත කිරීම සහ විෂය ප්‍රගතිය / සිසුන්ගේ XP මට්ටම් යාවත්කාලීන කිරීම
  Future<int> saveQuizResult(QuizResultModel result, List<StudentAnswerModel> answers) async {
    final db = await instance.database;

    // Transaction එකක් මඟින් සියලුම දත්ත එකවර සුරක්ෂිත කිරීම (Database Consistency)
    return await db.transaction<int>((txn) async {
      // 1. quiz_results වගුවට ප්‍රතිඵලය ඇතුළත් කිරීම
      final resultId = await txn.insert('quiz_results', result.toMap());

      // 2. student_answers වගුවට සිසුවා ලබාදුන් සියලුම පිළිතුරු ඇතුළත් කිරීම
      for (var answer in answers) {
        final answerMap = {
          'result_id': resultId,
          'question_id': answer.questionId,
          'selected_option': answer.selectedOption,
          'is_correct': answer.isCorrect ? 1 : 0,
        };
        await txn.insert('student_answers', answerMap);
      }

      // 3. සිසුවාට ලැබෙන XP ගණනය කිරීම (සෑම නිවැරදි පිළිතුරකටම 50 XP බැගින්)
      final int gainedXp = result.score * 50;

      // 4. සිසුවාගේ මුළු විභාග ප්‍රතිඵල විශ්ලේෂණය කර සාමාන්‍ය ලකුණු මට්ටම (Average Score) සෙවීම
      final List<Map<String, dynamic>> allScores = await txn.rawQuery('''
        SELECT score, total_questions FROM quiz_results WHERE student_id = ?
      ''', [result.studentId]);

      int totalCorrect = 0;
      int totalQs = 0;
      for (var row in allScores) {
        totalCorrect += row['score'] as int;
        totalQs += row['total_questions'] as int;
      }
      final double newAvgScore = totalQs > 0 ? (totalCorrect / totalQs) * 100 : 0.0;

      // 5. සිසුවාගේ පැතිකඩෙහි (Profile) XP සහ Average Score යාවත්කාලීන කිරීම
      await txn.rawUpdate('''
        UPDATE students 
        SET xp = xp + ?, avg_score = ?
        WHERE id = ?
      ''', [gainedXp, newAvgScore, result.studentId]);

      // 6. මෙම විෂය සම්පූර්ණ කිරීමේ ප්‍රතිශතය (Subject Completion Progress) යාවත්කාලීන කිරීම
      final List<Map<String, dynamic>> subjectResults = await txn.query(
        'quiz_results',
        where: 'student_id = ? AND subject_id = ?',
        whereArgs: [result.studentId, result.subjectId],
      );

      // සරලව: අවම වශයෙන් 1 වතාවක්වත් ක්විස් එකක් කළහොත් completion 100% (1.0) ලෙස හෝ 
      // කළ වාර ගණන අනුව ප්‍රගතිය වැඩිවන පරිදි සකස් කළ හැක. 
      // මෙහිදී අපි ලකුණු මට්ටම අනුව 1.0 (100% Done) දක්වා update කරමු.
      double bestAccuracy = 0.0;
      for (var res in subjectResults) {
        double acc = (res['score'] as int) / (res['total_questions'] as int);
        if (acc > bestAccuracy) bestAccuracy = acc;
      }
      
      await txn.update(
        'subjects',
        {'completed_rate': bestAccuracy},
        where: 'id = ?',
        whereArgs: [result.subjectId],
      );

      return resultId;
    });
  }

  // සිසුවෙකු මුහුණ දුන් සියලුම ක්විස් ප්‍රතිඵල ලබා ගැනීම (Home / Profile Page සඳහා)
  Future<List<QuizResultModel>> getStudentQuizHistory(int studentId) async {
    final db = await instance.database;
    final results = await db.query(
      'quiz_results',
      where: 'student_id = ?',
      orderBy: 'date_taken DESC',
    );

    return results.map((map) => QuizResultModel.fromMap(map)).toList();
  }

  // "Review Answer" පිටුව සඳහා සිසුවා ක්විස් එකකදී ලබාදුන් පිළිතුරු සහ අදාළ ප්‍රශ්න විස්තර ලබාගැනීම
  Future<List<StudentAnswerModel>> getAnswersForQuizResult(int resultId) async {
    final db = await instance.database;

    // INNER JOIN භාවිතයෙන් answers සහ questions එකවර ලබා ගැනීම
    final List<Map<String, dynamic>> queryResults = await db.rawQuery('''
      SELECT sa.*, q.question_text, q.option_1, q.option_2, q.option_3, q.option_4, q.correct_option, q.explanation, q.subject_id
      FROM student_answers sa
      INNER JOIN questions q ON sa.question_id = q.id
      WHERE sa.result_id = ?
    ''', [resultId]);

    return queryResults.map((row) {
      final question = QuestionModel(
        id: row['question_id'] as int,
        subjectId: row['subject_id'] as int,
        questionText: row['question_text'] as String,
        option1: row['option_1'] as String,
        option2: row['option_2'] as String,
        option3: row['option_3'] as String,
        option4: row['option_4'] as String,
        correctOption: row['correct_option'] as int,
        explanation: row['explanation'] as String,
      );

      return StudentAnswerModel.fromMap(row, question: question);
    }).toList();
  }
}
