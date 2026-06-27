import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/student_model.dart';
import '../models/subject_model.dart';
import '../models/question_model.dart';
import '../models/quiz_result_model.dart';
import '../models/student_answer_model.dart';

// Firebase සේවා හසුරුවන ප්‍රධාන Helper පන්තිය (Singleton Pattern)
// SQLite DatabaseHelper ප්‍රතිස්ථාපනය කරයි
class FirebaseService {
  static final FirebaseService instance = FirebaseService._init();
  FirebaseService._init();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Offline Mode indicator for demo setup
  bool _isOfflineMode = false;
  bool get isOfflineMode => _isOfflineMode;

  // Seeding lock to prevent concurrent duplicate seeds
  bool _seedingInProgress = false;

  // In-memory data for offline mode
  StudentModel? _offlineStudent;
  final List<SubjectModel> _offlineSubjects = [
    SubjectModel(
      id: 'religion',
      name: 'Religion',
      iconName: 'volunteer_activism',
      imageUrl:
          'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400&q=80',
      totalQuestions: 0,
      completedRate: 0.0,
    ),
    SubjectModel(
      id: 'sinhala',
      name: 'Sinhala',
      iconName: 'book',
      imageUrl:
          'https://images.unsplash.com/photo-1506880018603-83d5b814b5a6?w=400&q=80',
      totalQuestions: 30,
      completedRate: 0.0,
    ),
    SubjectModel(
      id: 'english',
      name: 'English',
      iconName: 'language',
      imageUrl:
          'https://images.unsplash.com/photo-1451226428352-cf66b8a0317a?w=400&q=80',
      totalQuestions: 0,
      completedRate: 0.0,
    ),
    SubjectModel(
      id: 'math',
      name: 'Mathematics',
      iconName: 'calculate',
      imageUrl:
          'https://images.unsplash.com/photo-1509228468518-180dd4864904?w=400&q=80',
      totalQuestions: 3,
      completedRate: 0.0,
    ),
    SubjectModel(
      id: 'sci',
      name: 'Science',
      iconName: 'science',
      imageUrl:
          'https://images.unsplash.com/photo-1507668077129-56e32842fceb?w=400&q=80',
      totalQuestions: 30,
      completedRate: 0.0,
    ),
    SubjectModel(
      id: 'history',
      name: 'History',
      iconName: 'history',
      imageUrl:
          'https://images.unsplash.com/photo-1461360370896-922624d12aa1?w=400&q=80',
      totalQuestions: 30,
      completedRate: 0.0,
    ),
    SubjectModel(
      id: 'business',
      name: 'Business & Accounting Studies',
      iconName: 'analytics',
      imageUrl:
          'https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=400&q=80',
      totalQuestions: 0,
      completedRate: 0.0,
    ),
    SubjectModel(
      id: 'geo',
      name: 'Geography',
      iconName: 'public',
      imageUrl:
          'https://images.unsplash.com/photo-1524661135-423995f22d0b?w=400&q=80',
      totalQuestions: 0,
      completedRate: 0.0,
    ),
    SubjectModel(
      id: 'civic',
      name: 'Civic Education',
      iconName: 'gavel',
      imageUrl:
          'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?w=400&q=80',
      totalQuestions: 0,
      completedRate: 0.0,
    ),
    SubjectModel(
      id: 'music',
      name: 'Music',
      iconName: 'music_note',
      imageUrl:
          'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=400&q=80',
      totalQuestions: 0,
      completedRate: 0.0,
    ),
    SubjectModel(
      id: 'dancing',
      name: 'Dancing',
      iconName: 'emoji_people',
      imageUrl:
          'https://images.unsplash.com/photo-1508700115892-45ecd05ae2ad?w=400&q=80',
      totalQuestions: 0,
      completedRate: 0.0,
    ),
    SubjectModel(
      id: 'art',
      name: 'Art (Act)',
      iconName: 'palette',
      imageUrl:
          'https://images.unsplash.com/photo-1513364776144-60967b0f800f?w=400&q=80',
      totalQuestions: 0,
      completedRate: 0.0,
    ),
    SubjectModel(
      id: 'ict',
      name: 'Information & Communication',
      iconName: 'computer',
      imageUrl:
          'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?w=400&q=80',
      totalQuestions: 0,
      completedRate: 0.0,
    ),
    SubjectModel(
      id: 'agriculture',
      name: 'Agriculture & Food Technology',
      iconName: 'agriculture',
      imageUrl:
          'https://images.unsplash.com/photo-1464226184884-fa280b87c3a9?w=400&q=80',
      totalQuestions: 0,
      completedRate: 0.0,
    ),
    SubjectModel(
      id: 'health',
      name: 'Health & Physical Education',
      iconName: 'fitness_center',
      imageUrl:
          'https://images.unsplash.com/photo-1476480862126-209bfaa8edc8?w=400&q=80',
      totalQuestions: 0,
      completedRate: 0.0,
    ),
  ];

