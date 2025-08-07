import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UnapprovedMentorsScreen extends StatelessWidget {
  const UnapprovedMentorsScreen({super.key});

  Future<void> _approveMentor(BuildContext context, Map<String, dynamic> mentorData) async {
    try {
      // Create FirebaseAuth account
      UserCredential credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: mentorData['email'],
        password: mentorData['password'],
      );

      final uid = credential.user!.uid;
      mentorData.remove('password');
      final tempId = mentorData['tempId'];

      // Save to mentors collection with uid as doc ID
      await FirebaseFirestore.instance.collection('mentors').doc(uid).set({
        ...mentorData,
        'uid': uid,
        'role': 'mentor',
        'approved': true,
        'profileImage': '',
        'bio': '',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Optionally add to users collection
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        ...mentorData,
        'uid': uid,
        'role': 'mentor',
        'approved': true,
      });

      // Delete temp doc
      await FirebaseFirestore.instance.collection('mentors').doc(tempId).delete();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mentor approved successfully.'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error approving mentor: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _rejectMentor(BuildContext context, String docId) async {
    try {
      await FirebaseFirestore.instance.collection('mentors').doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mentor rejected and deleted.'), backgroundColor: Colors.orange),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error rejecting mentor: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('mentors')
          .where('approved', isEqualTo: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final mentors = snapshot.data?.docs ?? [];

        if (mentors.isEmpty) {
          return const Center(child: Text("No unapproved mentors."));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: mentors.length,
          itemBuilder: (context, index) {
            final doc = mentors[index];
            final data = doc.data() as Map<String, dynamic>;
            data['tempId'] = doc.id; // store temp ID to delete later

            return Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("👤 ${data['fullName']}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text("📧 ${data['email']}"),
                    Text("📞 ${data['contact']}"),
                    Text("📚 Field: ${data['field']}"),
                    Text("🛠 Skills: ${data['skills'].join(', ')}"),
                    Text("✅ Quiz Score: ${data['quizScore']}%"),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _approveMentor(context, data),
                            icon: const Icon(Icons.check, color: Colors.white),
                            label: const Text("Approve", style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _rejectMentor(context, doc.id),
                            icon: const Icon(Icons.close, color: Colors.white),
                            label: const Text("Reject", style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
