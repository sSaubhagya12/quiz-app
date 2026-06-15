// සිසුවාගේ තොරතුරු නියෝජනය කරන Data Model පන්තිය (Firebase Firestore Version)
class StudentModel {
  final String? uid;      // Firebase Auth UID (Firestore Document ID ලෙසද භාවිතා කරනු ලැබේ)
  final String name;
  final String email;
  final String school;   // පාසලේ නම
  final String grade;    // ශ්‍රේණිය (උදා: Grade 11)
  final int oLevelYear;  // විභාගයට මුහුණ දෙන වසර (උදා: 2026)
  final int xp;          // සිසුවා ලබාගත් මුළු XP ලකුණු ප්‍රමාණය
  final double avgScore; // සිසුවාගේ සාමාන්‍ය ලකුණු ප්‍රතිශතය (Average Score %)

  StudentModel({
    this.uid,
    required this.name,
    required this.email,
    required this.school,
    required this.grade,
    required this.oLevelYear,
    this.xp = 0,
    this.avgScore = 0.0,
  });

  // Firestore දත්ත ගබඩාවට ඇතුළත් කිරීමට Map එකක් බවට පරිවර්තනය කිරීම (Serialization)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'school': school,
      'grade': grade,
      'oLevelYear': oLevelYear,
      'xp': xp,
      'avgScore': avgScore,
    };
  }

  // Firestore දත්ත ගබඩාවෙන් ලැබෙන Map එකක් StudentModel වස්තුවක් බවට පරිවර්තනය කිරීම (Deserialization)
  factory StudentModel.fromMap(Map<String, dynamic> map, {String? uid}) {
    return StudentModel(
      uid: uid ?? map['uid'] as String?,
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      school: map['school'] as String? ?? '',
      grade: map['grade'] as String? ?? '',
      oLevelYear: (map['oLevelYear'] as num?)?.toInt() ?? 2026,
      xp: (map['xp'] as num?)?.toInt() ?? 0,
      avgScore: (map['avgScore'] as num?)?.toDouble() ?? 0.0,
    );
  }

  // සිසුවාගේ තොරතුරු වෙනස් කර Update කිරීමේදී (Edit Profile feature) භාවිතා කිරීමට copyWith ක්‍රමවේදය
  StudentModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? school,
    String? grade,
    int? oLevelYear,
    int? xp,
    double? avgScore,
  }) {
    return StudentModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      school: school ?? this.school,
      grade: grade ?? this.grade,
      oLevelYear: oLevelYear ?? this.oLevelYear,
      xp: xp ?? this.xp,
      avgScore: avgScore ?? this.avgScore,
    );
  }
}
