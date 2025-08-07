import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../firestore_chat/chat_screen.dart';

class MentorChatPage extends StatefulWidget {
  final String? studentId;
  final String? studentName;

  const MentorChatPage({super.key, this.studentId, this.studentName});

  @override
  State<MentorChatPage> createState() => _MentorChatPageState();
}

class _MentorChatPageState extends State<MentorChatPage> {
  String mentorName = 'Mentor';
  final String mentorId = FirebaseAuth.instance.currentUser!.uid;
  final Map<String, String> _studentNameCache = {};

  @override
  void initState() {
    super.initState();
    _fetchMentorName();
  }

  Future<void> _fetchMentorName() async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(mentorId).get();
    if (doc.exists && doc.data()!.containsKey('fullName')) {
      setState(() {
        mentorName = doc['fullName'];
      });
    }
  }

  Future<String> _getStudentName(String studentId) async {
    if (_studentNameCache.containsKey(studentId)) {
      return _studentNameCache[studentId]!;
    }
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(studentId).get();
      if (doc.exists && doc.data()!.containsKey('fullName')) {
        final name = doc['fullName'];
        _studentNameCache[studentId] = name;
        return name;
      }
    } catch (_) {}
    return 'Student';
  }

  @override
  Widget build(BuildContext context) {
    if (widget.studentId != null && widget.studentName != null) {
      return ChatScreen(
        mentorId: mentorId,
        mentorName: mentorName,
        studentId: widget.studentId!,
        studentName: widget.studentName!,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Chats", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.deepPurple,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collectionGroup('messages')
            .where('mentorId', isEqualTo: mentorId)
            .where('timestamp', isNotEqualTo: null)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No messages yet."));
          }

          final messages = snapshot.data!.docs;
          final Map<String, Map<String, dynamic>> latestByStudent = {};
          final Map<String, int> unreadCountByStudent = {};

          for (var doc in messages) {
            final data = doc.data() as Map<String, dynamic>;
            final studentId = data['studentId'];
            final isRead = data['isRead'] ?? false;
            final isFromStudent = data['senderId'] == studentId;

            if (!latestByStudent.containsKey(studentId)) {
              latestByStudent[studentId] = data;
            }

            if (!isRead && isFromStudent) {
              unreadCountByStudent[studentId] = (unreadCountByStudent[studentId] ?? 0) + 1;
            }
          }

          final studentIds = latestByStudent.keys.toList();

          return FutureBuilder<List<String>>(
            future: Future.wait(studentIds.map(_getStudentName)),
            builder: (context, nameSnapshot) {
              if (!nameSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final studentNames = nameSnapshot.data!;

              return ListView.builder(
                itemCount: studentIds.length,
                itemBuilder: (context, index) {
                  final studentId = studentIds[index];
                  final data = latestByStudent[studentId]!;
                  final studentName = studentNames[index];
                  final lastMessage = data['text'] ?? '';
                  final unreadCount = unreadCountByStudent[studentId] ?? 0;

                  return ListTile(
                    leading: const Icon(Icons.person, color: Colors.deepPurple),
                    title: Text(studentName),
                    subtitle: Text(
                      lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: unreadCount > 0
                        ? CircleAvatar(
                      backgroundColor: Colors.red,
                      radius: 10,
                      child: Text(
                        '$unreadCount',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    )
                        : const Icon(Icons.chat_bubble_outline),
                    onTap: () {
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
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
