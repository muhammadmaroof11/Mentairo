// StudentChatPage.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../firestore_chat/chat_screen.dart';

class StudentChatPage extends StatelessWidget {
  const StudentChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    final studentId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collectionGroup('messages')
            .where('studentId', isEqualTo: studentId)
            .where('timestamp', isNotEqualTo: null)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No messages yet."));
          }

          final messages = snapshot.data!.docs;
          final Map<String, Map<String, dynamic>> latestByMentor = {};
          final Map<String, int> unreadCountByMentor = {};

          for (var doc in messages) {
            final data = doc.data() as Map<String, dynamic>;
            final mentorId = data['mentorId'];
            final isRead = data['isRead'] ?? false;
            final isFromMentor = data['senderId'] == mentorId;

            if (!latestByMentor.containsKey(mentorId)) {
              latestByMentor[mentorId] = data;
            }

            if (!isRead && isFromMentor) {
              unreadCountByMentor[mentorId] = (unreadCountByMentor[mentorId] ?? 0) + 1;
            }
          }

          return ListView(
            children: latestByMentor.entries.map((entry) {
              final data = entry.value;
              final mentorId = entry.key;
              final mentorName = data['mentorName'] ?? 'Mentor';
              final lastMessage = data['text'] ?? '';
              final unreadCount = unreadCountByMentor[mentorId] ?? 0;

              return ListTile(
                leading: const Icon(Icons.person, color: Colors.deepPurple),
                title: Text(mentorName),
                subtitle: Text(
                  lastMessage,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: unreadCount > 0
                    ? CircleAvatar(
                  backgroundColor: Colors.red,
                  radius: 10,
                  child: Text('$unreadCount', style: const TextStyle(color: Colors.white, fontSize: 12)),
                )
                    : const Icon(Icons.chat_bubble_outline),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(
                        mentorId: mentorId,
                        studentId: studentId,
                        studentName: FirebaseAuth.instance.currentUser!.displayName ?? 'Student',
                        mentorName: mentorName,
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
