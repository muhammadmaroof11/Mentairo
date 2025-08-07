import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../firestore_chat/chat_screen.dart';

class MentorProfileView extends StatelessWidget {
  final String mentorId;
  final String mentorName;
  final String? localImagePath;
  final String bio;
  final List<String> skills;

  const MentorProfileView({
    super.key,
    required this.mentorId,
    required this.mentorName,
    required this.localImagePath,
    required this.bio,
    required this.skills,
  });

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser!;
    final studentId = currentUser.uid;
    final studentName = currentUser.displayName ?? "Student";

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text('Mentor Profile', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: localImagePath != null && File(localImagePath!).existsSync()
                  ? FileImage(File(localImagePath!))
                  : const AssetImage('assets/images/default_profile.jpeg') as ImageProvider,
            ),
            const SizedBox(height: 16),
            Text(
              mentorName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (bio.isNotEmpty)
              Text(
                bio,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, color: Colors.black87),
              )
            else
              const Text("No bio provided.", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: skills.map((skill) => Chip(label: Text(skill))).toList(),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                            mentorId: mentorId,
                            mentorName: mentorName,
                            studentId: studentId,
                            studentName: studentName,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.message, color: Colors.white),
                    label: const Text('Message', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
