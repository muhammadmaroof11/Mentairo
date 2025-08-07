import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Import all field question maps
import 'package:mentairo/backend/comp_ques.dart';
import 'package:mentairo/backend/eng_ques.dart';
import 'package:mentairo/backend/business_ques.dart';
import 'package:mentairo/backend/design_ques.dart';
import 'package:mentairo/backend/medical_ques.dart';

class UploadQuestionsOnce extends StatefulWidget {
  const UploadQuestionsOnce({super.key});

  @override
  State<UploadQuestionsOnce> createState() => _UploadQuestionsOnceState();
}

class _UploadQuestionsOnceState extends State<UploadQuestionsOnce> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Merge all field maps
  Map<String, Map<String, List<Map<String, dynamic>>>> get allFieldMaps => {
    ...compQuestions,
    ...engQuestions,
    ...businessQuestions,
    ...designQuestions,
    ...medicalQuestions,
  };

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, uploadAllFields);
  }

  Future<void> uploadAllFields() async {
    for (final fieldName in allFieldMaps.keys) {
      final skillMap = allFieldMaps[fieldName];
      await uploadFieldQuestions(fieldName, skillMap);
    }
  }

  Future<void> uploadFieldQuestions(
      String fieldName, Map<String, List<Map<String, dynamic>>>? skillMap) async {
    if (skillMap == null || skillMap.isEmpty) {
      debugPrint('❌ Skill map is null or empty for field: $fieldName');
      return;
    }

    try {
      final metadataDoc =
      await _firestore.collection('metadata').doc('uploadStatus_$fieldName').get();
      final alreadyUploaded = metadataDoc.exists && metadataDoc.data()?['uploaded'] == true;

      if (alreadyUploaded) {
        debugPrint('⚠️ $fieldName already uploaded');
        return;
      }

      final fieldRef = _firestore.collection('fields').doc(fieldName);

      for (final skillName in skillMap.keys) {
        final questions = skillMap[skillName];
        if (questions == null || questions.isEmpty) {
          debugPrint('❌ No questions for $fieldName > $skillName');
          continue;
        }

        final skillRef = fieldRef.collection('skills').doc(skillName);
        for (final question in questions) {
          await skillRef.collection('questions').add(question);
        }
        debugPrint('✅ Uploaded ${questions.length} questions for $fieldName > $skillName');
      }

      await _firestore
          .collection('metadata')
          .doc('uploadStatus_$fieldName')
          .set({'uploaded': true});
      debugPrint('✅ Completed upload for $fieldName');
    } catch (e) {
      debugPrint('❌ Error uploading $fieldName: $e');
    }
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink(); // No UI
}
