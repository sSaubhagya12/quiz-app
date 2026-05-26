// විභාග ප්‍රශ්න සහ පිළිතුරු විකල්ප නියෝජනය කරන Data Model පන්තිය
class QuestionModel {
  final int? id;
  final int subjectId;          // මෙම ප්‍රශ්නය අයත් වන විෂයයේ ID එක (Foreign Key)
  final String questionText;    // ප්‍රශ්නයේ පෙළ (උදා: බලයේ ජාත්‍යන්තර ඒකකය කුමක්ද?)
  final String option1;         // පිළිතුරු විකල්පය 1
  final String option2;         // පිළිතුරු විකල්පය 2
  final String option3;         // පිළිතුරු විකල්පය 3
  final String option4;         // පිළිතුරු විකල්පය 4
  final int correctOption;      // නිවැරදි පිළිතුරෙහි අංකය (1, 2, 3, හෝ 4)
  final String explanation;     // පිළිතුර නිවැරදි වීමට හේතුව පැහැදිලි කරන විවරණය (Review Answer සඳහා)

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

  // SQLite වෙතින් ලබාගන්නා Map එකක් QuestionModel වස්තුවක් බවට පත් කිරීම
  factory QuestionModel.fromMap(Map<String, dynamic> map) {
    return QuestionModel(
      id: map['id'] as int?,
      subjectId: map['subject_id'] as int,
      questionText: map['question_text'] as String,
      option1: map['option_1'] as String,
      option2: map['option_2'] as String,
      option3: map['option_3'] as String,
      option4: map['option_4'] as String,
      correctOption: map['correct_option'] as int,
      explanation: map['explanation'] as String? ?? '',
    );
  }

  // SQLite වෙත ඇතුළත් කිරීම සඳහා Map එකක් බවට හැරවීම
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subject_id': subjectId,
      'question_text': questionText,
      'option_1': option1,
      'option_2': option2,
      'option_3': option3,
      'option_4': option4,
      'correct_option': correctOption,
      'explanation': explanation,
    };
  }
}
