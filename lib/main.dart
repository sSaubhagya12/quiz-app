import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'logic/providers/auth_provider.dart';
import 'logic/providers/subject_provider.dart';
import 'logic/providers/quiz_provider.dart';
import 'logic/providers/settings_provider.dart';
import 'logic/providers/theme_provider.dart';
import 'ui/screens/login_screen.dart';
import 'ui/screens/home_screen.dart';
import 'ui/screens/signup_screen.dart';





void main() async {
  // Firebase Initialize කිරීම
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    // MultiProvider මඟින් ඇප් එක ආරම්භයේදීම Providers ලියාපදිංචි කිරීම
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SubjectProvider()),
        ChangeNotifierProvider(create: (_) => QuizProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: const EduQuizApp(),
    ),
  );
}

class EduQuizApp extends StatelessWidget {
  const EduQuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    return MaterialApp(
      title: 'O/L Quiz App',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E3C72),
          primary: const Color(0xFF1E3C72),
          secondary: const Color(0xFFF2994A),
          surface: const Color(0xFFF8F9FA),
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Color(0xFF1E3C72)),
          bodyMedium: TextStyle(fontSize: 16, color: Colors.black87),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.dark,
          seedColor: const Color(0xFF1E3C72),
          primary: const Color(0xFF1E3C72),
          secondary: const Color(0xFFF2994A),
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white),
          bodyMedium: TextStyle(fontSize: 16, color: Colors.white70),
        ),
      ),
      home: const WelcomeOrLoginPage(),
    );
  }
}

// ආරම්භක පිවිසුම් පරීක්ෂක පිටුව
class WelcomeOrLoginPage extends StatelessWidget {
  const WelcomeOrLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    // AuthProvider නිරීක්ෂණය - authenticated නම් HomeScreen, නැත්නම් Welcome
    final authProvider = context.watch<AuthProvider>();

    if (authProvider.isAuthenticated) {
      return const HomeScreen();
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
