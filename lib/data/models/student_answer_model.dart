import 'question_model.dart';

// සිසුවා එක් ප්‍රශ්නයකට ලබා දුන් පිළිතුර ගබඩා කරන Data Model පන්තිය (Firebase Version)
class StudentAnswerModel {
  final String? id;          // Firestore Document ID
  final String resultId;     // මෙම පිළිතුර අයත් වන Quiz Result Document ID
  final String questionId;   // අදාළ ප්‍රශ්නයෙහි Firestore Document ID
  final int selectedOption;  // සිසුවා තෝරාගත් පිළිතුරු විකල්පය (1, 2, 3, හෝ 4)
  final bool isCorrect;      // පිළිතුර නිවැරදිද නැද්ද යන්න

  // UI එකෙහි Review Panel එකේ සම්පූර්ණ ප්‍රශ්නය දර්ශනය කිරීමට
  final QuestionModel? question;

  StudentAnswerModel({
    this.id,
    required this.resultId,
    required this.questionId,
    required this.selectedOption,
    required this.isCorrect,
    this.question,
  });

  // Firestore Document Snapshot වෙතින් StudentAnswerModel සෑදීම
  factory StudentAnswerModel.fromMap(Map<String, dynamic> map, {String? id, QuestionModel? question}) {
    return StudentAnswerModel(
      id: id ?? map['id'] as String?,
      resultId: map['resultId'] as String? ?? '',
      questionId: map['questionId'] as String? ?? '',
      selectedOption: (map['selectedOption'] as num?)?.toInt() ?? -1,
      isCorrect: map['isCorrect'] as bool? ?? false,
      question: question,
    );
  }

  // Firestore වෙත ඇතුළත් කිරීම සඳහා Map එකක් බවට හැරවීම
  Map<String, dynamic> toMap() {
    return {
      'resultId': resultId,
      'questionId': questionId,
      'selectedOption': selectedOption,
      'isCorrect': isCorrect,
    };
  }
}
