import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mentairo/widgets/profile_field.dart';

class MentorProfile extends StatefulWidget {
  const MentorProfile({super.key});

  @override
  State<MentorProfile> createState() => _MentorProfileState();
}

class _MentorProfileState extends State<MentorProfile> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  late Future<DocumentSnapshot> _mentorFuture;
  String? _localPhotoPath;
  String? _mentorDocId;
  int _photoVersion = 0;

  @override
  void initState() {
    super.initState();
    _mentorFuture = _fetchMentorDoc();
  }

  Future<DocumentSnapshot> _fetchMentorDoc() async {
    final query = await FirebaseFirestore.instance
        .collection('mentors')
        .where('email', isEqualTo: currentUser.email)
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      throw Exception('Mentor data not found.');
    }

    final doc = query.docs.first;
    _mentorDocId = doc.id;
    _localPhotoPath = doc.data()['localPhotoPath'];
    return doc;
  }

  Future<void> _refreshUserData() async {
    if (_mentorDocId == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('mentors')
        .doc(_mentorDocId)
        .get();
    setState(() {
      _localPhotoPath = doc.data()?['localPhotoPath'];
      _mentorFuture = Future.value(doc);
      _photoVersion++; // Force image widget refresh
    });
  }

  Future<void> _pickAndSaveImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null && _mentorDocId != null) {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = '${currentUser.uid}_profile.jpg';
      final localImage = File('${appDir.path}/$fileName');
      await File(pickedFile.path).copy(localImage.path);

      await FirebaseFirestore.instance
          .collection('mentors')
          .doc(_mentorDocId)
          .update({'localPhotoPath': localImage.path});

      await _refreshUserData();
    }
  }

  Future<void> _removeProfilePhoto() async {
    if (_localPhotoPath != null && File(_localPhotoPath!).existsSync()) {
      await File(_localPhotoPath!).delete();
    }

    if (_mentorDocId != null) {
      await FirebaseFirestore.instance
          .collection('mentors')
          .doc(_mentorDocId)
          .update({'localPhotoPath': null});
    }

    setState(() {
      _localPhotoPath = null;
      _photoVersion++; // Force image widget refresh
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Profile photo removed."),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F4F8),
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text('Profile', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _mentorFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Mentor data not found.'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          _localPhotoPath ??= data['localPhotoPath'];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      key: ValueKey(_photoVersion), // This forces widget rebuild
                      radius: 50,
                      backgroundColor: Colors.deepPurple.shade100,
                      backgroundImage: _localPhotoPath != null
                          ? FileImage(File(_localPhotoPath!))
                          : null,
                      child: _localPhotoPath == null
                          ? const Icon(Icons.person, color: Colors.white, size: 50)
                          : null,
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'change') {
                          _pickAndSaveImage();
                        } else if (value == 'remove') {
                          _removeProfilePhoto();
                        }
                      },
                      itemBuilder: (_) => [
                        const PopupMenuItem(value: 'change', child: Text('Change Photo')),
                        const PopupMenuItem(value: 'remove', child: Text('Remove Photo')),
                      ],
                      icon: const Icon(Icons.camera_alt, color: Colors.deepPurple),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  data['fullName'] ?? 'N/A',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(
                  data['email'] ?? 'Email not provided',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 30),
                ProfileField(
                  label: 'Skills',
                  value: (data['skills'] as List?)?.join(', ') ?? 'N/A',
                ),
                ProfileField(label: 'Phone', value: data['contact'] ?? 'N/A'),
                ProfileField(label: 'LinkedIn', value: data['linkedin'] ?? 'N/A'),
                ProfileField(label: 'Bio', value: data['bio'] ?? 'No bio added.'),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: () => _showEditProfileDialog(context, data),
                  icon: const Icon(Icons.edit),
                  label: const Text("Edit Profile"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, Map<String, dynamic> currentData) {
    final nameController = TextEditingController(text: currentData['fullName']);
    final contactController = TextEditingController(text: currentData['contact']);
    final linkedinController = TextEditingController(text: currentData['linkedin']);
    final bioController = TextEditingController(text: currentData['bio']);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Profile"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Full Name")),
              const SizedBox(height: 10),
              TextField(
                  controller: contactController,
                  decoration: const InputDecoration(labelText: "Phone")),
              const SizedBox(height: 10),
              TextField(
                  controller: linkedinController,
                  decoration: const InputDecoration(labelText: "LinkedIn URL")),
              const SizedBox(height: 10),
              TextField(
                  controller: bioController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: "Bio")),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              if (_mentorDocId == null) return;

              await FirebaseFirestore.instance.collection('mentors').doc(_mentorDocId).update({
                'fullName': nameController.text.trim(),
                'contact': contactController.text.trim(),
                'linkedin': linkedinController.text.trim(),
                'bio': bioController.text.trim(),
              });

              Navigator.pop(context);
              _refreshUserData();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text("Profile updated successfully"),
                    backgroundColor: Colors.green),
              );
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}