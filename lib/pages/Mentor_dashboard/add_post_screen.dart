import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddPost extends StatefulWidget {
  const AddPost({super.key});

  @override
  State<AddPost> createState() => _AddPostState();
}

class _AddPostState extends State<AddPost> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  String? selectedCategory;
  bool isLoading = false;

  final List<String> categories = [
    'Computer Science',
    'Engineering',
    'Business',
    'Design',
    'Medical',
  ];

  Future<void> _submitPost() async {
    if (titleController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        selectedCategory == null) return;

    setState(() => isLoading = true);

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final userData = userDoc.data();

      final mentorName = userData?['fullName'] ?? 'Mentor';
      final mentorField = userData?['field'] ?? 'General';

      await FirebaseFirestore.instance.collection('posts').add({
        'title': titleController.text.trim(),
        'description': descriptionController.text.trim(),
        'mentorId': uid,
        'mentorName': mentorName,
        'field': mentorField, // ✅ From mentor profile
        'category': selectedCategory, // ✅ From dropdown
        'createdAt': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Post created successfully"), backgroundColor: Colors.green),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Post", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                maxLines: 5,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 16),
              const Text("Select Post Category", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButton<String>(
                isExpanded: true,
                value: selectedCategory,
                hint: const Text("Choose a category"),
                items: categories.map((cat) {
                  return DropdownMenuItem(value: cat, child: Text(cat));
                }).toList(),
                onChanged: (value) => setState(() => selectedCategory = value),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: isLoading ? null : _submitPost,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Submit", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
