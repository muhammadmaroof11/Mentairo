// success_stories_page.dart
import 'package:flutter/material.dart';
import '../../widgets/section_header.dart';

class SuccessStoriesPage extends StatelessWidget {
  const SuccessStoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> staticStories = [
      {
        'studentName': 'Fatima Malik',
        'story': 'Fatima landed a UI/UX internship at Google after receiving guidance from her mentor.',
        'mentorName': 'Mr. Khalid',
      },
      {
        'studentName': 'Zubair Khan',
        'story': 'Zubair launched his first mobile app within 3 months of mentorship.',
        'mentorName': 'Ms. Ayesha',
      },
      {
        'studentName': 'Amina Tariq',
        'story': 'Amina got accepted into her dream university in Canada with the help of personalized mentorship.',
        'mentorName': 'Dr. Rehman',
      },
      {
        'studentName': 'Bilal Asif',
        'story': 'Bilal started his freelance graphic design career after a 6-week design mentorship.',
        'mentorName': 'Sir Noman',
      },
      {
        'studentName': 'Hira Shah',
        'story': 'Hira won a national science fair after deep research mentorship.',
        'mentorName': 'Professor Naeem',
      },
      {
        'studentName': 'Ali Murtaza',
        'story': 'Ali improved his communication skills and cracked his first job interview.',
        'mentorName': 'Ms. Tehmina',
      },
      {
        'studentName': 'Sana Javed',
        'story': 'Sana became a certified frontend developer through a mentor-led program.',
        'mentorName': 'Engineer Faraz',
      },
    ];

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        children: [
          const Text(
            '🎉 Success Stories',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'See how mentorship is changing lives.',
            style: TextStyle(fontSize: 16, color: Colors.black87),
          ),
          const SizedBox(height: 24),
          SectionHeader('Stories'),
          const SizedBox(height: 12),

          // Enhanced Static Stories Cards
          ...staticStories.map((data) {
            return Container(
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFEDE7F6), Color(0xFFFFFFFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['studentName']!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Divider(color: Colors.deepPurple, thickness: 1),
                    const SizedBox(height: 10),
                    Text(
                      data['story']!,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.4,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '- Mentored by ${data['mentorName']!}',
                      style: const TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
