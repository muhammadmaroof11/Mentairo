// posts_page.dart
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../widgets/post_card.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/section_header.dart';
import '../../firestore_chat/chat_screen.dart';
import '../../helper/transition_helper.dart';

class PostsPage extends StatefulWidget {
  const PostsPage({super.key});

  @override
  State<PostsPage> createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage> {
  String selectedCategory = 'All';
  List<String> categories = [
    'All',
    'Computer Science',
    'Engineering',
    'Business',
    'Medical',
    'Design'
  ];

  String _formatTimestamp(Timestamp timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp.toDate());
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hrs ago';
    return '${diff.inDays} days ago';
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        children: [
          SectionHeader('Categories'),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: categories.map((category) {
                return CategoryChip(
                  label: category,
                  isSelected: selectedCategory == category,
                  onTap: () {
                    setState(() {
                      selectedCategory = category;
                    });
                  },
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 32),
          SectionHeader('Recent Posts'),
          const SizedBox(height: 12),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('posts')
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Text('No posts available.');
              }

              final filtered = snapshot.data!.docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final category = data['category'] ?? 'All';
                return selectedCategory == 'All' || category == selectedCategory;
              }).toList();

              if (filtered.isEmpty) {
                return const Text('No posts found for this category.');
              }

              return Column(
                children: filtered.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final mentorId = data['mentorId'];
                  final mentorName = data['mentorName'] ?? 'Mentor';

                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('mentors')
                        .doc(mentorId)
                        .get(),
                    builder: (context, snapshot) {
                      String? localPhotoPath;
                      if (snapshot.hasData && snapshot.data!.exists) {
                        final mentorData =
                        snapshot.data!.data() as Map<String, dynamic>;
                        localPhotoPath = mentorData['localPhotoPath'];
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: PostCard(
                          mentorName: mentorName,
                          title: data['title'] ?? 'No Title',
                          description: data['description'] ?? 'No Description',
                          time: data['createdAt'] != null
                              ? _formatTimestamp(data['createdAt'] as Timestamp)
                              : 'Unknown time',
                          onBook: () {
                            final TextEditingController timeController =
                            TextEditingController();

                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text("Book Session"),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                        "Enter your preferred session time:"),
                                    const SizedBox(height: 10),
                                    TextField(
                                      controller: timeController,
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        labelText: 'e.g., 3:00 PM on Monday',
                                      ),
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: const Text("Cancel"),
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      final preferredTime =
                                      timeController.text.trim();
                                      if (preferredTime.isEmpty) return;

                                      Navigator.pop(ctx);

                                      final studentId = FirebaseAuth
                                          .instance.currentUser!.uid;
                                      final userSnap = await FirebaseFirestore
                                          .instance
                                          .collection('users')
                                          .doc(studentId)
                                          .get();
                                      final fullName = userSnap['fullName'];

                                      final chatId = "${studentId}_$mentorId";
                                      final requestId =
                                          "${studentId}_${mentorId}_${DateTime.now().millisecondsSinceEpoch}";

                                      final existing = await FirebaseFirestore
                                          .instance
                                          .collection('sessions')
                                          .where('studentId',
                                          isEqualTo: studentId)
                                          .where('mentorId',
                                          isEqualTo: mentorId)
                                          .get();

                                      if (existing.docs.isNotEmpty) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                "You already have a session confirmed with this mentor."),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                        return;
                                      }

                                      await FirebaseFirestore.instance
                                          .collection('session_requests')
                                          .doc(requestId)
                                          .set({
                                        'studentId': studentId,
                                        'mentorId': mentorId,
                                        'mentorName': mentorName,
                                        'studentName': fullName,
                                        'title': data['title'],
                                        'description': data['description'],
                                        'preferredTime': preferredTime,
                                        'createdAt': Timestamp.now(),
                                        'status': 'pending',
                                        'isRead': false,
                                      });

                                      await FirebaseFirestore.instance
                                          .collection('chats')
                                          .doc(chatId)
                                          .collection('messages')
                                          .add({
                                        'text':
                                        "Hi, I'm interested in '${data['title']}' and prefer $preferredTime.",
                                        'mentorId': mentorId,
                                        'studentId': studentId,
                                        'studentName': fullName,
                                        'mentorName': mentorName,
                                        'senderId': studentId,
                                        'isRead': false,
                                        'timestamp': Timestamp.now(),
                                      });

                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content:
                                          Text("Request sent successfully."),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    },
                                    child: const Text("Send Request"),
                                  ),
                                ],
                              ),
                            );
                          },
                          onMessage: () {
                            showModalBottomSheet(
                              context: context,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(16)),
                              ),
                              builder: (ctx) => Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('Message $mentorName',
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 16),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(ctx);
                                        Navigator.push(
                                          context,
                                          createRoute(ChatScreen(
                                            mentorId: mentorId,
                                            studentId: uid,
                                            studentName: '',
                                            mentorName: mentorName,
                                          )),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.deepPurple,
                                        foregroundColor: Colors.white,
                                      ),
                                      child: const Text('Send a Message'),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          localPhotoPath: localPhotoPath,
                        ),
                      );
                    },
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
