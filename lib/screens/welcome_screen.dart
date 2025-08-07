import 'package:flutter/material.dart';
import 'package:mentairo/pages/Student_dashboard/student_dashboard.dart';
import 'login_screen.dart';
import 'signup_student_screen.dart';
import 'signup_mentor_screen.dart';
import '../helper/transition_helper.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Image(
              image: AssetImage('assets/images/logo.png'),
              height: 150,
            ),
            const SizedBox(height: 20),
            const Text(
              "Mentairo",
              style: TextStyle(
                color: Colors.deepPurple,
                fontWeight: FontWeight.bold,
                fontSize: 26,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Your Partner in Academic Excellence",
              style: TextStyle(color: Colors.deepPurple),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(context, createRoute(const LoginScreen()));
              },
              child: const Text('Login'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                _showRoleSelector(context);
              },
              child: const Text('Sign Up'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.deepPurple,
                side: const BorderSide(color: Colors.deepPurple),
                minimumSize: const Size(double.infinity, 50),
              ),
            ),

            const SizedBox(height: 20),
            // TextButton(
            //   onPressed: () {
            //     Navigator.pushReplacement(
            //       context,
            //       createRoute(const StudentDashboard()),
            //     );
            //   },
            //   child: const Text('Continue Without Login'),
            // ),
          ],
        ),
      ),
    );
  }

  void _showRoleSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Sign Up As',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.school),
              label: const Text("Student"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(context, createRoute(const SignUpStudentScreen()));
              },
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.person),
              label: const Text("Mentor"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(context, createRoute(const SignUpMentorScreen()));
              },
            ),
          ],
        ),
      ),
    );
  }
}
