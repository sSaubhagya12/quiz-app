// සිසුවා ලබාගත් අවසාන ලකුණු සහ ප්‍රතිඵල විස්තර නියෝජනය කරන Data Model පන්තිය
class QuizResultModel {
  final int? id;
  final int studentId;       // ක්විස් එකට මුහුණ දුන් සිසුවාගේ ID එක (Foreign Key)
  final int subjectId;       // අදාළ විෂයෙහි ID එක (Foreign Key)
  final int score;           // නිවැරදි පිළිතුරු සංඛ්‍යාව (උදා: 32)
  final int totalQuestions;  // මුළු ප්‍රශ්න සංඛ්‍යාව (උදා: 40)
  final int timeSpent;       // ක්විස් එක සඳහා ගතවූ කාලය - තත්පර වලින් (උදා: 1122 තත්පර = විනාඩි 18:42)
  final String dateTaken;    // ක්විස් එකට මුහුණ දුන් දිනය සහ වේලාව

  QuizResultModel({
    this.id,
    required this.studentId,
    required this.subjectId,
    required this.score,
    required this.totalQuestions,
    required this.timeSpent,
    required this.dateTaken,
  });

  // SQLite වෙතින් ලබාගන්නා Map එකක් QuizResultModel වස්තුවක් බවට පත් කිරීම
  factory QuizResultModel.fromMap(Map<String, dynamic> map) {
    return QuizResultModel(
      id: map['id'] as int?,
      studentId: map['student_id'] as int,
      subjectId: map['subject_id'] as int,
      score: map['score'] as int,
      totalQuestions: map['total_questions'] as int,
      timeSpent: map['time_spent'] as int,
      dateTaken: map['date_taken'] as String,
    );
  }

  // SQLite වෙත ඇතුළත් කිරීම සඳහා Map එකක් බවට හැරවීම
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'student_id': studentId,
      'subject_id': subjectId,
      'score': score,
      'total_questions': totalQuestions,
      'time_spent': timeSpent,
      'date_taken': dateTaken,
    };
  }

  // ලකුණු ප්‍රතිශතය ගණනය කිරීමේ ක්‍රමවේදය (උදා: 80% Accuracy)
  double get accuracyPercentage {
    if (totalQuestions == 0) return 0.0;
    return (score / totalQuestions) * 100;
  }

  // ගතවූ කාලය විනාඩි සහ තත්පර ලෙස සකස් කර පෙන්වීම (Format: MM:SS)
  String get formattedTime {
    final minutes = (timeSpent ~/ 60).toString().padLeft(2, '0');
    final seconds = (timeSpent % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }
}
