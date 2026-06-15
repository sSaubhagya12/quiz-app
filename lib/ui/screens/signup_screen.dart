import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../logic/providers/auth_provider.dart';
import '../../data/models/student_model.dart';
import 'home_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _schoolController = TextEditingController();
  final _gradeController = TextEditingController();
  final _yearController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _schoolController.dispose();
    _gradeController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  void _handleSignup() async {
    final authProvider = context.read<AuthProvider>();
    
    int oLevelYear = 2024;
    try {
      oLevelYear = int.parse(_yearController.text);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("O/L Year must be a valid number!")),
      );
      return;
    }

    final newStudent = StudentModel(
      name: _nameController.text,
      email: _emailController.text,
      school: _schoolController.text,
      grade: _gradeController.text,
      oLevelYear: oLevelYear,
    );

    final success = await authProvider.register(newStudent, _passwordController.text);
    
    if (success) {
      if (mounted) {
        // Clear entire stack and go to HomeScreen
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      }
    } else {
      if (mounted && authProvider.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Registration", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1E3C72),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.person_add, size: 80, color: Color(0xFF1E3C72)),
                const SizedBox(height: 20),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: "Full Name", border: OutlineInputBorder(), prefixIcon: Icon(Icons.person)),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: "Email", border: OutlineInputBorder(), prefixIcon: Icon(Icons.email)),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: "Password (Min 8 characters)", border: OutlineInputBorder(), prefixIcon: Icon(Icons.lock)),
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _schoolController,
                  decoration: const InputDecoration(labelText: "School", border: OutlineInputBorder(), prefixIcon: Icon(Icons.school)),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _gradeController,
                        decoration: const InputDecoration(labelText: "Grade", border: OutlineInputBorder(), prefixIcon: Icon(Icons.grade)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _yearController,
                        decoration: const InputDecoration(labelText: "O/L Year", border: OutlineInputBorder(), prefixIcon: Icon(Icons.calendar_today)),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                authProvider.isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _handleSignup,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          backgroundColor: const Color(0xFF1E3C72),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text("Sign Up", style: TextStyle(fontSize: 18)),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
