import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mentairo/pages/Student_dashboard/student_chat_page.dart';
import 'package:mentairo/pages/Student_dashboard/student_profile.dart';
import 'package:mentairo/pages/Student_dashboard/search_page.dart';
import 'package:mentairo/pages/Student_dashboard/session_page.dart';
import 'package:mentairo/pages/Student_dashboard/posts_by_mentor.dart';
import 'package:mentairo/pages/Admin_dashboard/success_stories_page.dart';
import 'notification_page.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  int _selectedPageIndex = 0;
  String userName = "Guest";
  String role = "Student";

  final List<Widget> _pages = [
    const SuccessStoriesPage(),
    const SessionPage(),
    const StudentChatPage(),
  ];

  final List<String> _pageTitles = [
    'Home',
    'Sessions',
    'Chat',
  ];

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  void _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        setState(() {
          userName = doc['fullName'] ?? "Student";
        });
      }
    }
  }

  void _selectDrawerPage(Widget page, String title) {
    Navigator.pop(context);
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (_, __, ___) => Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.deepPurple,
            elevation: 4,
            iconTheme: const IconThemeData(color: Colors.white),
            title: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
          body: page,
        ),
        transitionsBuilder: (_, animation, __, child) {
          const begin = Offset(1.0, 0.0); // slide in from right
          const end = Offset.zero;
          final tween = Tween(begin: begin, end: end);
          final offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FF),
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        elevation: 4,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          _pageTitles[_selectedPageIndex],
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => const NotificationPage(),
                  transitionsBuilder: (_, animation, __, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  transitionDuration: const Duration(milliseconds: 300),
                ),
              );
            },

          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.deepPurple),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.account_circle, size: 50, color: Colors.white),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          role,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.search),
              title: const Text('Search'),
              onTap: () => _selectDrawerPage(const SearchPage(), 'Search'),
            ),
            ListTile(
              leading: const Icon(Icons.feed),
              title: const Text('Posts'),
              onTap: () => _selectDrawerPage(const PostsPage(), 'Posts'),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () => _selectDrawerPage(const StudentProfile(), 'Profile'),
            ),
            const Divider(),
            FirebaseAuth.instance.currentUser == null
                ? ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Exit Guest Mode'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/welcome');
              },
            )
                : ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Log Out'),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/welcome');
              },
            ),
          ],
        ),
      ),
      body: _pages[_selectedPageIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedPageIndex,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _selectedPageIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'Sessions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
        ],
      ),
    );
  }
}