  final Map<String, List<QuestionModel>> _offlineQuestions = {
    'religion': [
      QuestionModel(
          id: 'rel_q1',
          subjectId: 'religion',
          questionText:
              'සිදුහත් බෝසතාණන් වහන්සේ දේවාරාධනය ලැබීමෙන් පසු තම අවසන් උපත සඳහා සුදුසු පසුබිම නුවණින් විමසා බැලීම හඳුන්වනුයේ,',
          option1: 'සමතිස් පෙරුම් පිරීම නමිනි.',
          option2: 'පංච මහා විලෝකනය නමිනි.',
          option3: 'පංච මහා ස්වප්න (සිහින) දැකීම නමිනි.',
          option4: 'චතුරංග සමන්නාගත වීර්ය වැඩීම නමිනි.',
          correctOption: 2,
          explanation: 'නිවැරදි පිළිතුර 2 වේ.'),
      QuestionModel(
          id: 'rel_q2',
          subjectId: 'religion',
          questionText:
              'තරුණ සිදුහත් කුමාරයාට ජීවිතයේ සැබෑ යථාර්ථය අවබෝධ වුයේ,',
          option1: 'නිබ්බුත පද ඇසීමෙනි.',
          option2: 'මාර දූවරුන්ගේ රංගනය දැකීමෙනි.',
          option3: 'සතර පෙර නිමිති දැකීමෙනි.',
          option4: 'නළඟනන්ගේ විප්රකාර දැකීමෙනි.',
          correctOption: 3,
          explanation: 'නිවැරදි පිළිතුර 3 වේ.'),
      QuestionModel(
          id: 'rel_q3',
          subjectId: 'religion',
          questionText:
              'යසෝදරා දේවියට පුතකු ලද බව පණිවුඩකරුවකු මගින් අසන්නට ලැබුණු විට සිදුහත් බෝසතුන්ගේ මුවින් "රාහුලෝ ජාතෝ බන්ධනං ජාතං" යනුවෙන් ප්රකාශ වූයේ,',
          option1: 'තම දේවියට පුතකු උපන් බව ඇසීම සතුට ගෙන දෙන්නක් වූ බැවිනි.',
          option2: 'රාහුල කුමාරයාට අනාගතයේ බන්ධන ඇතිවන බැවිනි.',
          option3: 'උපන් කුමාරයාට රාහුල යන නම තැබිය යුතු වූ බැවිනි.',
          option4: 'ගිහිගෙයින් නික්ම පැවිදි වීමට බාධාවක් වන බැවිනි.',
          correctOption: 4,
          explanation: 'නිවැරදි පිළිතුර 4 වේ.'),
      QuestionModel(
          id: 'rel_q4',
          subjectId: 'religion',
          questionText:
              '"අනුන් මාගේ, ධර්මයේ හෝ සංඝයාගේ අගුණ හෝ ගුණ කියතොත් ඉන් අසතුටට හෝ ප්රීතියට පත් නොවිය යුතුය. " බුදුරජාණන් වහන්සේ මෙලෙස දේශනා කළේ එක්තරා පරිබ්රාජකයකුගේ හා ඔහුගේ අන්තේවාසිකයාගේ කතාබහක් නිසාය. ඒ දෙදෙනාගේ නම් ඇතුළත් වරණය කුමක්ද?',
          option1: 'සුප්පිය හා සෝණදණ්ඩ',
          option2: 'බ්රහ්ම දත්ත හා සුප්රබුද්ධ',
          option3: 'සුප්පිය හා බ්රහ්ම දත්ත',
          option4: 'සුප්පිය හා තෝදෙය්ය',
          correctOption: 3,
          explanation: 'නිවැරදි පිළිතුර 3 වේ.'),
      QuestionModel(
          id: 'rel_q5',
          subjectId: 'religion',
          questionText:
              'බුදුරජාණන් වහන්සේ නිශ්ශබ්දතාව අගය කරන බවත්, තම අසපුවට උන්වහන්සේ වඩින නිසා නිශ්ශබ්දතාව ආරක්ෂා කරන ලෙසත් තම සිසුනට දන්වනු ලැබූයේ,',
          option1: 'උපක ආජීවකයා විසිනි.',
          option2: 'සංජය පිරිවැජියා විසිනි.',
          option3: 'චංකී බ්රාහ්මණයා විසිනි.',
          option4: 'පොට්ඨපාද පිරිවැජියා විසිනි.',
          correctOption: 4,
          explanation: 'නිවැරදි පිළිතුර 4 වේ.'),
      QuestionModel(
          id: 'rel_q6',
          subjectId: 'religion',
          questionText:
              'සිද්ධාර්ථ කුමාරයාගේ උත්පත්තිය හා බුදුරජාණන් වහන්සේගේ පරිනිර්වාණය සිදු වූ ස්ථාන දැක්වෙන වරණය කුමක්ද?',
          option1: 'නිග්රෝධ උයන හා කලන්දක නිවාප',
          option2: 'ලුම්බිණි සල් උයන හා උපවත්තන සල් උයන',
          option3: 'ජීවක අඹ උයන හා සප්තපර්ණී ගුහාව',
          option4: 'ලුම්බිණි සල් උයන හා ඉසිපතන මිගදාය',
          correctOption: 2,
          explanation: 'නිවැරදි පිළිතුර 2 වේ.'),
      QuestionModel(
          id: 'rel_q7',
          subjectId: 'religion',
          questionText:
              'බුදුරජාණන් වහන්සේ පාරිලෙය්ය වනයෙහි වැඩ වසමින් වඳුරකුගේ හා ඇතකුගේ උවටැන් ලබමින් ගත කළේ කිනම් වස්කාලය ද?',
          option1: 'පස්වන වස්කාලයයි.',
          option2: 'හයවන වස්කාලයයි.',
          option3: 'අටවන වස්කාලයයි.',
          option4: 'දහවන වස්කාලයයි.',
          correctOption: 4,
          explanation: 'නිවැරදි පිළිතුර 4 වේ.'),
      QuestionModel(
          id: 'rel_q8',
          subjectId: 'religion',
          questionText:
              'බුදුරජාණන් වහන්සේගේ වර්ණනාවට භාජනය වූ උදේන, ගෝතමක, සත්තම්බක, සාරන්දද ආදී රමණීය චෛත්ය ස්ථාන පිහිටියේ,',
          option1: 'විශාලා මහනුවරයි.',
          option2: 'රජගහ නුවරයි.',
          option3: 'කිඹුල්වත් නුවරයි.',
          option4: 'උදේනි නුවරයි.',
          correctOption: 1,
          explanation: 'නිවැරදි පිළිතුර 1 වේ.'),
      QuestionModel(
          id: 'rel_q9',
          subjectId: 'religion',
          questionText:
              'සුදත්ත හෙවත් අනේපිඬු සිටුතුමාට බුදුරජාණන් වහන්සේ පළමු වරට මුණ ගැසුනේ උන්වහන්සේ,',
          option1: 'ඉසිපතන මිගදායේ වැඩ සිටියදී ය.',
          option2: 'අනෝමා නදී තීරයේ අනුපිය අඹ වනයේ වැඩ සිටියදී ය.',
          option3: 'රජගහ නුවර සීත වනයේ වැඩ සිටියදී ය.',
          option4: 'විශාලා මහ නුවර කූඨාගාර ශාලාවේ වැඩ සිටියදීය.',
          correctOption: 3,
          explanation: 'නිවැරදි පිළිතුර 3 වේ.'),
      QuestionModel(
          id: 'rel_q10',
          subjectId: 'religion',
          questionText:
              'පුද්ගලයාට වැළඳෙන විවිධාකාර රෝගාබාධ හා ඒ සඳහා හේතුවන කරුණු පිළිබඳ පෙන්වා දෙමින් දේශනා කළ සූත්ර ධර්මය වන්නේ,',
          option1: 'ඉසිගිලි සූත්රයයි.',
          option2: 'ගිරිමානන්ද සූත්රයයි.',
          option3: 'වුන්ද සූත්රයයි.',
          option4: 'මහාසමය සූත්රයයි.',
          correctOption: 2,
          explanation: 'නිවැරදි පිළිතුර 2 වේ.'),
      QuestionModel(
          id: 'rel_q11',
          subjectId: 'religion',
          questionText:
              'බුදුරජාණන් වහන්සේගේ අනුශාසනය පරිදි, බඹරා මල නොතලා රොන් ගන්නාක් මෙන් භික්ෂූන් වහන්සේ ද සමාජයට බරක් නොවන ආකාරයෙන් සැදැහැවතුන්ගෙන්,',
          option1: 'පิน ලබාගත යුතුය.',
          option2: 'සිව්පසය ලබාගත යුතු ය.',
          option3: 'ගරු සම්මාන ලබාගත යුතුය.',
          option4: 'මිල මුදල් ලබාගත යුතු ය.',
          correctOption: 2,
          explanation: 'නිවැරදි පිළිතුර 2 වේ.'),
      QuestionModel(
          id: 'rel_q12',
          subjectId: 'religion',
          questionText:
              'සම්මා සම්බුද්ධත්වය ප්රාර්ථනා කරන බෝධිසත්වයන් වහන්සේලා දස පාරමිතා තුන් ආකාරයකින් සම්පූර්ණ කිරීමෙන් පාරමිතා ධර්ම තිහක් බවට පත් වේ. එම තුන් ආකාරය,',
          option1: 'දාන, සීල, භාවනා නම් වේ.',
          option2: 'සම්මා සම්බුද්ධ, පච්චෙක බුද්ධ, අරහන්ත බුද්ධ නම් වේ.',
          option3: 'සීල, සමාධි, ප්රඥා නම් වේ.',
          option4: 'පාරමී, උපපාරමී, පරමත්ථ පාරමී නම් වේ.',
          correctOption: 4,
          explanation: 'නිවැරදි පිළිතුර 4 වේ.'),
      QuestionModel(
          id: 'rel_q13',
          subjectId: 'religion',
          questionText:
              'තණ්හා මාන මිථ්යා දෘෂ්ටියෙන් තොරව, කරුණා ප්රඥාවෙන් යුතුව, කය වචන දෙකෙහි සංවර බව ඇතිකර ගනිමින් සම්පූර්ණ කරන පාරමිතාව හඳුන්වනුයේ,',
          option1: 'සීල පාරමිතාව නමිනි.',
          option2: 'සච්ච පාරමිතාව නමිනි.',
          option3: 'ඛන්ති පාරමිතාව නමිනි.',
          option4: 'නෙක්ඛම්ම පාරමිතාව නමිනි.',
          correctOption: 1,
          explanation: 'නිවැරදි පිළිතුර 1 වේ.'),
      QuestionModel(
          id: 'rel_q14',
          subjectId: 'religion',
          questionText:
              'සිදුහත් බෝසතාණන් වහන්සේ උපේක්ෂා පාරමිතාව සම්පුර්ණ කළ ආකාරය ප්රකට වන ජාතක කථාව කුමක්ද?',
          option1: 'මඝමානවක ජාතකය',
          option2: 'ලෝමහංස ජාතකය',
          option3: 'උම්මග්ග ජාතකය',
          option4: 'වට්ටක ජාතකය',
          correctOption: 2,
          explanation: 'නිවැරදි පිළිතුර 2 වේ.'),
      QuestionModel(
          id: 'rel_q15',
          subjectId: 'religion',
          questionText:
              'ධර්ම රත්නයේ ගුණ අතර “ තමා විසින්ම පිළිපැද, මෙලොවදීම ප්රතිඵල දැක ගත හැකිවීමේ ගුණය * හැඳින් වෙන්නේ,',
          option1: 'සන්දිට්ඨික නමිනි.',
          option2: 'අකාලික නමිනි.',
          option3: 'ඒහිපස්සික නමිනි.',
          option4: 'ඕපනයික නමිනි.',
          correctOption: 1,
          explanation: 'නිවැරදි පිළිතුර 1 වේ.'),
      QuestionModel(
          id: 'rel_q16',
          subjectId: 'religion',
          questionText:
              'පටිච්ච සමුප්පාද න්යායට අනුව “ හේතුං පටිච්ච සම්භුතං හේතු භංගා නිරුජ්ඣති\' යන්නෙන් අදහස් කරන ලද්දේ,',
          option1: 'ඕනෑම දෙයක් ඇති වීමට කිසියම් හේතුවක් බලපාන බවයි.',
          option2: 'හේතු සොයා බලා ඒවාට ප්රතිකර්ම කළ යුතු බවයි.',
          option3: 'හේතු නැතිවන විට, ඒ හේතු නිසා හටගත් ඵල ද නැතිව යන බවයි.',
          option4: 'හේතුවක් කරණ කොට උපන් සියල්ල විනාශ වන බවයි.',
          correctOption: 3,
          explanation: 'නිවැරදි පිළිතුර 3 වේ.'),
      QuestionModel(
          id: 'rel_q17',
          subjectId: 'religion',
          questionText:
              '" මහණෙනි. දුප්පතුන්ට ධනය නූපදනා කළ දිළිඳුකම වැඩි වේ." යනාදී වශයෙන් හේතුඵල දහම අනුව සමාජ ගැටලු ඇතිවන ආකාරය පැහැදිලි කරමින් දේශනා කළ සූත්ර ධර්මය කුමක්ද?',
          option1: 'සාමඤ්ඤඵල සූත්රය',
          option2: 'චක්කවත්ති සීහනාද සූත්රය',
          option3: 'බ්රහ්මජාල සූත්රය',
          option4: 'කසී භාරද්වාජ සූත්රය',
          correctOption: 2,
          explanation: 'නිවැරදි පිළිතුර 2 වේ.'),
      QuestionModel(
          id: 'rel_q18',
          subjectId: 'religion',
          questionText:
              'බෞද්ධ ඉගැන්වීම අනුව සත්ත්වයා හා ලෝකය යනු ස්කන්ධ ධර්ම පහක එකතුවකි. එම ස්කන්ධ ධර්ම පහ,',
          option1: 'රූප, වේදනා, සඤ්ඤා, චේතනා, විඤ්ඤාණ නම් වේ.',
          option2: 'රූප, ශබ්ද, ගන්ධ, රස, පොට්ඨබ්බ නම් වේ.',
          option3: 'රූප, වේදනා, තණ්හා, උපාදාන, භව නම් වේ.',
          option4: 'රූප, වේදනා, සඤ්ඤා, සංඛාර, විඤ්ඤාණ නම් වේ.',
          correctOption: 4,
          explanation: 'නිවැරදි පිළිතුර 4 වේ.'),
      QuestionModel(
          id: 'rel_q19',
          subjectId: 'religion',
          questionText:
              'පහත සඳහන් සූත්ර අතුරෙන් කුසලා කුසල කර්ම හා කර්ම විපාක පිළිබඳව මනාව විස්තර කර දෙන සූත්ර ධර්මය වන්නේ,',
          option1: 'අනත්ත ලක්ඛණ සූත්රයයි.',
          option2: 'පරාභව සූත්රයයි.',
          option3: 'චුල්ල කම්ම විභංග සූත්රයයි.',
          option4: 'මහා මංගල සූත්රයයි.',
          correctOption: 3,
          explanation: 'නිවැරදි පිළිතුර 3 වේ.'),
      QuestionModel(
          id: 'rel_q20',
          subjectId: 'religion',
          questionText:
              'බුදුරජාණන් වහන්සේ තෝදෙය්ය පුත්ර සුභ මානවකයාට දේශනා කළ පරිදි, යමෙකු දුර්වර්ණව උපත ලැබීම සඳහා ඉවහල් වන ක්රියාව වන්නේ,',
          option1: 'ප්රාණඝාතයෙහි නිරත වීමයි.',
          option2: 'ද්වේශයෙන් කටයුතු කිරීමයි.',
          option3: 'තමා සතු කිසිවක් අන් අයට නොදීමයි.',
          option4: 'අන් සැපතට ඊර්ෂ්යා කිරිමයි.',
          correctOption: 2,
          explanation: 'නිවැරදි පිළිතුර 2 වේ.'),
      QuestionModel(
          id: 'rel_q21',
          subjectId: 'religion',
          questionText:
              '" සිතින් දැඩිව අල්ලා ගැනීම හේතු කොට ගෙන නැවත නැවත භවයට එකතු වේ" යන්න සඳහන් අනුලෝම පටිච්ච සමුප්පාද පාඨය කුමක්ද?',
          option1: '" සංඛාර පච්චයා විඤ්ඤාණං \'',
          option2: '" ඵස්ස පච්චයා වේදනා "',
          option3: '"උපාදාන පච්චයා භවො "',
          option4: '"භව පච්චයා ජාති”',
          correctOption: 3,
          explanation: 'නිවැරදි පිළිතුර 3 වේ.'),
      QuestionModel(
          id: 'rel_q22',
          subjectId: 'religion',
          questionText:
              'පංච නීවරණ ධර්ම අතරට අයත් \'සිතෙහි නොසන්සුන්කම හා කළ නොකළ දේ පිළිබඳ සිතෙහි ඇතිවන පසුතැවිල්ල\' හඳුන්වනු ලබන්නේ,',
          option1: 'ව්යාපාද නමිනි.',
          option2: 'ථීනමිද්ධ නමිනි.',
          option3: 'උද්ධච්ච කුක්කුච්ච නමිනි.',
          option4: 'විචිකිච්ඡා නමිනි.',
          correctOption: 3,
          explanation: 'නිවැරදි පිළිතුර 3 වේ.'),
      QuestionModel(
          id: 'rel_q23',
          subjectId: 'religion',
          questionText:
              'යහපතට යෙදූ විට මව්පියන් කරන යහපතට වඩා යහපතක් සිදු කරන්නා වූත්, අයහපතට යෙදූ විට සතුරකු කරන අයහපතට වඩා අයහපතක් සිදු කරන්නා වූත් එකම සාධකය ලෙස බුදු දහමෙහි පෙන්වා දෙනු ලබන්නේ,',
          option1: 'සිතයි.',
          option2: 'කයයි.',
          option3: 'වචනයයි.',
          option4: 'වේදනාවයි.',
          correctOption: 1,
          explanation: 'නිවැරදි පිළිතුර 1 වේ.'),
      QuestionModel(
          id: 'rel_q24',
          subjectId: 'religion',
          questionText:
              'බුදු දහමෙහි විස්තර වන පංච බලි සංකල්පයෙහි එන \'පුබ්බපේත බලි\' යන්නෙහි අර්ථය වන්නේ,',
          option1: 'ඥාතීන්ට සංග්රහ කිරීමයි.',
          option2: 'ආගන්තුකයින්ට සංග්රහ කිරීමයි.',
          option3: 'මියගිය ඥාතීන්ට පින් දීමයි.',
          option4: 'දෙවියන්ට පින් අනුමෝදන් කිරීමයි.',
          correctOption: 3,
          explanation: 'නිවැරදි පිළිතුර 3 වේ.'),
      QuestionModel(
          id: 'rel_q25',
          subjectId: 'religion',
          questionText:
              'කරුණු නොදැන පදනමකින් තොරව ඇති කරගත් ශ්රද්ධාව, ධර්මයෙහි හඳුන්වනු ලබන්නේ,',
          option1: 'අමූලිකා සද්ධා නමිනි.',
          option2: 'ආකාරවතී සද්ධා නමිනි.',
          option3: 'අචල සද්ධා නමිනි.',
          option4: 'අවෙච්චප්පසාද සද්ධා නමිනි.',
          correctOption: 1,
          explanation: 'නිවැරදි පිළිතුර 1 වේ.'),
      QuestionModel(
          id: 'rel_q26',
          subjectId: 'religion',
          questionText:
              'පුද්ගලයකුගේ ප්රතිසන්ධිය ලබාදීමට ඉවහල් වන කර්මය හඳුන්වනු ලබන්නේ,',
          option1: 'ජනක කර්ම නමිනි.',
          option2: 'උපත්ථම්භක කර්ම නමිනි.',
          option3: 'උපපීඩක කර්ම නමිනි.',
          option4: 'උපඝාතක කර්ම නමිනි.',
          correctOption: 1,
          explanation: 'නිවැරදි පිළිතුර 1 වේ.'),
      QuestionModel(
          id: 'rel_q27',
          subjectId: 'religion',
          questionText:
              'බුදුරජාණන් වහන්සේ බුද්ධත්වයට පත්වීමෙන් අනතුරුව ප්රකාශ කළ ප්රථම උදාන වාක්යයෙන්, දුක් සහිත පංචස්කන්ධය නමැති ගෘහය නිර්මාණය කරන අදෘශ්යමාන බලවේගය ලෙස හඳුන්වා ඇත්තේ,',
          option1: 'අවිද්යාවයි.',
          option2: 'වේදනාවයි.',
          option3: 'තෘෂ්ණාවයි.',
          option4: 'විඤ්ඤාණයයි.',
          correctOption: 3,
          explanation: 'නිවැරදි පිළිතුර 3 වේ.'),
      QuestionModel(
          id: 'rel_q28',
          subjectId: 'religion',
          questionText:
              'ආර්ය අෂ්ටාංගික මාර්ගය ත්රිශික්ෂාවට බෙදා දැක්වීමේදී සීලය යටතට අයත් මාර්ග අංග ඇතුළත් වරණය තෝරන්න.',
          option1: 'සම්මා දිට්ඨි, සම්මා සංකප්ප, සම්මා වාචා',
          option2: 'සම්මා කම්මන්ත, සම්මා ආජීව, සම්මා වායාම',
          option3: 'සම්මා වායාම, සම්මා සති, සම්මා සමාධි',
          option4: 'සම්මා වාචා, සම්මා කම්මන්ත, සම්මා ආජීව',
          correctOption: 4,
          explanation: 'නිවැරදි පිළිතුර 4 වේ.'),
      QuestionModel(
          id: 'rel_q29',
          subjectId: 'religion',
          questionText:
              'බුදුරජාණන් වහන්සේ අනේපිඬු සිටුතුමාට දේශනා කළ \'පත්තකම්ම සූත්රයේ\' ධනය හෙවත් භෝග සම්පත් මනාව පරිහරණය කිරීමට උපදෙස් ලබා දී ඇත. එහි දැක්වෙන කරුණු අතරට අයත් නොවන කරුණ කුමක්ද ?',
          option1: 'ආත්මාර්ථය සඳහාම ධනය ඉපයිය යුතු ය.',
          option2: 'ධාර්මිකව උපයාගත් ධනය මනාව ආරක්ෂා කරගත යුතු ය.',
          option3: 'පංච බලි නම් යුතුකම් පහක් ඉටු කළ යුතු ය.',
          option4: 'මහණ බමුණන්ට සංග්රහ කිරීම සඳහා වැය කළ යුතු ය.',
          correctOption: 1,
          explanation: 'නිවැරදි පිළිතුර 1 වේ.'),
      QuestionModel(
          id: 'rel_q30',
          subjectId: 'religion',
          questionText:
              '" අසවලා මට බැන්නේ ය. මට පහර දුන්නේ ය. මා පැරද වූයේ ය." යනාදී වශයෙන් වෛර බඳින්නාගේ වෛරය නොසන්සිඳෙන බව අවධාරණය කරමින් දේශනා කළ ධම්මපද ගාථාවේ මුල් දෙපදය වන්නේ,',
          option1: '\'තංච කම්මං කතං සාධු - යං කත්වා නානුතප්පති" යන්නයි.',
          option2: '\'අත්තනාව කතං පාපං - අත්තනා සංකිලිස්සති" යන්නයි.',
          option3: '"අක්කොච්ඡි මං අවධි මං - අජිනි මං අහාසි මේ" යන්නයි.',
          option4: '" සූකරානි අසාධුනී - අත්තනෝ අහිතානි ච" යන්නයි.',
          correctOption: 3,
          explanation: 'නිවැරදි පිළිතුර 3 වේ.'),
    ],
    'sinhala': [
      QuestionModel(
          id: 'sin_q1',
          subjectId: 'sinhala',
          questionText:
              'ඔහුගෙන් වචනයක් ගැනීම වනාහි ගලෙන් පට්ටයක් ගැනීම වැනි කාර්යයකි.',
          option1: 'අමාරුවෙන් කළ යුත්තකි.',
          option2: 'ඉතා පහසු කටයුත්තකි.',
          option3: 'ශරීර ශක්තිය යොදා කළ යුත්තකි.',
          option4: 'කිසිදා සිදු කළ නොහැක්කකි.',
          correctOption: 4,
          explanation: 'නිවැරදි පිළිතුර: (4)'),
      QuestionModel(
          id: 'sin_q2',
          subjectId: 'sinhala',
          questionText: 'මා දුන් අඹගෙඩිය, දුගියා තලු මරමින් කෑවේ ය.',
          option1: 'ඉතා ම ආශාවෙන්',
          option2: 'කටින් හඬක් පිට කරමින්',
          option3: 'තල්ලෙහි ගෑවෙන පරිද්දෙන්',
          option4: 'ඉතා අකමැත්තෙන්',
          correctOption: 1,
          explanation: 'නිවැරදි පිළිතුර: (1)'),
      QuestionModel(
          id: 'sin_q3',
          subjectId: 'sinhala',
          questionText:
              'සිරිපාල දිය යටින් ගින්දර ගෙනියන පුද්ගලයකු සේ ප්‍රසිද්ධ ය.',
          option1: 'උපක්‍රමශීලී ව වැඩ නොකරන',
          option2: 'අන්‍යයා තළා - පෙළා වැඩ කරන',
          option3: 'කට්ට, කෛරාටික, වංචනික ක්‍රියා කරන',
          option4: 'අන් අයට කළ නොහැකි දේ කරන',
          correctOption: 3,
          explanation: 'නිවැරදි පිළිතුර: (3)'),
      QuestionModel(
          id: 'sin_q4',
          subjectId: 'sinhala',
          questionText:
              'යමක් ඇති සැටියෙන් වර්ණනා කිරීම ........................ වේ.',
          option1: 'ස්වභාවාලංකාරය',
          option2: 'ස්වභාවෝක්ත්‍යාලංකාරය',
          option3: 'ස්වභාව සිද්ධාලංකාරය',
          option4: 'ස්වභාව ධර්මාලංකාරය',
          correctOption: 2,
          explanation: 'නිවැරදි පිළිතුර: (2)'),
      QuestionModel(
          id: 'sin_q5',
          subjectId: 'sinhala',
          questionText:
              'තමාගෙන් වූ වරද ඔවුහු ........................ ලක් කළහ.',
          option1: 'සාධාරණීකරණයට',
          option2: 'අසාධාරණීකරණයට',
          option3: 'වර්ගීකරණයට',
          option4: 'ප්‍රමිතිකරණයට',
          correctOption: 1,
          explanation: 'නිවැරදි පිළිතුර: (1)'),
      QuestionModel(
          id: 'sin_q6',
          subjectId: 'sinhala',
          questionText:
              'ඇතැමුන් ජනප්‍රසාදය අහිමි කර ගත්තේ තම ........................ නිසාය.',
          option1: 'අවංකකම',
          option2: 'අනතිමානීකම',
          option3: 'ගුණවත්කම',
          option4: 'උද්ධච්චකම',
          correctOption: 4,
          explanation: 'නිවැරදි පිළිතුර: (4)'),
      QuestionModel(
          id: 'sin_q7',
          subjectId: 'sinhala',
          questionText: 'ආකාරාදි පිළිවෙළ නිවැරදිව දැක්වෙන පද පේළිය තෝරන්න.',
          option1: 'තිසරය, කෝකිලය, නීලකොබෝව, සැවුලුව',
          option2: 'ගිරාව, මයුරය, සැළලිහිණිය, හංසය',
          option3: 'රත්නාවලිය, පූජාවලිය, බුත්සරණ, ධර්ම ප්‍රදීපිකාව',
          option4: 'සසදාවත, මුවදෙව්දාවත, කව්සිළුමිණ, කාව්‍යශේඛරය',
          correctOption: 2,
          explanation: 'නිවැරදි පිළිතුර: (2) - ග, ම, ස, හ අනුපිළිවෙළ'),
      QuestionModel(
          id: 'sin_q8',
          subjectId: 'sinhala',
          questionText:
              'සැම පදයකම අක්ෂර වින්‍යාසය නිවැරදි ව යෙදී ඇති පද පේළිය තෝරන්න.',
          option1: 'සම්මුඛ, සුකුමාළ, සිතුමිණ, චුම්භක',
          option2: 'ගුරුමුෂ්ඨි, ගොලුවා, චන්ද්‍ර ග්‍රහණ, තොටුපොල',
          option3: 'පරිඥාණ, පරිපූර්ණ, යුද්ධායුද, ශික්ෂණ',
          option4: 'ආරූඪ, මිනුම, ශීතෝෂ්ණ, සහස්‍ර',
          correctOption: 4,
          explanation: 'නිවැරදි පිළිතුර: (4)'),
      QuestionModel(
          id: 'sin_q9',
          subjectId: 'sinhala',
          questionText:
              'දීර්ඝ පාපිල්ල, කොම්බුව හා දීර්ඝත්ව ලක්ෂණය, දීර්ඝ ඇදය සහ කෙටි ඉස්පිල්ල අනුපිළිවෙළින් යෙදී ඇති වරණය තෝරන්න.',
          option1: 'සූරයා, කේතලය, නෑකම, විපත',
          option2: 'නෑකම, කේතලය, සූරයා, විපත',
          option3: 'සූරයා, විපත, නෑකම, කේතලය',
          option4: 'නෑකම, විපත, කේතලය, සූරයා',
          correctOption: 1,
          explanation: 'නිවැරදි පිළිතුර: (1)'),
      QuestionModel(
          id: 'sin_q10',
          subjectId: 'sinhala',
          questionText: 'ඕෂ්ඨජ ව්‍යංජන පමණක් අන්තර්ගත වචනය තෝරන්න.',
          option1: 'භය',
          option2: 'මල',
          option3: 'පඹ',
          option4: 'පස',
          correctOption: 3,
          explanation: 'නිවැරදි පිළිතුර: (3)'),
      QuestionModel(
          id: 'sin_q11',
          subjectId: 'sinhala',
          questionText: '"ඇළ දොළ" යන්න අයත් වන්නේ,',
          option1: 'අන්‍යාර්ථ සමාසයට ය.',
          option2: 'විභක්ති සමාසයට ය.',
          option3: 'දකාරාර්ථ සමාසයට ය.',
          option4: 'අව්‍යය සමාසයට ය.',
          correctOption: 3,
          explanation: 'නිවැරදි පිළිතුර: (3) - ද්වන්ද සමාසය'),
      QuestionModel(
          id: 'sin_q12',
          subjectId: 'sinhala',
          questionText: 'අනුක්ත නාම පද පමණක් යෙදී ඇති වරණය තෝරන්න.',
          option1: 'සාවකු, ගෙම්බෙක්, වනචාරියකු, දෙවඟනක',
          option2: 'වහලකු, දුනුවායන්, අප, සහෘදයෝ',
          option3: 'කපුටෙකු, යෞවනියක්, ක්‍රීඩිකාවක, මා',
          option4: 'සොල්දාදුවකු, මාළුවකු, ව්‍යාපාරිකයන්, තොප',
          correctOption: 1,
          explanation: 'නිවැරදි පිළිතුර: (1)'),
      QuestionModel(
          id: 'sin_q13',
          subjectId: 'sinhala',
          questionText:
              '"සේවකයෝ රාජකාරි නිමා කර කාර්යාලයෙන් පිටත් වූහ." - "කාර්යාලයෙන්" යන්නෙහි විභක්තිය?',
          option1: 'අවධි විභක්තිය',
          option2: 'ආධාර විභක්තිය',
          option3: 'සම්ප්‍රදාන විභක්තිය',
          option4: 'කර්ම විභක්තිය',
          correctOption: 1,
          explanation: 'නිවැරදි පිළිතුර: (1)'),
      QuestionModel(
          id: 'sin_q14',
          subjectId: 'sinhala',
          questionText:
              'නීති + ඉක යන ප්‍රකෘතිය හා ප්‍රත්‍යයය එක් වූ විට සෑදෙන නිවැරදි වචනය?',
          option1: 'නෛතික',
          option2: 'නීතියික',
          option3: 'නෛතීක',
          option4: 'නීතික',
          correctOption: 1,
          explanation: 'නිවැරදි පිළිතුර: (1)'),
      QuestionModel(
          id: 'sin_q15',
          subjectId: 'sinhala',
          questionText: 'ව්‍යාකරණ ප්‍රවර්ගයට අයත් නොවන පදයක් සහිත වරණය: කෘදන්ත',
          option1: 'පූර්ව ක්‍රියා - කා, නා, පා, දා',
          option2: 'කෘදන්ත - සරන, කරන, දරන, පරණ',
          option3: 'ස්වර සන්ධි - මලසුන, මතැත්, එදිනෙදා, සිතැති',
          option4: 'උපසර්ග - විරූප, විදේශ, විසන්ධි, විරාග',
          correctOption: 2,
          explanation: 'නිවැරදි පිළිතුර: (2) - "පරණ" කෘදන්ත නොවේ'),
      QuestionModel(
          id: 'sin_q16',
          subjectId: 'sinhala',
          questionText: 'මිශ්‍ර ක්‍රියාවක් යෙදී ඇති වාක්‍යය කුමක්ද?',
          option1: 'තම නමින් මිය ගිය ඥාතීන් සිහි කොට පින් දෙන්න.',
          option2: 'ඔවුහු මිතුදමින් වෙළී සිටියහ.',
          option3: 'ඔහු ගුණවත්කමින් පිරිපුන් මිනිසෙක් වූයේය.',
          option4: 'නිමාශා තම දක්ෂතා විදහා පාමින් ගීයක් ගැයුවාය.',
          correctOption: 4,
          explanation: 'නිවැරදි පිළිතුර: (4)'),
      QuestionModel(
          id: 'sin_q17',
          subjectId: 'sinhala',
          questionText:
              '"නිරාගමික" යන්නෙහි අර්ථය: "කලින් කල ලෝකයෙහි නිරාගමික සංකල්ප පහළ වෙයි."',
          option1: 'ආගමකට අයත් වූ',
          option2: 'ආගමානුකූල හැඟීමෙන් යුතු',
          option3: 'ආගමකට අයත් නැති',
          option4: 'වැරදි ආගමික අදහස් සහිත',
          correctOption: 3,
          explanation: 'නිවැරදි පිළිතුර: (3)'),
      QuestionModel(
          id: 'sin_q18',
          subjectId: 'sinhala',
          questionText:
              '"රණ ශූරයෙකි" යන්නෙහි අර්ථය: "සීතාවක රාජසිංහ රජතුමා රණ ශූරයෙකි."',
          option1: 'යුද්ධයෙහි දක්ෂ නොවූවෙකි.',
          option2: 'යුද්ධ ජයග්‍රහණයේ දක්ෂයෙකි.',
          option3: 'යුද්ධකාමියෙකි.',
          option4: 'යුද්ධයෙහි දක්ෂයෙකි.',
          correctOption: 4,
          explanation: 'නිවැරදි පිළිතුර: (4)'),
      QuestionModel(
          id: 'sin_q19',
          subjectId: 'sinhala',
          questionText:
              '"අතීතාවර්ජනයක" යන්නෙහි අර්ථය: "ශිෂ්‍යාව අතීතාවර්ජනයක නිරත වූවා ය."',
          option1: 'අතීතය අමතක කිරීමක',
          option2: 'අතීතයට ගමන් කිරීමක',
          option3: 'අතීතය ගැන මතක් කිරීමක',
          option4: 'අතීතයේ ජීවත් වීමක',
          correctOption: 3,
          explanation: 'නිවැරදි පිළිතුර: (3)'),
      QuestionModel(
          id: 'sin_q20',
          subjectId: 'sinhala',
          questionText:
              'අන්‍යෝන්‍ය වශයෙන් සමීප කාර්‍යයන් සමග බැඳී නොපවත්නා පද පේළිය තෝරන්න.',
          option1: 'අල්මාරිය, පෙට්ටිය, ලාච්චුව, පුටුව',
          option2: 'ඉටිපන්දම්, හඳුන්කූරු, පහන්, කපුරු',
          option3: 'පොල්, ලුණු, දුරු, මිරිස්',
          option4: 'කොට්ටය, ඇඳ මෙට්ටය, ඇතිරිල්ල',
          correctOption: 1,
          explanation: 'නිවැරදි පිළිතුර: (1)'),
      QuestionModel(
          id: 'sin_q21',
          subjectId: 'sinhala',
          questionText: 'සමානාර්ථ යෙදුම් පමණක් ඇතුළත් පද පේළිය තෝරන්න.',
          option1: 'දේව - සුර, භෝජන - ආහාර, මුහුද - ජලාශය, වාහනය - රථය',
          option2: 'මිනිසා - මනුෂ්‍යයා, සවන - කන, නේත්‍ර - නයන, නගරය - නුවර',
          option3: 'වාලුකා - වැලි, ගෘහය - ගෙය, භාග්‍යය - දුක, තරුණ - යොවුන්',
          option4:
              'ප්‍රාසාදය - පහය, සත්‍යය - ඇත්ත, දිනය - වර්ෂය, කුඹුර - ක්ෂේත්‍රය',
          correctOption: 2,
          explanation: 'නිවැරදි පිළිතුර: (2)'),
      QuestionModel(
          id: 'sin_q22',
          subjectId: 'sinhala',
          questionText: '"කාලය" යන පදයට සමානාර්ථයක් නොදෙන පදයක් ඇතුළත් වරණය?',
          option1: 'කාලය - වේලාව, තල, නිමේෂය, දහවල',
          option2: 'ශරීරය - දේහය, සිරුර, කය, ඇඟ',
          option3: 'කුරුල්ලා - ශකුන, පක්ෂියා, විහඟ, දද',
          option4: 'හස්ති - ගජ, වරණ, ඇතා, ගිජිඳු',
          correctOption: 1,
          explanation: 'නිවැරදි පිළිතුර: (1)'),
      QuestionModel(
          id: 'sin_q23',
          subjectId: 'sinhala',
          questionText: 'විරුද්ධාර්ථවත් පද යුගලයක් ඇතුළත් නොවන වරණය?',
          option1: 'විමල - නිමල',
          option2: 'ආදර - අනාදර',
          option3: 'ඵල - අඵල',
          option4: 'හුරු - නුහුරු',
          correctOption: 1,
          explanation: 'නිවැරදි පිළිතුර: (1)'),
      QuestionModel(
          id: 'sin_q24',
          subjectId: 'sinhala',
          questionText: 'වැරදි අදහස දෙන ප්‍රකාශය කුමක්ද?',
          option1: '"නුඹ" යනු මධ්‍යම පුරුෂ බහු වචනයකි.',
          option2: 'ඍ යන්න මූර්ධජ අක්ෂරයකි.',
          option3: '"බලමි" යන්න වර්තමාන කාල, උත්තම පුරුෂ, ඒක වචනයකි.',
          option4: '"බලවත්" යන්න තද්ධිත පදයකි.',
          correctOption: 1,
          explanation: 'නිවැරදි පිළිතුර: (1)'),
      QuestionModel(
          id: 'sin_q25',
          subjectId: 'sinhala',
          questionText: 'මනා පද ගැළපීමෙන් යුක්ත අර්ථාන්විත වාක්‍යය?',
          option1: 'සාහිත්‍ය නිර්මාණයක් පදනම් වී වස්තු බීජයක් ඇති කෙරේ.',
          option2: 'යුද්ධයක් නිසා දේශපාලන ලෝකයේ ස්ථාවරත්වයට හේතු වේ.',
          option3: 'සතුරන්ගේ ආක්‍රමණ වලට අප උපක්‍රමශීලී විය යුතු ය.',
          option4: 'තොරතුරු යාවත්කාලීන කිරීම රටක ප්‍රගමනයට උපකාරී වෙයි.',
          correctOption: 4,
          explanation: 'නිවැරදි පිළිතුර: (4)'),
      QuestionModel(
          id: 'sin_q26',
          subjectId: 'sinhala',
          questionText:
              'තිබෙන දෙයටත් වඩා අයහපත් දෙයක් ළං කර ගැනීම - ගැළපෙන පිරුළ?',
          option1: 'කන්න දුන්න අත හපා කෑව වගේ.',
          option2: 'ඉස්සෙල්ලා ආපු කනට වඩා පස්සෙ ආපු අඟ ලොකු වුණා වගේ.',
          option3: 'ඉඟුරු දී මිරිස් ගත්තා වගේ.',
          option4: 'වඳින්න ගිය දේවාලේ ඉහේ කඩා වැටුණ වගේ.',
          correctOption: 3,
          explanation: 'නිවැරදි පිළිතුර: (3)'),
      QuestionModel(
          id: 'sin_q27',
          subjectId: 'sinhala',
          questionText: 'තමාගේ ම වරදින් විනාශයක් කරා ළඟා වීම - ගැළපෙන පිරුළ?',
          option1: 'මාළුවා නැහෙන්නේ කට නිසාලු.',
          option2: 'වත්ත බද්දට දී ඇස්සට දත නියවනවා ලු.',
          option3: 'කලක දි වහලු කලක දි රහ වෙනවා ලු.',
          option4: 'ඌරො කැකුණ තළන කොට හබන් කුකුළන්ට රජ මඟුල් ලු.',
          correctOption: 1,
          explanation: 'නිවැරදි පිළිතුර: (1)'),
      QuestionModel(
          id: 'sin_q28',
          subjectId: 'sinhala',
          questionText:
              'ද්විත්ව රූප හා පරරූප සන්ධියට අදාළ නිදසුන් පිළිවෙළින් දැක්වෙන වරණය?',
          option1: 'අද්දැකීම, සන්නස්',
          option2: 'සන්නස්, අද්දැකීම',
          option3: 'පත්තිරු, අද්දැකීම',
          option4: 'සන්නස්, පත්තිරු',
          correctOption: 1,
          explanation: 'නිවැරදි පිළිතුර: (1)'),
      QuestionModel(
          id: 'sin_q29',
          subjectId: 'sinhala',
          questionText: 'ව්‍යාකරණානුකූල ව නිවැරදි වාක්‍යය?',
          option1: 'ශිෂ්‍ය - ශිෂ්‍යාවෝ උදෑසන ම පාසලට පැමිණ ඇත.',
          option2: 'සොර මුළ ධනය පැහැර ගනියි.',
          option3: 'ඈ ප්‍රසිද්ධ ලේඛිකාවක් වූවා ය.',
          option4: 'රජතුමා සිංහයෙක් සේ නිර්භීත විය.',
          correctOption: 3,
          explanation: 'නිවැරදි පිළිතුර: (3)'),
      QuestionModel(
          id: 'sin_q30',
          subjectId: 'sinhala',
          questionText: 'ව්‍යාකරණානුකූල ව නිවැරදි වාක්‍යය ?',
          option1: 'අම්මා හෝ තාත්තා රෝහලට යන්නේය.',
          option2: 'ගවයෝ කුඹුරු පාළු කරතිය ගොවීහු චෝදනා කරති.',
          option3: 'තාරකාවන් බටහිර දිග අහසේ දිලිසෙති.',
          option4: 'ශිෂ්‍යයාද තෝ ද පාසලට යහි.',
          correctOption: 1,
          explanation: 'නිවැරදි පිළිතුර: (1)'),
    ],
    'sci': [
      QuestionModel(
          id: 'sci_q1',
          subjectId: 'sci',
          questionText: 'බහිස්ස්‍රාවී ද්‍රව්‍යයක් වන යුරියා නිපදවෙන්නේ?',
          option1: 'වකුගඩුවල',
          option2: 'අක්මාවෙහි',
          option3: 'මුත්‍රාශයෙහි',
          option4: 'වෘක්කාණුවල',
          correctOption: 2,
          explanation:
              'යුරියා නිපදවෙන්නේ අක්මාවෙහිය. වකුගඩු මගින් රුධිරයෙන් එය පෙරීගෙන මුත්‍රාවට යයි.'),
      QuestionModel(
          id: 'sci_q2',
          subjectId: 'sci',
          questionText: 'ක්ෂමතාවේ (Power) ඒකකය කුමක්ද?',
          option1: 'Ws',
          option2: 'Ws⁻¹',
          option3: 'Js',
          option4: 'Js⁻¹',
          correctOption: 4,
          explanation: 'ක්ෂමතාව = ශක්තිය/කාලය = J/s = Js⁻¹ (Watt).'),
      QuestionModel(
          id: 'sci_q3',
          subjectId: 'sci',
          questionText:
              'අයිසොප්‍රොපිල් ඇල්කොහොල් (CH₃)₂CHOH අණුවක ඇති පරමාණු ගණන?',
          option1: '8',
          option2: '10',
          option3: '11',
          option4: '12',
          correctOption: 4,
          explanation: 'C=3, H=8 (2×3+1+1), O=1 → මුළු = 12.'),
      QuestionModel(
          id: 'sci_q4',
          subjectId: 'sci',
          questionText:
              'ශාක පත්‍ර තුළ නිපදවන ආහාර ශාක දේහය පුරා පරිවහනය කරන පටකය කුමක්ද?',
          option1: 'ශෛලම',
          option2: 'ප්ලෝයම',
          option3: 'කැම්බියම',
          option4: 'දෘඪස්තර',
          correctOption: 2,
          explanation:
              'ප්ලෝයම (Phloem) ආහාර ශාකයේ සිතු ආහාර ශාක දේහය පුරා ගෙනයයි.'),
      QuestionModel(
          id: 'sci_q5',
          subjectId: 'sci',
          questionText:
              'වස්තු දෙකක් එකිනෙක පිරි මැදීමෙන් එක් වස්තුවකට ධන ආරෝපණයක් ලැබීමේ දී අනෙකට සංක්‍රමණය වනුයේ?',
          option1: 'ඉලෙක්ට්‍රෝනයි',
          option2: 'ප්‍රෝටෝනයි',
          option3: 'නියුට්‍රෝනයි',
          option4: 'ඉලෙක්ට්‍රෝන හා ප්‍රෝටෝනයි',
          correctOption: 1,
          explanation: 'ඉලෙක්ට්‍රෝන සංචලනශීලී බැවින් ඒවාම සංක්‍රමණය වේ.'),
      QuestionModel(
          id: 'sci_q6',
          subjectId: 'sci',
          questionText:
              'පිළිවෙළින් ආම්ලික ඔක්සයිඩයක්, උභයගුණ ඔක්සයිඩයක් සහ භාස්මික ඔක්සයිඩයක් ඇතුළත් වන්නේ මින් කුමක්ද?',
          option1: 'SO₃, Al₂O₃, SiO₂',
          option2: 'SO₃, Al₂O₃, MgO',
          option3: 'CO₂, SiO₂, MgO',
          option4: 'SiO₂, CO₂, Al₂O₃',
          correctOption: 2,
          explanation: 'SO₃=ආම්ලික, Al₂O₃=උභයගුණ, MgO=භාස්මික.'),
      QuestionModel(
          id: 'sci_q7',
          subjectId: 'sci',
          questionText: 'ශාක සෛලයක ඇති අජීවී ව්‍යුහයක් ලෙස හැඳින්විය හැකි ය.',
          option1: 'සෛල බිත්තිය',
          option2: 'ප්ලාස්ම පටලය',
          option3: 'රයිබොසෝම',
          option4: 'ගොල්ගි දේහ',
          correctOption: 1,
          explanation:
              'සෛල බිත්තිය (Cell Wall) මළ සෛල ද්‍රව්‍යයෙන් සෑදූ අජීවී ව්‍යුහයකි.'),
      QuestionModel(
          id: 'sci_q8',
          subjectId: 'sci',
          questionText:
              'විද්‍යුත්-චුම්බක තරංග හා සම්බන්ධ පහත ප්‍රකාශ වලින් අසත්‍ය ප්‍රකාශය කුමක්ද?',
          option1: 'ශක්තිය සම්ප්‍රේෂණය කරයි',
          option2: 'රික්තයේ දී 3×10⁸ ms⁻¹ වේගයකින් ගමන් කරයි',
          option3: 'පදාර්ථමය මාධ්‍යයක දී සංඛ්‍යාතය රික්තයේ දීට වඩා අඩු වේ',
          option4: 'පදාර්ථමය මාධ්‍යයක දී වේගය රික්තයේ දීට වඩා අඩු වේ',
          correctOption: 3,
          explanation:
              'සංඛ්‍යාතය (frequency) මාධ්‍ය වෙනස් වුණත් නොවෙනස් ව පවතී; වේගය සහ තරංගදෛර්ඝ්‍යය වෙනස් වේ.'),
      QuestionModel(
          id: 'sci_q9',
          subjectId: 'sci',
          questionText: 'අයනික සංයෝග පිළිබඳ ව සත්‍ය වනුයේ පහත කුමන ප්‍රකාශයද?',
          option1: 'ඝන අවස්ථාවේ දී විදුලිය සන්නයනය කරයි',
          option2: 'සියල්ල ම ඉතා හොඳින් ජලයේ දිය වේ',
          option3: 'ගලාංක හා ද්‍රවාංක ඉහළ අගයන් ගනී',
          option4: 'විලීන අවස්ථාවේ දී විදුලිය සන්නයනය නො කරයි',
          correctOption: 3,
          explanation: 'අයනික සංයෝගවල ගලාංක හා ද්‍රවාංක ඉහළ අගයන් ගනී.'),
      QuestionModel(
          id: 'sci_q10',
          subjectId: 'sci',
          questionText:
              'කැස්ස සමඟ රුධිරය පිටවීම, ශරීරයේ බර අඩු වීම, අධික වෙහෙස — මෙම පුද්ගලයාට වැළඳී තිබීමට හැක්කේ?',
          option1: 'නිව්මෝනියාවයි',
          option2: 'බ්‍රොන්කයිටිස් රෝගයයි',
          option3: 'ක්ෂය රෝගයයි',
          option4: 'සිලිකෝසිස් රෝගයයි',
          correctOption: 3,
          explanation:
              'ක්ෂය රෝගය (Tuberculosis) හේතුවෙන් රුධිරය සහිත කැස්ස, බර අඩු වීම, වෙහෙස ඇතිවේ.'),
      QuestionModel(
          id: 'sci_q11',
          subjectId: 'sci',
          questionText:
              'ආලෝක වර්තනය පිළිබඳ ප්‍රකාශ සලකා බලන්න. (A=විරලතර සිට ඝනතර දක්වා පමණි, B=වේග එකිනෙකින් වෙනස් වීමයි, C=සංඛ්‍යාතය වෙනස් වේ)',
          option1: 'A පමණි',
          option2: 'B පමණි',
          option3: 'A හා C පමණි',
          option4: 'B හා C පමණි',
          correctOption: 2,
          explanation:
              'A අසත්‍ය (ඝනතරෙන් විරලතරට ද ව.ව.), B සත්‍ය, C අසත්‍ය (සංඛ්‍යාතය නොවෙනස්).'),
      QuestionModel(
          id: 'sci_q12',
          subjectId: 'sci',
          questionText:
              'පොළොව මත g=10 ms⁻² වේ. සඳ මත එම අගය පොළොව මෙන් 1/6 කි. පොළොව මත බර 60 N වන වස්තුවක සඳ මත බර?',
          option1: '10 N',
          option2: '60 N',
          option3: '100 N',
          option4: '360 N',
          correctOption: 1,
          explanation:
              'ස්කන්ධය = 60/10 = 6 kg. සඳ g = 10/6. බර = 6×10/6 = 10 N.'),
      QuestionModel(
          id: 'sci_q13',
          subjectId: 'sci',
          questionText:
              'පෘෂ්ඨ වංශි සත්ත්ව කාණ්ඩයට අයත් ආවේස් හා මැමේලියාවට පමණක් පොදු ලක්ෂණ? (A=සමතාපීත්වය, B=රෝම, C=අස්ථිමය, D=කුටීර හතරක් සහිත හෘදය)',
          option1: 'A හා B',
          option2: 'A හා D',
          option3: 'B හා C',
          option4: 'C හා D',
          correctOption: 2,
          explanation:
              'A: සමතාපිත්වය, D: කුටීර 4ක හෘදය — දෙකටම පොදු. B: රෝම මැමේලියාවට පමණි.'),
      QuestionModel(
          id: 'sci_q14',
          subjectId: 'sci',
          questionText: 'ලෝහ පිළිබඳ ව අසත්‍ය ප්‍රකාශය මින් කුමක්ද?',
          option1: 'මූල ද්‍රව්‍ය වලින් බහුතරය ලෝහ වේ',
          option2: 'සියලු ම ලෝහ විද්‍යුතය සන්නයනය කරයි',
          option3: 'ලෝහ පරමාණු ඉලෙක්ට්‍රෝන පිට කරමින් ධන අයන නිපදවයි',
          option4: 'සියලු ම ලෝහ අම්ල සමග ප්‍රතික්‍රියා කර හයිඩ්‍රජන් පිට කරයි',
          correctOption: 4,
          explanation:
              'Cu, Ag, Au වැනි ලෝහ ඇතැම් අම්ල සමග H₂ නිකුත් නොකරයි — අසත්‍ය.'),
      QuestionModel(
          id: 'sci_q15',
          subjectId: 'sci',
          questionText:
              'එක්තරා ද්‍රාවණයකට මෙතිල් ඔරේන්ජ් බිංදු කිහිපයක් එක් කළ විට එය රතු පැහැයට හැරිණි. pH අගය වීමට වඩාත් ඉඩ ඇත්තේ?',
          option1: '2',
          option2: '7',
          option3: '12',
          option4: '14',
          correctOption: 1,
          explanation:
              'මෙතිල් ඔරේන්ජ් ආම්ලික (pH < 4) ද්‍රාවණවල රතු වේ. pH 2 = ආම්ලික.'),
      QuestionModel(
          id: 'sci_q16',
          subjectId: 'sci',
          questionText:
              'අතිධ්වනි තරංගය පරාවර්තනය වී පැමිණීමට 4s ගත වේ. ගැඹුර 2880 m නම් ජලය තුළ එහි වේගය?',
          option1: '720 ms⁻¹',
          option2: '1440 ms⁻¹',
          option3: '2880 ms⁻¹',
          option4: '3700 ms⁻¹',
          correctOption: 2,
          explanation:
              'ගමන් කළ දිග = 2×2880 = 5760m. වේගය = 5760/4 = 1440 ms⁻¹.'),
      QuestionModel(
          id: 'sci_q17',
          subjectId: 'sci',
          questionText:
              'පහසුවෙන් දහනය වන, වාතයට වඩා ඝනත්වයෙන් අඩු, ජලයේ මඳ වශයෙන් ද්‍රාව්‍ය වන වායුව?',
          option1: 'හයිඩ්‍රජන්ය',
          option2: 'නයිට්‍රජන් ය',
          option3: 'ඔක්සිජන්ය',
          option4: 'කාබන් ඩයොක්සයිඩ් ය',
          correctOption: 1,
          explanation:
              'හයිඩ්‍රජන් (H₂) — දාහ්‍ය, ඝනත්වයෙන් ලෙහෙසිම, ජලයේ ස්වල්ප ද්‍රාව්‍ය.'),
      QuestionModel(
          id: 'sci_q18',
          subjectId: 'sci',
          questionText:
              'හෘද ස්පන්දන වේගය පාලනය කරන මධ්‍ය ස්නායු පද්ධතියට අයත් කොටස කුමක්ද?',
          option1: 'මස්තිෂ්කය',
          option2: 'අනුමස්තිෂ්කය',
          option3: 'සුෂුම්නාව',
          option4: 'සුෂුම්නා ශීර්ෂකය',
          correctOption: 4,
          explanation:
              'සුෂුම්නා ශීර්ෂකයේ (Medulla oblongata) හෘද ස්පන්දන කේන්ද්‍රය ඇත.'),
      QuestionModel(
          id: 'sci_q19',
          subjectId: 'sci',
          questionText:
              'සන්නායකයක ප්‍රතිරෝධය පිළිබඳ ප්‍රකාශ: (A=විභව අන්තරය මත, B=දිගට අනුලෝමව, C=ධාරාව මත රඳා පවතී). සත්‍ය වනුයේ?',
          option1: 'A පමණි',
          option2: 'B පමණි',
          option3: 'A හා B පමණි',
          option4: 'A හා C පමණි',
          correctOption: 2,
          explanation:
              'R = ρL/A. A: V මතත් C: I මතත් රඳා නොපවතී — B පමණි සත්‍ය.'),
      QuestionModel(
          id: 'sci_q20',
          subjectId: 'sci',
          questionText:
              'කැල්සියම් කාබනේට් 10 g ක ඇති CaCO₃ මවුල ප්‍රමාණය කොපමණද (CaCO₃=100)?',
          option1: '0.01',
          option2: '0.1',
          option3: '1',
          option4: '10',
          correctOption: 2,
          explanation: 'n = m/M = 10/100 = 0.1 mol.'),
      QuestionModel(
          id: 'sci_q21',
          subjectId: 'sci',
          questionText: 'කාබොහයිඩ්‍රේට පිළිබඳව නිවැරදි ප්‍රකාශය තෝරන්න.',
          option1: 'සියලු ම කාබොහයිඩ්‍රේට ජල ද්‍රාව්‍ය වේ',
          option2: 'සියලු ම කාබොහයිඩ්‍රේට ස්ඵටිකරූපී වේ',
          option3: 'කාබොහයිඩ්‍රේටවල C, H හා O අතර අනුපාතය 1:2:1 වේ',
          option4: 'ග්ලූකෝස් යනු කාබොහයිඩ්‍රේටවල තැනුම් ඒකකයයි',
          correctOption: 4,
          explanation:
              'ග්ලූකෝස් (monosaccharide) කාබොහයිඩ්‍රේටවල මූලික ඒකකයයි.'),
      QuestionModel(
          id: 'sci_q22',
          subjectId: 'sci',
          questionText:
              'ඝන ද්‍රව්‍යයකින් සාදන ලද වස්තුවක් ද්‍රවයක ඉපිලීම සඳහා?',
          option1: 'ඝන ඝනත්වය ද්‍රවයේ ඝනත්වයට වඩා අඩු විය යුතුය',
          option2: 'ඝන වස්තුවේ ස්කන්ධය විස්ථාපිත ද්‍රව ස්කන්ධයට සමාන විය යුතුය',
          option3: 'ඝන වස්තුවේ බර විස්ථාපිත ද්‍රව පරිමාවේ බරට සමාන විය යුතුය',
          option4:
              'ඝන වස්තුවේ බර එය මත ඇති වන උඩුකුරු තෙරපුමට වඩා අඩු විය යුතුය',
          correctOption: 2,
          explanation:
              'ආකිමිඩීස් න්‍යාය — ඉපිලෙන විට ඝන ස්කන්ධය = විස්ථාපිත ද්‍රව ස්කන්ධය.'),
      QuestionModel(
          id: 'sci_q23',
          subjectId: 'sci',
          questionText:
              'Tt ප්‍රවේණි දර්ශය සහිත ජීවීන් දෙදෙනෙකු අතර අන්තරාභිජනනයෙන් බිහි වන ජනිතයන්ගේ ප්‍රවේණි දර්ශ හා රූපානුදර්ශ සංඛ්‍යාව?',
          option1: '2 සහ 1',
          option2: '3 සහ 2',
          option3: '4 සහ 2',
          option4: '4 සහ 3',
          correctOption: 2,
          explanation:
              'TT, Tt, tt = ප්‍රවේණිදර්ශ 3; TT+Tt=ලොකු, tt=කුඩා = රූපානුදර්ශ 2.'),
      QuestionModel(
          id: 'sci_q24',
          subjectId: 'sci',
          questionText:
              'Fe₂O₃ + 3CO → 2Fe + 3CO₂. Fe₂O₃ මවුල එකක් භාවිතයෙන් නිපදවිය හැකි Fe ස්කන්ධය (Fe=56)?',
          option1: '28 g',
          option2: '56 g',
          option3: '112 g',
          option4: '168 g',
          correctOption: 3,
          explanation: 'Fe₂O₃ 1 mol → Fe 2 mol = 2×56 = 112 g.'),
      QuestionModel(
          id: 'sci_q25',
          subjectId: 'sci',
          questionText:
              'වයිරස් ආසාදනයකට ලක් වූ පුද්ගලයෙකුගේ රුධිරයේ පට්ටිකා සාමාන්‍ය අගයට වඩා අඩු වූ විට?',
          option1: 'ඔක්සිජන් පරිවහනය වේගවත් වේ',
          option2: 'ප්‍රතිදේහ නිපදවීම අඩාල වේ',
          option3: 'රුධිරය කැටි ගැසීම නිසි පරිදි සිදු නො වේ',
          option4: 'හෝමෝන පරිවහනය සෙමින් සිදු වේ',
          correctOption: 3,
          explanation:
              'පට්ටිකා (thrombocytes) රුධිර කැටිගැසීමට (clotting) දායකවේ.'),
      QuestionModel(
          id: 'sci_q26',
          subjectId: 'sci',
          questionText:
              'A - උත්ප්‍රේරක මගින් රසායනික ප්‍රතික්‍රියාවක ශීඝ්‍රතාව වැඩි වේ. B - ප්‍රතික්‍රියාව අවසානයේ උත්ප්‍රේරකයේ රසායනික සංයුතිය වෙනස් වේ.',
          option1: 'A සහ B ප්‍රකාශ දෙක ම සත්‍ය වේ',
          option2: 'A ප්‍රකාශය සත්‍ය වන අතර B ප්‍රකාශය අසත්‍ය වේ',
          option3: 'A සහ B ප්‍රකාශ දෙක ම අසත්‍ය වේ',
          option4: 'A ප්‍රකාශය අසත්‍ය වන අතර B ප්‍රකාශය සත්‍ය වේ',
          correctOption: 2,
          explanation:
              'A: සත්‍ය. B: අසත්‍ය — උත්ප්‍රේරකය ක්‍රියාවලිය අවසානයේ නොවෙනස්ව ඉතිරිවේ.'),
      QuestionModel(
          id: 'sci_q27',
          subjectId: 'sci',
          questionText:
              'බහු අවයවක: A=ඉතා ඉහළ සාපේක්ෂ අණුක ස්කන්ධය, B=කුඩා අණු පුනරාවර්තන ඒකක සේ හැඳින්වේ, C=කෘත්‍රිම හා ස්වාභාවික. සත්‍ය?',
          option1: 'A පමණි',
          option2: 'B පමණි',
          option3: 'A හා C පමණි',
          option4: 'B හා C පමණි',
          correctOption: 3,
          explanation:
              'A: සත්‍ය (ඉහළ mol mass). B: අසත්‍ය — කුඩා අණු "monomers" ලෙස හඳුන්වේ. C: සත්‍ය.'),
      QuestionModel(
          id: 'sci_q28',
          subjectId: 'sci',
          questionText:
              'ප්‍රවේග - කාල ප්‍රස්තාරය පිළිබඳ දක්වා ඇති පහත ප්‍රකාශ වලින් අසත්‍ය ප්‍රකාශය කුමක්ද?',
          option1: 'ප්‍රස්තාරයෙන් ආවරණය වන වර්ග ඵලයෙන් වස්තුවේ විස්ථාපනය ලැබේ',
          option2:
              'නිශ්චලතාවෙන් චලිතය අරඹන වස්තු සඳහා ප්‍රස්තාරය ඇරඹෙනුයේ මූල ලක්ෂ්‍යයෙනි',
          option3:
              'කාලයත් සමඟ ප්‍රවේගය වෙනස් වන චලිතයක දී ප්‍රස්තාරයේ අනුක්‍රමණය ශුන්‍ය වේ',
          option4: 'ප්‍රස්තාරයේ අනුක්‍රමණයෙන් ත්වරණය/මන්දනය ලැබේ',
          correctOption: 3,
          explanation:
              'ප්‍රවේගය වෙනස් නම් ත්වරණය ≠ 0 → ප්‍රස්තාරය අනුක්‍රමය ශූන්‍ය නොවේ.'),
      QuestionModel(
          id: 'sci_q29',
          subjectId: 'sci',
          questionText:
              'සාගර පරිසර පද්ධතිවල ඇල්ගී ගහනය අසාමාන්‍ය ලෙස වර්ධනය වීමට දායක වන දූෂකය කුමක්ද?',
          option1: 'බැර ලෝහ',
          option2: 'සල්ෆේට්',
          option3: 'න්‍යෂ්ටික අපද්‍රව්‍ය',
          option4: 'පොස්පේට්',
          correctOption: 4,
          explanation:
              'පොස්පේට් (phosphates) ශාක පෝෂකයක් ලෙස ක්‍රියාකර ඇල්ගී වර්ධනය (eutrophication) ඇතිකරේ.'),
      QuestionModel(
          id: 'sci_q30',
          subjectId: 'sci',
          questionText:
              'වෙරළ ඛාදනය + කුණාටු ඇතිවන වාර ගණන වැඩිවීම — මෙම තත්ත්වයට ඉහළ ම දායකත්වය සපයන්නේ?',
          option1: 'ගෝලීය උණුසුම ඉහළ යාම',
          option2: 'හරිතාගාර ආචරණය',
          option3: 'ඕසෝන් වියන ක්ෂය වීම',
          option4: 'සුපෝෂණය',
          correctOption: 1,
          explanation:
              'ගෝලීය උණුසුම ඉහළ යාම නිසා මුහුදු මට්ටම ඉහළ යාම, කුණාටු ශක්තිය වැඩිවීම සහ වෙරළ ඛාදනය ඇතිවේ.'),
    ],
    'math': [
      QuestionModel(
        id: 'math_q1',
        subjectId: 'math',
        questionText: '3x + 5 = 20 සමීකරණයේ x හි අගය සොයන්න.',
        option1: 'x = 3',
        option2: 'x = 5',
        option3: 'x = 15',
        option4: 'x = 10',
        correctOption: 2,
        explanation: '3x = 15 → x = 5.',
      ),
      QuestionModel(
        id: 'math_q2',
        subjectId: 'math',
        questionText: 'රවුමක විෂ්කම්භය 14 cm නම් අරය (Radius) කොපමණද?',
        option1: '28 cm',
        option2: '14 cm',
        option3: '7 cm',
        option4: '3.5 cm',
        correctOption: 3,
        explanation: 'අරය = විෂ්කම්භය / 2 = 14 / 2 = 7 cm.',
      ),
      QuestionModel(
        id: 'math_q3',
        subjectId: 'math',
        questionText: 'ප්‍රථමක සංඛ්‍යාවක් (Prime Number) නොවන්නේ කුමක්ද?',
        option1: '2',
        option2: '3',
        option3: '5',
        option4: '9',
        correctOption: 4,
        explanation: '9 = 3×3 බැවින් ප්‍රථමක සංඛ්‍යාවක් නොවේ.',
      ),
    ],
    'history': [
      QuestionModel(
          id: 'his_q1',
          subjectId: 'history',
          questionText: 'මහාවංශය රචනා කළේ කවරෙකු ද?',
          option1: 'ධම්මකිත්ති',
          option2: 'බුද්ධඝෝෂ',
          option3: 'මහානාම',
          option4: 'රේවත',
          correctOption: 3,
          explanation: 'මහාවංශය රචනා කළේ මහානාම හිමි ය.'),
      QuestionModel(
          id: 'his_q2',
          subjectId: 'history',
          questionText:
              'ශ්‍රී ලංකාවේ ප්‍රථම සිංහල රාජ්‍ය ස්ථාපිත කළේ කවරෙකු ද?',
          option1: 'දේවානම්පියතිස්ස',
          option2: 'විජය',
          option3: 'පාණ්ඩුකාභය',
          option4: 'දුටුගැමුණු',
          correctOption: 2,
          explanation: 'ශ්‍රී ලංකාවේ ප්‍රථම සිංහල රාජ්‍ය ස්ථාපිත කළේ විජය ය.'),
      QuestionModel(
          id: 'his_q3',
          subjectId: 'history',
          questionText: 'අනුරාධපුර රාජධානිය ස්ථාපිත කළේ කවරෙකු ද?',
          option1: 'දේවානම්පියතිස්ස',
          option2: 'විජය',
          option3: 'පාණ්ඩුකාභය',
          option4: 'වළගම්බා',
          correctOption: 3,
          explanation: 'අනුරාධපුර රාජධානිය ස්ථාපිත කළේ පාණ්ඩුකාභය ය.'),
      QuestionModel(
          id: 'his_q4',
          subjectId: 'history',
          questionText: 'ශ්‍රී ලංකාවට බෞද්ධ දහම හඳුන්වා දුන් දූතයා කවරෙකු ද?',
          option1: 'සංඝමිත්තා',
          option2: 'මහින්ද',
          option3: 'ධර්මාශෝක',
          option4: 'රේවත',
          correctOption: 2,
          explanation: 'ශ්‍රී ලංකාවට බෞද්ධ දහම හඳුන්වා දුන්නේ මහින්ද ය.'),
      QuestionModel(
          id: 'his_q5',
          subjectId: 'history',
          questionText: 'ජය ශ්‍රී මහා බෝධිය ශ්‍රී ලංකාවට ගෙනා කවරෙකු ද?',
          option1: 'සංඝමිත්තා',
          option2: 'මහින්ද',
          option3: 'ධර්මාශෝක',
          option4: 'ඉන්ද්‍රගුප්ත',
          correctOption: 1,
          explanation:
              'ජය ශ්‍රී මහා බෝධිය ශ්‍රී ලංකාවට ගෙනා කවරෙකු ද සංඝමිත්තා ය.'),
      QuestionModel(
          id: 'his_q6',
          subjectId: 'history',
          questionText:
              'ගැමුණු රජු දකුණු ඉන්දියාවෙන් පැමිණ ශ්‍රී ලංකාව ජය ගත් ඇලළ රජු?',
          option1: 'කජු බාහු',
          option2: 'ඵරඛු',
          option3: 'ඵළ්ළ',
          option4: 'ඇල',
          correctOption: 3,
          explanation: 'දකුණු ඉන්දියාවෙන් ශ්‍රී ලංකාව ආක්‍රමණය කළේ ඵළ්ළ ය.'),
      QuestionModel(
          id: 'his_q7',
          subjectId: 'history',
          questionText: 'දළදා මාළිගාව පිහිටා ඇත්තේ කොතෙක ද?',
          option1: 'කොළඹ',
          option2: 'ගාල්ල',
          option3: 'කෑගල්ල',
          option4: 'මහනුවර',
          correctOption: 4,
          explanation: 'දළදා මාළිගාව පිහිටා ඇත්තේ මහනුවර ය.'),
      QuestionModel(
          id: 'his_q8',
          subjectId: 'history',
          questionText: 'ශ්‍රී ලංකාව ස්වාධීනත්වය ලැබූ දිනය?',
          option1: '1948 පෙබරවාරි 4',
          option2: '1947 අගෝස්තු 15',
          option3: '1949 ජනවාරි 26',
          option4: '1950 ජූනි 10',
          correctOption: 1,
          explanation: 'ශ්‍රී ලංකාව ස්වාධීනත්වය ලැබූ දිනය 1948 පෙබරවාරි 4 ය.'),
      QuestionModel(
          id: 'his_q9',
          subjectId: 'history',
          questionText: 'ශ්‍රී ලංකාවේ ප්‍රථම අගමැතිවරයා කවරෙකු ද?',
          option1: 'ඩී. එස්. සේනානායක',
          option2: 'ශ්‍රීමාවෝ බණ්ඩාරනායක',
          option3: 'ජේ. ආර්. ජයවර්ධන',
          option4: 'ඩඩ්ලි සේනානායක',
          correctOption: 1,
          explanation: 'ශ්‍රී ලංකාවේ ප්‍රථම අගමැතිවරයා ඩී. එස්. සේනානායක ය.'),
      QuestionModel(
          id: 'his_q10',
          subjectId: 'history',
          questionText: 'ලෝකයේ ප්‍රථම කාන්තා අගමැතිවරිය?',
          option1: 'ඉන්දිරා ගාන්ධි',
          option2: 'ශ්‍රීමාවෝ බණ්ඩාරනායක',
          option3: 'ගෝල්ඩා මේයර්',
          option4: 'මාග්‍රට් තැචර්',
          correctOption: 2,
          explanation: 'ශ්‍රීමාවෝ බණ්ඩාරනායක ලෝකයේ ප්‍රථම කාන්තා අගමැතිවරිය.'),
      QuestionModel(
          id: 'his_q11',
          subjectId: 'history',
          questionText:
              'ශ්‍රී ලංකාවේ ප්‍රජාතාන්ත්‍රික සමාජවාදී ජනරජය ප්‍රකාශ කළ වර්ෂය?',
          option1: '1972',
          option2: '1948',
          option3: '1978',
          option4: '1983',
          correctOption: 1,
          explanation: '1972 දී ශ්‍රී ලංකාව ජනරජයක් විය.'),
      QuestionModel(
          id: 'his_q12',
          subjectId: 'history',
          questionText: 'රෝහල් ශිෂ්‍ය ව්‍යාපාරයට නායකත්වය දුන් අය?',
          option1: 'ස්වාමී විවේකානන්ද',
          option2: 'ශ්‍රී ලංකාවේ',
          option3: 'පාරේ',
          option4: 'හෙන්රි ස්ටීල් ඕල්කොට්',
          correctOption: 4,
          explanation:
              'හෙන්රි ස්ටීල් ඕල්කොට් ශ්‍රී ලංකාවේ ජාතික ව්‍යාපාරයට දායකවිය.'),
      QuestionModel(
          id: 'his_q13',
          subjectId: 'history',
          questionText: 'ශ්‍රී ලංකාවේ ජාතික ගීය රචනා කළේ?',
          option1: 'ආනන්ද සමරකෝන්',
          option2: 'රබීන්ද්‍රනාත් තාගෝර්',
          option3: 'සිරිල් ද ශිල්වා',
          option4: 'ජෝන් ද ශිල්වා',
          correctOption: 1,
          explanation: 'ශ්‍රී ලංකාවේ ජාතික ගීය රචනා කළේ ආනන්ද සමරකෝන් ය.'),
      QuestionModel(
          id: 'his_q14',
          subjectId: 'history',
          questionText: 'ශ්‍රී ලංකාවේ ප්‍රථම ජනාධිපතිවරයා?',
          option1: 'ඩී. එස්. සේනානායක',
          option2: 'ශ්‍රීමාවෝ බණ්ඩාරනායක',
          option3: 'ජේ. ආර්. ජයවර්ධන',
          option4: 'ඩඩ්ලි සේනානායක',
          correctOption: 3,
          explanation: 'ශ්‍රී ලංකාවේ ප්‍රථම ජනාධිපතිවරයා ජේ. ආර්. ජයවර්ධන ය.'),
      QuestionModel(
          id: 'his_q15',
          subjectId: 'history',
          questionText: 'පොළොන්නරුව රාජධානිය ස්ථාපිත කළේ?',
          option1: 'දුටුගැමුණු',
          option2: 'පරාක්‍රමබාහු',
          option3: 'විජය',
          option4: 'පාණ්ඩුකාභය',
          correctOption: 2,
          explanation:
              'පොළොන්නරුව රාජධානිය ප්‍රධාන රජු ලෙස ශ්‍රේෂ්ඨ ලෙස ජනප්‍රිය වූ රජු පරාක්‍රමබාහු ය.'),
      QuestionModel(
          id: 'his_q16',
          subjectId: 'history',
          questionText: 'ශ්‍රී ලංකාවේ ප්‍රාකෘතික ජාතිය?',
          option1: 'ශ්‍රී ලාංකික',
          option2: 'සිංහල',
          option3: 'ඇඳ',
          option4: 'ද්‍රවිඩ',
          correctOption: 3,
          explanation: 'ශ්‍රී ලංකාවේ ප්‍රාකෘතික ජාතිය ඇඳ (Vedda) ය.'),
      QuestionModel(
          id: 'his_q17',
          subjectId: 'history',
          questionText: 'සිදුහත් කුමරු ශාක්‍ය රාජ්‍යයේ ඉපදුණු ස්ථානය?',
          option1: 'සාරනාත්',
          option2: 'ලුම්බිනි',
          option3: 'බෝධ ගයා',
          option4: 'කුශිනගර',
          correctOption: 2,
          explanation: 'සිදුහත් කුමරු ඉපදුණේ ලුම්බිනි හිය.'),
      QuestionModel(
          id: 'his_q18',
          subjectId: 'history',
          questionText: 'ධර්මාශෝක රජු ගොඩ නැංවූ රාජ්‍යය?',
          option1: 'මොරිය',
          option2: 'ගුප්ත',
          option3: 'කුෂාන',
          option4: 'නන්ද',
          correctOption: 1,
          explanation: 'ධර්මාශෝක රජු මොරිය රාජ්‍යයේ රජු ය.'),
      QuestionModel(
          id: 'his_q19',
          subjectId: 'history',
          questionText: 'ශ්‍රී ලංකාවේ ජාතික කොඩිය නිර්මාණය කළ වර්ෂය?',
          option1: '1948',
          option2: '1950',
          option3: '1972',
          option4: '1978',
          correctOption: 1,
          explanation: 'ශ්‍රී ලංකාවේ ජාතික කොඩිය 1948 දී සිය රූපය ලැබිය.'),
      QuestionModel(
          id: 'his_q20',
          subjectId: 'history',
          questionText: 'කොළඹ නගරය ගොඩ නැගුණු සමය?',
          option1: 'ලන්දේසි',
          option2: 'බ්‍රිතාන්‍ය',
          option3: 'පෘතුගීසි',
          option4: 'ලංකා',
          correctOption: 3,
          explanation: 'කොළඹ නගරය ප්‍රධාන ලෙස ගොඩ නැගුණේ පෘතුගීසි සමයේ ය.'),
      QuestionModel(
          id: 'his_q21',
          subjectId: 'history',
          questionText: 'ශ්‍රී ලංකාවේ ලන්දේසි ආධිපත්‍ය කාලය?',
          option1: '1505-1658',
          option2: '1658-1796',
          option3: '1796-1948',
          option4: '1948-1972',
          correctOption: 2,
          explanation: 'ලන්දේසි ආධිපත්‍ය 1658-1796 කාලය.'),
      QuestionModel(
          id: 'his_q22',
          subjectId: 'history',
          questionText: 'ශ්‍රී ලංකාවේ පෘතුගීසි ආධිපත්‍ය ආරම්භ වූ වර්ෂය?',
          option1: '1505',
          option2: '1658',
          option3: '1796',
          option4: '1815',
          correctOption: 1,
          explanation: 'පෘතුගීසි ආධිපත්‍ය ආරම්භ වූ වර්ෂය 1505 ය.'),
      QuestionModel(
          id: 'his_q23',
          subjectId: 'history',
          questionText:
              'ශ්‍රී ලංකාවේ නිදහස් ගිවිසුමට අත්සන් කළ බ්‍රිතාන්‍ය නිලධාරියා?',
          option1: 'ලෝර්ඩ් මවුන්ට්බැටන්',
          option2: 'ශ්‍රී ලන්ඩන්',
          option3: 'ශ්‍රී පීතර්',
          option4: 'ශ්‍රී ජෝන්',
          correctOption: 1,
          explanation: 'ශ්‍රී ලංකාවේ නිදහස ලෝර්ඩ් මවුන්ට්බැටන් සමඟ ය.'),
      QuestionModel(
          id: 'his_q24',
          subjectId: 'history',
          questionText: 'ශ්‍රී ලංකාවේ 1815 ගිවිසුම?',
          option1: 'ඔලිවිය ගිවිසුම',
          option2: 'කෑගල්ල ගිවිසුම',
          option3: 'මහනුවර ගිවිසුම',
          option4: 'ගාල්ල ගිවිසුම',
          correctOption: 3,
          explanation: '1815 ගිවිසුම මහනුවර ගිවිසුම ය.'),
      QuestionModel(
          id: 'his_q25',
          subjectId: 'history',
          questionText: 'ශ්‍රී ලංකාවේ ප්‍රථම ආණ්ඩු ක්‍රම ව්‍යවස්ථාව?',
          option1: '1947',
          option2: '1948',
          option3: '1972',
          option4: '1978',
          correctOption: 1,
          explanation: 'ශ්‍රී ලංකාවේ ප්‍රථම ව්‍යවස්ථාව 1947 ය.'),
      QuestionModel(
          id: 'his_q26',
          subjectId: 'history',
          questionText: 'ශ්‍රී ලංකාවේ ශ්‍රේෂ්ඨාධිකරණය ස්ථාපිත කළ වර්ෂය?',
          option1: '1801',
          option2: '1815',
          option3: '1833',
          option4: '1948',
          correctOption: 3,
          explanation: 'ශ්‍රේෂ්ඨාධිකරණය ස්ථාපිත කළ වර්ෂය 1833 ය.'),
      QuestionModel(
          id: 'his_q27',
          subjectId: 'history',
          questionText: 'ශ්‍රී ලංකාවේ දළදා ශ්‍රී ලංකාවට ගෙනා රජ?',
          option1: 'දේවානම්පියතිස්ස',
          option2: 'කිර්ති ශ්‍රී රාජසිංහ',
          option3: 'ශ්‍රී ලංකා',
          option4: 'ශ්‍රී ශ්‍රී',
          correctOption: 2,
          explanation:
              'දළදා ශ්‍රී ලංකාවට ගෙනෙනු ලැබූ රජු කිර්ති ශ්‍රී රාජසිංහ ය.'),
      QuestionModel(
          id: 'his_q28',
          subjectId: 'history',
          questionText: 'ශ්‍රී ලංකාව UN සාමාජිකත්වය ලැබූ වර්ෂය?',
          option1: '1948',
          option2: '1955',
          option3: '1972',
          option4: '1978',
          correctOption: 2,
          explanation: 'ශ්‍රී ලංකාව 1955 දී UN සාමාජිකත්වය ලැබිය.'),
      QuestionModel(
          id: 'his_q29',
          subjectId: 'history',
          questionText:
              'බ්‍රිතාන්‍ය ආණ්ඩු සමයේ ශ්‍රී ලංකාවේ ව්‍යවස්ථාපිත ශිෂ්‍ය ව්‍යාපාරය ශ්‍රී ලාංකික?',
          option1: '1915',
          option2: '1818',
          option3: '1848',
          option4: '1832',
          correctOption: 1,
          explanation: '1915 කොළඹ කළකිරීමේ කෝලාහලය සිදු විය.'),
      QuestionModel(
          id: 'his_q30',
          subjectId: 'history',
          questionText: 'ශ්‍රී ලංකාවේ ප්‍රථම ජනලේඛනය?',
          option1: '1871',
          option2: '1891',
          option3: '1901',
          option4: '1881',
          correctOption: 1,
          explanation: 'ශ්‍රී ලංකාවේ ප්‍රථම ජනලේඛනය 1871 ය.'),
    ],
  };

