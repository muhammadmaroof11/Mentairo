import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mentairo/pages/Mentor_dashboard/booked_sessions.dart';
import 'package:mentairo/pages/Mentor_dashboard/mentor_chat_page.dart';
import 'package:mentairo/pages/Mentor_dashboard/mentor_profile.dart';
import 'package:mentairo/pages/Mentor_dashboard/mentor_req_page.dart';
import '../../helper/transition_helper.dart';

class MentorDashboard extends StatelessWidget {
  const MentorDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text(
          "Mentor Dashboard",
          style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            tooltip: 'Profile',
            onPressed: () => Navigator.push(context, createRoute(const MentorProfile())),
          ),
        ],
      ),
      drawer: _buildDrawer(context, uid),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        onPressed: () => Navigator.pushNamed(context, '/add_post'),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatsRow(uid),
            const SizedBox(height: 16),
            _buildTipsCard(),
            const SizedBox(height: 16),
            _buildRecentSessions(uid),
            const SizedBox(height: 16),
            _buildPostSection(uid),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, String uid) {
    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topRight: Radius.circular(24), bottomRight: Radius.circular(24)),
      ),
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.deepPurple),
            child: FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance
                  .collection('mentors')
                  .where('uid', isEqualTo: uid)
                  .limit(1)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Colors.white));
                }

                final docs = snapshot.data?.docs;
                final data = docs != null && docs.isNotEmpty
                    ? docs.first.data() as Map<String, dynamic>
                    : null;

                return Row(
                  children: [
                    const Icon(Icons.account_circle, size: 50, color: Colors.white),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data?['fullName'] ?? 'Mentor',
                            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            data?['role'] ?? 'Mentor',
                            style: const TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("Profile"),
            onTap: () => Navigator.push(context, createRoute(const MentorProfile())),
          ),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text("Booked Sessions"),
            onTap: () => Navigator.push(context, createRoute(const BookedSessions())),
          ),
          ListTile(
            leading: const Icon(Icons.chat),
            title: const Text("Chat"),
            onTap: () => Navigator.push(context, createRoute(const MentorChatPage())),
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Requests"),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('session_requests')
                      .where('mentorId', isEqualTo: uid)
                      .where('isRead', isEqualTo: false)
                      .snapshots(),
                  builder: (context, snapshot) {
                    int unread = snapshot.data?.docs.length ?? 0;
                    if (unread == 0) return const SizedBox.shrink();
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12)),
                      child: Text('$unread', style: const TextStyle(color: Colors.white, fontSize: 12)),
                    );
                  },
                ),
              ],
            ),
            onTap: () => Navigator.push(context, createRoute(const MentorRequestsPage())),
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout", style: TextStyle(color: Colors.red)),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(String uid) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('posts').where('mentorId', isEqualTo: uid).snapshots(),
          builder: (context, snapshot) {
            int count = snapshot.hasData ? snapshot.data!.docs.length : 0;
            return _buildStatCard("Posts", count);
          },
        ),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('session_requests').where('mentorId', isEqualTo: uid).snapshots(),
          builder: (context, snapshot) {
            int count = snapshot.hasData ? snapshot.data!.docs.length : 0;
            return _buildStatCard("Requests", count);
          },
        ),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('bookings').where('mentorId', isEqualTo: uid).snapshots(),
          builder: (context, snapshot) {
            int count = snapshot.hasData ? snapshot.data!.docs.length : 0;
            return _buildStatCard("Sessions", count);
          },
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, int count) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text('$count', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildTipsCard() {
    return Card(
      color: Colors.amber.shade100,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: const ListTile(
        leading: Icon(Icons.lightbulb, color: Colors.deepPurple),
        title: Text("Tip of the Day"),
        subtitle: Text("Respond to requests quickly to increase visibility!"),
      ),
    );
  }

  Widget _buildRecentSessions(String uid) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('bookings')
          .where('mentorId', isEqualTo: uid)
          .orderBy('timestamp', descending: true)
          .limit(5)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const SizedBox.shrink();
        final sessions = snapshot.data!.docs;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Recent Sessions", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: sessions.length,
                itemBuilder: (context, index) {
                  final session = sessions[index];
                  return Card(
                    margin: const EdgeInsets.only(right: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(session['studentName'], style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text(session['date']),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPostSection(String uid) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .where('mentorId', isEqualTo: uid)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No posts yet"));
        }

        final posts = snapshot.data!.docs;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Your Posts", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ListView.builder(
              itemCount: posts.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final post = posts[index];
                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    title: Text(post['title'], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                    subtitle: Text(post['description']),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          _showEditDialog(context, post);
                        } else if (value == 'delete') {
                          _deletePost(post.id, context);
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(value: 'edit', child: Text('Edit')),
                        PopupMenuItem(value: 'delete', child: Text('Delete')),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _showEditDialog(BuildContext context, DocumentSnapshot post) {
    final titleController = TextEditingController(text: post['title'] ?? '');
    final descController = TextEditingController(text: post['description'] ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Post'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Title')),
            const SizedBox(height: 8),
            TextField(controller: descController, decoration: const InputDecoration(labelText: 'Description')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('posts').doc(post.id).update({
                'title': titleController.text.trim(),
                'description': descController.text.trim(),
              });
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _deletePost(String postId, BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Post"),
        content: const Text("Are you sure you want to delete this post?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete")),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance.collection('posts').doc(postId).delete();
    }
  }
}
