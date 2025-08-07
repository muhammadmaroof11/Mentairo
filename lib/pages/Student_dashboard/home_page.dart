import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  List<DocumentSnapshot> _stories = [];

  @override
  void initState() {
    super.initState();
    _fetchStories();
  }

  void _fetchStories() {
    FirebaseFirestore.instance
        .collection('success_stories')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      if (_stories.isEmpty) {
        _stories = snapshot.docs;
        for (var i = 0; i < _stories.length; i++) {
          _listKey.currentState?.insertItem(i);
        }
      } else {
        // handle updates (for a real-time app)
        setState(() {
          _stories = snapshot.docs;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
          return const Scaffold(
            body: Center(child: Text('User data not found.')),
          );
        }

        final userData = userSnapshot.data!.data() as Map<String, dynamic>;
        final fullName = userData['fullName'] ?? 'User';

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.deepPurple,
                expandedHeight: 160,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text('Hi $fullName 👋'),
                  background: Container(
                    color: Colors.deepPurple,
                    padding: const EdgeInsets.only(top: 50, left: 20, right: 20),
                    alignment: Alignment.bottomLeft,
                    child: const Text(
                      'Check out how students are succeeding with mentorship.',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ),
                ),
              ),

              // Section Title
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Row(
                    children: const [
                      Icon(Icons.star, color: Colors.deepPurple),
                      SizedBox(width: 8),
                      Text(
                        'Success Stories',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Animated List of Stories
              SliverToBoxAdapter(
                child: AnimatedList(
                  key: _listKey,
                  shrinkWrap: true,
                  initialItemCount: _stories.length,
                  physics: const NeverScrollableScrollPhysics(), // scrolling handled by CustomScrollView
                  itemBuilder: (context, index, animation) {
                    final doc = _stories[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
                    final formattedDate = createdAt != null
                        ? DateFormat('MMMM d, y').format(createdAt)
                        : '';

                    return SizeTransition(
                      sizeFactor: animation,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        child: Material(
                          elevation: 3,
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data['studentName'] ?? 'A student',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.deepPurple,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  data['story'] ?? 'No story provided.',
                                  style: const TextStyle(fontSize: 15),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '- Mentored by ${data['mentorName'] ?? 'Unknown'}',
                                  style: const TextStyle(
                                    fontStyle: FontStyle.italic,
                                    color: Colors.black54,
                                  ),
                                ),
                                if (formattedDate.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Text(
                                      formattedDate,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 60)),
            ],
          ),
        );
      },
    );
  }
}
