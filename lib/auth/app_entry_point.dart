import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../screens/splash_screen.dart';
import '../screens/welcome_screen.dart';
import '../pages/Student_dashboard/student_dashboard.dart';
import '../pages/Mentor_dashboard/mentor_dashboard.dart';

class AppEntryPoint extends StatelessWidget {
  const AppEntryPoint({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        } else if (!authSnapshot.hasData) {
          return const WelcomeScreen();
        } else {
          final uid = authSnapshot.data!.uid;

          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
            builder: (context, userSnapshot) {
              if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                return const WelcomeScreen();
              }

              final role = userSnapshot.data!['role'];
              if (role == 'student') return const StudentDashboard();
              if (role == 'mentor') return const MentorDashboard();
              return const WelcomeScreen();
            },
          );
        }
      },
    );
  }
}