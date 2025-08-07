import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For SystemNavigator.pop
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mentairo/pages/Admin_dashboard/admin_dashboard.dart';
import 'package:mentairo/screens/signup_mentor_screen.dart';
import 'package:mentairo/screens/signup_student_screen.dart';
import 'package:mentairo/helper/transition_helper.dart';
import '../pages/Student_dashboard/student_dashboard.dart';
import '../pages/Mentor_dashboard/mentor_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _loading = false;
  String? _error;
  bool _showPassword = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    if (args != null && args['approved'] == true) {
      Future.microtask(() {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Admin has approved you. You can now log in."),
            backgroundColor: Colors.green,
          ),
        );
      });
    }
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email == 'admin@mentairo.com' && password == 'admin123') {
      Navigator.pushReplacement(context, createRoute(const AdminDashboard()));
      return;
    }

    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Please fill all the fields');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      UserCredential result = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      String uid = result.user!.uid;

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (!userDoc.exists) {
        setState(() => _error = "User record not found.");
        return;
      }

      final role = userDoc['role'];

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login Successfully!"), backgroundColor: Colors.green),
      );

      if (role == 'admin') {
        Navigator.pushReplacement(context, createRoute(const AdminDashboard()));
      } else if (role == 'student') {
        Navigator.pushReplacement(context, createRoute(const StudentDashboard()));
      } else if (role == 'mentor') {
        Navigator.pushReplacement(context, createRoute(const MentorDashboard()));
      } else {
        setState(() => _error = "Unknown user role.");
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _error = e.message ?? "Login failed");
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showRoleSelector() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Continue as", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(context, createRoute(const SignUpStudentScreen()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Icon(Icons.school), SizedBox(width: 10), Text("Student")],
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(context, createRoute(const SignUpMentorScreen()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Icon(Icons.person_outline), SizedBox(width: 10), Text("Mentor")],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _confirmExitApp() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Exit App"),
        content: const Text("Are you sure you want to exit the app?"),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: const Text("Exit"),
            onPressed: () => SystemNavigator.pop(),
          ),
        ],
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _confirmExitApp,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.deepPurple),
            onPressed: _confirmExitApp,
          ),
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: Center(
                child: Opacity(
                  opacity: 0.05,
                  child: Image.asset('assets/images/logo.png', width: 400),
                ),
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text("Welcome to ", style: TextStyle(fontSize: 20, color: Colors.deepPurple, fontWeight: FontWeight.w500)),
                          Text("Mentairo", style: TextStyle(fontSize: 20, color: Colors.deepPurple, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Sign in", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                        Row(
                          children: [
                            const Text("No Account? ", style: TextStyle(color: Colors.black54, fontSize: 14)),
                            GestureDetector(
                              onTap: _showRoleSelector,
                              child: const Text("Sign up", style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    const Text("Enter your email address"),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        hintText: 'Email address',
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text("Enter your Password"),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _passwordController,
                      obscureText: !_showPassword,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        suffixIcon: IconButton(
                          icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility),
                          onPressed: () {
                            setState(() => _showPassword = !_showPassword);
                          },
                        ),
                      ),
                    ),
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(_error!, style: const TextStyle(color: Colors.red)),
                      ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _loading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple[700],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: _loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Sign in"),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
