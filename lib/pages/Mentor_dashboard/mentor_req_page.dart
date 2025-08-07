import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MentorRequestsPage extends StatelessWidget {
  const MentorRequestsPage({super.key});

  String _formatTime(dynamic value) {
    if (value is Timestamp) {
      final dateTime = value.toDate();
      return "${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}";
    } else if (value is String && value.trim().isNotEmpty) {
      return value;
    } else {
      return "Not specified";
    }
  }

  Future<void> sendNotification({
    required String userId,
    required String title,
    required String message,
  }) async {
    await FirebaseFirestore.instance.collection('notifications').add({
      'userId': userId,
      'title': title,
      'message': message,
      'timestamp': Timestamp.now(),
    });
  }

  Future<void> _showRejectionDialog(
      BuildContext context,
      DocumentReference reqRef,
      String studentId,
      String title,
      ) async {
    String reason = '';
    final TextEditingController controller = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Reason for Rejection"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Enter reason..."),
          onChanged: (val) => reason = val,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              if (reason.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Please enter a reason."),
                  backgroundColor: Colors.orange,
                ));
                return;
              }

              Navigator.of(ctx).pop();

              await reqRef.delete();

              await sendNotification(
                userId: studentId,
                title: "Session Rejected",
                message: "Your session '$title' was rejected. Reason: $reason",
              );

              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text("Session rejected."),
                backgroundColor: Colors.red,
              ));
            },
            child: const Text("Reject", style: TextStyle(color: Colors.white),),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Session Requests", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('session_requests')
            .where('mentorId', isEqualTo: uid)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No requests yet."));
          }

          final requests = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final req = requests[index];
              final data = req.data() as Map<String, dynamic>;

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                width: double.infinity,
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(data['studentName'] ?? 'Unknown',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text("📘 Title: ${data['title'] ?? 'No title'}"),
                        const SizedBox(height: 4),
                        Text("📝 Description: ${data['description'] ?? 'No description'}"),
                        const SizedBox(height: 4),
                        Text("🕒 Preferred Time: ${_formatTime(data['preferredTime'])}"),
                        const SizedBox(height: 4),
                        Text("⏳ Status: ${data['status'] ?? 'pending'}"),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: () => _showRejectionDialog(
                                  context,
                                  req.reference,
                                  data['studentId'],
                                  data['title'] ?? 'your session',
                                ),
                                child: const Text("Reject", style: TextStyle(color: Colors.red)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  final sessionId =
                                      "${data['studentId']}_${data['mentorId']}_${DateTime.now().millisecondsSinceEpoch}";
                                  final channelName = "session_$sessionId";

                                  await FirebaseFirestore.instance.collection('sessions').add({
                                    'sessionId': sessionId,
                                    'channelName': channelName,
                                    'studentId': data['studentId'],
                                    'mentorId': data['mentorId'],
                                    'studentName': data['studentName'],
                                    'mentorName': data['mentorName'],
                                    'title': data['title'],
                                    'description': data['description'],
                                    'preferredTime': data['preferredTime'],
                                    'status': 'confirmed',
                                    'createdAt': Timestamp.now(),
                                  });

                                  await sendNotification(
                                    userId: data['studentId'],
                                    title: "Session Confirmed",
                                    message: "Your session '${data['title']}' has been confirmed.",
                                  );

                                  await req.reference.delete();

                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                    content: Text("Session confirmed."),
                                    backgroundColor: Colors.green,
                                  ));
                                },
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                                child: const Text("Confirm", style: TextStyle(color: Colors.white)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
