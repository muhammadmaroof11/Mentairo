import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:mentairo/widgets/profile_field.dart';
import '../../functions/confirmLogOut.dart';
import '../../widgets/profile_tile.dart';

class StudentProfile extends StatefulWidget {
  const StudentProfile({super.key});

  @override
  State<StudentProfile> createState() => _StudentProfileState();
}

class _StudentProfileState extends State<StudentProfile> {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  late Map<String, dynamic> _userData;
  String? _localPhotoPath;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final snapshot = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final data = snapshot.data() as Map<String, dynamic>;
    setState(() {
      _userData = data;
      _localPhotoPath = data['localPhotoPath'];
      _loading = false;
    });
  }

  Future<void> _pickAndSaveImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = '${uid}_profile.jpg';
      final localImage = File('${appDir.path}/$fileName');
      await File(pickedFile.path).copy(localImage.path);

      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'localPhotoPath': localImage.path,
      });

      setState(() {
        _localPhotoPath = localImage.path;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile picture updated'), backgroundColor: Colors.green),
      );
    }
  }

  Future<void> _removePhoto() async {
    final appDir = await getApplicationDocumentsDirectory();
    final localImage = File('${appDir.path}/${uid}_profile.jpg');

    if (await localImage.exists()) {
      await localImage.delete();
    }

    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'localPhotoPath': null,
    });

    setState(() {
      _localPhotoPath = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile picture removed'), backgroundColor: Colors.orange),
    );
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo),
            title: const Text("Change Photo"),
            onTap: () {
              Navigator.pop(context);
              _pickAndSaveImage();
            },
          ),
          if (_localPhotoPath != null)
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text("Remove Photo"),
              onTap: () {
                Navigator.pop(context);
                _removePhoto();
              },
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F4F8),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  key: ValueKey(_localPhotoPath), // ensures re-render when photo changes
                  radius: 50,
                  backgroundColor: Colors.deepPurple,
                  backgroundImage: _localPhotoPath != null ? FileImage(File(_localPhotoPath!)) : null,
                  child: _localPhotoPath == null
                      ? const Icon(Icons.person, size: 50, color: Colors.white)
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: InkWell(
                    onTap: _showPhotoOptions,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.deepPurple,
                      ),
                      child: const Icon(Icons.camera_alt, size: 20, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _userData['fullName'] ?? 'Name not found',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              _userData['email'] ?? 'Email not provided',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 30),
            ProfileField(label: 'Contact', value: _userData['contact'] ?? 'N/A'),
            ProfileField(label: 'Institute', value: _userData['institute'] ?? 'N/A'),
            const SizedBox(height: 30),
            ProfileTile(
              icon: Icons.edit,
              title: 'Edit Profile',
              onTap: () => _showEditProfileDialog(context),
            ),
            ProfileTile(
              icon: Icons.logout,
              title: 'Logout',
              onTap: () => ConfirmLogout(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    final nameController = TextEditingController(text: _userData['fullName']);
    final contactController = TextEditingController(text: _userData['contact']);
    final instituteController = TextEditingController(text: _userData['institute']);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Profile"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: "Full Name")),
              const SizedBox(height: 10),
              TextField(controller: contactController, decoration: const InputDecoration(labelText: "Phone")),
              const SizedBox(height: 10),
              TextField(controller: instituteController, decoration: const InputDecoration(labelText: "Institute")),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final updatedData = {
                'fullName': nameController.text.trim(),
                'contact': contactController.text.trim(),
                'institute': instituteController.text.trim(),
              };

              await FirebaseFirestore.instance.collection('users').doc(uid).update(updatedData);
              Navigator.pop(context);
              await _fetchUserData();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Profile updated successfully"),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}