  final List<QuizResultModel> _offlineResults = [];
  final Map<String, List<StudentAnswerModel>> _offlineAnswers = {};

  // ==========================================
  // 1. STUDENT AUTHENTICATION (Login / SignUp)
  // ==========================================

  // නව සිසුවෙකු ලියාපදිංචි කිරීම (Firebase Auth + Firestore)
  Future<String> registerStudent(StudentModel student, String password) async {
    if (_isOfflineMode) {
      _offlineStudent = student.copyWith(uid: 'offline_student_uid');
      return 'offline_student_uid';
    }

    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: student.email.trim(),
        password: password,
      );
      final uid = credential.user!.uid;
      await _db.collection('users').doc(uid).set(student.toMap());
      return uid;
    } on FirebaseAuthException catch (e) {
      print('FIREBASE AUTH ERROR CODE: ${e.code}');
      print('FIREBASE AUTH ERROR MESSAGE: ${e.message}');
      if (e.code == 'email-already-in-use') {
        throw Exception('මෙම ඊමේල් ලිපිනය දැනටමත් ලියාපදිංචි කර ඇත!');
      } else if (e.code == 'weak-password') {
        throw Exception('මුරපදය ශක්තිමත් නොවේ. අවම අකුරු 6ක් භාවිතා කරන්න!');
      } else if (e.code == 'operation-not-allowed') {
        throw Exception(
            'Firebase හි Email/Password ක්‍රමය සක්‍රීය කර නොමැත! (Enable Email/Password in console)');
      }
      throw Exception(
          'ලියාපදිංචි වීමේදී දෝෂයක් සිදුවිය: ${e.message} (Code: ${e.code})');
    } catch (e) {
      print('GENERAL ERROR: $e');
      throw Exception('ලියාපදිංචි වීමේදී අසාමාන්‍ය දෝෂයක් සිදුවිය: $e');
    }
  }

  // Email/Password ලොගින් (Firebase Auth)
  Future<StudentModel?> loginStudent(String email, String password) async {
    if (_isOfflineMode) {
      return _offlineStudent ??
          StudentModel(
            uid: 'offline_student_uid',
            name: 'Demo Student',
            email: email,
            school: 'ආදර්ශ මහා විද්‍යාලය',
            grade: '11 ශ්‍රේණිය',
            oLevelYear: 2026,
            xp: 100,
            avgScore: 80.0,
          );
    }

    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final uid = credential.user!.uid;
      return await getStudentByUid(uid);
    } on FirebaseAuthException catch (e) {
      print('FIREBASE LOGIN ERROR CODE: ${e.code}');
      print('FIREBASE LOGIN ERROR MESSAGE: ${e.message}');
      if (e.code == 'user-not-found') {
        throw Exception('ඊමේල් ලිපිනයට අදාළ ගිණුමක් නොමැත!');
      } else if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        throw Exception('ඊමේල් හෝ මුරපදය වැරදිය!');
      } else if (e.code == 'operation-not-allowed') {
        throw Exception(
            'Firebase හි Email/Password ක්‍රමය සක්‍රීය කර නොමැත! (Enable Email/Password in console)');
      }
      throw Exception('ලොගිනය ව්‍යර්ථ විය: ${e.message} (Code: ${e.code})');
    } catch (e) {
      print('GENERAL LOGIN ERROR: $e');
      throw Exception('ලොගින් වීමේදී අසාමාන්‍ය දෝෂයක් සිදුවිය: $e');
    }
  }

  // Auto-login with demo account (Fields are empty)
  Future<StudentModel?> loginWithDemoAccount() async {
    const demoEmail = 'demo@quiz.app';
    const demoPassword = 'demo123456';

    if (_isOfflineMode) {
      _offlineStudent = StudentModel(
        uid: 'offline_demo_uid',
        name: 'Demo Student (Offline Bypass)',
        email: demoEmail,
        school: 'ආදර්ශ මහා විද්‍යාලය',
        grade: '11 ශ්‍රේණිය',
        oLevelYear: 2026,
        xp: 150,
        avgScore: 75.0,
      );
      return _offlineStudent;
    }

    try {
      // Try signing in first
      final credential = await _auth.signInWithEmailAndPassword(
        email: demoEmail,
        password: demoPassword,
      );
      return await getStudentByUid(credential.user!.uid);
    } catch (e) {
      // Any error (config not ready, network, user-not-found) triggers offline bypass instantly
      _isOfflineMode = true;
      _offlineStudent = StudentModel(
        uid: 'offline_demo_uid',
        name: 'Demo Student (Offline Bypass)',
        email: demoEmail,
        school: 'ආදර්ශ මහා විද්‍යාලය',
        grade: '11 ශ්‍රේණිය',
        oLevelYear: 2026,
        xp: 150,
        avgScore: 75.0,
      );
      return _offlineStudent;
    }
  }

  // UID අනුව Student profile ලබාගැනීම
  Future<StudentModel?> getStudentByUid(String uid) async {
    if (_isOfflineMode) {
      return _offlineStudent;
    }
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return StudentModel.fromMap(doc.data()!, uid: uid);
      }
    } catch (_) {
      _isOfflineMode = true;
      return _offlineStudent;
    }
    return null;
  }

  // Email අනුව student check කිරීම (signup duplicate check)
  Future<bool> emailExists(String email) async {
    if (_isOfflineMode) return false;
    try {
      // Use Firestore query instead of deprecated fetchSignInMethodsForEmail
      final snap = await _db
          .collection('users')
          .where('email', isEqualTo: email.trim())
          .limit(1)
          .get();
      return snap.docs.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  // සිසුවා ලොග් අවුට් කිරීම
  Future<void> signOut() async {
    if (!_isOfflineMode) {
      await _auth.signOut();
    }
    _offlineStudent = null;
    _isOfflineMode = false;
  }

  // දැනට ලොග් ව ිසිටින user UID ලබා ගැනීම
  String? get currentUid =>
      _isOfflineMode ? _offlineStudent?.uid : _auth.currentUser?.uid;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ==========================================
  // 2. STUDENT PROFILE UPDATE
  // ==========================================

  Future<void> updateStudentProfile(StudentModel student) async {
    if (_isOfflineMode) {
      _offlineStudent = student;
      return;
    }
    if (student.uid == null) throw Exception('UID නොමැත!');
    await _db.collection('users').doc(student.uid).update(student.toMap());
  }

  Future<void> updateStudentStats(
      String uid, int additionalXp, double newAvgScore) async {
    if (_isOfflineMode) {
      if (_offlineStudent != null) {
        _offlineStudent = _offlineStudent!.copyWith(
          xp: _offlineStudent!.xp + additionalXp,
          avgScore: newAvgScore,
        );
      }
      return;
    }
    await _db.collection('users').doc(uid).update({
      'xp': FieldValue.increment(additionalXp),
      'avgScore': newAvgScore,
    });
  }

  // ==========================================
  // 3. SUBJECTS (Home & Choose Subject Pages)
  // ==========================================

  // Firestore සිට විෂය ලැයිස්තුව ලබාගැනීම
  Future<List<SubjectModel>> getSubjects({String? searchQuery}) async {
    if (_isOfflineMode) {
      final all = _offlineSubjects;
      if (searchQuery != null && searchQuery.isNotEmpty) {
        return all
            .where(
                (s) => s.name.toLowerCase().contains(searchQuery.toLowerCase()))
            .toList();
      }
      return all;
    }

    try {
      final snap = await _db.collection('subjects').get();

      // Seed missing subjects using fixed IDs (idempotent upsert — never creates duplicates)
      if ((snap.docs.isEmpty || snap.docs.length < 15) && !_seedingInProgress) {
        _seedingInProgress = true;
        try {
          await _seedSubjectsAndQuestions();
        } finally {
          _seedingInProgress = false;
        }
      }

      final newSnap = await _db.collection('subjects').get();
      var all = newSnap.docs
          .map((d) => SubjectModel.fromMap(d.data(), id: d.id))
          .toList();

      // Deduplicate by name (safety net for any pre-existing duplicates in Firestore)
      final seen = <String>{};
      all = all.where((s) => seen.add(s.name.toLowerCase())).toList();

      if (searchQuery != null && searchQuery.isNotEmpty) {
        return all
            .where(
                (s) => s.name.toLowerCase().contains(searchQuery.toLowerCase()))
            .toList();
      }
      return all;
    } catch (_) {
      _isOfflineMode = true;
      return getSubjects(searchQuery: searchQuery);
    }
  }

  // Fixed subject IDs and seed data — using fixed doc IDs ensures set() is idempotent (no duplicates ever)
  static const List<Map<String, dynamic>> _subjectSeedData = [
    {
      'id': 'religion',
      'name': 'Religion',
      'iconName': 'volunteer_activism',
      'imageUrl':
          'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400&q=80',
      'totalQuestions': 0,
      'completedRate': 0.0
    },
    {
      'id': 'sinhala',
      'name': 'Sinhala',
      'iconName': 'book',
      'imageUrl':
          'https://images.unsplash.com/photo-1506880018603-83d5b814b5a6?w=400&q=80',
      'totalQuestions': 30,
      'completedRate': 0.0
    },
    {
      'id': 'english',
      'name': 'English',
      'iconName': 'language',
      'imageUrl':
          'https://images.unsplash.com/photo-1451226428352-cf66b8a0317a?w=400&q=80',
      'totalQuestions': 0,
      'completedRate': 0.0
    },
    {
      'id': 'math',
      'name': 'Mathematics',
      'iconName': 'calculate',
      'imageUrl':
          'https://images.unsplash.com/photo-1509228468518-180dd4864904?w=400&q=80',
      'totalQuestions': 3,
      'completedRate': 0.0
    },
    {
      'id': 'sci',
      'name': 'Science',
      'iconName': 'science',
      'imageUrl':
          'https://images.unsplash.com/photo-1507668077129-56e32842fceb?w=400&q=80',
      'totalQuestions': 30,
      'completedRate': 0.0
    },
    {
      'id': 'history',
      'name': 'History',
      'iconName': 'history',
      'imageUrl':
          'https://images.unsplash.com/photo-1461360370896-922624d12aa1?w=400&q=80',
      'totalQuestions': 30,
      'completedRate': 0.0
    },
    {
      'id': 'business',
      'name': 'Business & Accounting Studies',
      'iconName': 'analytics',
      'imageUrl':
          'https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=400&q=80',
      'totalQuestions': 0,
      'completedRate': 0.0
    },
    {
      'id': 'geo',
      'name': 'Geography',
      'iconName': 'public',
      'imageUrl':
          'https://images.unsplash.com/photo-1524661135-423995f22d0b?w=400&q=80',
      'totalQuestions': 0,
      'completedRate': 0.0
    },
    {
      'id': 'civic',
      'name': 'Civic Education',
      'iconName': 'gavel',
      'imageUrl':
          'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?w=400&q=80',
      'totalQuestions': 0,
      'completedRate': 0.0
    },
    {
      'id': 'music',
      'name': 'Music',
      'iconName': 'music_note',
      'imageUrl':
          'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=400&q=80',
      'totalQuestions': 0,
      'completedRate': 0.0
    },
    {
      'id': 'dancing',
      'name': 'Dancing',
      'iconName': 'emoji_people',
      'imageUrl':
          'https://images.unsplash.com/photo-1508700115892-45ecd05ae2ad?w=400&q=80',
      'totalQuestions': 0,
      'completedRate': 0.0
    },
    {
      'id': 'art',
      'name': 'Art (Act)',
      'iconName': 'palette',
      'imageUrl':
          'https://images.unsplash.com/photo-1513364776144-60967b0f800f?w=400&q=80',
      'totalQuestions': 0,
      'completedRate': 0.0
    },
    {
      'id': 'ict',
      'name': 'Information & Communication',
      'iconName': 'computer',
      'imageUrl':
          'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?w=400&q=80',
      'totalQuestions': 0,
      'completedRate': 0.0
    },
    {
      'id': 'agriculture',
      'name': 'Agriculture & Food Technology',
      'iconName': 'agriculture',
      'imageUrl':
          'https://images.unsplash.com/photo-1464226184884-fa280b87c3a9?w=400&q=80',
      'totalQuestions': 0,
      'completedRate': 0.0
    },
    {
      'id': 'health',
      'name': 'Health & Physical Education',
      'iconName': 'fitness_center',
      'imageUrl':
          'https://images.unsplash.com/photo-1476480862126-209bfaa8edc8?w=400&q=80',
      'totalQuestions': 0,
      'completedRate': 0.0
    },
  ];

  Future<void> updateSubjectProgress(
      String subjectId, double completedRate) async {
    if (_isOfflineMode) {
      final idx = _offlineSubjects.indexWhere((s) => s.id == subjectId);
      if (idx != -1) {
        _offlineSubjects[idx] =
            _offlineSubjects[idx].copyWith(completedRate: completedRate);
      }
      return;
    }
    await _db
        .collection('subjects')
        .doc(subjectId)
        .update({'completedRate': completedRate});
  }

  // ==========================================
  // 4. QUESTIONS (Quiz Page)
  // ==========================================

  Future<List<QuestionModel>> getQuestionsBySubject(String subjectId) async {
    if (_isOfflineMode) {
      return _offlineQuestions[subjectId] ?? [];
    }

    try {
      final snap = await _db
          .collection('subjects')
          .doc(subjectId)
          .collection('questions')
          .get();

      // Force sync for ICT, Civic, Business subjects (data stored in dedicated seed methods)
      if (subjectId == 'ict' || subjectId == 'civic' || subjectId == 'business') {
        final cleanBatch = _db.batch();
        for (var doc in snap.docs) {
          cleanBatch.delete(doc.reference);
        }
        await cleanBatch.commit();
        if (subjectId == 'ict') await _seedIctQuestions();
        if (subjectId == 'civic') await _seedCivicQuestions();
        if (subjectId == 'business') await _seedBusinessQuestions();
        final newSnap = await _db.collection('subjects').doc(subjectId).collection('questions').get();
        final qs = newSnap.docs.map((d) => QuestionModel.fromMap(d.data(), id: d.id, subjectId: subjectId)).toList();
        qs.sort((a, b) {
          final numA = int.tryParse(a.id?.replaceAll(RegExp(r'[^0-9]'), '') ?? '0') ?? 0;
          final numB = int.tryParse(b.id?.replaceAll(RegExp(r'[^0-9]'), '') ?? '0') ?? 0;
          return numA.compareTo(numB);
        });
        return qs;
      }

      // Firebase eke questions adu nam _offlineQuestions walen auto-seed karamu
      final offlineQs = _offlineQuestions[subjectId];
      if (offlineQs != null && snap.docs.length < offlineQs.length) {
        final batch = _db.batch();
        for (var q in offlineQs) {
          // Use fixed ID from the model to prevent duplicates if some already exist
          final ref = _db
              .collection('subjects')
              .doc(subjectId)
              .collection('questions')
              .doc(q.id);
          batch.set(
              ref,
              {
                'subjectId': subjectId,
                'questionText': q.questionText,
                'option1': q.option1,
                'option2': q.option2,
                'option3': q.option3,
                'option4': q.option4,
                'correctOption': q.correctOption,
                'explanation': q.explanation,
              },
              SetOptions(merge: true));
        }

        // Update the subject document with the correct total questions count
        final subjectRef = _db.collection('subjects').doc(subjectId);
        batch.set(subjectRef, {'totalQuestions': offlineQs.length},
            SetOptions(merge: true));

        await batch.commit();

        // Commit karala nawa data ganna
        final newSnap = await _db
            .collection('subjects')
            .doc(subjectId)
            .collection('questions')
            .get();
        final questions = newSnap.docs
            .map((d) =>
                QuestionModel.fromMap(d.data(), id: d.id, subjectId: subjectId))
            .toList();
        questions.sort((a, b) {
          final numA =
              int.tryParse(a.id?.replaceAll(RegExp(r'[^0-9]'), '') ?? '0') ?? 0;
          final numB =
              int.tryParse(b.id?.replaceAll(RegExp(r'[^0-9]'), '') ?? '0') ?? 0;
          return numA.compareTo(numB);
        });
        return questions;
      }

      final questions = snap.docs
          .map((d) =>
              QuestionModel.fromMap(d.data(), id: d.id, subjectId: subjectId))
          .toList();
      questions.sort((a, b) {
        final numA =
            int.tryParse(a.id?.replaceAll(RegExp(r'[^0-9]'), '') ?? '0') ?? 0;
        final numB =
            int.tryParse(b.id?.replaceAll(RegExp(r'[^0-9]'), '') ?? '0') ?? 0;
        return numA.compareTo(numB);
      });
      return questions;
    } catch (_) {
      _isOfflineMode = true;
      return getQuestionsBySubject(subjectId);
    }
  }

  // ==========================================
  // 5. QUIZ RESULTS (Results & Review Pages)
  // ==========================================

  Future<String> saveQuizResult(
      QuizResultModel result, List<StudentAnswerModel> answers) async {
    if (_isOfflineMode) {
      final mockResultId =
          'offline_res_${DateTime.now().millisecondsSinceEpoch}';
      final newResult = QuizResultModel(
        id: mockResultId,
        studentId: result.studentId,
        subjectId: result.subjectId,
        score: result.score,
        totalQuestions: result.totalQuestions,
        timeSpent: result.timeSpent,
        dateTaken: result.dateTaken,
      );
      _offlineResults.add(newResult);

      final List<StudentAnswerModel> updatedAnswers = answers
          .map((a) => StudentAnswerModel(
                id: a.id,
                resultId: mockResultId,
                questionId: a.questionId,
                selectedOption: a.selectedOption,
                isCorrect: a.isCorrect,
                question: a.question,
              ))
          .toList();
      _offlineAnswers[mockResultId] = updatedAnswers;

      // Update student stats locally (only this user's results)
      int totalCorrect = 0;
      int totalQs = 0;
      for (var res in _offlineResults) {
        if (res.studentId == result.studentId) {
          totalCorrect += res.score;
          totalQs += res.totalQuestions;
        }
      }
      final double newAvgScore =
          totalQs > 0 ? (totalCorrect / totalQs) * 100 : 0.0;
      final int gainedXp = result.score * 50;

      await updateStudentStats(result.studentId, gainedXp, newAvgScore);
      await updateSubjectProgress(
          result.subjectId, result.score / result.totalQuestions);

      return mockResultId;
    }

    try {
      final batch = _db.batch();
      final resultRef = _db
          .collection('users')
          .doc(result.studentId)
          .collection('results')
          .doc(result.subjectId); // Use subjectId to overwrite and keep only one record per subject

      // To handle answers, we can't easily batch delete a subcollection. 
      // But we can overwrite the result document.
      batch.set(resultRef, result.toMap());

      for (var answer in answers) {
        final answerRef = resultRef.collection('answers').doc(answer.questionId); // Overwrite old answers using questionId
        batch.set(answerRef, {
          'resultId': resultRef.id,
          'questionId': answer.questionId,
          'selectedOption': answer.selectedOption,
          'isCorrect': answer.isCorrect,
        });
      }

      await batch.commit();

      final allResultsSnap = await _db
          .collection('users')
          .doc(result.studentId)
          .collection('results')
          .get();

      int totalCorrect = 0;
      int totalQs = 0;
      for (var doc in allResultsSnap.docs) {
        final data = doc.data();
        totalCorrect += (data['score'] as num?)?.toInt() ?? 0;
        totalQs += (data['totalQuestions'] as num?)?.toInt() ?? 0;
      }
      final double newAvgScore =
          totalQs > 0 ? (totalCorrect / totalQs) * 100 : 0.0;
      final int gainedXp = result.score * 50;

      await updateStudentStats(result.studentId, gainedXp, newAvgScore);

      double bestAccuracy = 0.0;
      for (var doc in allResultsSnap.docs) {
        final data = doc.data();
        if (data['subjectId'] == result.subjectId) {
          final int s = (data['score'] as num?)?.toInt() ?? 0;
          final int t = (data['totalQuestions'] as num?)?.toInt() ?? 1;
          final double acc = s / t;
          if (acc > bestAccuracy) bestAccuracy = acc;
        }
      }
      await updateSubjectProgress(result.subjectId, bestAccuracy);

      return resultRef.id;
    } catch (_) {
      _isOfflineMode = true;
      return saveQuizResult(result, answers);
    }
  }

  // Get highest scores by subject for a given student
  Future<Map<String, QuizResultModel>> getHighestScoresBySubject(String studentId) async {
    final Map<String, QuizResultModel> highestScores = {};
    final validSubjectIds = _subjectSeedData.map((e) => e['id'] as String).toSet();

    if (_isOfflineMode) {
      for (var result in _offlineResults) {
        if (result.studentId == studentId && validSubjectIds.contains(result.subjectId)) {
          final existing = highestScores[result.subjectId];
          if (existing == null || result.score > existing.score) {
            highestScores[result.subjectId] = result;
          }
        }
      }
      return highestScores;
    }

    try {
      final snap = await _db
          .collection('users')
          .doc(studentId)
          .collection('results')
          .get();

      for (var doc in snap.docs) {
        final result = QuizResultModel.fromMap(doc.data(), id: doc.id);
        
        // Filter out corrupted records where subjectId is an auto-generated Firebase ID
        if (!validSubjectIds.contains(result.subjectId)) continue;

        final existing = highestScores[result.subjectId];
        if (existing == null || result.score > existing.score) {
          highestScores[result.subjectId] = result;
        }
      }
      return highestScores;
    } catch (_) {
      _isOfflineMode = true;
      return getHighestScoresBySubject(studentId);
    }
  }

  Future<List<QuizResultModel>> getStudentQuizHistory(String studentId) async {
    if (_isOfflineMode) {
      return _offlineResults;
    }
    try {
      final snap = await _db
          .collection('users')
          .doc(studentId)
          .collection('results')
          .orderBy('dateTaken', descending: true)
          .get();

      return snap.docs
          .map((d) => QuizResultModel.fromMap(d.data(), id: d.id))
          .toList();
    } catch (_) {
      _isOfflineMode = true;
      return _offlineResults;
    }
  }

  Future<List<StudentAnswerModel>> getAnswersForQuizResult(
      String uid, String resultId) async {
    if (_isOfflineMode) {
      final answers = _offlineAnswers[resultId] ?? [];
      // Attach mock questions to review
      final List<StudentAnswerModel> detailedAnswers = [];
      for (var a in answers) {
        QuestionModel? question;
        for (var key in _offlineQuestions.keys) {
          final found =
              _offlineQuestions[key]!.where((q) => q.id == a.questionId);
          if (found.isNotEmpty) {
            question = found.first;
            break;
          }
        }
        detailedAnswers.add(StudentAnswerModel(
          id: a.id,
          resultId: a.resultId,
          questionId: a.questionId,
          selectedOption: a.selectedOption,
          isCorrect: a.isCorrect,
          question: question,
        ));
      }
      return detailedAnswers;
    }

    try {
      final snap = await _db
          .collection('users')
          .doc(uid)
          .collection('results')
          .doc(resultId)
          .collection('answers')
          .get();

      List<StudentAnswerModel> answers = [];
      for (var doc in snap.docs) {
        final data = doc.data();
        final String questionId = data['questionId'] as String? ?? '';

        QuestionModel? question;
        final subjectSnap = await _db.collection('subjects').get();
        for (var subDoc in subjectSnap.docs) {
          final qDoc = await _db
              .collection('subjects')
              .doc(subDoc.id)
              .collection('questions')
              .doc(questionId)
              .get();
          if (qDoc.exists && qDoc.data() != null) {
            question = QuestionModel.fromMap(qDoc.data()!,
                id: qDoc.id, subjectId: subDoc.id);
            break;
          }
        }

        answers.add(
            StudentAnswerModel.fromMap(data, id: doc.id, question: question));
      }
      return answers;
    } catch (_) {
      _isOfflineMode = true;
      return getAnswersForQuizResult(uid, resultId);
    }
  }

  // ==========================================
  // 6. DATA SEEDING (First-time Firestore setup)
  // ==========================================
  Future<void> _seedSubjectsAndQuestions() async {
    final batch = _db.batch();

    // Use fixed document IDs — batch.set() with a fixed ID is an idempotent upsert,
    // so calling this multiple times never creates duplicate subject documents.
    for (var sub in _subjectSeedData) {
      final id = sub['id'] as String;
      final data = Map<String, dynamic>.from(sub)..remove('id');
      final ref = _db.collection('subjects').doc(id);
      batch.set(ref, data, SetOptions(merge: true));
    }
    await batch.commit();

    // Fixed subject IDs for questions
    const String scienceId = 'sci';
    final scienceQuestions = [
      {
        'subjectId': scienceId,
        'questionText': 'බහිස්ස්‍රාවී ද්‍රව්‍යයක් වන යුරියා නිපදවෙන්නේ?',
        'option1': 'වකුගඩුවල',
        'option2': 'අක්මාවෙහි',
        'option3': 'මුත්‍රාශයෙහි',
        'option4': 'වෘක්කාණුවල',
        'correctOption': 2,
        'explanation': 'යුරියා නිපදවෙන්නේ අක්මාවෙහිය.'
      },
      {
        'subjectId': scienceId,
        'questionText': 'ක්ෂමතාවේ (Power) ඒකකය කුමක්ද?',
        'option1': 'Ws',
        'option2': 'Ws⁻¹',
        'option3': 'Js',
        'option4': 'Js⁻¹',
        'correctOption': 4,
        'explanation': 'ක්ෂමතාව = ශක්තිය/කාලය = Js⁻¹ (Watt).'
      },
      {
        'subjectId': scienceId,
        'questionText':
            'අයිසොප්‍රොපිල් ඇල්කොහොල් (CH₃)₂CHOH අණුවක ඇති පරමාණු ගණන?',
        'option1': '8',
        'option2': '10',
        'option3': '11',
        'option4': '12',
        'correctOption': 4,
        'explanation': 'C=3, H=8, O=1 → මුළු = 12.'
      },
      {
        'subjectId': scienceId,
        'questionText':
            'ශාක පත්‍ර තුළ නිපදවන ආහාර ශාක දේහය පුරා පරිවහනය කරන පටකය?',
        'option1': 'ශෛලම',
        'option2': 'ප්ලෝයම',
        'option3': 'කැම්බියම',
        'option4': 'දෘඪස්තර',
        'correctOption': 2,
        'explanation': 'ප්ලෝයම (Phloem) ආහාර ගෙනයයි.'
      },
      {
        'subjectId': scienceId,
        'questionText':
            'වස්තු පිරි මැදීමෙන් ධන ආරෝපණ ලැබීමේ දී අනෙකට සංක්‍රමණය වනුයේ?',
        'option1': 'ඉලෙක්ට්‍රෝනයි',
        'option2': 'ප්‍රෝටෝනයි',
        'option3': 'නියුට්‍රෝනයි',
        'option4': 'ඉලෙක්ට්‍රෝන හා ප්‍රෝටෝනයි',
        'correctOption': 1,
        'explanation': 'ඉලෙක්ට්‍රෝන සංචලනශීලී බැවින් ඒවාම සංක්‍රමණය වේ.'
      },
      {
        'subjectId': scienceId,
        'questionText':
            'පිළිවෙළින් ආම්ලික, උභයගුණ, භාස්මික ඔක්සයිඩ ඇතුළත් කුමක්ද?',
        'option1': 'SO₃, Al₂O₃, SiO₂',
        'option2': 'SO₃, Al₂O₃, MgO',
        'option3': 'CO₂, SiO₂, MgO',
        'option4': 'SiO₂, CO₂, Al₂O₃',
        'correctOption': 2,
        'explanation': 'SO₃=ආම්ලික, Al₂O₃=උභයගුණ, MgO=භාස්මික.'
      },
      {
        'subjectId': scienceId,
        'questionText': 'ශාක සෛලයක ඇති අජීවී ව්‍යුහය?',
        'option1': 'සෛල බිත්තිය',
        'option2': 'ප්ලාස්ම පටලය',
        'option3': 'රයිබොසෝම',
        'option4': 'ගොල්ගි දේහ',
        'correctOption': 1,
        'explanation': 'සෛල බිත්තිය (Cell Wall) අජීවී ව්‍යුහයකි.'
      },
      {
        'subjectId': scienceId,
        'questionText': 'විද්‍යුත්-චුම්බක තරංග ගැන අසත්‍ය ප්‍රකාශය?',
        'option1': 'ශක්තිය සම්ප්‍රේෂණය කරයි',
        'option2': 'රික්තයේ 3×10⁸ ms⁻¹ ගමන් කරයි',
        'option3': 'පදාර්ථ මාධ්‍යයේ සංඛ්‍යාතය රික්තයේ දීට වඩා අඩු',
        'option4': 'පදාර්ථ මාධ්‍යයේ වේගය රික්තයේ දීට වඩා අඩු',
        'correctOption': 3,
        'explanation': 'සංඛ්‍යාතය (frequency) නොවෙනස් ව පවතී.'
      },
      {
        'subjectId': scienceId,
        'questionText': 'අයනික සංයෝග ගැන සත්‍ය ප්‍රකාශය?',
        'option1': 'ඝන අවස්ථාවේ විදුලිය සන්නයනය',
        'option2': 'සියල්ල ජලයේ හොඳින් දිය වේ',
        'option3': 'ගලාංක හා ද්‍රවාංක ඉහළ',
        'option4': 'විලීනයේ විදුලිය සන්නයනය නොකරයි',
        'correctOption': 3,
        'explanation': 'අයනික සංයෝගවල ගලාංක හා ද්‍රවාංක ඉහළ.'
      },
      {
        'subjectId': scienceId,
        'questionText': 'කැස්ස සමඟ රුධිරය, බර අඩුවීම, වෙහෙස — රෝගය?',
        'option1': 'නිව්මෝනියාව',
        'option2': 'බ්‍රොන්කයිටිස්',
        'option3': 'ක්ෂය රෝගය',
        'option4': 'සිලිකෝසිස්',
        'correctOption': 3,
        'explanation': 'ක්ෂය රෝගය (Tuberculosis) හේතුවෙනි.'
      },
      {
        'subjectId': scienceId,
        'questionText':
            'ආලෝක වර්තනය: A=විරලතරසිට ඝනතරට, B=වේග වෙනස, C=සංඛ්‍යාතය වෙනස. සත්‍ය?',
        'option1': 'A පමණි',
        'option2': 'B පමණි',
        'option3': 'A හා C',
        'option4': 'B හා C',
        'correctOption': 2,
        'explanation': 'B සත්‍ය. A,C අසත්‍ය.'
      },
      {
        'subjectId': scienceId,
        'questionText': 'පොළොව g=10, සඳ g=10/6. 60N වස්තුවක සඳ මත බර?',
        'option1': '10 N',
        'option2': '60 N',
        'option3': '100 N',
        'option4': '360 N',
        'correctOption': 1,
        'explanation': 'ස්කන්ධය=6kg. සඳ g=10/6. බර=6×10/6=10N.'
      },
      {
        'subjectId': scienceId,
        'questionText':
            'ආවේස් හා මැමේලියාවට පොදු: A=සමතාපිත්ව, B=රෝම, C=අස්ථිමය, D=හෘදය කුටීර4',
        'option1': 'A හා B',
        'option2': 'A හා D',
        'option3': 'B හා C',
        'option4': 'C හා D',
        'correctOption': 2,
        'explanation': 'A,D දෙකටම පොදු.'
      },
      {
        'subjectId': scienceId,
        'questionText': 'ලෝහ ගැන අසත්‍ය ප්‍රකාශය?',
        'option1': 'බහුතරය ලෝහ',
        'option2': 'සියල්ල විදුලිය සන්නයනය',
        'option3': 'ධන අයන නිපදවයි',
        'option4': 'සියල්ල H₂ නිකුත් කරයි',
        'correctOption': 4,
        'explanation': 'Cu, Ag, Au H₂ නිකුත් නොකරයි.'
      },
      {
        'subjectId': scienceId,
        'questionText': 'මෙතිල් ඔරේන්ජ් රතු — pH?',
        'option1': '2',
        'option2': '7',
        'option3': '12',
        'option4': '14',
        'correctOption': 1,
        'explanation': 'pH<4 රතු. pH 2 ආම්ලික.'
      },
      {
        'subjectId': scienceId,
        'questionText': 'අතිධ්වනිය 4s. ගැඹුර 2880m. ජල ශබ්ද වේගය?',
        'option1': '720 ms⁻¹',
        'option2': '1440 ms⁻¹',
        'option3': '2880 ms⁻¹',
        'option4': '3700 ms⁻¹',
        'correctOption': 2,
        'explanation': '5760/4=1440 ms⁻¹.'
      },
      {
        'subjectId': scienceId,
        'questionText': 'දහනය, වාතයෙන් ළා, ජලයේ ස්වල්ප ද්‍රාව්‍ය — වායුව?',
        'option1': 'හයිඩ්‍රජන්',
        'option2': 'නයිට්‍රජන්',
        'option3': 'ඔක්සිජන්',
        'option4': 'CO₂',
        'correctOption': 1,
        'explanation': 'H₂ — දාහ්‍ය, ළා, ස්වල්ප ද්‍රාව්‍ය.'
      },
      {
        'subjectId': scienceId,
        'questionText': 'හෘද ස්පන්දන පාලනය කරන CNS කොටස?',
        'option1': 'මස්තිෂ්කය',
        'option2': 'අනුමස්තිෂ්කය',
        'option3': 'සුෂුම්නාව',
        'option4': 'සුෂුම්නා ශීර්ෂකය',
        'correctOption': 4,
        'explanation': 'Medulla oblongata හෘද ස්පන්දන කේන්ද්‍රය.'
      },
      {
        'subjectId': scienceId,
        'questionText': 'ප්‍රතිරෝධය: A=V මත, B=දිගට, C=I මත. සත්‍ය?',
        'option1': 'A',
        'option2': 'B',
        'option3': 'A හා B',
        'option4': 'A හා C',
        'correctOption': 2,
        'explanation': 'R=ρL/A. B පමණි සත්‍ය.'
      },
      {
        'subjectId': scienceId,
        'questionText': 'CaCO₃ 10g මවුල (CaCO₃=100)?',
        'option1': '0.01',
        'option2': '0.1',
        'option3': '1',
        'option4': '10',
        'correctOption': 2,
        'explanation': 'n=10/100=0.1 mol.'
      },
      {
        'subjectId': scienceId,
        'questionText': 'කාබොහයිඩ්‍රේට ගැන නිවැරදි ප්‍රකාශය?',
        'option1': 'සියල්ල ජල ද්‍රාව්‍ය',
        'option2': 'සියල්ල ස්ඵටිකරූපී',
        'option3': 'C:H:O = 1:2:1',
        'option4': 'ග්ලූකෝස් තැනුම් ඒකකය',
        'correctOption': 4,
        'explanation': 'ග්ලූකෝස් (monosaccharide) මූලික ඒකකය.'
      },
      {
        'subjectId': scienceId,
        'questionText': 'ඝන ද්‍රවයේ ඉපිලීමට?',
        'option1': 'ඝනත්වය ද්‍රවයෙන් අඩු',
        'option2': 'ස්කන්ධය = විස්ථාපිත ස්කන්ධය',
        'option3': 'බර = විස්ථාපිත ද්‍රව බර',
        'option4': 'බර < උඩුකුරු තෙරපුම',
        'correctOption': 2,
        'explanation': 'ආකිමිඩීස් — ඉපිලෙන විට ස්කන්ධය = විස්ථාපිත ස්කන්ධය.'
      },
      {
        'subjectId': scienceId,
        'questionText': 'Tt×Tt ප්‍රවේණිදර්ශ හා රූපානුදර්ශ ගණන?',
        'option1': '2 සහ 1',
        'option2': '3 සහ 2',
        'option3': '4 සහ 2',
        'option4': '4 සහ 3',
        'correctOption': 2,
        'explanation': 'TT,Tt,tt=3 ප්‍රවේණිදර්ශ; 2 රූපානුදර්ශ.'
      },
      {
        'subjectId': scienceId,
        'questionText': 'Fe₂O₃+3CO→2Fe+3CO₂. Fe₂O₃ 1mol → Fe ස්කන්ධය (Fe=56)?',
        'option1': '28g',
        'option2': '56g',
        'option3': '112g',
        'option4': '168g',
        'correctOption': 3,
        'explanation': '2mol×56=112g.'
      },
      {
        'subjectId': scienceId,
        'questionText': 'පට්ටිකා අඩු වූ විට?',
        'option1': 'O₂ පරිවහනය වැඩිවේ',
        'option2': 'ප්‍රතිදේහ අඩාල',
        'option3': 'රුධිර කැටිගැසීම නොවේ',
        'option4': 'හෝමෝන සෙමින්',
        'correctOption': 3,
        'explanation': 'පට්ටිකා clotting සඳහා.'
      },
      {
        'subjectId': scienceId,
        'questionText':
            'A=උත්ප්‍රේරකය ශීඝ්‍රතාව වැඩිකරයි. B=ප්‍රතික්‍රියාවෙන් සංයුතිය වෙනස්.',
        'option1': 'A හා B සත්‍ය',
        'option2': 'A සත්‍ය B අසත්‍ය',
        'option3': 'A හා B අසත්‍ය',
        'option4': 'A අසත්‍ය B සත්‍ය',
        'correctOption': 2,
        'explanation': 'A සත්‍ය. B අසත්‍ය — නොවෙනස්ව ඉතිරිවේ.'
      },
      {
        'subjectId': scienceId,
        'questionText':
            'බහු අවයවක: A=ඉහළ mol mass, B=monomers ලෙස, C=කෘත්‍රිම/ස්වාභාවික. සත්‍ය?',
        'option1': 'A',
        'option2': 'B',
        'option3': 'A හා C',
        'option4': 'B හා C',
        'correctOption': 3,
        'explanation': 'A,C සත්‍ය. B අසත්‍ය.'
      },
      {
        'subjectId': scienceId,
        'questionText': 'v-t ප්‍රස්තාර ගැන අසත්‍ය?',
        'option1': 'වර්ග ඵලය = විස්ථාපනය',
        'option2': 'නිශ්චලතාවෙන් ආරම්භ = (0,0)',
        'option3': 'v වෙනස් නම් gradient=0',
        'option4': 'gradient = ත්වරණය',
        'correctOption': 3,
        'explanation': 'v වෙනස් නම් gradient≠0.'
      },
      {
        'subjectId': scienceId,
        'questionText': 'ඇල්ගී වර්ධනය — සාගර දූෂකය?',
        'option1': 'බැර ලෝහ',
        'option2': 'සල්ෆේට්',
        'option3': 'න්‍යෂ්ටික අපද්‍රව්‍ය',
        'option4': 'පොස්පේට්',
        'correctOption': 4,
        'explanation': 'Phosphates eutrophication ඇති කරයි.'
      },
      {
        'subjectId': scienceId,
        'questionText': 'වෙරළ ඛාදනය + කුණාටු වැඩිවීමට හේතුව?',
        'option1': 'ගෝලීය උණුසුම',
        'option2': 'හරිතාගාර ආචරණය',
        'option3': 'ඕසෝන් ක්ෂය',
        'option4': 'සුපෝෂණය',
        'correctOption': 1,
        'explanation': 'ගෝලීය උෂ්ණය ↑ → මුහුදු මට්ටම ↑, කුණාටු.'
      },
    ];

    final batch2 = _db.batch();
    for (var q in scienceQuestions) {
      final ref = _db
          .collection('subjects')
          .doc(scienceId)
          .collection('questions')
          .doc();
      batch2.set(ref, q);
    }

    const String mathId = 'math';
    final mathQuestions = [
      {
        'subjectId': mathId,
        'questionText': '3x + 5 = 20 සමීකරණයේ x හි අගය සොයන්න.',
        'option1': 'x = 3',
        'option2': 'x = 5',
        'option3': 'x = 15',
        'option4': 'x = 10',
        'correctOption': 2,
        'explanation': '3x = 15 → x = 5.'
      },
      {
        'subjectId': mathId,
        'questionText': 'රවුමක විෂ්කම්භය 14 cm නම් අරය (Radius) කොපමණද?',
        'option1': '28 cm',
        'option2': '14 cm',
        'option3': '7 cm',
        'option4': '3.5 cm',
        'correctOption': 3,
        'explanation': 'අරය = විෂ්කම්භය / 2 = 14 / 2 = 7 cm.'
      },
      {
        'subjectId': mathId,
        'questionText': 'ප්‍රථමක සංඛ්‍යාවක් (Prime Number) නොවන්නේ කුමක්ද?',
        'option1': '2',
        'option2': '3',
        'option3': '5',
        'option4': '9',
        'correctOption': 4,
        'explanation': '9 = 3×3 බැවින් ප්‍රථමක සංඛ්‍යාවක් නොවේ.'
      },
    ];

    for (var q in mathQuestions) {
      final ref =
          _db.collection('subjects').doc(mathId).collection('questions').doc();
      batch2.set(ref, q);
    }

    await batch2.commit();

    // Sinhala questions — seeded with fixed IDs (idempotent)
    const String sinhalaId = 'sinhala';
    final sinhalaQuestions = [
      {
        'id': 'sin_q1',
        'subjectId': sinhalaId,
        'questionText':
            'ඔහුගෙන් වචනයක් ගැනීම වනාහි ගලෙන් පට්ටයක් ගැනීම වැනි කාර්යයකි.',
        'option1': 'අමාරුවෙන් කළ යුත්තකි.',
        'option2': 'ඉතා පහසු කටයුත්තකි.',
        'option3': 'ශරීර ශක්තිය යොදා කළ යුත්තකි.',
        'option4': 'කිසිදා සිදු කළ නොහැක්කකි.',
        'correctOption': 4,
        'explanation': 'නිවැරදි පිළිතුර: (4)'
      },
      {
        'id': 'sin_q2',
        'subjectId': sinhalaId,
        'questionText': 'මා දුන් අඹගෙඩිය, දුගියා තලු මරමින් කෑවේ ය.',
        'option1': 'ඉතා ම ආශාවෙන්',
        'option2': 'කටින් හඬක් පිට කරමින්',
        'option3': 'තල්ලෙහි ගෑවෙන පරිද්දෙන්',
        'option4': 'ඉතා අකමැත්තෙන්',
        'correctOption': 1,
        'explanation': 'නිවැරදි පිළිතුර: (1)'
      },
      {
        'id': 'sin_q3',
        'subjectId': sinhalaId,
        'questionText':
            'සිරිපාල දිය යටින් ගින්දර ගෙනියන පුද්ගලයකු සේ ප්‍රසිද්ධ ය.',
        'option1': 'උපක්‍රමශීලී ව වැඩ නොකරන',
        'option2': 'අන්‍යයා තළා - පෙළා වැඩ කරන',
        'option3': 'කට්ට, කෛරාටික, වංචනික ක්‍රියා කරන',
        'option4': 'අන් අයට කළ නොහැකි දේ කරන',
        'correctOption': 3,
        'explanation': 'නිවැරදි පිළිතුර: (3)'
      },
      {
        'id': 'sin_q4',
        'subjectId': sinhalaId,
        'questionText':
            'යමක් ඇති සැටියෙන් වර්ණනා කිරීම ........................ වේ.',
        'option1': 'ස්වභාවාලංකාරය',
        'option2': 'ස්වභාවෝක්ත්‍යාලංකාරය',
        'option3': 'ස්වභාව සිද්ධාලංකාරය',
        'option4': 'ස්වභාව ධර්මාලංකාරය',
        'correctOption': 2,
        'explanation': 'නිවැරදි පිළිතුර: (2)'
      },
      {
        'id': 'sin_q5',
        'subjectId': sinhalaId,
        'questionText':
            'තමාගෙන් වූ වරද ඔවුහු ........................ ලක් කළහ.',
        'option1': 'සාධාරණීකරණයට',
        'option2': 'අසාධාරණීකරණයට',
        'option3': 'වර්ගීකරණයට',
        'option4': 'ප්‍රමිතිකරණයට',
        'correctOption': 1,
        'explanation': 'නිවැරදි පිළිතුර: (1)'
      },
      {
        'id': 'sin_q6',
        'subjectId': sinhalaId,
        'questionText':
            'ඇතැමුන් ජනප්‍රසාදය අහිමි කර ගත්තේ තම ........................ නිසාය.',
        'option1': 'අවංකකම',
        'option2': 'අනතිමානීකම',
        'option3': 'ගුණවත්කම',
        'option4': 'උද්ධච්චකම',
        'correctOption': 4,
        'explanation': 'නිවැරදි පිළිතුර: (4)'
      },
      {
        'id': 'sin_q7',
        'subjectId': sinhalaId,
        'questionText': 'ආකාරාදි පිළිවෙළ නිවැරදිව දැක්වෙන පද පේළිය තෝරන්න.',
        'option1': 'තිසරය, කෝකිලය, නීලකොබෝව, සැවුලුව',
        'option2': 'ගිරාව, මයුරය, සැළලිහිණිය, හංසය',
        'option3': 'රත්නාවලිය, පූජාවලිය, බුත්සරණ, ධර්ම ප්‍රදීපිකාව',
        'option4': 'සසදාවත, මුවදෙව්දාවත, කව්සිළුමිණ, කාව්‍යශේඛරය',
        'correctOption': 2,
        'explanation': 'නිවැරදි පිළිතුර: (2)'
      },
      {
        'id': 'sin_q8',
        'subjectId': sinhalaId,
        'questionText':
            'සැම පදයකම අක්ෂර වින්‍යාසය නිවැරදි ව යෙදී ඇති පද පේළිය?',
        'option1': 'සම්මුඛ, සුකුමාළ, සිතුමිණ, චුම්භක',
        'option2': 'ගුරුමුෂ්ඨි, ගොලුවා, චන්ද්‍ර ග්‍රහණ, තොටුපොල',
        'option3': 'පරිඥාණ, පරිපූර්ණ, යුද්ධායුද, ශික්ෂණ',
        'option4': 'ආරූඪ, මිනුම, ශීතෝෂ්ණ, සහස්‍ර',
        'correctOption': 4,
        'explanation': 'නිවැරදි පිළිතුර: (4)'
      },
      {
        'id': 'sin_q9',
        'subjectId': sinhalaId,
        'questionText':
            'දීර්ඝ පාපිල්ල, කොම්බුව, දීර්ඝ ඇදය, කෙටි ඉස්පිල්ල අනුපිළිවෙළින් ඇති වරණය?',
        'option1': 'සූරයා, කේතලය, නෑකම, විපත',
        'option2': 'නෑකම, කේතලය, සූරයා, විපත',
        'option3': 'සූරයා, විපත, නෑකම, කේතලය',
        'option4': 'නෑකම, විපත, කේතලය, සූරයා',
        'correctOption': 1,
        'explanation': 'නිවැරදි පිළිතුර: (1)'
      },
      {
        'id': 'sin_q10',
        'subjectId': sinhalaId,
        'questionText': 'ඕෂ්ඨජ ව්‍යංජන පමණක් අන්තර්ගත වචනය?',
        'option1': 'භය',
        'option2': 'මල',
        'option3': 'පඹ',
        'option4': 'පස',
        'correctOption': 3,
        'explanation': 'නිවැරදි පිළිතුර: (3)'
      },
      {
        'id': 'sin_q11',
        'subjectId': sinhalaId,
        'questionText': '"ඇළ දොළ" යන්න අයත් වන්නේ,',
        'option1': 'අන්‍යාර්ථ සමාසයට ය.',
        'option2': 'විභක්ති සමාසයට ය.',
        'option3': 'දකාරාර්ථ සමාසයට ය.',
        'option4': 'අව්‍යය සමාසයට ය.',
        'correctOption': 3,
        'explanation': 'නිවැරදි පිළිතුර: (3)'
      },
      {
        'id': 'sin_q12',
        'subjectId': sinhalaId,
        'questionText': 'අනුක්ත නාම පද පමණක් යෙදී ඇති වරණය?',
        'option1': 'සාවකු, ගෙම්බෙක්, වනචාරියකු, දෙවඟනක',
        'option2': 'වහලකු, දුනුවායන්, අප, සහෘදයෝ',
        'option3': 'කපුටෙකු, යෞවනියක්, ක්‍රීඩිකාවක, මා',
        'option4': 'සොල්දාදුවකු, මාළුවකු, ව්‍යාපාරිකයන්, තොප',
        'correctOption': 1,
        'explanation': 'නිවැරදි පිළිතුර: (1)'
      },
      {
        'id': 'sin_q13',
        'subjectId': sinhalaId,
        'questionText': '"කාර්යාලයෙන්" යන්නෙහි විභක්තිය කුමක්ද?',
        'option1': 'අවධි විභක්තිය',
        'option2': 'ආධාර විභක්තිය',
        'option3': 'සම්ප්‍රදාන විභක්තිය',
        'option4': 'කර්ම විභක්තිය',
        'correctOption': 1,
        'explanation': 'නිවැරදි පිළිතුර: (1)'
      },
      {
        'id': 'sin_q14',
        'subjectId': sinhalaId,
        'questionText': 'නීති + ඉක = ?',
        'option1': 'නෛතික',
        'option2': 'නීතියික',
        'option3': 'නෛතීක',
        'option4': 'නීතික',
        'correctOption': 1,
        'explanation': 'නිවැරදි පිළිතුර: (1)'
      },
      {
        'id': 'sin_q15',
        'subjectId': sinhalaId,
        'questionText': 'කෘදන්ත ප්‍රවර්ගයට නොගැලපෙන පදය ඇති වරණය?',
        'option1': 'පූර්ව ක්‍රියා - කා, නා, පා, දා',
        'option2': 'කෘදන්ත - සරන, කරන, දරන, පරණ',
        'option3': 'ස්වර සන්ධි - මලසුන, මතැත්, එදිනෙදා, සිතැති',
        'option4': 'උපසර්ග - විරූප, විදේශ, විසන්ධි, විරාග',
        'correctOption': 2,
        'explanation': 'නිවැරදි පිළිතුර: (2)'
      },
      {
        'id': 'sin_q16',
        'subjectId': sinhalaId,
        'questionText': 'මිශ්‍ර ක්‍රියාවක් යෙදී ඇති වාක්‍යය?',
        'option1': 'සිහි කොට පින් දෙන්න.',
        'option2': 'ඔවුහු මිතුදමින් වෙළී සිටියහ.',
        'option3': 'ඔහු ගුණවත්කමින් පිරිපුන් මිනිසෙක් වූයේය.',
        'option4': 'නිමාශා දක්ෂතා විදහා පාමින් ගීයක් ගැයුවාය.',
        'correctOption': 4,
        'explanation': 'නිවැරදි පිළිතුර: (4)'
      },
      {
        'id': 'sin_q17',
        'subjectId': sinhalaId,
        'questionText': '"නිරාගමික" යන්නෙහි අර්ථය?',
        'option1': 'ආගමකට අයත් වූ',
        'option2': 'ආගමානුකූල හැඟීමෙන් යුතු',
        'option3': 'ආගමකට අයත් නැති',
        'option4': 'වැරදි ආගමික අදහස් සහිත',
        'correctOption': 3,
        'explanation': 'නිවැරදි පිළිතුර: (3)'
      },
      {
        'id': 'sin_q18',
        'subjectId': sinhalaId,
        'questionText': '"රණ ශූරයෙකි" යන්නෙහි අර්ථය?',
        'option1': 'යුද්ධයෙහි දක්ෂ නොවූවෙකි.',
        'option2': 'යුද්ධ ජයග්‍රහණයේ දක්ෂයෙකි.',
        'option3': 'යුද්ධකාමියෙකි.',
        'option4': 'යුද්ධයෙහි දක්ෂයෙකි.',
        'correctOption': 4,
        'explanation': 'නිවැරදි පිළිතුර: (4)'
      },
      {
        'id': 'sin_q19',
        'subjectId': sinhalaId,
        'questionText': '"අතීතාවර්ජනයක" යන්නෙහි අර්ථය?',
        'option1': 'අතීතය අමතක කිරීමක',
        'option2': 'අතීතයට ගමන් කිරීමක',
        'option3': 'අතීතය ගැන මතක් කිරීමක',
        'option4': 'අතීතයේ ජීවත් වීමක',
        'correctOption': 3,
        'explanation': 'නිවැරදි පිළිතුර: (3)'
      },
      {
        'id': 'sin_q20',
        'subjectId': sinhalaId,
        'questionText': 'සමීප කාර්‍යයන් සමග බැඳී නොපවත්නා පද පේළිය?',
        'option1': 'අල්මාරිය, පෙට්ටිය, ලාච්චුව, පුටුව',
        'option2': 'ඉටිපන්දම්, හඳුන්කූරු, පහන්, කපුරු',
        'option3': 'පොල්, ලුණු, දුරු, මිරිස්',
        'option4': 'කොට්ටය, ඇඳ මෙට්ටය, ඇතිරිල්ල',
        'correctOption': 1,
        'explanation': 'නිවැරදි පිළිතුර: (1)'
      },
      {
        'id': 'sin_q21',
        'subjectId': sinhalaId,
        'questionText': 'සමානාර්ථ යෙදුම් පමණක් ඇතුළත් වරණය?',
        'option1': 'දේව-සුර, භෝජන-ආහාර, මුහුද-ජලාශය, වාහනය-රථය',
        'option2': 'මිනිසා-මනුෂ්‍යයා, සවන-කන, නේත්‍ර-නයන, නගරය-නුවර',
        'option3': 'වාලුකා-වැලි, ගෘහය-ගෙය, භාග්‍යය-දුක, තරුණ-යොවුන්',
        'option4': 'ප්‍රාසාදය-පහය, සත්‍යය-ඇත්ත, දිනය-වර්ෂය, කුඹුර-ක්ෂේත්‍රය',
        'correctOption': 2,
        'explanation': 'නිවැරදි පිළිතුර: (2)'
      },
      {
        'id': 'sin_q22',
        'subjectId': sinhalaId,
        'questionText': '"කාලය" යනයේ සමානාර්ථ නොවන පදයක් ඇති වරණය?',
        'option1': 'කාලය - වේලාව, තල, නිමේෂය, දහවල',
        'option2': 'ශරීරය - දේහය, සිරුර, කය, ඇඟ',
        'option3': 'කුරුල්ලා - ශකුන, පක්ෂියා, විහඟ, දද',
        'option4': 'හස්ති - ගජ, වරණ, ඇතා, ගිජිඳු',
        'correctOption': 1,
        'explanation': 'නිවැරදි පිළිතුර: (1)'
      },
      {
        'id': 'sin_q23',
        'subjectId': sinhalaId,
        'questionText': 'විරුද්ධාර්ථවත් පද යුගලයක් ඇතුළත් නොවන වරණය?',
        'option1': 'විමල - නිමල',
        'option2': 'ආදර - අනාදර',
        'option3': 'ඵල - අඵල',
        'option4': 'හුරු - නුහුරු',
        'correctOption': 1,
        'explanation': 'නිවැරදි පිළිතුර: (1)'
      },
      {
        'id': 'sin_q24',
        'subjectId': sinhalaId,
        'questionText': 'වැරදි අදහස දෙන ප්‍රකාශය?',
        'option1': '"නුඹ" යනු මධ්‍යම පුරුෂ බහු වචනයකි.',
        'option2': 'ඍ යන්න මූර්ධජ අක්ෂරයකි.',
        'option3': '"බලමි" යන්න වර්තමාන කාල, උත්තම පුරුෂ, ඒකවචනයකි.',
        'option4': '"බලවත්" යන්න තද්ධිත පදයකි.',
        'correctOption': 1,
        'explanation': 'නිවැරදි පිළිතුර: (1)'
      },
      {
        'id': 'sin_q25',
        'subjectId': sinhalaId,
        'questionText': 'මනා පද ගැළපීමෙන් යුක්ත අර්ථාන්විත වාක්‍යය?',
        'option1': 'සාහිත්‍ය නිර්මාණයක් පදනම් වී වස්තු බීජයක් ඇති කෙරේ.',
        'option2': 'යුද්ධයක් නිසා ස්ථාවරත්වයට හේතු වේ.',
        'option3': 'සතුරන්ගේ ආක්‍රමණවලට අප උපක්‍රමශීලී විය යුතු ය.',
        'option4': 'තොරතුරු යාවත්කාලීන කිරීම ප්‍රගමනයට උපකාරී වෙයි.',
        'correctOption': 4,
        'explanation': 'නිවැරදි පිළිතුර: (4)'
      },
      {
        'id': 'sin_q26',
        'subjectId': sinhalaId,
        'questionText': 'ඉඟුරු දී මිරිස් ගත්තා — මෙයින් ගැළපෙන අදහස?',
        'option1': 'කන්න දුන්නා හපා කෑව',
        'option2': 'ලොකු ලොකු ඉලක්ක කොට ගැනීම',
        'option3': 'තිබෙන දෙයටත් වඩා අයහපත් දෙය ළං කරගැනීම',
        'option4': 'වඩාත් හොඳ ප්‍රතිඵල ලැබීම',
        'correctOption': 3,
        'explanation': 'නිවැරදි පිළිතුර: (3)'
      },
      {
        'id': 'sin_q27',
        'subjectId': sinhalaId,
        'questionText': 'තමාගේ ම වරදින් විනාශයට ළඟා වීම — ගැළපෙන පිරුළ?',
        'option1': 'මාළුවා නැහෙන්නේ කට නිසාලු.',
        'option2': 'වත්ත බද්දට දී ඇස්සට දත නියවනවා ලු.',
        'option3': 'කලක දි වහලු කලක දි රහ වෙනවා ලු.',
        'option4': 'ඌරො කැකුණ තළන කොට හබන් කුකුළන්ට රජ මඟුල් ලු.',
        'correctOption': 1,
        'explanation': 'නිවැරදි පිළිතුර: (1)'
      },
      {
        'id': 'sin_q28',
        'subjectId': sinhalaId,
        'questionText': 'ද්විත්ව රූප හා පරරූප සන්ධි නිදසුන් පිළිවෙළ?',
        'option1': 'අද්දැකීම, සන්නස්',
        'option2': 'සන්නස්, අද්දැකීම',
        'option3': 'පත්තිරු, අද්දැකීම',
        'option4': 'සන්නස්, පත්තිරු',
        'correctOption': 1,
        'explanation': 'නිවැරදි පිළිතුර: (1)'
      },
      {
        'id': 'sin_q29',
        'subjectId': sinhalaId,
        'questionText': 'ව්‍යාකරණානුකූල ව නිවැරදි වාක්‍යය?',
        'option1': 'ශිෂ්‍ය - ශිෂ්‍යාවෝ උදෑසන ම පාසලට පැමිණ ඇත.',
        'option2': 'සොර මුළ ධනය පැහැර ගනියි.',
        'option3': 'ඈ ප්‍රසිද්ධ ලේඛිකාවක් වූවා ය.',
        'option4': 'රජතුමා සිංහයෙක් සේ නිර්භීත විය.',
        'correctOption': 3,
        'explanation': 'නිවැරදි පිළිතුර: (3)'
      },
      {
        'id': 'sin_q30',
        'subjectId': sinhalaId,
        'questionText': 'ව්‍යාකරණානුකූල ව නිවැරදි වාක්‍යය (2)?',
        'option1': 'අම්මා හෝ තාත්තා රෝහලට යන්නේය.',
        'option2': 'ගවයෝ කුඹුරු පාළු කරතිය ගොවීහු චෝදනා කරති.',
        'option3': 'තාරකාවන් බටහිර දිග අහසේ දිලිසෙති.',
        'option4': 'ශිෂ්‍යයාද තෝ ද පාසලට යහි.',
        'correctOption': 1,
        'explanation': 'නිවැරදි පිළිතුර: (1)'
      },
    ];

    final batchSinhala = _db.batch();
    for (var q in sinhalaQuestions) {
      final id = q['id'] as String;
      final data = Map<String, dynamic>.from(q)..remove('id');
      final ref = _db
          .collection('subjects')
          .doc(sinhalaId)
          .collection('questions')
          .doc(id);
      batchSinhala.set(ref, data, SetOptions(merge: true));
    }
    await batchSinhala.commit();

    await _db
        .collection('subjects')
        .doc(sinhalaId)
        .update({'totalQuestions': 30});

    // History questions — seeded with fixed IDs (idempotent)
    const String historyId = 'history';
    final historyQuestions = [
      {
        'id': 'his_q1',
        'subjectId': historyId,
        'questionText': 'මහාවංශය රචනා කළේ කවරෙකු ද?',
        'option1': 'ධම්මකිත්ති',
        'option2': 'බුද්ධඝෝෂ',
        'option3': 'මහානාම',
        'option4': 'රේවත',
        'correctOption': 3,
        'explanation': 'මහාවංශය රචනා කළේ මහානාම හිමි ය.'
      },
      {
        'id': 'his_q2',
        'subjectId': historyId,
        'questionText':
            'ශ්‍රී ලංකාවේ ප්‍රථම සිංහල රාජ්‍ය ස්ථාපිත කළේ කවරෙකු ද?',
        'option1': 'දේවානම්පියතිස්ස',
        'option2': 'විජය',
        'option3': 'පාණ්ඩුකාභය',
        'option4': 'දුටුගැමුණු',
        'correctOption': 2,
        'explanation': 'ශ්‍රී ලංකාවේ ප්‍රථම සිංහල රාජ්‍ය ස්ථාපිත කළේ විජය ය.'
      },
      {
        'id': 'his_q3',
        'subjectId': historyId,
        'questionText': 'අනුරාධපුර රාජධානිය ස්ථාපිත කළේ කවරෙකු ද?',
        'option1': 'දේවානම්පියතිස්ස',
        'option2': 'විජය',
        'option3': 'පාණ්ඩුකාභය',
        'option4': 'වළගම්බා',
        'correctOption': 3,
        'explanation': 'අනුරාධපුර රාජධානිය ස්ථාපිත කළේ පාණ්ඩුකාභය ය.'
      },
      {
        'id': 'his_q4',
        'subjectId': historyId,
        'questionText': 'ශ්‍රී ලංකාවට බෞද්ධ දහම හඳුන්වා දුන් දූතයා කවරෙකු ද?',
        'option1': 'සංඝමිත්තා',
        'option2': 'මහින්ද',
        'option3': 'ධර්මාශෝක',
        'option4': 'රේවත',
        'correctOption': 2,
        'explanation': 'ශ්‍රී ලංකාවට බෞද්ධ දහම හඳුන්වා දුන්නේ මහින්ද ය.'
      },
      {
        'id': 'his_q5',
        'subjectId': historyId,
        'questionText': 'ජය ශ්‍රී මහා බෝධිය ශ්‍රී ලංකාවට ගෙනා කවරෙකු ද?',
        'option1': 'සංඝමිත්තා',
        'option2': 'මහින්ද',
        'option3': 'ධර්මාශෝක',
        'option4': 'ඉන්ද්‍රගුප්ත',
        'correctOption': 1,
        'explanation':
            'ජය ශ්‍රී මහා බෝධිය ශ්‍රී ලංකාවට ගෙනා කවරෙකු ද සංඝමිත්තා ය.'
      },
      {
        'id': 'his_q6',
        'subjectId': historyId,
        'questionText': 'දළදා මාළිගාව පිහිටා ඇත්තේ කොතෙක ද?',
        'option1': 'කොළඹ',
        'option2': 'ගාල්ල',
        'option3': 'කෑගල්ල',
        'option4': 'මහනුවර',
        'correctOption': 4,
        'explanation': 'දළදා මාළිගාව පිහිටා ඇත්තේ මහනුවර ය.'
      },
      {
        'id': 'his_q7',
        'subjectId': historyId,
        'questionText': 'ශ්‍රී ලංකාව ස්වාධීනත්වය ලැබූ දිනය?',
        'option1': '1948 පෙබරවාරි 4',
        'option2': '1947 අගෝස්තු 15',
        'option3': '1949 ජනවාරි 26',
        'option4': '1950 ජූනි 10',
        'correctOption': 1,
        'explanation': 'ශ්‍රී ලංකාව ස්වාධීනත්වය ලැබූ දිනය 1948 පෙබරවාරි 4 ය.'
      },
      {
        'id': 'his_q8',
        'subjectId': historyId,
        'questionText': 'ශ්‍රී ලංකාවේ ප්‍රථම අගමැතිවරයා කවරෙකු ද?',
        'option1': 'ඩී. එස්. සේනානායක',
        'option2': 'ශ්‍රීමාවෝ බණ්ඩාරනායක',
        'option3': 'ජේ. ආර්. ජයවර්ධන',
        'option4': 'ඩඩ්ලි සේනානායක',
        'correctOption': 1,
        'explanation': 'ශ්‍රී ලංකාවේ ප්‍රථම අගමැතිවරයා ඩී. එස්. සේනානායක ය.'
      },
      {
        'id': 'his_q9',
        'subjectId': historyId,
        'questionText': 'ලෝකයේ ප්‍රථම කාන්තා අගමැතිවරිය?',
        'option1': 'ඉන්දිරා ගාන්ධි',
        'option2': 'ශ්‍රීමාවෝ බණ්ඩාරනායක',
        'option3': 'ගෝල්ඩා මේයර්',
        'option4': 'මාග්‍රට් තැචර්',
        'correctOption': 2,
        'explanation': 'ශ්‍රීමාවෝ බණ්ඩාරනායක ලෝකයේ ප්‍රථම කාන්තා අගමැතිවරිය.'
      },
      {
        'id': 'his_q10',
        'subjectId': historyId,
        'questionText':
            'ශ්‍රී ලංකාවේ ප්‍රජාතාන්ත්‍රික සමාජවාදී ජනරජය ප්‍රකාශ කළ වර්ෂය?',
        'option1': '1972',
        'option2': '1948',
        'option3': '1978',
        'option4': '1983',
        'correctOption': 1,
        'explanation': '1972 දී ශ්‍රී ලංකාව ජනරජයක් විය.'
      },
      {
        'id': 'his_q11',
        'subjectId': historyId,
        'questionText': 'ශ්‍රී ලංකාවේ ජාතික ගීය රචනා කළේ?',
        'option1': 'ආනන්ද සමරකෝන්',
        'option2': 'රබීන්ද්‍රනාත් තාගෝර්',
        'option3': 'සිරිල් ද ශිල්වා',
        'option4': 'ජෝන් ද ශිල්වා',
        'correctOption': 1,
        'explanation': 'ශ්‍රී ලංකාවේ ජාතික ගීය රචනා කළේ ආනන්ද සමරකෝන් ය.'
      },
      {
        'id': 'his_q12',
        'subjectId': historyId,
        'questionText': 'ශ්‍රී ලංකාවේ ප්‍රථම ජනාධිපතිවරයා?',
        'option1': 'ඩී. එස්. සේනානායක',
        'option2': 'ශ්‍රීමාවෝ බණ්ඩාරනායක',
        'option3': 'ජේ. ආර්. ජයවර්ධන',
        'option4': 'ඩඩ්ලි සේනානායක',
        'correctOption': 3,
        'explanation': 'ශ්‍රී ලංකාවේ ප්‍රථම ජනාධිපතිවරයා ජේ. ආර්. ජයවර්ධන ය.'
      },
      {
        'id': 'his_q13',
        'subjectId': historyId,
        'questionText': 'පොළොන්නරුව රාජධානිය ප්‍රධාන වශයෙන් දියුණු කළ රජු?',
        'option1': 'දුටුගැමුණු',
        'option2': 'පරාක්‍රමබාහු I',
        'option3': 'විජය',
        'option4': 'පාණ්ඩුකාභය',
        'correctOption': 2,
        'explanation':
            'පොළොන්නරුව රාජධානිය ප්‍රධාන වශයෙන් දියුණු කළේ පරාක්‍රමබාහු I ය.'
      },
      {
        'id': 'his_q14',
        'subjectId': historyId,
        'questionText': 'ශ්‍රී ලංකාවේ ප්‍රාකෘතික ජාතිය?',
        'option1': 'ශ්‍රී ලාංකික',
        'option2': 'සිංහල',
        'option3': 'වැද්දා',
        'option4': 'ද්‍රවිඩ',
        'correctOption': 3,
        'explanation': 'ශ්‍රී ලංකාවේ ප්‍රාකෘතික ජාතිය වැද්දා ය.'
      },
      {
        'id': 'his_q15',
        'subjectId': historyId,
        'questionText': 'සිදුහත් කුමරු ඉපදුණු ස්ථානය?',
        'option1': 'සාරනාත්',
        'option2': 'ලුම්බිනි',
        'option3': 'බෝධ ගයා',
        'option4': 'කුශිනගර',
        'correctOption': 2,
        'explanation': 'සිදුහත් කුමරු ඉපදුණේ ලුම්බිනි හිය.'
      },
      {
        'id': 'his_q16',
        'subjectId': historyId,
        'questionText': 'ධර්මාශෝක රජු අයත් රාජ්‍යය?',
        'option1': 'මොරිය',
        'option2': 'ගුප්ත',
        'option3': 'කුෂාන',
        'option4': 'නන්ද',
        'correctOption': 1,
        'explanation': 'ධර්මාශෝක රජු මොරිය රාජ්‍යයේ රජු ය.'
      },
      {
        'id': 'his_q17',
        'subjectId': historyId,
        'questionText': 'ශ්‍රී ලංකාව UN සාමාජිකත්වය ලැබූ වර්ෂය?',
        'option1': '1948',
        'option2': '1955',
        'option3': '1972',
        'option4': '1978',
        'correctOption': 2,
        'explanation': 'ශ්‍රී ලංකාව 1955 දී UN සාමාජිකත්වය ලැබිය.'
      },
      {
        'id': 'his_q18',
        'subjectId': historyId,
        'questionText': 'ශ්‍රී ලංකාවේ ප්‍රථම ආණ්ඩු ක්‍රම ව්‍යවස්ථාව?',
        'option1': '1947',
        'option2': '1948',
        'option3': '1972',
        'option4': '1978',
        'correctOption': 1,
        'explanation': 'ශ්‍රී ලංකාවේ ප්‍රථම ව්‍යවස්ථාව 1947 ය.'
      },
      {
        'id': 'his_q19',
        'subjectId': historyId,
        'questionText': 'ශ්‍රී ලංකාවේ පෘතුගීසි ආධිපත්‍ය ආරම්භ වූ වර්ෂය?',
        'option1': '1505',
        'option2': '1658',
        'option3': '1796',
        'option4': '1815',
        'correctOption': 1,
        'explanation': 'පෘතුගීසි ආධිපත්‍ය ආරම්භ වූ වර්ෂය 1505 ය.'
      },
      {
        'id': 'his_q20',
        'subjectId': historyId,
        'questionText': 'ශ්‍රී ලංකාවේ ලන්දේසි ආධිපත්‍ය කාලය?',
        'option1': '1505-1658',
        'option2': '1658-1796',
        'option3': '1796-1948',
        'option4': '1948-1972',
        'correctOption': 2,
        'explanation': 'ලන්දේසි ආධිපත්‍ය 1658-1796 කාලය.'
      },
      {
        'id': 'his_q21',
        'subjectId': historyId,
        'questionText': '1815 මහනුවර ගිවිසුම අත්සන් කළ ශ්‍රී ලාංකික රජු?',
        'option1': 'කීර්ති ශ්‍රී රාජසිංහ',
        'option2': 'ශ්‍රී වික්‍රම රාජසිංහ',
        'option3': 'රාජාධිරාජසිංහ',
        'option4': 'විමල ධර්ම සූරිය',
        'correctOption': 2,
        'explanation':
            '1815 ගිවිසුම අත්සන් කළ ශ්‍රී ලාංකික රජු ශ්‍රී වික්‍රම රාජසිංහ ය.'
      },
      {
        'id': 'his_q22',
        'subjectId': historyId,
        'questionText': 'ශ්‍රේෂ්ඨාධිකරණය ස්ථාපිත කළ වර්ෂය?',
        'option1': '1801',
        'option2': '1815',
        'option3': '1833',
        'option4': '1948',
        'correctOption': 3,
        'explanation': 'ශ්‍රේෂ්ඨාධිකරණය ස්ථාපිත කළ වර්ෂය 1833 ය.'
      },
      {
        'id': 'his_q23',
        'subjectId': historyId,
        'questionText': 'ශ්‍රී ලංකාවේ ප්‍රථම ජනලේඛනය?',
        'option1': '1871',
        'option2': '1891',
        'option3': '1901',
        'option4': '1881',
        'correctOption': 1,
        'explanation': 'ශ්‍රී ලංකාවේ ප්‍රථම ජනලේඛනය 1871 ය.'
      },
      {
        'id': 'his_q24',
        'subjectId': historyId,
        'questionText': 'ශ්‍රී ලංකාවේ දළදා ශ්‍රී ලංකාවට ගෙනා රජු?',
        'option1': 'දේවානම්පියතිස්ස',
        'option2': 'කිර්ති ශ්‍රී රාජසිංහ',
        'option3': 'දුටුගැමුණු',
        'option4': 'වළගම්බා',
        'correctOption': 2,
        'explanation':
            'දළදා ශ්‍රී ලංකාවට ගෙනෙනු ලැබූ රජු කිර්ති ශ්‍රී රාජසිංහ ය.'
      },
      {
        'id': 'his_q25',
        'subjectId': historyId,
        'questionText': 'හෙන්රි ස්ටීල් ඕල්කොට් ශ්‍රී ලංකාවට ආ වර්ෂය?',
        'option1': '1875',
        'option2': '1880',
        'option3': '1883',
        'option4': '1870',
        'correctOption': 2,
        'explanation': 'හෙන්රි ස්ටීල් ඕල්කොට් 1880 දී ශ්‍රී ලංකාවට ආවේ ය.'
      },
      {
        'id': 'his_q26',
        'subjectId': historyId,
        'questionText': 'ශ්‍රී ලංකාවේ ප්‍රථම කාන්තා ජනාධිපතිවරිය?',
        'option1': 'ශ්‍රීමාවෝ බණ්ඩාරනායක',
        'option2': 'චන්ද්‍රිකා කුමාරතුංග',
        'option3': 'සිරිමා ඩිසානායක',
        'option4': 'රොෂාන් රණසිංහ',
        'correctOption': 2,
        'explanation':
            'ශ්‍රී ලංකාවේ ප්‍රථම කාන්තා ජනාධිපතිවරිය චන්ද්‍රිකා කුමාරතුංග ය.'
      },
      {
        'id': 'his_q27',
        'subjectId': historyId,
        'questionText': 'දුටුගැමුණු රජු දකුණු ඉන්දියාවෙන් ආ රජු ජය ගත්තේ?',
        'option1': 'ඵළ්ළ',
        'option2': 'එළාර',
        'option3': 'පදේශී',
        'option4': 'ගජබාහු',
        'correctOption': 2,
        'explanation': 'දුටුගැමුණු රජු ජය ගත්තේ දකුණු ඉන්දීය රජ එළාර ය.'
      },
      {
        'id': 'his_q28',
        'subjectId': historyId,
        'questionText': 'ශ්‍රී ලංකාවේ ජාතික කොඩිය නිර්මාණය කළ වර්ෂය?',
        'option1': '1948',
        'option2': '1950',
        'option3': '1972',
        'option4': '1978',
        'correctOption': 1,
        'explanation': 'ශ්‍රී ලංකාවේ ජාතික කොඩිය 1948 දී නිල රූපය ලැබිය.'
      },
      {
        'id': 'his_q29',
        'subjectId': historyId,
        'questionText': 'ශ්‍රී ලංකාවේ 1971 කැරැල්ලට නායකත්වය දුන්නේ?',
        'option1': 'රෝහණ විජේවීර',
        'option2': 'ෆිලිප් ගුණවර්ධන',
        'option3': 'කොල්වින් ආර්. ද සිල්වා',
        'option4': 'ලෙස්ලි ගූණේවර්ධන',
        'correctOption': 1,
        'explanation': '1971 කැරැල්ලට නායකත්වය දුන්නේ රෝහණ විජේවීර ය.'
      },
      {
        'id': 'his_q30',
        'subjectId': historyId,
        'questionText': 'ශ්‍රී ලංකාවේ දීර්ඝතම සිවිල් යුද්ධය අවසන් වූ වර්ෂය?',
        'option1': '2005',
        'option2': '2007',
        'option3': '2009',
        'option4': '2011',
        'correctOption': 3,
        'explanation': 'ශ්‍රී ලංකාවේ සිවිල් යුද්ධය 2009 දී අවසන් විය.'
      },
    ];

    final batch3 = _db.batch();
    for (var q in historyQuestions) {
      final id = q['id'] as String;
      final data = Map<String, dynamic>.from(q)..remove('id');
      // Fixed question IDs — idempotent upsert, never duplicates
      final ref = _db
          .collection('subjects')
          .doc(historyId)
          .collection('questions')
          .doc(id);
      batch3.set(ref, data, SetOptions(merge: true));
    }
    await batch3.commit();

    // Also update history subject totalQuestions count
    await _db
        .collection('subjects')
        .doc(historyId)
        .update({'totalQuestions': 30});

  Future<void> _seedIctQuestions() async {
    const ictId = 'ict';
    final ictQuestions = [
      {'id':'ict_q1','subjectId':ictId,'questionText':'මේස පරිගණකයකින් (Desktop Computer) සාමාන්‍යයෙන් ලැබෙන ප්‍රධාන වාසිය:','option1':'බැටරියෙන් ක්‍රියාත්මක වීම','option2':'රැගෙන යාමේ පහසුව','option3':'වඩා විශාල Monitor එකක් සම්බන්ධ කිරීමේ හැකියාව','option4':'සැහැල්ලු නිමැවුම','correctOption':3,'explanation':'Desktop computers support large monitors and more peripherals than laptops.'},
      {'id':'ict_q2','subjectId':ictId,'questionText':'OS සහ මෘදුකාංගවල උපදෙස් ක්‍රියාත්මක වන්නේ:','option1':'Cache Memory','option2':'RAM','option3':'Processor (CPU)','option4':'Secondary Storage','correctOption':3,'explanation':'CPU executes all program instructions — it is the brain of the computer.'},
      {'id':'ict_q3','subjectId':ictId,'questionText':'Input device නොවන්නේ කුමක්ද?','option1':'Keyboard','option2':'Mouse','option3':'Printer','option4':'Scanner','correctOption':3,'explanation':'Printer is an output device; it produces output, not input.'},
      {'id':'ict_q4','subjectId':ictId,'questionText':'1 Kilobyte (KB) = කී Bytes ද?','option1':'1000','option2':'1024','option3':'100','option4':'10000','correctOption':2,'explanation':'1 KB = 1024 Bytes (binary system).'},
      {'id':'ict_q5','subjectId':ictId,'questionText':'ROM (Read Only Memory) ලක්ෂණය:','option1':'Volatile memory','option2':'Power off වූ විට data නැතිවේ','option3':'Non-volatile — power off වුවත් data රැකේ','option4':'තාවකාලික ගබඩාවකි','correctOption':3,'explanation':'ROM is non-volatile; BIOS/firmware stored permanently.'},
      {'id':'ict_q6','subjectId':ictId,'questionText':'සීමිත ප්‍රදේශයක (ගොඩනැගිල්ලක) ජාලය:','option1':'WAN','option2':'MAN','option3':'LAN','option4':'Internet','correctOption':3,'explanation':'LAN (Local Area Network) connects devices within a limited area like a school or building.'},
      {'id':'ict_q7','subjectId':ictId,'questionText':'256MB ඉඩ ඇති USB එකට 0.3GB ගොනු paste කළහොත්:','option1':'ගොනුව සාර්ථකව paste වේ','option2':'ඉඩ මදි නිසා paste කළ නොහැක','option3':'ගොනුවෙන් අඩක් paste වේ','option4':'ධාවකය format වේ','correctOption':2,'explanation':'0.3GB≈307MB > 256MB ∴ paste කළ නොහැක.'},
      {'id':'ict_q8','subjectId':ictId,'questionText':'ASCII හි A=65 නම්, 67 නිරූපණය කරන්නේ:','option1':'B','option2':'C','option3':'D','option4':'E','correctOption':2,'explanation':'65=A, 66=B, 67=C.'},
      {'id':'ict_q9','subjectId':ictId,'questionText':'Operating System හි මූලික කාර්යයක් නොවන්නේ:','option1':'Memory Management','option2':'File Management','option3':'Word document අක්ෂර වැරදි නිවැරදි කිරීම','option4':'Process Management','correctOption':3,'explanation':'Spell check = Application software; OS කාර්යයක් නොවේ.'},
      {'id':'ict_q10','subjectId':ictId,'questionText':'Word Processing: A-Password යෙදා save කළ හැක. B-.pdf ලෙස save කළ හැක. C-Save As භාවිත කළ හැක. නිවැරදි:','option1':'A සහ B පමණි','option2':'A සහ C පමණි','option3':'B සහ C පමණි','option4':'A, B සහ C සියල්ලම','correctOption':4,'explanation':'MS Word: password, PDF export, Save As — තුනම සිදු කළ හැකිය.'},
      {'id':'ict_q11','subjectId':ictId,'questionText':'පාඨ කොටසක් දෙපසම සමාන (Justify) කිරීම:','option1':'Left align','option2':'Center align','option3':'Justify align','option4':'Right align','correctOption':3,'explanation':'Justify align = සියලු පේළි සම දිගකට.'},
      {'id':'ict_q12','subjectId':ictId,'questionText':'H₂O හි Subscript ලබා ගැනීමට:','option1':'X² (Superscript)','option2':'X₂ (Subscript)','option3':'Font color','option4':'Bold','correctOption':2,'explanation':'Subscript (X₂) = H₂O වැනි පහළ දර්ශක.'},
      {'id':'ict_q13','subjectId':ictId,'questionText':'එකම ලිපිය ලිපින ලැයිස්තු සමඟ ස්වයංක්‍රීයව යැවීමේ feature:','option1':'Mail Merge','option2':'Macro','option3':'Hyperlink','option4':'Find and Replace','correctOption':1,'explanation':'Mail Merge: ලිපිය + ලිපින දත්ත = bulk ලේඛන.'},
      {'id':'ict_q14','subjectId':ictId,'questionText':'Spreadsheet software ONLY ඇතුළත් වරණය:','option1':'MS Word, MS Excel, Google Sheets','option2':'Google Sheets, MS Excel, LibreOffice Calc','option3':'LibreOffice Writer, MS Excel, OpenOffice Calc','option4':'MS PowerPoint, Google Sheets, MS Excel','correctOption':2,'explanation':'Google Sheets, MS Excel, LibreOffice Calc = spreadsheet software.'},
      {'id':'ict_q15','subjectId':ictId,'questionText':'A1:C3 cell range හි cells ගණන:','option1':'3','option2':'6','option3':'9','option4':'12','correctOption':3,'explanation':'3 columns × 3 rows = 9 cells.'},
      {'id':'ict_q16','subjectId':ictId,'questionText':'A1:A5 sum ලබා ගැනීමට නිවැරදි function:','option1':'=SUM(A1-A5)','option2':'=SUM(A1:A5)','option3':'=ADD(A1:A5)','option4':'=TOTAL(A1..A5)','correctOption':2,'explanation':'=SUM(start:end) = නිවැරදි syntax.'},
      {'id':'ict_q17','subjectId':ictId,'questionText':'Presentation software ONLY ඇතුළත් වරණය:','option1':'MS PowerPoint, LibreOffice Impress, Google Slides','option2':'MS Excel, Google Slides, Apple Keynote','option3':'MS PowerPoint, Audacity, VLC Player','option4':'Google Sheets, MS PowerPoint, Ubuntu','correctOption':1,'explanation':'PowerPoint, Impress, Slides = presentation software.'},
      {'id':'ict_q18','subjectId':ictId,'questionText':'Database record අනන්‍යව හඳුනා ගැනීමට:','option1':'Foreign Key','option2':'Primary Key','option3':'Composite Key','option4':'Candidate Key','correctOption':2,'explanation':'Primary Key = uniquely identifies each record.'},
      {'id':'ict_q19','subjectId':ictId,'questionText':'වගු දෙකක් සම්බන්ධ කිරීමේදී ලබාගත් Primary Key හඳුන්වන්නේ:','option1':'Primary Key','option2':'Foreign Key','option3':'Candidate Key','option4':'Super Key','correctOption':2,'explanation':'Foreign Key = වෙනත් table හි Primary Key.'},
      {'id':'ict_q20','subjectId':ictId,'questionText':'DBMS ගැන නිවැරදි ප්‍රකාශය:','option1':'Data Redundancy පාලනය කළ නොහැකිය','option2':'Electronic DB හිදී data සෙවීම කාර්යක්ෂමය','option3':'Data type අනිවාර්ය නොවේ','option4':'Primary key null ලෙස තැබිය හැකිය','correctOption':2,'explanation':'Query ලෙස electronic DB හිදී ඉක්මනින් data සෙවිය හැකිය.'},
      {'id':'ict_q21','subjectId':ictId,'questionText':'Flowchart හි Decision/Selection symbol:','option1':'Rectangle','option2':'Parallelogram','option3':'Diamond','option4':'Oval','correctOption':3,'explanation':'Diamond = Yes/No decision symbol.'},
      {'id':'ict_q22','subjectId':ictId,'questionText':'Pascal හි constants ප්‍රකාශ කිරීමේ keyword:','option1':'var','option2':'const','option3':'program','option4':'begin','correctOption':2,'explanation':'const keyword = constants declaration in Pascal.'},
      {'id':'ict_q23','subjectId':ictId,'questionText':'පැස්කල් භාෂාවේ පූර්ණ සංඛ්‍යා (Integers) ගබඩා කිරීමේ data type:','option1':'Real','option2':'Char','option3':'Integer','option4':'Boolean','correctOption':3,'explanation':'Integer = පූර්ණ සංඛ්‍යා; Real = දශම සහිත සංඛ්‍යා.'},
      {'id':'ict_q24','subjectId':ictId,'questionText':'SDLC හි Coding ට පෙර සිදු කළ යුතු පියවර:','option1':'System Design','option2':'System Testing','option3':'System Maintenance','option4':'System Deployment','correctOption':1,'explanation':'Design → Coding → Testing → Deployment.'},
      {'id':'ict_q25','subjectId':ictId,'questionText':'User විසින් system requirements සපුරාලනු ලැබේදැයි පරීක්ෂා කිරීම:','option1':'Unit Testing','option2':'Integration Testing','option3':'Acceptance Testing','option4':'System Testing','correctOption':3,'explanation':'Acceptance Testing = user/client validates the system.'},
      {'id':'ict_q26','subjectId':ictId,'questionText':'නිවැරදි IPv4 ලිපිනය:','option1':'192.168.1.1','option2':'256.100.0.5','option3':'10.20.30','option4':'172.16.254.1.2','correctOption':1,'explanation':'IPv4: 4 octets, 0-255 each. 192.168.1.1 = valid.'},
      {'id':'ict_q27','subjectId':ictId,'questionText':'HTML හි image embed කිරීමේ නිවැරදි tag:','option1':'<image src="pic.jpg">','option2':'<img> src="pic.jpg" </img>','option3':'<img src="pic.jpg">','option4':'<href img="pic.jpg">','correctOption':3,'explanation':'<img src="url"> = correct HTML image tag.'},
      {'id':'ict_q28','subjectId':ictId,'questionText':'HTML හි විශාලම heading tag:','option1':'<heading>','option2':'<h6>','option3':'<h1_topic>','option4':'<h1>','correctOption':4,'explanation':'<h1> = largest heading, <h6> = smallest.'},
      {'id':'ict_q29','subjectId':ictId,'questionText':'Vector vs Raster graphics නිවැරදි ප්‍රකාශය:','option1':'Raster විශාල කළ quality නොඅඩු වේ','option2':'Vector pixels වලින් සෑදී ඇත','option3':'Vector graphics quality නොවෙනස්ව resize කළ හැකිය','option4':'.jpg සහ .png = vector formats','correctOption':3,'explanation':'Vector = mathematical equations → scalable without pixelation.'},
      {'id':'ict_q30','subjectId':ictId,'questionText':'අනුන්ගේ නිර්මාණය තමාගේ ලෙස ඉදිරිපත් කිරීම:','option1':'Digital Divide','option2':'Plagiarism','option3':'Software Piracy','option4':'Hacking','correctOption':2,'explanation':'Plagiarism = presenting others\' work as your own.'},
    ];
    final batchIct = _db.batch();
    for (var q in ictQuestions) {
      final id = q['id'] as String;
      final data = Map<String, dynamic>.from(q)..remove('id');
      batchIct.set(_db.collection('subjects').doc(ictId).collection('questions').doc(id), data, SetOptions(merge: true));
    }
    await batchIct.commit();
    await _db.collection('subjects').doc(ictId).update({'totalQuestions': 30});
  }
}
