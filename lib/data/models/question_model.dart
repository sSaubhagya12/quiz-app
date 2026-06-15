// විභාග ප්‍රශ්න සහ පිළිතුරු විකල්ප නියෝජනය කරන Data Model පන්තිය (Firebase Version)
class QuestionModel {
  final String? id;          // Firestore Document ID
  final String subjectId;    // මෙම ප්‍රශ්නය අයත් වන විෂයයේ Firestore ID
  final String questionText; // ප්‍රශ්නයේ පෙළ
  final String option1;      // පිළිතුරු විකල්පය 1
  final String option2;      // පිළිතුරු විකල්පය 2
  final String option3;      // පිළිතුරු විකල්පය 3
  final String option4;      // පිළිතුරු විකල්පය 4
  final int correctOption;   // නිවැරදි පිළිතුරෙහි අංකය (1, 2, 3, හෝ 4)
  final String explanation;  // පිළිතුර නිවැරදි වීමට හේතුව (Review Answer සඳහා)

  QuestionModel({
    this.id,
    required this.subjectId,
    required this.questionText,
    required this.option1,
    required this.option2,
    required this.option3,
    required this.option4,
    required this.correctOption,
    required this.explanation,
  });

  // Firestore Document Snapshot වෙතින් QuestionModel සෑදීම
  factory QuestionModel.fromMap(Map<String, dynamic> map, {String? id, String? subjectId}) {
    return QuestionModel(
      id: id ?? map['id'] as String?,
      subjectId: subjectId ?? map['subjectId'] as String? ?? '',
      questionText: map['questionText'] as String? ?? '',
      option1: map['option1'] as String? ?? '',
      option2: map['option2'] as String? ?? '',
      option3: map['option3'] as String? ?? '',
      option4: map['option4'] as String? ?? '',
      correctOption: (map['correctOption'] as num?)?.toInt() ?? 1,
      explanation: map['explanation'] as String? ?? '',
    );
  }

  // Firestore වෙත ඇතුළත් කිරීම සඳහා Map එකක් බවට හැරවීම
  Map<String, dynamic> toMap() {
    return {
      'subjectId': subjectId,
      'questionText': questionText,
      'option1': option1,
      'option2': option2,
      'option3': option3,
      'option4': option4,
      'correctOption': correctOption,
      'explanation': explanation,
    };
  }
}
