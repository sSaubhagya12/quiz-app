import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'logic/providers/auth_provider.dart';
import 'logic/providers/subject_provider.dart';
import 'logic/providers/quiz_provider.dart';
import 'ui/screens/login_screen.dart';
import 'ui/screens/signup_screen.dart';

void main() {
  // SQLite Database එක නිවැරදිව Initialize වීම සහතික කිරීම
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(
    // MultiProvider මඟින් ඇප් එක ආරම්භයේදීම අපගේ Providers 3ම ලියාපදිංචි කිරීම
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SubjectProvider()),
        ChangeNotifierProvider(create: (_) => QuizProvider()),
      ],
      child: const EduQuizApp(),
    ),
  );
}

class EduQuizApp extends StatelessWidget {
  const EduQuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'O/L Quiz App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        // සාමාන්‍ය පෙළ සිසුන් කැමති වන අලංකාර වර්ණ පද්ධතියක් (Color Palette)
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E3C72), // Premium Deep Blue වර්ණය
          primary: const Color(0xFF1E3C72),
          secondary: const Color(0xFFF2994A), // Orange Accent වර්ණය
          surface: const Color(0xFFF8F9FA), // Soft grey background
        ),
        // අකුරු (Typography) සැකසීම
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Color(0xFF1E3C72)),
          bodyMedium: TextStyle(fontSize: 16, color: Colors.black87),
        ),
      ),
      // ආරම්භක පිටුව ලෙස Login Page එක හෝ Home Page එක දැක්විය හැක.
      // මෙහිදී, සිසුවා දැනටමත් ලොග් වී ඇත්නම් කෙලින්ම Home Page එකට යාමට සකස් කළ හැක.
      home: const WelcomeOrLoginPage(),
    );
  }
}

// ආරම්භක පිවිසුම් පරීක්ෂක පිටුව
class WelcomeOrLoginPage extends StatelessWidget {
  const WelcomeOrLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    // AuthProvider එක සජීවීව නිරීක්ෂණය කිරීම
    final authProvider = context.watch<AuthProvider>();

    // සිසුවා දැනටමත් ලොග් වී ඇත්නම් කෙලින්ම Home Page එක පෙන්වයි.
    // ලොග් වී නොමැති නම් Login Page එක පෙන්වයි.
    if (authProvider.isAuthenticated) {
      return const Scaffold(
        body: Center(
          child: Text(
            "සාර්ථකව ඇතුළු විය! මෙතැන් සිට Home Screen එක Load වේ.",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.school, size: 100, color: Color(0xFF1E3C72)),
                const SizedBox(height: 20),
                const Text(
                  "EduQuiz O-Level",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1E3C72)),
                ),
                const SizedBox(height: 10),
                const Text(
                  "G.C.E. O/L විභාගය ඉතා ඉහළින් ජය ගැනීමට උදවු වන අත්වැල",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 40),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  },
                  icon: const Icon(Icons.login),
                  label: const Text("Student Login"),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(250, 50),
                    backgroundColor: const Color(0xFF1E3C72),
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 15),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SignupScreen()),
                    );
                  },
                  icon: const Icon(Icons.person_add),
                  label: const Text("Sign Up (ලියාපදිංචි වන්න)"),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(250, 50),
                    side: const BorderSide(color: Color(0xFF1E3C72)),
                    foregroundColor: const Color(0xFF1E3C72),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
