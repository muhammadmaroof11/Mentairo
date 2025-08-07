import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'mentor_profile_view.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<DocumentSnapshot> _allMentors = [];
  List<DocumentSnapshot> _filteredMentors = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchApprovedMentors();
  }

  Future<void> _fetchApprovedMentors() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('mentors')
          .where('approved', isEqualTo: true)
          .get();

      setState(() {
        _allMentors = snapshot.docs;
        _filteredMentors = _allMentors;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading mentors: $e');
      setState(() => _isLoading = false);
    }
  }

  void _filterMentors(String query) {
    final q = query.trim().toLowerCase();

    if (q.isEmpty) {
      setState(() => _filteredMentors = _allMentors);
      return;
    }

    final results = _allMentors.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final name = (data['fullName'] ?? '').toString().toLowerCase();
      final field = (data['field'] ?? '').toString().toLowerCase();
      final skills = (data['skills'] as List?)?.join(',').toLowerCase() ?? '';
      return name.contains(q) || field.contains(q) || skills.contains(q);
    }).toList();

    setState(() => _filteredMentors = results);
  }

  ImageProvider _getImageProvider(String? path) {
    if (path != null && File(path).existsSync()) {
      return FileImage(File(path));
    } else {
      return const AssetImage('assets/default_profile.jpeg');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              onChanged: _filterMentors,
              decoration: InputDecoration(
                hintText: 'Search by name, field or skills...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _filteredMentors.isEmpty
                  ? const Center(child: Text('No mentors found.'))
                  : ListView.builder(
                itemCount: _filteredMentors.length,
                itemBuilder: (context, index) {
                  final data = _filteredMentors[index].data() as Map<String, dynamic>;

                  final uid = data['uid'] ?? '';
                  final name = data['fullName'] ?? 'Unknown';
                  final bio = data['bio'] ?? '';
                  final skills = List<String>.from(data['skills'] ?? []);
                  final field = data['field'] ?? '';
                  final contact = data['contact'] ?? '';
                  final linkedin = data['linkedin'] ?? '';
                  final imagePath = data['localPhotoPath'];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: CircleAvatar(
                        radius: 30,
                        backgroundImage: _getImageProvider(imagePath),
                      ),
                      title: Text(name,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 6),
                          Text("Field: $field"),
                          Text("Skills: ${skills.join(', ')}"),
                          Text("Contact: $contact"),
                          if (linkedin.isNotEmpty) Text("LinkedIn: $linkedin"),
                        ],
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MentorProfileView(
                              mentorId: uid,
                              mentorName: name,
                              localImagePath: imagePath,
                              bio: bio,
                              skills: skills,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
