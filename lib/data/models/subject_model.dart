// විෂයන් සහ ඒවායේ ප්‍රගතිය (Progress) නියෝජනය කරන Data Model පන්තිය
class SubjectModel {
  final int? id;
  final String name;             // විෂයේ නම (උදා: Science, Mathematics)
  final String iconName;         // UI එකෙහි අදාළ Icon එක පෙන්වීමට භාවිතා කරන නම
  final int totalQuestions;      // විෂයට අදාළ මුළු ප්‍රශ්න සංඛ්‍යාව
  final double completedRate;    // සිසුවා විෂය සම්පූර්ණ කර ඇති ප්‍රතිශතය (0.0 සිට 1.0 දක්වා - Progress Bar සඳහා)

  SubjectModel({
    this.id,
    required this.name,
    required this.iconName,
    this.totalQuestions = 0,
    this.completedRate = 0.0,
  });

  // දත්ත SQLite දත්ත ගබඩාවෙන් ලබාගැනීම සඳහා Map එකකින් SubjectModel වස්තුවක් සැකසීම
  factory SubjectModel.fromMap(Map<String, dynamic> map) {
    return SubjectModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      iconName: map['icon_name'] as String,
      totalQuestions: map['total_questions'] as int? ?? 0,
      completedRate: (map['completed_rate'] as num? ?? 0.0).toDouble(),
    );
  }

  // දත්ත SQLite වෙත ගබඩා කිරීමට Map එකක් බවට හැරවීම
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon_name': iconName,
      'total_questions': totalQuestions,
      'completed_rate': completedRate,
    };
  }

  // වෙනස්කම් සහිතව නව SubjectModel එකක් සෑදීමට (Progress update කිරීමේදී පහසු වේ)
  SubjectModel copyWith({
    int? id,
    String? name,
    String? iconName,
    int? totalQuestions,
    double? completedRate,
  }) {
    return SubjectModel(
      id: id ?? this.id,
      name: name ?? this.name,
      iconName: iconName ?? this.iconName,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      completedRate: completedRate ?? this.completedRate,
    );
  }
}
