// සිසුවා ලබාගත් අවසාන ලකුණු සහ ප්‍රතිඵල විස්තර නියෝජනය කරන Data Model පන්තිය (Firebase Version)
class QuizResultModel {
  final String? id;          // Firestore Document ID
  final String studentId;    // ක්විස් එකට මුහුණ දුන් සිසුවාගේ UID (Firebase Auth)
  final String subjectId;    // අදාළ විෂයෙහි Firestore Document ID
  final int score;           // නිවැරදි පිළිතුරු සංඛ්‍යාව
  final int totalQuestions;  // මුළු ප්‍රශ්න සංඛ්‍යාව
  final int timeSpent;       // ක්විස් එකට ගතවූ කාලය (තත්පර)
  final String dateTaken;    // ක්විස් එකට මුහුණ දුන් දිනය

  QuizResultModel({
    this.id,
    required this.studentId,
    required this.subjectId,
    required this.score,
    required this.totalQuestions,
    required this.timeSpent,
    required this.dateTaken,
  });

  // Firestore Document Snapshot වෙතින් QuizResultModel සෑදීම
  factory QuizResultModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return QuizResultModel(
      id: id ?? map['id'] as String?,
      studentId: map['studentId'] as String? ?? '',
      subjectId: map['subjectId'] as String? ?? '',
      score: (map['score'] as num?)?.toInt() ?? 0,
      totalQuestions: (map['totalQuestions'] as num?)?.toInt() ?? 0,
      timeSpent: (map['timeSpent'] as num?)?.toInt() ?? 0,
      dateTaken: map['dateTaken'] as String? ?? DateTime.now().toIso8601String(),
    );
  }

  // Firestore වෙත ඇතුළත් කිරීම සඳහා Map එකක් බවට හැරවීම
  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'subjectId': subjectId,
      'score': score,
      'totalQuestions': totalQuestions,
      'timeSpent': timeSpent,
      'dateTaken': dateTaken,
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
