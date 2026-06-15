// විෂයන් සහ ඒවායේ ප්‍රගතිය (Progress) නියෝජනය කරන Data Model පන්තිය (Firebase Version)
class SubjectModel {
  final String? id;          // Firestore Document ID
  final String name;         // විෂයේ නම (උදා: Science, Mathematics)
  final String iconName;     // UI එකෙහි අදාළ Icon එක පෙන්වීමට භාවිතා කරන නම
  final String? imageUrl;    // විෂය නියෝජනය කරන පින්තූරයේ URL එක
  final int totalQuestions;  // විෂයට අදාළ මුළු ප්‍රශ්න සංඛ්‍යාව
  final double completedRate; // සිසුවා විෂය සම්පූර්ණ කර ඇති ප්‍රතිශතය (0.0 - 1.0)

  SubjectModel({
    this.id,
    required this.name,
    required this.iconName,
    this.imageUrl,
    this.totalQuestions = 0,
    this.completedRate = 0.0,
  });

  // Firestore Document Snapshot වෙතින් SubjectModel සෑදීම
  factory SubjectModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return SubjectModel(
      id: id ?? map['id'] as String?,
      name: map['name'] as String? ?? '',
      iconName: map['iconName'] as String? ?? 'book',
      imageUrl: map['imageUrl'] as String?,
      totalQuestions: (map['totalQuestions'] as num?)?.toInt() ?? 0,
      completedRate: (map['completedRate'] as num?)?.toDouble() ?? 0.0,
    );
  }

  // Firestore වෙත ගබඩා කිරීමට Map එකක් බවට හැරවීම
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'iconName': iconName,
      'imageUrl': imageUrl,
      'totalQuestions': totalQuestions,
      'completedRate': completedRate,
    };
  }

  // වෙනස්කම් සහිතව නව SubjectModel එකක් සෑදීමට
  SubjectModel copyWith({
    String? id,
    String? name,
    String? iconName,
    String? imageUrl,
    int? totalQuestions,
    double? completedRate,
  }) {
    return SubjectModel(
      id: id ?? this.id,
      name: name ?? this.name,
      iconName: iconName ?? this.iconName,
      imageUrl: imageUrl ?? this.imageUrl,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      completedRate: completedRate ?? this.completedRate,
    );
  }
}
