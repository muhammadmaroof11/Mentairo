import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'approved_page.dart';
import 'waiting_page.dart';

class QuizScreen extends StatefulWidget {
  final String field;
  final List<String> selectedSkills;
  final Map<String, dynamic> mentorData;

  const QuizScreen({
    super.key,
    required this.field,
    required this.selectedSkills,
    required this.mentorData,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final _answers = <String, String>{};
  final _questions = <Map<String, dynamic>>[];
  bool _submitting = false;
  bool _loadingQuestions = true;

  Stream<DocumentSnapshot>? _approvalStream;
  bool _alreadyNavigated = false;
  bool _quizSubmitted = false;

  @override
  void initState() {
    super.initState();
    loadQuestions();
  }

  Future<void> loadQuestions() async {
    setState(() {
      _loadingQuestions = true;
      _questions.clear();
      _answers.clear();
    });

    try {
      final firestore = FirebaseFirestore.instance;
      for (String skill in widget.selectedSkills) {
        final skillQuestions = await firestore
            .collection('fields')
            .doc(widget.field)
            .collection('skills')
            .doc(skill)
            .collection('questions')
            .limit(3)
            .get();

        for (final doc in skillQuestions.docs) {
          _questions.add({
            'id': doc.id,
            'skill': skill,
            'question': doc['question'],
            'options': doc['options'],
            'answer': doc['answer'],
          });
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading questions: $e'), backgroundColor: Colors.red),
        );
      }
    }

    setState(() => _loadingQuestions = false);
  }

  Future<void> submitQuiz() async {
    setState(() => _submitting = true);

    int correct = 0;
    for (var q in _questions) {
      final selected = _answers['${q['skill']}_${q['id']}'];
      if (selected == q['answer']) correct++;
    }

    final score = (correct / _questions.length * 100).round();

    final firestore = FirebaseFirestore.instance;
    final baseData = {
      ...widget.mentorData,
      'field': widget.field,
      'skills': widget.selectedSkills,
      'quizScore': score,
      'profileImage': '',
      'bio': '',
      'createdAt': FieldValue.serverTimestamp(),
      'approved': false,
      'role': 'mentor',
    };

    try {
      // Save to mentors collection with generated ID
      await firestore.collection('mentors').add(baseData);

      // Listen to approval in 'users' collection
      setState(() {
        _approvalStream = firestore
            .collection('users')
            .where('email', isEqualTo: widget.mentorData['email'])
            .limit(1)
            .snapshots()
            .map((snapshot) => snapshot.docs.isNotEmpty ? snapshot.docs.first : null)
            .map((doc) => doc != null ? doc.reference.snapshots() : null)
            .asyncExpand((stream) => stream ?? const Stream.empty());

        _quizSubmitted = true;
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Your request has been sent to the admin for approval.')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Submission failed: $e'), backgroundColor: Colors.red),
        );
      }
    }

    setState(() => _submitting = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_quizSubmitted && _approvalStream != null) {
      return StreamBuilder<DocumentSnapshot>(
        stream: _approvalStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const WaitingPage();
          }

          if (snapshot.hasData && snapshot.data!.exists) {
            final data = snapshot.data!.data() as Map<String, dynamic>;
            final approved = data['approved'] == true;

            if (approved && !_alreadyNavigated) {
              _alreadyNavigated = true;
              Future.microtask(() {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const ApprovedPage()),
                );
              });
            }
          }

          return const WaitingPage();
        },
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Mentor Quiz')),
      body: _loadingQuestions
          ? const Center(child: CircularProgressIndicator())
          : _questions.isEmpty
          ? const Center(child: Text('No questions found. Please contact admin.'))
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Text(
              'You must complete the quiz to submit your request.',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
          ),
          for (var q in _questions)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${q['skill']} - ${q['question']}',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    for (String opt in List<String>.from(q['options']))
                      RadioListTile<String>(
                        title: Text(opt),
                        value: opt,
                        groupValue: _answers['${q['skill']}_${q['id']}'],
                        onChanged: (value) {
                          setState(() {
                            _answers['${q['skill']}_${q['id']}'] = value!;
                          });
                        },
                      ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _answers.length == _questions.length && !_submitting
                ? submitQuiz
                : null,
            child: _submitting
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Submit for Approval'),
          ),
        ],
      ),
    );
  }
}
