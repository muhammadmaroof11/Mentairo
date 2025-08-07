import 'dart:io';

import 'package:flutter/material.dart';
class PostCard extends StatelessWidget {
  final String mentorName;
  final String title;
  final String description;
  final String time;
  final VoidCallback onBook;
  final VoidCallback onMessage;
  final String? localPhotoPath; // 🔹 Add this line

  const PostCard({
    super.key,
    required this.mentorName,
    required this.title,
    required this.description,
    required this.time,
    required this.onBook,
    required this.onMessage,
    this.localPhotoPath, // 🔹 Add this
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: localPhotoPath != null
                      ? FileImage(File(localPhotoPath!))
                      : null,
                  backgroundColor: Colors.deepPurple.shade100,
                  child: localPhotoPath == null
                      ? const Icon(Icons.person, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: onMessage,
                  child: Text(
                    mentorName,
                    style: const TextStyle(
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(description),
            const SizedBox(height: 8),
            Text(time, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: onBook,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
              child: const Text('Book Session'),
            ),
          ],
        ),
      ),
    );
  }
}
