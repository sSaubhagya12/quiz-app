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

  // In-memory data for offline mode
  StudentModel? _offlineStudent;
  final List<SubjectModel> _offlineSubjects = [
    SubjectModel(
      id: 'religion',
      name: 'Religion',
      iconName: 'volunteer_activism',
      imageUrl: 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400&q=80',
      totalQuestions: 0,
      completedRate: 0.0,
    ),
    SubjectModel(
      id: 'sinhala',
      name: 'Sinhala',
      iconName: 'book',
      imageUrl: 'https://images.unsplash.com/photo-1506880018603-83d5b814b5a6?w=400&q=80',
      totalQuestions: 0,
      completedRate: 0.0,
    ),
    SubjectModel(
      id: 'english',
      name: 'English',
      iconName: 'language',
      imageUrl: 'https://images.unsplash.com/photo-1451226428352-cf66b8a0317a?w=400&q=80',
      totalQuestions: 0,
      completedRate: 0.0,
    ),
    SubjectModel(
      id: 'math',
      name: 'Mathematics',
      iconName: 'calculate',
      imageUrl: 'https://images.unsplash.com/photo-1509228468518-180dd4864904?w=400&q=80',
      totalQuestions: 3,
      completedRate: 0.0,
    ),
    SubjectModel(
      id: 'sci',
      name: 'Science',
      iconName: 'science',
      imageUrl: 'https://images.unsplash.com/photo-1507668077129-56e32842fceb?w=400&q=80',
      totalQuestions: 30,
      completedRate: 0.0,
    ),
    SubjectModel(
      id: 'history',
      name: 'History',
      iconName: 'history',
      imageUrl: 'https://images.unsplash.com/photo-1461360370896-922624d12aa1?w=400&q=80',
      totalQuestions: 30,
      completedRate: 0.0,
    ),
    SubjectModel(
      id: 'business',
      name: 'Business & Accounting Studies',
      iconName: 'analytics',
      imageUrl: 'https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=400&q=80',
      totalQuestions: 0,
      completedRate: 0.0,
    ),
    SubjectModel(
      id: 'geo',
      name: 'Geography',
      iconName: 'public',
      imageUrl: 'https://images.unsplash.com/photo-1524661135-423995f22d0b?w=400&q=80',
      totalQuestions: 0,
      completedRate: 0.0,
    ),
    SubjectModel(
      id: 'civic',
      name: 'Civic Education',
      iconName: 'gavel',
      imageUrl: 'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?w=400&q=80',
      totalQuestions: 0,
      completedRate: 0.0,
    ),
    SubjectModel(
      id: 'music',
      name: 'Music',
      iconName: 'music_note',
      imageUrl: 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=400&q=80',
      totalQuestions: 0,
      completedRate: 0.0,
    ),
    SubjectModel(
      id: 'dancing',
      name: 'Dancing',
      iconName: 'emoji_people',
      imageUrl: 'https://images.unsplash.com/photo-1508700115892-45ecd05ae2ad?w=400&q=80',
      totalQuestions: 0,
      completedRate: 0.0,
    ),
    SubjectModel(
      id: 'art',
      name: 'Art (Act)',
      iconName: 'palette',
      imageUrl: 'https://images.unsplash.com/photo-1513364776144-60967b0f800f?w=400&q=80',
      totalQuestions: 0,
      completedRate: 0.0,
    ),
    SubjectModel(
      id: 'ict',
      name: 'Information & Communication',
      iconName: 'computer',
      imageUrl: 'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?w=400&q=80',
      totalQuestions: 0,
      completedRate: 0.0,
    ),
    SubjectModel(
      id: 'agriculture',
      name: 'Agriculture & Food Technology',
      iconName: 'agriculture',
      imageUrl: 'https://images.unsplash.com/photo-1464226184884-fa280b87c3a9?w=400&q=80',
      totalQuestions: 0,
      completedRate: 0.0,
    ),
    SubjectModel(
      id: 'health',
      name: 'Health & Physical Education',
      iconName: 'fitness_center',
      imageUrl: 'https://images.unsplash.com/photo-1476480862126-209bfaa8edc8?w=400&q=80',
      totalQuestions: 0,
      completedRate: 0.0,
    ),
  ];

  final Map<String, List<QuestionModel>> _offlineQuestions = {
    'sci': [
      QuestionModel(id: 'sci_q1', subjectId: 'sci', questionText: 'බහිස්ස්‍රාවී ද්‍රව්‍යයක් වන යුරියා නිපදවෙන්නේ?', option1: 'වකුගඩුවල', option2: 'අක්මාවෙහි', option3: 'මුත්‍රාශයෙහි', option4: 'වෘක්කාණුවල', correctOption: 2, explanation: 'යුරියා නිපදවෙන්නේ අක්මාවෙහිය. වකුගඩු මගින් රුධිරයෙන් එය පෙරීගෙන මුත්‍රාවට යයි.'),
      QuestionModel(id: 'sci_q2', subjectId: 'sci', questionText: 'ක්ෂමතාවේ (Power) ඒකකය කුමක්ද?', option1: 'Ws', option2: 'Ws⁻¹', option3: 'Js', option4: 'Js⁻¹', correctOption: 4, explanation: 'ක්ෂමතාව = ශක්තිය/කාලය = J/s = Js⁻¹ (Watt).'),
      QuestionModel(id: 'sci_q3', subjectId: 'sci', questionText: 'අයිසොප්‍රොපිල් ඇල්කොහොල් (CH₃)₂CHOH අණුවක ඇති පරමාණු ගණන?', option1: '8', option2: '10', option3: '11', option4: '12', correctOption: 4, explanation: 'C=3, H=8 (2×3+1+1), O=1 → මුළු = 12.'),
      QuestionModel(id: 'sci_q4', subjectId: 'sci', questionText: 'ශාක පත්‍ර තුළ නිපදවන ආහාර ශාක දේහය පුරා පරිවහනය කරන පටකය කුමක්ද?', option1: 'ශෛලම', option2: 'ප්ලෝයම', option3: 'කැම්බියම', option4: 'දෘඪස්තර', correctOption: 2, explanation: 'ප්ලෝයම (Phloem) ආහාර ශාකයේ සිතු ආහාර ශාක දේහය පුරා ගෙනයයි.'),
      QuestionModel(id: 'sci_q5', subjectId: 'sci', questionText: 'වස්තු දෙකක් එකිනෙක පිරි මැදීමෙන් එක් වස්තුවකට ධන ආරෝපණයක් ලැබීමේ දී අනෙකට සංක්‍රමණය වනුයේ?', option1: 'ඉලෙක්ට්‍රෝනයි', option2: 'ප්‍රෝටෝනයි', option3: 'නියුට්‍රෝනයි', option4: 'ඉලෙක්ට්‍රෝන හා ප්‍රෝටෝනයි', correctOption: 1, explanation: 'ඉලෙක්ට්‍රෝන සංචලනශීලී බැවින් ඒවාම සංක්‍රමණය වේ.'),
      QuestionModel(id: 'sci_q6', subjectId: 'sci', questionText: 'පිළිවෙළින් ආම්ලික ඔක්සයිඩයක්, උභයගුණ ඔක්සයිඩයක් සහ භාස්මික ඔක්සයිඩයක් ඇතුළත් වන්නේ මින් කුමක්ද?', option1: 'SO₃, Al₂O₃, SiO₂', option2: 'SO₃, Al₂O₃, MgO', option3: 'CO₂, SiO₂, MgO', option4: 'SiO₂, CO₂, Al₂O₃', correctOption: 2, explanation: 'SO₃=ආම්ලික, Al₂O₃=උභයගුණ, MgO=භාස්මික.'),
      QuestionModel(id: 'sci_q7', subjectId: 'sci', questionText: 'ශාක සෛලයක ඇති අජීවී ව්‍යුහයක් ලෙස හැඳින්විය හැකි ය.', option1: 'සෛල බිත්තිය', option2: 'ප්ලාස්ම පටලය', option3: 'රයිබොසෝම', option4: 'ගොල්ගි දේහ', correctOption: 1, explanation: 'සෛල බිත්තිය (Cell Wall) මළ සෛල ද්‍රව්‍යයෙන් සෑදූ අජීවී ව්‍යුහයකි.'),
      QuestionModel(id: 'sci_q8', subjectId: 'sci', questionText: 'විද්‍යුත්-චුම්බක තරංග හා සම්බන්ධ පහත ප්‍රකාශ වලින් අසත්‍ය ප්‍රකාශය කුමක්ද?', option1: 'ශක්තිය සම්ප්‍රේෂණය කරයි', option2: 'රික්තයේ දී 3×10⁸ ms⁻¹ වේගයකින් ගමන් කරයි', option3: 'පදාර්ථමය මාධ්‍යයක දී සංඛ්‍යාතය රික්තයේ දීට වඩා අඩු වේ', option4: 'පදාර්ථමය මාධ්‍යයක දී වේගය රික්තයේ දීට වඩා අඩු වේ', correctOption: 3, explanation: 'සංඛ්‍යාතය (frequency) මාධ්‍ය වෙනස් වුණත් නොවෙනස් ව පවතී; වේගය සහ තරංගදෛර්ඝ්‍යය වෙනස් වේ.'),
      QuestionModel(id: 'sci_q9', subjectId: 'sci', questionText: 'අයනික සංයෝග පිළිබඳ ව සත්‍ය වනුයේ පහත කුමන ප්‍රකාශයද?', option1: 'ඝන අවස්ථාවේ දී විදුලිය සන්නයනය කරයි', option2: 'සියල්ල ම ඉතා හොඳින් ජලයේ දිය වේ', option3: 'ගලාංක හා ද්‍රවාංක ඉහළ අගයන් ගනී', option4: 'විලීන අවස්ථාවේ දී විදුලිය සන්නයනය නො කරයි', correctOption: 3, explanation: 'අයනික සංයෝගවල ගලාංක හා ද්‍රවාංක ඉහළ අගයන් ගනී.'),
      QuestionModel(id: 'sci_q10', subjectId: 'sci', questionText: 'කැස්ස සමඟ රුධිරය පිටවීම, ශරීරයේ බර අඩු වීම, අධික වෙහෙස — මෙම පුද්ගලයාට වැළඳී තිබීමට හැක්කේ?', option1: 'නිව්මෝනියාවයි', option2: 'බ්‍රොන්කයිටිස් රෝගයයි', option3: 'ක්ෂය රෝගයයි', option4: 'සිලිකෝසිස් රෝගයයි', correctOption: 3, explanation: 'ක්ෂය රෝගය (Tuberculosis) හේතුවෙන් රුධිරය සහිත කැස්ස, බර අඩු වීම, වෙහෙස ඇතිවේ.'),
      QuestionModel(id: 'sci_q11', subjectId: 'sci', questionText: 'ආලෝක වර්තනය පිළිබඳ ප්‍රකාශ සලකා බලන්න. (A=විරලතර සිට ඝනතර දක්වා පමණි, B=වේග එකිනෙකින් වෙනස් වීමයි, C=සංඛ්‍යාතය වෙනස් වේ)', option1: 'A පමණි', option2: 'B පමණි', option3: 'A හා C පමණි', option4: 'B හා C පමණි', correctOption: 2, explanation: 'A අසත්‍ය (ඝනතරෙන් විරලතරට ද ව.ව.), B සත්‍ය, C අසත්‍ය (සංඛ්‍යාතය නොවෙනස්).'),
      QuestionModel(id: 'sci_q12', subjectId: 'sci', questionText: 'පොළොව මත g=10 ms⁻² වේ. සඳ මත එම අගය පොළොව මෙන් 1/6 කි. පොළොව මත බර 60 N වන වස්තුවක සඳ මත බර?', option1: '10 N', option2: '60 N', option3: '100 N', option4: '360 N', correctOption: 1, explanation: 'ස්කන්ධය = 60/10 = 6 kg. සඳ g = 10/6. බර = 6×10/6 = 10 N.'),
      QuestionModel(id: 'sci_q13', subjectId: 'sci', questionText: 'පෘෂ්ඨ වංශි සත්ත්ව කාණ්ඩයට අයත් ආවේස් හා මැමේලියාවට පමණක් පොදු ලක්ෂණ? (A=සමතාපීත්වය, B=රෝම, C=අස්ථිමය, D=කුටීර හතරක් සහිත හෘදය)', option1: 'A හා B', option2: 'A හා D', option3: 'B හා C', option4: 'C හා D', correctOption: 2, explanation: 'A: සමතාපිත්වය, D: කුටීර 4ක හෘදය — දෙකටම පොදු. B: රෝම මැමේලියාවට පමණි.'),
      QuestionModel(id: 'sci_q14', subjectId: 'sci', questionText: 'ලෝහ පිළිබඳ ව අසත්‍ය ප්‍රකාශය මින් කුමක්ද?', option1: 'මූල ද්‍රව්‍ය වලින් බහුතරය ලෝහ වේ', option2: 'සියලු ම ලෝහ විද්‍යුතය සන්නයනය කරයි', option3: 'ලෝහ පරමාණු ඉලෙක්ට්‍රෝන පිට කරමින් ධන අයන නිපදවයි', option4: 'සියලු ම ලෝහ අම්ල සමග ප්‍රතික්‍රියා කර හයිඩ්‍රජන් පිට කරයි', correctOption: 4, explanation: 'Cu, Ag, Au වැනි ලෝහ ඇතැම් අම්ල සමග H₂ නිකුත් නොකරයි — අසත්‍ය.'),
      QuestionModel(id: 'sci_q15', subjectId: 'sci', questionText: 'එක්තරා ද්‍රාවණයකට මෙතිල් ඔරේන්ජ් බිංදු කිහිපයක් එක් කළ විට එය රතු පැහැයට හැරිණි. pH අගය වීමට වඩාත් ඉඩ ඇත්තේ?', option1: '2', option2: '7', option3: '12', option4: '14', correctOption: 1, explanation: 'මෙතිල් ඔරේන්ජ් ආම්ලික (pH < 4) ද්‍රාවණවල රතු වේ. pH 2 = ආම්ලික.'),
      QuestionModel(id: 'sci_q16', subjectId: 'sci', questionText: 'අතිධ්වනි තරංගය පරාවර්තනය වී පැමිණීමට 4s ගත වේ. ගැඹුර 2880 m නම් ජලය තුළ එහි වේගය?', option1: '720 ms⁻¹', option2: '1440 ms⁻¹', option3: '2880 ms⁻¹', option4: '3700 ms⁻¹', correctOption: 2, explanation: 'ගමන් කළ දිග = 2×2880 = 5760m. වේගය = 5760/4 = 1440 ms⁻¹.'),
      QuestionModel(id: 'sci_q17', subjectId: 'sci', questionText: 'පහසුවෙන් දහනය වන, වාතයට වඩා ඝනත්වයෙන් අඩු, ජලයේ මඳ වශයෙන් ද්‍රාව්‍ය වන වායුව?', option1: 'හයිඩ්‍රජන්ය', option2: 'නයිට්‍රජන් ය', option3: 'ඔක්සිජන්ය', option4: 'කාබන් ඩයොක්සයිඩ් ය', correctOption: 1, explanation: 'හයිඩ්‍රජන් (H₂) — දාහ්‍ය, ඝනත්වයෙන් ලෙහෙසිම, ජලයේ ස්වල්ප ද්‍රාව්‍ය.'),
      QuestionModel(id: 'sci_q18', subjectId: 'sci', questionText: 'හෘද ස්පන්දන වේගය පාලනය කරන මධ්‍ය ස්නායු පද්ධතියට අයත් කොටස කුමක්ද?', option1: 'මස්තිෂ්කය', option2: 'අනුමස්තිෂ්කය', option3: 'සුෂුම්නාව', option4: 'සුෂුම්නා ශීර්ෂකය', correctOption: 4, explanation: 'සුෂුම්නා ශීර්ෂකයේ (Medulla oblongata) හෘද ස්පන්දන කේන්ද්‍රය ඇත.'),
      QuestionModel(id: 'sci_q19', subjectId: 'sci', questionText: 'සන්නායකයක ප්‍රතිරෝධය පිළිබඳ ප්‍රකාශ: (A=විභව අන්තරය මත, B=දිගට අනුලෝමව, C=ධාරාව මත රඳා පවතී). සත්‍ය වනුයේ?', option1: 'A පමණි', option2: 'B පමණි', option3: 'A හා B පමණි', option4: 'A හා C පමණි', correctOption: 2, explanation: 'R = ρL/A. A: V මතත් C: I මතත් රඳා නොපවතී — B පමණි සත්‍ය.'),
      QuestionModel(id: 'sci_q20', subjectId: 'sci', questionText: 'කැල්සියම් කාබනේට් 10 g ක ඇති CaCO₃ මවුල ප්‍රමාණය කොපමණද (CaCO₃=100)?', option1: '0.01', option2: '0.1', option3: '1', option4: '10', correctOption: 2, explanation: 'n = m/M = 10/100 = 0.1 mol.'),
      QuestionModel(id: 'sci_q21', subjectId: 'sci', questionText: 'කාබොහයිඩ්‍රේට පිළිබඳව නිවැරදි ප්‍රකාශය තෝරන්න.', option1: 'සියලු ම කාබොහයිඩ්‍රේට ජල ද්‍රාව්‍ය වේ', option2: 'සියලු ම කාබොහයිඩ්‍රේට ස්ඵටිකරූපී වේ', option3: 'කාබොහයිඩ්‍රේටවල C, H හා O අතර අනුපාතය 1:2:1 වේ', option4: 'ග්ලූකෝස් යනු කාබොහයිඩ්‍රේටවල තැනුම් ඒකකයයි', correctOption: 4, explanation: 'ග්ලූකෝස් (monosaccharide) කාබොහයිඩ්‍රේටවල මූලික ඒකකයයි.'),
      QuestionModel(id: 'sci_q22', subjectId: 'sci', questionText: 'ඝන ද්‍රව්‍යයකින් සාදන ලද වස්තුවක් ද්‍රවයක ඉපිලීම සඳහා?', option1: 'ඝන ඝනත්වය ද්‍රවයේ ඝනත්වයට වඩා අඩු විය යුතුය', option2: 'ඝන වස්තුවේ ස්කන්ධය විස්ථාපිත ද්‍රව ස්කන්ධයට සමාන විය යුතුය', option3: 'ඝන වස්තුවේ බර විස්ථාපිත ද්‍රව පරිමාවේ බරට සමාන විය යුතුය', option4: 'ඝන වස්තුවේ බර එය මත ඇති වන උඩුකුරු තෙරපුමට වඩා අඩු විය යුතුය', correctOption: 2, explanation: 'ආකිමිඩීස් න්‍යාය — ඉපිලෙන විට ඝන ස්කන්ධය = විස්ථාපිත ද්‍රව ස්කන්ධය.'),
      QuestionModel(id: 'sci_q23', subjectId: 'sci', questionText: 'Tt ප්‍රවේණි දර්ශය සහිත ජීවීන් දෙදෙනෙකු අතර අන්තරාභිජනනයෙන් බිහි වන ජනිතයන්ගේ ප්‍රවේණි දර්ශ හා රූපානුදර්ශ සංඛ්‍යාව?', option1: '2 සහ 1', option2: '3 සහ 2', option3: '4 සහ 2', option4: '4 සහ 3', correctOption: 2, explanation: 'TT, Tt, tt = ප්‍රවේණිදර්ශ 3; TT+Tt=ලොකු, tt=කුඩා = රූපානුදර්ශ 2.'),
      QuestionModel(id: 'sci_q24', subjectId: 'sci', questionText: 'Fe₂O₃ + 3CO → 2Fe + 3CO₂. Fe₂O₃ මවුල එකක් භාවිතයෙන් නිපදවිය හැකි Fe ස්කන්ධය (Fe=56)?', option1: '28 g', option2: '56 g', option3: '112 g', option4: '168 g', correctOption: 3, explanation: 'Fe₂O₃ 1 mol → Fe 2 mol = 2×56 = 112 g.'),
      QuestionModel(id: 'sci_q25', subjectId: 'sci', questionText: 'වයිරස් ආසාදනයකට ලක් වූ පුද්ගලයෙකුගේ රුධිරයේ පට්ටිකා සාමාන්‍ය අගයට වඩා අඩු වූ විට?', option1: 'ඔක්සිජන් පරිවහනය වේගවත් වේ', option2: 'ප්‍රතිදේහ නිපදවීම අඩාල වේ', option3: 'රුධිරය කැටි ගැසීම නිසි පරිදි සිදු නො වේ', option4: 'හෝමෝන පරිවහනය සෙමින් සිදු වේ', correctOption: 3, explanation: 'පට්ටිකා (thrombocytes) රුධිර කැටිගැසීමට (clotting) දායකවේ.'),
      QuestionModel(id: 'sci_q26', subjectId: 'sci', questionText: 'A - උත්ප්‍රේරක මගින් රසායනික ප්‍රතික්‍රියාවක ශීඝ්‍රතාව වැඩි වේ. B - ප්‍රතික්‍රියාව අවසානයේ උත්ප්‍රේරකයේ රසායනික සංයුතිය වෙනස් වේ.', option1: 'A සහ B ප්‍රකාශ දෙක ම සත්‍ය වේ', option2: 'A ප්‍රකාශය සත්‍ය වන අතර B ප්‍රකාශය අසත්‍ය වේ', option3: 'A සහ B ප්‍රකාශ දෙක ම අසත්‍ය වේ', option4: 'A ප්‍රකාශය අසත්‍ය වන අතර B ප්‍රකාශය සත්‍ය වේ', correctOption: 2, explanation: 'A: සත්‍ය. B: අසත්‍ය — උත්ප්‍රේරකය ක්‍රියාවලිය අවසානයේ නොවෙනස්ව ඉතිරිවේ.'),
      QuestionModel(id: 'sci_q27', subjectId: 'sci', questionText: 'බහු අවයවක: A=ඉතා ඉහළ සාපේක්ෂ අණුක ස්කන්ධය, B=කුඩා අණු පුනරාවර්තන ඒකක සේ හැඳින්වේ, C=කෘත්‍රිම හා ස්වාභාවික. සත්‍ය?', option1: 'A පමණි', option2: 'B පමණි', option3: 'A හා C පමණි', option4: 'B හා C පමණි', correctOption: 3, explanation: 'A: සත්‍ය (ඉහළ mol mass). B: අසත්‍ය — කුඩා අණු "monomers" ලෙස හඳුන්වේ. C: සත්‍ය.'),
      QuestionModel(id: 'sci_q28', subjectId: 'sci', questionText: 'ප්‍රවේග - කාල ප්‍රස්තාරය පිළිබඳ දක්වා ඇති පහත ප්‍රකාශ වලින් අසත්‍ය ප්‍රකාශය කුමක්ද?', option1: 'ප්‍රස්තාරයෙන් ආවරණය වන වර්ග ඵලයෙන් වස්තුවේ විස්ථාපනය ලැබේ', option2: 'නිශ්චලතාවෙන් චලිතය අරඹන වස්තු සඳහා ප්‍රස්තාරය ඇරඹෙනුයේ මූල ලක්ෂ්‍යයෙනි', option3: 'කාලයත් සමඟ ප්‍රවේගය වෙනස් වන චලිතයක දී ප්‍රස්තාරයේ අනුක්‍රමණය ශුන්‍ය වේ', option4: 'ප්‍රස්තාරයේ අනුක්‍රමණයෙන් ත්වරණය/මන්දනය ලැබේ', correctOption: 3, explanation: 'ප්‍රවේගය වෙනස් නම් ත්වරණය ≠ 0 → ප්‍රස්තාරය අනුක්‍රමය ශූන්‍ය නොවේ.'),
      QuestionModel(id: 'sci_q29', subjectId: 'sci', questionText: 'සාගර පරිසර පද්ධතිවල ඇල්ගී ගහනය අසාමාන්‍ය ලෙස වර්ධනය වීමට දායක වන දූෂකය කුමක්ද?', option1: 'බැර ලෝහ', option2: 'සල්ෆේට්', option3: 'න්‍යෂ්ටික අපද්‍රව්‍ය', option4: 'පොස්පේට්', correctOption: 4, explanation: 'පොස්පේට් (phosphates) ශාක පෝෂකයක් ලෙස ක්‍රියාකර ඇල්ගී වර්ධනය (eutrophication) ඇතිකරේ.'),
      QuestionModel(id: 'sci_q30', subjectId: 'sci', questionText: 'වෙරළ ඛාදනය + කුණාටු ඇතිවන වාර ගණන වැඩිවීම — මෙම තත්ත්වයට ඉහළ ම දායකත්වය සපයන්නේ?', option1: 'ගෝලීය උණුසුම ඉහළ යාම', option2: 'හරිතාගාර ආචරණය', option3: 'ඕසෝන් වියන ක්ෂය වීම', option4: 'සුපෝෂණය', correctOption: 1, explanation: 'ගෝලීය උණුසුම ඉහළ යාම නිසා මුහුදු මට්ටම ඉහළ යාම, කුණාටු ශක්තිය වැඩිවීම සහ වෙරළ ඛාදනය ඇතිවේ.'),
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
      QuestionModel(id: 'his_q1', subjectId: 'history', questionText: 'මහාවංශය රචනා කළේ කවරෙකු ද?', option1: 'ධම්මකිත්ති', option2: 'බුද්ධඝෝෂ', option3: 'මහානාම', option4: 'රේවත', correctOption: 3, explanation: 'මහාවංශය රචනා කළේ මහානාම හිමි ය.'),
      QuestionModel(id: 'his_q2', subjectId: 'history', questionText: 'ශ්‍රී ලංකාවේ ප්‍රථම සිංහල රාජ්‍ය ස්ථාපිත කළේ කවරෙකු ද?', option1: 'දේවානම්පියතිස්ස', option2: 'විජය', option3: 'පාණ්ඩුකාභය', option4: 'දුටුගැමුණු', correctOption: 2, explanation: 'ශ්‍රී ලංකාවේ ප්‍රථම සිංහල රාජ්‍ය ස්ථාපිත කළේ විජය ය.'),
      QuestionModel(id: 'his_q3', subjectId: 'history', questionText: 'අනුරාධපුර රාජධානිය ස්ථාපිත කළේ කවරෙකු ද?', option1: 'දේවානම්පියතිස්ස', option2: 'විජය', option3: 'පාණ්ඩුකාභය', option4: 'වළගම්බා', correctOption: 3, explanation: 'අනුරාධපුර රාජධානිය ස්ථාපිත කළේ පාණ්ඩුකාභය ය.'),
      QuestionModel(id: 'his_q4', subjectId: 'history', questionText: 'ශ්‍රී ලංකාවට බෞද්ධ දහම හඳුන්වා දුන් දූතයා කවරෙකු ද?', option1: 'සංඝමිත්තා', option2: 'මහින්ද', option3: 'ධර්මාශෝක', option4: 'රේවත', correctOption: 2, explanation: 'ශ්‍රී ලංකාවට බෞද්ධ දහම හඳුන්වා දුන්නේ මහින්ද ය.'),
      QuestionModel(id: 'his_q5', subjectId: 'history', questionText: 'ජය ශ්‍රී මහා බෝධිය ශ්‍රී ලංකාවට ගෙනා කවරෙකු ද?', option1: 'සංඝමිත්තා', option2: 'මහින්ද', option3: 'ධර්මාශෝක', option4: 'ඉන්ද්‍රගුප්ත', correctOption: 1, explanation: 'ජය ශ්‍රී මහා බෝධිය ශ්‍රී ලංකාවට ගෙනා කවරෙකු ද සංඝමිත්තා ය.'),
      QuestionModel(id: 'his_q6', subjectId: 'history', questionText: 'ගැමුණු රජු දකුණු ඉන්දියාවෙන් පැමිණ ශ්‍රී ලංකාව ජය ගත් ඇලළ රජු?', option1: 'කජු බාහු', option2: 'ඵරඛු', option3: 'ඵළ්ළ', option4: 'ඇල', correctOption: 3, explanation: 'දකුණු ඉන්දියාවෙන් ශ්‍රී ලංකාව ආක්‍රමණය කළේ ඵළ්ළ ය.'),
      QuestionModel(id: 'his_q7', subjectId: 'history', questionText: 'දළදා මාළිගාව පිහිටා ඇත්තේ කොතෙක ද?', option1: 'කොළඹ', option2: 'ගාල්ල', option3: 'කෑගල්ල', option4: 'මහනුවර', correctOption: 4, explanation: 'දළදා මාළිගාව පිහිටා ඇත්තේ මහනුවර ය.'),
      QuestionModel(id: 'his_q8', subjectId: 'history', questionText: 'ශ්‍රී ලංකාව ස්වාධීනත්වය ලැබූ දිනය?', option1: '1948 පෙබරවාරි 4', option2: '1947 අගෝස්තු 15', option3: '1949 ජනවාරි 26', option4: '1950 ජූනි 10', correctOption: 1, explanation: 'ශ්‍රී ලංකාව ස්වාධීනත්වය ලැබූ දිනය 1948 පෙබරවාරි 4 ය.'),
      QuestionModel(id: 'his_q9', subjectId: 'history', questionText: 'ශ්‍රී ලංකාවේ ප්‍රථම අගමැතිවරයා කවරෙකු ද?', option1: 'ඩී. එස්. සේනානායක', option2: 'ශ්‍රීමාවෝ බණ්ඩාරනායක', option3: 'ජේ. ආර්. ජයවර්ධන', option4: 'ඩඩ්ලි සේනානායක', correctOption: 1, explanation: 'ශ්‍රී ලංකාවේ ප්‍රථම අගමැතිවරයා ඩී. එස්. සේනානායක ය.'),
      QuestionModel(id: 'his_q10', subjectId: 'history', questionText: 'ලෝකයේ ප්‍රථම කාන්තා අගමැතිවරිය?', option1: 'ඉන්දිරා ගාන්ධි', option2: 'ශ්‍රීමාවෝ බණ්ඩාරනායක', option3: 'ගෝල්ඩා මේයර්', option4: 'මාග්‍රට් තැචර්', correctOption: 2, explanation: 'ශ්‍රීමාවෝ බණ්ඩාරනායක ලෝකයේ ප්‍රථම කාන්තා අගමැතිවරිය.'),
      QuestionModel(id: 'his_q11', subjectId: 'history', questionText: 'ශ්‍රී ලංකාවේ ප්‍රජාතාන්ත්‍රික සමාජවාදී ජනරජය ප්‍රකාශ කළ වර්ෂය?', option1: '1972', option2: '1948', option3: '1978', option4: '1983', correctOption: 1, explanation: '1972 දී ශ්‍රී ලංකාව ජනරජයක් විය.'),
      QuestionModel(id: 'his_q12', subjectId: 'history', questionText: 'රෝහල් ශිෂ්‍ය ව්‍යාපාරයට නායකත්වය දුන් අය?', option1: 'ස්වාමී විවේකානන්ද', option2: 'ශ්‍රී ලංකාවේ', option3: 'පාරේ', option4: 'හෙන්රි ස්ටීල් ඕල්කොට්', correctOption: 4, explanation: 'හෙන්රි ස්ටීල් ඕල්කොට් ශ්‍රී ලංකාවේ ජාතික ව්‍යාපාරයට දායකවිය.'),
      QuestionModel(id: 'his_q13', subjectId: 'history', questionText: 'ශ්‍රී ලංකාවේ ජාතික ගීය රචනා කළේ?', option1: 'ආනන්ද සමරකෝන්', option2: 'රබීන්ද්‍රනාත් තාගෝර්', option3: 'සිරිල් ද ශිල්වා', option4: 'ජෝන් ද ශිල්වා', correctOption: 1, explanation: 'ශ්‍රී ලංකාවේ ජාතික ගීය රචනා කළේ ආනන්ද සමරකෝන් ය.'),
      QuestionModel(id: 'his_q14', subjectId: 'history', questionText: 'ශ්‍රී ලංකාවේ ප්‍රථම ජනාධිපතිවරයා?', option1: 'ඩී. එස්. සේනානායක', option2: 'ශ්‍රීමාවෝ බණ්ඩාරනායක', option3: 'ජේ. ආර්. ජයවර්ධන', option4: 'ඩඩ්ලි සේනානායක', correctOption: 3, explanation: 'ශ්‍රී ලංකාවේ ප්‍රථම ජනාධිපතිවරයා ජේ. ආර්. ජයවර්ධන ය.'),
      QuestionModel(id: 'his_q15', subjectId: 'history', questionText: 'පොළොන්නරුව රාජධානිය ස්ථාපිත කළේ?', option1: 'දුටුගැමුණු', option2: 'පරාක්‍රමබාහු', option3: 'විජය', option4: 'පාණ්ඩුකාභය', correctOption: 2, explanation: 'පොළොන්නරුව රාජධානිය ප්‍රධාන රජු ලෙස ශ්‍රේෂ්ඨ ලෙස ජනප්‍රිය වූ රජු පරාක්‍රමබාහු ය.'),
      QuestionModel(id: 'his_q16', subjectId: 'history', questionText: 'ශ්‍රී ලංකාවේ ප්‍රාකෘතික ජාතිය?', option1: 'ශ්‍රී ලාංකික', option2: 'සිංහල', option3: 'ඇඳ', option4: 'ද්‍රවිඩ', correctOption: 3, explanation: 'ශ්‍රී ලංකාවේ ප්‍රාකෘතික ජාතිය ඇඳ (Vedda) ය.'),
      QuestionModel(id: 'his_q17', subjectId: 'history', questionText: 'සිදුහත් කුමරු ශාක්‍ය රාජ්‍යයේ ඉපදුණු ස්ථානය?', option1: 'සාරනාත්', option2: 'ලුම්බිනි', option3: 'බෝධ ගයා', option4: 'කුශිනගර', correctOption: 2, explanation: 'සිදුහත් කුමරු ඉපදුණේ ලුම්බිනි හිය.'),
      QuestionModel(id: 'his_q18', subjectId: 'history', questionText: 'ධර්මාශෝක රජු ගොඩ නැංවූ රාජ්‍යය?', option1: 'මොරිය', option2: 'ගුප්ත', option3: 'කුෂාන', option4: 'නන්ද', correctOption: 1, explanation: 'ධර්මාශෝක රජු මොරිය රාජ්‍යයේ රජු ය.'),
      QuestionModel(id: 'his_q19', subjectId: 'history', questionText: 'ශ්‍රී ලංකාවේ ජාතික කොඩිය නිර්මාණය කළ වර්ෂය?', option1: '1948', option2: '1950', option3: '1972', option4: '1978', correctOption: 1, explanation: 'ශ්‍රී ලංකාවේ ජාතික කොඩිය 1948 දී සිය රූපය ලැබිය.'),
      QuestionModel(id: 'his_q20', subjectId: 'history', questionText: 'කොළඹ නගරය ගොඩ නැගුණු සමය?', option1: 'ලන්දේසි', option2: 'බ්‍රිතාන්‍ය', option3: 'පෘතුගීසි', option4: 'ලංකා', correctOption: 3, explanation: 'කොළඹ නගරය ප්‍රධාන ලෙස ගොඩ නැගුණේ පෘතුගීසි සමයේ ය.'),
      QuestionModel(id: 'his_q21', subjectId: 'history', questionText: 'ශ්‍රී ලංකාවේ ලන්දේසි ආධිපත්‍ය කාලය?', option1: '1505-1658', option2: '1658-1796', option3: '1796-1948', option4: '1948-1972', correctOption: 2, explanation: 'ලන්දේසි ආධිපත්‍ය 1658-1796 කාලය.'),
      QuestionModel(id: 'his_q22', subjectId: 'history', questionText: 'ශ්‍රී ලංකාවේ පෘතුගීසි ආධිපත්‍ය ආරම්භ වූ වර්ෂය?', option1: '1505', option2: '1658', option3: '1796', option4: '1815', correctOption: 1, explanation: 'පෘතුගීසි ආධිපත්‍ය ආරම්භ වූ වර්ෂය 1505 ය.'),
      QuestionModel(id: 'his_q23', subjectId: 'history', questionText: 'ශ්‍රී ලංකාවේ නිදහස් ගිවිසුමට අත්සන් කළ බ්‍රිතාන්‍ය නිලධාරියා?', option1: 'ලෝර්ඩ් මවුන්ට්බැටන්', option2: 'ශ්‍රී ලන්ඩන්', option3: 'ශ්‍රී පීතර්', option4: 'ශ්‍රී ජෝන්', correctOption: 1, explanation: 'ශ්‍රී ලංකාවේ නිදහස ලෝර්ඩ් මවුන්ට්බැටන් සමඟ ය.'),
      QuestionModel(id: 'his_q24', subjectId: 'history', questionText: 'ශ්‍රී ලංකාවේ 1815 ගිවිසුම?', option1: 'ඔලිවිය ගිවිසුම', option2: 'කෑගල්ල ගිවිසුම', option3: 'මහනුවර ගිවිසුම', option4: 'ගාල්ල ගිවිසුම', correctOption: 3, explanation: '1815 ගිවිසුම මහනුවර ගිවිසුම ය.'),
      QuestionModel(id: 'his_q25', subjectId: 'history', questionText: 'ශ්‍රී ලංකාවේ ප්‍රථම ආණ්ඩු ක්‍රම ව්‍යවස්ථාව?', option1: '1947', option2: '1948', option3: '1972', option4: '1978', correctOption: 1, explanation: 'ශ්‍රී ලංකාවේ ප්‍රථම ව්‍යවස්ථාව 1947 ය.'),
      QuestionModel(id: 'his_q26', subjectId: 'history', questionText: 'ශ්‍රී ලංකාවේ ශ්‍රේෂ්ඨාධිකරණය ස්ථාපිත කළ වර්ෂය?', option1: '1801', option2: '1815', option3: '1833', option4: '1948', correctOption: 3, explanation: 'ශ්‍රේෂ්ඨාධිකරණය ස්ථාපිත කළ වර්ෂය 1833 ය.'),
      QuestionModel(id: 'his_q27', subjectId: 'history', questionText: 'ශ්‍රී ලංකාවේ දළදා ශ්‍රී ලංකාවට ගෙනා රජ?', option1: 'දේවානම්පියතිස්ස', option2: 'කිර්ති ශ්‍රී රාජසිංහ', option3: 'ශ්‍රී ලංකා', option4: 'ශ්‍රී ශ්‍රී', correctOption: 2, explanation: 'දළදා ශ්‍රී ලංකාවට ගෙනෙනු ලැබූ රජු කිර්ති ශ්‍රී රාජසිංහ ය.'),
      QuestionModel(id: 'his_q28', subjectId: 'history', questionText: 'ශ්‍රී ලංකාව UN සාමාජිකත්වය ලැබූ වර්ෂය?', option1: '1948', option2: '1955', option3: '1972', option4: '1978', correctOption: 2, explanation: 'ශ්‍රී ලංකාව 1955 දී UN සාමාජිකත්වය ලැබිය.'),
      QuestionModel(id: 'his_q29', subjectId: 'history', questionText: 'බ්‍රිතාන්‍ය ආණ්ඩු සමයේ ශ්‍රී ලංකාවේ ව්‍යවස්ථාපිත ශිෂ්‍ය ව්‍යාපාරය ශ්‍රී ලාංකික?', option1: '1915', option2: '1818', option3: '1848', option4: '1832', correctOption: 1, explanation: '1915 කොළඹ කළකිරීමේ කෝලාහලය සිදු විය.'),
      QuestionModel(id: 'his_q30', subjectId: 'history', questionText: 'ශ්‍රී ලංකාවේ ප්‍රථම ජනලේඛනය?', option1: '1871', option2: '1891', option3: '1901', option4: '1881', correctOption: 1, explanation: 'ශ්‍රී ලංකාවේ ප්‍රථම ජනලේඛනය 1871 ය.'),
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
        throw Exception('Firebase හි Email/Password ක්‍රමය සක්‍රීය කර නොමැත! (Enable Email/Password in console)');
      }
      throw Exception('ලියාපදිංචි වීමේදී දෝෂයක් සිදුවිය: ${e.message} (Code: ${e.code})');
    } catch (e) {
      print('GENERAL ERROR: $e');
      throw Exception('ලියාපදිංචි වීමේදී අසාමාන්‍ය දෝෂයක් සිදුවිය: $e');
    }
  }

  // Email/Password ලොගින් (Firebase Auth)
  Future<StudentModel?> loginStudent(String email, String password) async {
    if (_isOfflineMode) {
      return _offlineStudent ?? StudentModel(
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
        throw Exception('Firebase හි Email/Password ක්‍රමය සක්‍රීය කර නොමැත! (Enable Email/Password in console)');
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
  String? get currentUid => _isOfflineMode ? _offlineStudent?.uid : _auth.currentUser?.uid;

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

  Future<void> updateStudentStats(String uid, int additionalXp, double newAvgScore) async {
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
        return all.where((s) => s.name.toLowerCase().contains(searchQuery.toLowerCase())).toList();
      }
      return all;
    }

    try {
      final snap = await _db.collection('subjects').get();
      if (snap.docs.isEmpty) {
        await _seedSubjectsAndQuestions();
        final newSnap = await _db.collection('subjects').get();
        final all = newSnap.docs.map((d) => SubjectModel.fromMap(d.data(), id: d.id)).toList();
        if (searchQuery != null && searchQuery.isNotEmpty) {
          return all.where((s) => s.name.toLowerCase().contains(searchQuery.toLowerCase())).toList();
        }
        return all;
      }

      var all = snap.docs.map((d) => SubjectModel.fromMap(d.data(), id: d.id)).toList();
      // Firestore හි ඇති විෂයන් ප්‍රමාණය 15 ට වඩා අඩු නම්, ඉතිරි ඒවා seed කිරීම
      if (all.length < 15) {
        await _seedMissingSubjects(all);
        final newSnap = await _db.collection('subjects').get();
        all = newSnap.docs.map((d) => SubjectModel.fromMap(d.data(), id: d.id)).toList();
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        return all.where((s) => s.name.toLowerCase().contains(searchQuery.toLowerCase())).toList();
      }
      return all;
    } catch (_) {
      _isOfflineMode = true;
      return getSubjects(searchQuery: searchQuery);
    }
  }

  // Firestore හි නොමැති විෂයන් seed කිරීමට සහායක ක්‍රමවේදයක්
  Future<void> _seedMissingSubjects(List<SubjectModel> existing) async {
    final batch = _db.batch();
    final existingNames = existing.map((s) => s.name.toLowerCase()).toSet();

    final subjectsToSeed = [
      {'name': 'Religion', 'iconName': 'volunteer_activism', 'imageUrl': 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400&q=80', 'totalQuestions': 0, 'completedRate': 0.0},
      {'name': 'Sinhala', 'iconName': 'book', 'imageUrl': 'https://images.unsplash.com/photo-1506880018603-83d5b814b5a6?w=400&q=80', 'totalQuestions': 0, 'completedRate': 0.0},
      {'name': 'English', 'iconName': 'language', 'imageUrl': 'https://images.unsplash.com/photo-1451226428352-cf66b8a0317a?w=400&q=80', 'totalQuestions': 0, 'completedRate': 0.0},
      {'name': 'Mathematics', 'iconName': 'calculate', 'imageUrl': 'https://images.unsplash.com/photo-1509228468518-180dd4864904?w=400&q=80', 'totalQuestions': 3, 'completedRate': 0.0},
      {'name': 'Science', 'iconName': 'science', 'imageUrl': 'https://images.unsplash.com/photo-1507668077129-56e32842fceb?w=400&q=80', 'totalQuestions': 30, 'completedRate': 0.0},
      {'name': 'History', 'iconName': 'history', 'imageUrl': 'https://images.unsplash.com/photo-1461360370896-922624d12aa1?w=400&q=80', 'totalQuestions': 0, 'completedRate': 0.0},
      {'name': 'Business & Accounting Studies', 'iconName': 'analytics', 'imageUrl': 'https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=400&q=80', 'totalQuestions': 0, 'completedRate': 0.0},
      {'name': 'Geography', 'iconName': 'public', 'imageUrl': 'https://images.unsplash.com/photo-1524661135-423995f22d0b?w=400&q=80', 'totalQuestions': 0, 'completedRate': 0.0},
      {'name': 'Civic Education', 'iconName': 'gavel', 'imageUrl': 'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?w=400&q=80', 'totalQuestions': 0, 'completedRate': 0.0},
      {'name': 'Music', 'iconName': 'music_note', 'imageUrl': 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=400&q=80', 'totalQuestions': 0, 'completedRate': 0.0},
      {'name': 'Dancing', 'iconName': 'emoji_people', 'imageUrl': 'https://images.unsplash.com/photo-1508700115892-45ecd05ae2ad?w=400&q=80', 'totalQuestions': 0, 'completedRate': 0.0},
      {'name': 'Art (Act)', 'iconName': 'palette', 'imageUrl': 'https://images.unsplash.com/photo-1513364776144-60967b0f800f?w=400&q=80', 'totalQuestions': 0, 'completedRate': 0.0},
      {'name': 'Information & Communication', 'iconName': 'computer', 'imageUrl': 'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?w=400&q=80', 'totalQuestions': 0, 'completedRate': 0.0},
      {'name': 'Agriculture & Food Technology', 'iconName': 'agriculture', 'imageUrl': 'https://images.unsplash.com/photo-1464226184884-fa280b87c3a9?w=400&q=80', 'totalQuestions': 0, 'completedRate': 0.0},
      {'name': 'Health & Physical Education', 'iconName': 'fitness_center', 'imageUrl': 'https://images.unsplash.com/photo-1476480862126-209bfaa8edc8?w=400&q=80', 'totalQuestions': 0, 'completedRate': 0.0},
    ];

    for (var sub in subjectsToSeed) {
      if (!existingNames.contains((sub['name'] as String).toLowerCase())) {
        final ref = _db.collection('subjects').doc();
        batch.set(ref, sub);
      }
    }
    await batch.commit();
  }

  Future<void> updateSubjectProgress(String subjectId, double completedRate) async {
    if (_isOfflineMode) {
      final idx = _offlineSubjects.indexWhere((s) => s.id == subjectId);
      if (idx != -1) {
        _offlineSubjects[idx] = _offlineSubjects[idx].copyWith(completedRate: completedRate);
      }
      return;
    }
    await _db.collection('subjects').doc(subjectId).update({'completedRate': completedRate});
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

      // Firebase eke questions naha nam _offlineQuestions walen auto-seed karamu
      if (snap.docs.isEmpty) {
        final offlineQs = _offlineQuestions[subjectId];
        if (offlineQs != null && offlineQs.isNotEmpty) {
          final batch = _db.batch();
          for (var q in offlineQs) {
            final ref = _db
                .collection('subjects')
                .doc(subjectId)
                .collection('questions')
                .doc();
            batch.set(ref, {
              'subjectId': subjectId,
              'questionText': q.questionText,
              'option1': q.option1,
              'option2': q.option2,
              'option3': q.option3,
              'option4': q.option4,
              'correctOption': q.correctOption,
              'explanation': q.explanation,
            });
          }
          await batch.commit();

          // Commit karala nawa data ganna
          final newSnap = await _db
              .collection('subjects')
              .doc(subjectId)
              .collection('questions')
              .get();
          return newSnap.docs
              .map((d) => QuestionModel.fromMap(d.data(), id: d.id, subjectId: subjectId))
              .toList();
        }
        return [];
      }

      return snap.docs
          .map((d) => QuestionModel.fromMap(d.data(), id: d.id, subjectId: subjectId))
          .toList();
    } catch (_) {
      _isOfflineMode = true;
      return getQuestionsBySubject(subjectId);
    }
  }

  // ==========================================
  // 5. QUIZ RESULTS (Results & Review Pages)
  // ==========================================

  Future<String> saveQuizResult(QuizResultModel result, List<StudentAnswerModel> answers) async {
    if (_isOfflineMode) {
      final mockResultId = 'offline_res_${DateTime.now().millisecondsSinceEpoch}';
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
      
      final List<StudentAnswerModel> updatedAnswers = answers.map((a) => StudentAnswerModel(
        id: a.id,
        resultId: mockResultId,
        questionId: a.questionId,
        selectedOption: a.selectedOption,
        isCorrect: a.isCorrect,
        question: a.question,
      )).toList();
      _offlineAnswers[mockResultId] = updatedAnswers;

      // Update student stats locally
      int totalCorrect = 0;
      int totalQs = 0;
      for (var res in _offlineResults) {
        totalCorrect += res.score;
        totalQs += res.totalQuestions;
      }
      final double newAvgScore = totalQs > 0 ? (totalCorrect / totalQs) * 100 : 0.0;
      final int gainedXp = result.score * 50;

      await updateStudentStats(result.studentId, gainedXp, newAvgScore);
      await updateSubjectProgress(result.subjectId, result.score / result.totalQuestions);

      return mockResultId;
    }

    try {
      final batch = _db.batch();
      final resultRef = _db
          .collection('users')
          .doc(result.studentId)
          .collection('results')
          .doc();

      batch.set(resultRef, result.toMap());

      for (var answer in answers) {
        final answerRef = resultRef.collection('answers').doc();
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
      final double newAvgScore = totalQs > 0 ? (totalCorrect / totalQs) * 100 : 0.0;
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

  Future<List<StudentAnswerModel>> getAnswersForQuizResult(String uid, String resultId) async {
    if (_isOfflineMode) {
      final answers = _offlineAnswers[resultId] ?? [];
      // Attach mock questions to review
      final List<StudentAnswerModel> detailedAnswers = [];
      for (var a in answers) {
        QuestionModel? question;
        for (var key in _offlineQuestions.keys) {
          final found = _offlineQuestions[key]!.where((q) => q.id == a.questionId);
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
            question = QuestionModel.fromMap(qDoc.data()!, id: qDoc.id, subjectId: subDoc.id);
            break;
          }
        }

        answers.add(StudentAnswerModel.fromMap(data, id: doc.id, question: question));
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

    final subjects = [
      {'name': 'Religion', 'iconName': 'volunteer_activism', 'imageUrl': 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400&q=80', 'totalQuestions': 0, 'completedRate': 0.0},
      {'name': 'Sinhala', 'iconName': 'book', 'imageUrl': 'https://images.unsplash.com/photo-1506880018603-83d5b814b5a6?w=400&q=80', 'totalQuestions': 0, 'completedRate': 0.0},
      {'name': 'English', 'iconName': 'language', 'imageUrl': 'https://images.unsplash.com/photo-1451226428352-cf66b8a0317a?w=400&q=80', 'totalQuestions': 0, 'completedRate': 0.0},
      {'name': 'Mathematics', 'iconName': 'calculate', 'imageUrl': 'https://images.unsplash.com/photo-1509228468518-180dd4864904?w=400&q=80', 'totalQuestions': 3, 'completedRate': 0.0},
      {'name': 'Science', 'iconName': 'science', 'imageUrl': 'https://images.unsplash.com/photo-1507668077129-56e32842fceb?w=400&q=80', 'totalQuestions': 30, 'completedRate': 0.0},
      {'name': 'History', 'iconName': 'history', 'imageUrl': 'https://images.unsplash.com/photo-1461360370896-922624d12aa1?w=400&q=80', 'totalQuestions': 0, 'completedRate': 0.0},
      {'name': 'Business & Accounting Studies', 'iconName': 'analytics', 'imageUrl': 'https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=400&q=80', 'totalQuestions': 0, 'completedRate': 0.0},
      {'name': 'Geography', 'iconName': 'public', 'imageUrl': 'https://images.unsplash.com/photo-1524661135-423995f22d0b?w=400&q=80', 'totalQuestions': 0, 'completedRate': 0.0},
      {'name': 'Civic Education', 'iconName': 'gavel', 'imageUrl': 'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?w=400&q=80', 'totalQuestions': 0, 'completedRate': 0.0},
      {'name': 'Music', 'iconName': 'music_note', 'imageUrl': 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=400&q=80', 'totalQuestions': 0, 'completedRate': 0.0},
      {'name': 'Dancing', 'iconName': 'emoji_people', 'imageUrl': 'https://images.unsplash.com/photo-1508700115892-45ecd05ae2ad?w=400&q=80', 'totalQuestions': 0, 'completedRate': 0.0},
      {'name': 'Art (Act)', 'iconName': 'palette', 'imageUrl': 'https://images.unsplash.com/photo-1513364776144-60967b0f800f?w=400&q=80', 'totalQuestions': 0, 'completedRate': 0.0},
      {'name': 'Information & Communication', 'iconName': 'computer', 'imageUrl': 'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?w=400&q=80', 'totalQuestions': 0, 'completedRate': 0.0},
      {'name': 'Agriculture & Food Technology', 'iconName': 'agriculture', 'imageUrl': 'https://images.unsplash.com/photo-1464226184884-fa280b87c3a9?w=400&q=80', 'totalQuestions': 0, 'completedRate': 0.0},
      {'name': 'Health & Physical Education', 'iconName': 'fitness_center', 'imageUrl': 'https://images.unsplash.com/photo-1476480862126-209bfaa8edc8?w=400&q=80', 'totalQuestions': 0, 'completedRate': 0.0},
    ];

    final Map<String, String> subjectIds = {};
    for (var sub in subjects) {
      final ref = _db.collection('subjects').doc();
      batch.set(ref, sub);
      subjectIds[sub['name'] as String] = ref.id;
    }

    await batch.commit();

    final String scienceId = subjectIds['Science']!;
    final scienceQuestions = [
      {'subjectId': scienceId, 'questionText': 'බහිස්ස්‍රාවී ද්‍රව්‍යයක් වන යුරියා නිපදවෙන්නේ?', 'option1': 'වකුගඩුවල', 'option2': 'අක්මාවෙහි', 'option3': 'මුත්‍රාශයෙහි', 'option4': 'වෘක්කාණුවල', 'correctOption': 2, 'explanation': 'යුරියා නිපදවෙන්නේ අක්මාවෙහිය.'},
      {'subjectId': scienceId, 'questionText': 'ක්ෂමතාවේ (Power) ඒකකය කුමක්ද?', 'option1': 'Ws', 'option2': 'Ws⁻¹', 'option3': 'Js', 'option4': 'Js⁻¹', 'correctOption': 4, 'explanation': 'ක්ෂමතාව = ශක්තිය/කාලය = Js⁻¹ (Watt).'},
      {'subjectId': scienceId, 'questionText': 'අයිසොප්‍රොපිල් ඇල්කොහොල් (CH₃)₂CHOH අණුවක ඇති පරමාණු ගණන?', 'option1': '8', 'option2': '10', 'option3': '11', 'option4': '12', 'correctOption': 4, 'explanation': 'C=3, H=8, O=1 → මුළු = 12.'},
      {'subjectId': scienceId, 'questionText': 'ශාක පත්‍ර තුළ නිපදවන ආහාර ශාක දේහය පුරා පරිවහනය කරන පටකය?', 'option1': 'ශෛලම', 'option2': 'ප්ලෝයම', 'option3': 'කැම්බියම', 'option4': 'දෘඪස්තර', 'correctOption': 2, 'explanation': 'ප්ලෝයම (Phloem) ආහාර ගෙනයයි.'},
      {'subjectId': scienceId, 'questionText': 'වස්තු පිරි මැදීමෙන් ධන ආරෝපණ ලැබීමේ දී අනෙකට සංක්‍රමණය වනුයේ?', 'option1': 'ඉලෙක්ට්‍රෝනයි', 'option2': 'ප්‍රෝටෝනයි', 'option3': 'නියුට්‍රෝනයි', 'option4': 'ඉලෙක්ට්‍රෝන හා ප්‍රෝටෝනයි', 'correctOption': 1, 'explanation': 'ඉලෙක්ට්‍රෝන සංචලනශීලී බැවින් ඒවාම සංක්‍රමණය වේ.'},
      {'subjectId': scienceId, 'questionText': 'පිළිවෙළින් ආම්ලික, උභයගුණ, භාස්මික ඔක්සයිඩ ඇතුළත් කුමක්ද?', 'option1': 'SO₃, Al₂O₃, SiO₂', 'option2': 'SO₃, Al₂O₃, MgO', 'option3': 'CO₂, SiO₂, MgO', 'option4': 'SiO₂, CO₂, Al₂O₃', 'correctOption': 2, 'explanation': 'SO₃=ආම්ලික, Al₂O₃=උභයගුණ, MgO=භාස්මික.'},
      {'subjectId': scienceId, 'questionText': 'ශාක සෛලයක ඇති අජීවී ව්‍යුහය?', 'option1': 'සෛල බිත්තිය', 'option2': 'ප්ලාස්ම පටලය', 'option3': 'රයිබොසෝම', 'option4': 'ගොල්ගි දේහ', 'correctOption': 1, 'explanation': 'සෛල බිත්තිය (Cell Wall) අජීවී ව්‍යුහයකි.'},
      {'subjectId': scienceId, 'questionText': 'විද්‍යුත්-චුම්බක තරංග ගැන අසත්‍ය ප්‍රකාශය?', 'option1': 'ශක්තිය සම්ප්‍රේෂණය කරයි', 'option2': 'රික්තයේ 3×10⁸ ms⁻¹ ගමන් කරයි', 'option3': 'පදාර්ථ මාධ්‍යයේ සංඛ්‍යාතය රික්තයේ දීට වඩා අඩු', 'option4': 'පදාර්ථ මාධ්‍යයේ වේගය රික්තයේ දීට වඩා අඩු', 'correctOption': 3, 'explanation': 'සංඛ්‍යාතය (frequency) නොවෙනස් ව පවතී.'},
      {'subjectId': scienceId, 'questionText': 'අයනික සංයෝග ගැන සත්‍ය ප්‍රකාශය?', 'option1': 'ඝන අවස්ථාවේ විදුලිය සන්නයනය', 'option2': 'සියල්ල ජලයේ හොඳින් දිය වේ', 'option3': 'ගලාංක හා ද්‍රවාංක ඉහළ', 'option4': 'විලීනයේ විදුලිය සන්නයනය නොකරයි', 'correctOption': 3, 'explanation': 'අයනික සංයෝගවල ගලාංක හා ද්‍රවාංක ඉහළ.'},
      {'subjectId': scienceId, 'questionText': 'කැස්ස සමඟ රුධිරය, බර අඩුවීම, වෙහෙස — රෝගය?', 'option1': 'නිව්මෝනියාව', 'option2': 'බ්‍රොන්කයිටිස්', 'option3': 'ක්ෂය රෝගය', 'option4': 'සිලිකෝසිස්', 'correctOption': 3, 'explanation': 'ක්ෂය රෝගය (Tuberculosis) හේතුවෙනි.'},
      {'subjectId': scienceId, 'questionText': 'ආලෝක වර්තනය: A=විරලතරසිට ඝනතරට, B=වේග වෙනස, C=සංඛ්‍යාතය වෙනස. සත්‍ය?', 'option1': 'A පමණි', 'option2': 'B පමණි', 'option3': 'A හා C', 'option4': 'B හා C', 'correctOption': 2, 'explanation': 'B සත්‍ය. A,C අසත්‍ය.'},
      {'subjectId': scienceId, 'questionText': 'පොළොව g=10, සඳ g=10/6. 60N වස්තුවක සඳ මත බර?', 'option1': '10 N', 'option2': '60 N', 'option3': '100 N', 'option4': '360 N', 'correctOption': 1, 'explanation': 'ස්කන්ධය=6kg. සඳ g=10/6. බර=6×10/6=10N.'},
      {'subjectId': scienceId, 'questionText': 'ආවේස් හා මැමේලියාවට පොදු: A=සමතාපිත්ව, B=රෝම, C=අස්ථිමය, D=හෘදය කුටීර4', 'option1': 'A හා B', 'option2': 'A හා D', 'option3': 'B හා C', 'option4': 'C හා D', 'correctOption': 2, 'explanation': 'A,D දෙකටම පොදු.'},
      {'subjectId': scienceId, 'questionText': 'ලෝහ ගැන අසත්‍ය ප්‍රකාශය?', 'option1': 'බහුතරය ලෝහ', 'option2': 'සියල්ල විදුලිය සන්නයනය', 'option3': 'ධන අයන නිපදවයි', 'option4': 'සියල්ල H₂ නිකුත් කරයි', 'correctOption': 4, 'explanation': 'Cu, Ag, Au H₂ නිකුත් නොකරයි.'},
      {'subjectId': scienceId, 'questionText': 'මෙතිල් ඔරේන්ජ් රතු — pH?', 'option1': '2', 'option2': '7', 'option3': '12', 'option4': '14', 'correctOption': 1, 'explanation': 'pH<4 රතු. pH 2 ආම්ලික.'},
      {'subjectId': scienceId, 'questionText': 'අතිධ්වනිය 4s. ගැඹුර 2880m. ජල ශබ්ද වේගය?', 'option1': '720 ms⁻¹', 'option2': '1440 ms⁻¹', 'option3': '2880 ms⁻¹', 'option4': '3700 ms⁻¹', 'correctOption': 2, 'explanation': '5760/4=1440 ms⁻¹.'},
      {'subjectId': scienceId, 'questionText': 'දහනය, වාතයෙන් ළා, ජලයේ ස්වල්ප ද්‍රාව්‍ය — වායුව?', 'option1': 'හයිඩ්‍රජන්', 'option2': 'නයිට්‍රජන්', 'option3': 'ඔක්සිජන්', 'option4': 'CO₂', 'correctOption': 1, 'explanation': 'H₂ — දාහ්‍ය, ළා, ස්වල්ප ද්‍රාව්‍ය.'},
      {'subjectId': scienceId, 'questionText': 'හෘද ස්පන්දන පාලනය කරන CNS කොටස?', 'option1': 'මස්තිෂ්කය', 'option2': 'අනුමස්තිෂ්කය', 'option3': 'සුෂුම්නාව', 'option4': 'සුෂුම්නා ශීර්ෂකය', 'correctOption': 4, 'explanation': 'Medulla oblongata හෘද ස්පන්දන කේන්ද්‍රය.'},
      {'subjectId': scienceId, 'questionText': 'ප්‍රතිරෝධය: A=V මත, B=දිගට, C=I මත. සත්‍ය?', 'option1': 'A', 'option2': 'B', 'option3': 'A හා B', 'option4': 'A හා C', 'correctOption': 2, 'explanation': 'R=ρL/A. B පමණි සත්‍ය.'},
      {'subjectId': scienceId, 'questionText': 'CaCO₃ 10g මවුල (CaCO₃=100)?', 'option1': '0.01', 'option2': '0.1', 'option3': '1', 'option4': '10', 'correctOption': 2, 'explanation': 'n=10/100=0.1 mol.'},
      {'subjectId': scienceId, 'questionText': 'කාබොහයිඩ්‍රේට ගැන නිවැරදි ප්‍රකාශය?', 'option1': 'සියල්ල ජල ද්‍රාව්‍ය', 'option2': 'සියල්ල ස්ඵටිකරූපී', 'option3': 'C:H:O = 1:2:1', 'option4': 'ග්ලූකෝස් තැනුම් ඒකකය', 'correctOption': 4, 'explanation': 'ග්ලූකෝස් (monosaccharide) මූලික ඒකකය.'},
      {'subjectId': scienceId, 'questionText': 'ඝන ද්‍රවයේ ඉපිලීමට?', 'option1': 'ඝනත්වය ද්‍රවයෙන් අඩු', 'option2': 'ස්කන්ධය = විස්ථාපිත ස්කන්ධය', 'option3': 'බර = විස්ථාපිත ද්‍රව බර', 'option4': 'බර < උඩුකුරු තෙරපුම', 'correctOption': 2, 'explanation': 'ආකිමිඩීස් — ඉපිලෙන විට ස්කන්ධය = විස්ථාපිත ස්කන්ධය.'},
      {'subjectId': scienceId, 'questionText': 'Tt×Tt ප්‍රවේණිදර්ශ හා රූපානුදර්ශ ගණන?', 'option1': '2 සහ 1', 'option2': '3 සහ 2', 'option3': '4 සහ 2', 'option4': '4 සහ 3', 'correctOption': 2, 'explanation': 'TT,Tt,tt=3 ප්‍රවේණිදර්ශ; 2 රූපානුදර්ශ.'},
      {'subjectId': scienceId, 'questionText': 'Fe₂O₃+3CO→2Fe+3CO₂. Fe₂O₃ 1mol → Fe ස්කන්ධය (Fe=56)?', 'option1': '28g', 'option2': '56g', 'option3': '112g', 'option4': '168g', 'correctOption': 3, 'explanation': '2mol×56=112g.'},
      {'subjectId': scienceId, 'questionText': 'පට්ටිකා අඩු වූ විට?', 'option1': 'O₂ පරිවහනය වැඩිවේ', 'option2': 'ප්‍රතිදේහ අඩාල', 'option3': 'රුධිර කැටිගැසීම නොවේ', 'option4': 'හෝමෝන සෙමින්', 'correctOption': 3, 'explanation': 'පට්ටිකා clotting සඳහා.'},
      {'subjectId': scienceId, 'questionText': 'A=උත්ප්‍රේරකය ශීඝ්‍රතාව වැඩිකරයි. B=ප්‍රතික්‍රියාවෙන් සංයුතිය වෙනස්.', 'option1': 'A හා B සත්‍ය', 'option2': 'A සත්‍ය B අසත්‍ය', 'option3': 'A හා B අසත්‍ය', 'option4': 'A අසත්‍ය B සත්‍ය', 'correctOption': 2, 'explanation': 'A සත්‍ය. B අසත්‍ය — නොවෙනස්ව ඉතිරිවේ.'},
      {'subjectId': scienceId, 'questionText': 'බහු අවයවක: A=ඉහළ mol mass, B=monomers ලෙස, C=කෘත්‍රිම/ස්වාභාවික. සත්‍ය?', 'option1': 'A', 'option2': 'B', 'option3': 'A හා C', 'option4': 'B හා C', 'correctOption': 3, 'explanation': 'A,C සත්‍ය. B අසත්‍ය.'},
      {'subjectId': scienceId, 'questionText': 'v-t ප්‍රස්තාර ගැන අසත්‍ය?', 'option1': 'වර්ග ඵලය = විස්ථාපනය', 'option2': 'නිශ්චලතාවෙන් ආරම්භ = (0,0)', 'option3': 'v වෙනස් නම් gradient=0', 'option4': 'gradient = ත්වරණය', 'correctOption': 3, 'explanation': 'v වෙනස් නම් gradient≠0.'},
      {'subjectId': scienceId, 'questionText': 'ඇල්ගී වර්ධනය — සාගර දූෂකය?', 'option1': 'බැර ලෝහ', 'option2': 'සල්ෆේට්', 'option3': 'න්‍යෂ්ටික අපද්‍රව්‍ය', 'option4': 'පොස්පේට්', 'correctOption': 4, 'explanation': 'Phosphates eutrophication ඇති කරයි.'},
      {'subjectId': scienceId, 'questionText': 'වෙරළ ඛාදනය + කුණාටු වැඩිවීමට හේතුව?', 'option1': 'ගෝලීය උණුසුම', 'option2': 'හරිතාගාර ආචරණය', 'option3': 'ඕසෝන් ක්ෂය', 'option4': 'සුපෝෂණය', 'correctOption': 1, 'explanation': 'ගෝලීය උෂ්ණය ↑ → මුහුදු මට්ටම ↑, කුණාටු.'},
    ];

    final batch2 = _db.batch();
    for (var q in scienceQuestions) {
      final ref = _db.collection('subjects').doc(scienceId).collection('questions').doc();
      batch2.set(ref, q);
    }

    final String mathId = subjectIds['Mathematics']!;
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
      final ref = _db.collection('subjects').doc(mathId).collection('questions').doc();
      batch2.set(ref, q);
    }

    await batch2.commit();
  }
}
