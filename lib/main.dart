import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mentairo/pages/Admin_dashboard/admin_dashboard.dart';
import 'package:mentairo/pages/Mentor_dashboard/add_post_screen.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mentairo/pages/Mentor_dashboard/booked_sessions.dart';
import 'package:mentairo/pages/Mentor_dashboard/mentor_chat_page.dart';
import 'package:mentairo/pages/Mentor_dashboard/mentor_profile.dart';
import 'package:mentairo/screens/splash_screen.dart';
import 'backend/upload_ques_once.dart';
import 'screens/login_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/signup_student_screen.dart';
import 'screens/signup_mentor_screen.dart';
import 'pages/Student_dashboard/student_dashboard.dart';
import 'pages/Mentor_dashboard/mentor_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await initializeDateFormatting();
  runApp(const MentairoApp());
}

class MentairoApp extends StatelessWidget {
  const MentairoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mentairo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Montserrat',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.deepPurple),
          bodyMedium: TextStyle(fontSize: 16, color: Colors.black87),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
            minimumSize: const Size(double.infinity, 55),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
      home: Stack(
        children: const [
          SplashScreen(),         // 👈 your actual entry point
          UploadQuestionsOnce(), // 👈 runs silently in background
        ],
      ),
      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup_student': (context) => const SignUpStudentScreen(),
        '/signup_mentor': (context) => const SignUpMentorScreen(),
        '/student_dashboard': (context) => const StudentDashboard(),
        '/mentor_dashboard': (context) => const MentorDashboard(),
        '/add_post': (context) => const AddPost(),
        '/booked_sessions': (context) => const BookedSessions(),
        '/chat': (context) => const MentorChatPage(),
        '/edit_profile': (context) => const MentorProfile(),
        '/mentor_profile': (context) => MentorProfile(),
        '/admin_dashboard': (context) => const AdminDashboard()
      },
    );
  }
}
