import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../pages/Student_dashboard/student_dashboard.dart';
import '../pages/Mentor_dashboard/mentor_dashboard.dart';
import '../screens/welcome_screen.dart';
import '../helper/transition_helper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _circleController;
  late Animation<double> _circleFade;
  late Animation<double> _circleScale;

  late AnimationController _logoController;
  late Animation<Offset> _logoSlide;
  late Animation<double> _logoFade;

  @override
  void initState() {
    super.initState();

    // Circle animation
    _circleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _circleFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _circleController, curve: Curves.easeIn),
    );
    _circleScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _circleController, curve: Curves.easeOutBack),
    );

    // Logo animation
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _logoSlide = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _logoController, curve: Curves.easeOut));
    _logoFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeIn),
    );

    // Start animations
    _circleController.forward().whenComplete(() {
      Future.delayed(const Duration(milliseconds: 400), () {
        _logoController.forward();
      });
    });

    // After delay, check user status and navigate
    Future.delayed(const Duration(seconds: 5), _checkUserStatus);
  }

  Future<void> _checkUserStatus() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      if (mounted) {
        Navigator.pushReplacement(context, createRoute(const WelcomeScreen()));
      }
      return;
    }

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (!userDoc.exists) {
        Navigator.pushReplacement(context, createRoute(const WelcomeScreen()));
        return;
      }

      final role = userDoc['role'];
      if (role == 'student') {
        Navigator.pushReplacement(context, createRoute(const StudentDashboard()));
      } else if (role == 'mentor') {
        Navigator.pushReplacement(context, createRoute(const MentorDashboard()));
      } else {
        Navigator.pushReplacement(context, createRoute(const WelcomeScreen()));
      }
    } catch (e) {
      Navigator.pushReplacement(context, createRoute(const WelcomeScreen()));
    }
  }

  @override
  void dispose() {
    _circleController.dispose();
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple, Colors.indigo],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _circleFade,
            child: ScaleTransition(
              scale: _circleScale,
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: FadeTransition(
                  opacity: _logoFade,
                  child: SlideTransition(
                    position: _logoSlide,
                    child: const Hero(
                      tag: 'logo',
                      child: Image(
                        image: AssetImage('assets/images/logo.png'),
                        height: 150,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
