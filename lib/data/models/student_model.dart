// සිසුවාගේ තොරතුරු නියෝජනය කරන Data Model පන්තිය
class StudentModel {
  final int? id;
  final String name;
  final String email;
  final String password; // දත්ත ගබඩාවේ Authentication සඳහා
  final String school;   // පාසලේ නම
  final String grade;    // ශ්‍රේණිය (උදා: Grade 11)
  final int oLevelYear;  // විභාගයට මුහුණ දෙන වසර (උදා: 2024)
  final int xp;          // සිසුවා ලබාගත් මුළු XP ලකුණු ප්‍රමාණය
  final double avgScore; // සිසුවාගේ සාමාන්‍ය ලකුණු ප්‍රතිශතය (Average Score %)

  StudentModel({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.school,
    required this.grade,
    required this.oLevelYear,
    this.xp = 0,
    this.avgScore = 0.0,
  });

  // දත්ත SQLite දත්ත ගබඩාවට ඇතුළත් කිරීමට Map එකක් බවට පරිවර්තනය කිරීම (Serialization)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'school': school,
      'grade': grade,
      'o_level_year': oLevelYear,
      'xp': xp,
      'avg_score': avgScore,
    };
  }

  // SQLite දත්ත ගබඩාවෙන් ලැබෙන Map එකක් StudentModel වස්තුවක් බවට පරිවර්තනය කිරීම (Deserialization)
  factory StudentModel.fromMap(Map<String, dynamic> map) {
    return StudentModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      email: map['email'] as String,
      password: map['password'] as String,
      school: map['school'] as String,
      grade: map['grade'] as String,
      oLevelYear: map['o_level_year'] as int,
      xp: map['xp'] as int? ?? 0,
      avgScore: (map['avg_score'] as num? ?? 0.0).toDouble(),
    );
  }

  // සිසුවාගේ තොරතුරු වෙනස් කර Update කිරීමේදී (Edit Profile feature) භාවිතා කිරීමට copyWith ක්‍රමවේදය
  StudentModel copyWith({
    int? id,
    String? name,
    String? email,
    String? password,
    String? school,
    String? grade,
    int? oLevelYear,
    int? xp,
    double? avgScore,
  }) {
    return StudentModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      school: school ?? this.school,
      grade: grade ?? this.grade,
      oLevelYear: oLevelYear ?? this.oLevelYear,
      xp: xp ?? this.xp,
      avgScore: avgScore ?? this.avgScore,
    );
  }
}
