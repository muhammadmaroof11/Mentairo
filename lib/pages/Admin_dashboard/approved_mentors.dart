import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ApprovedMentorsScreen extends StatelessWidget {
  const ApprovedMentorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('mentors')
          .where('approved', isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final mentors = snapshot.data?.docs ?? [];

        if (mentors.isEmpty) {
          return const Center(child: Text("No approved mentors."));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: mentors.length,
          itemBuilder: (context, index) {
            final data = mentors[index].data() as Map<String, dynamic>;
            return Card(
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                title: Text(data['fullName'], style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("📧 ${data['email']}\n🛠 ${data['skills'].join(', ')}"),
              ),
            );
          },
        );
      },
    );
  }
}
