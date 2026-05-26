import 'question_model.dart';

// සිසුවා එක් ප්‍රශ්නයකට ලබා දුන් පිළිතුර ගබඩා කරන Data Model පන්තිය
class StudentAnswerModel {
  final int? id;
  final int resultId;          // මෙම පිළිතුර අයත් වන Quiz Result එකෙහි ID එක (Foreign Key)
  final int questionId;        // අදාළ ප්‍රශ්නයෙහි ID එක (Foreign Key)
  final int selectedOption;    // සිසුවා තෝරාගත් පිළිතුරු විකල්පය (1, 2, 3, හෝ 4)
  final bool isCorrect;        // පිළිතුර නිවැරදිද නැද්ද යන්න (True/False)
  
  // UI එකෙහි Review Panel එක පහසුවෙන් පෙන්වීම සඳහා ප්‍රශ්නයේ විස්තරද ඇතුළත් කළ හැක
  final QuestionModel? question; 

  StudentAnswerModel({
    this.id,
    required this.resultId,
    required this.questionId,
    required this.selectedOption,
    required this.isCorrect,
    this.question,
  });

  // SQLite වෙතින් ලබාගන්නා Map එකක් StudentAnswerModel වස්තුවක් බවට පත් කිරීම
  factory StudentAnswerModel.fromMap(Map<String, dynamic> map, {QuestionModel? question}) {
    return StudentAnswerModel(
      id: map['id'] as int?,
      resultId: map['result_id'] as int,
      questionId: map['question_id'] as int,
      selectedOption: map['selected_option'] as int,
      isCorrect: (map['is_correct'] as int) == 1,
      question: question,
    );
  }

  // SQLite වෙත ඇතුළත් කිරීම සඳහා Map එකක් බවට හැරවීම
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'result_id': resultId,
      'question_id': questionId,
      'selected_option': selectedOption,
      'is_correct': isCorrect ? 1 : 0,
    };
  }
}
