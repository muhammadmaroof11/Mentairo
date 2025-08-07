import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/session_card.dart';

class SessionPage extends StatelessWidget {
  const SessionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('sessions')
            .where('studentId', isEqualTo: uid)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No sessions found."));
          }

          final sessions = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              final data = sessions[index].data() as Map<String, dynamic>;
              return SessionCard(
                title: data['title'] ?? 'Session',
                date: data['createdAt'].toDate().toLocal().toString().split(" ")[0],
                time: data['createdAt'].toDate().toLocal().toString().split(" ")[1].substring(0, 5),
                status: data['status'],
                onTap: () {},
              );
            },
          );
        },
      ),
    );
  }
}