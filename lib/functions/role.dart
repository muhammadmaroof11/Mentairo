import 'package:flutter/material.dart';
import 'package:mentairo/screens/signup_student_screen.dart';
import '../screens/login_screen.dart';
import '../screens/signup_mentor_screen.dart';
import '../helper/transition_helper.dart';

void showRoleSelector(BuildContext context, bool isLogin) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isLogin ? 'Login As' : 'Sign Up As',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
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
                Navigator.push(
                  context,
                  createRoute(isLogin
                      ? const LoginScreen()
                      : const SignUpStudentScreen()),
                );
              },
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.person_outline),
              label: const Text("Mentor"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  createRoute(isLogin
                      ? const LoginScreen()
                      : const SignUpMentorScreen()),
                );
              },
            ),
          ],
        ),
      );
    },
  );
}
