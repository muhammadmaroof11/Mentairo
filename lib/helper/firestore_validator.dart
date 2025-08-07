import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreValidator {
  static Future<bool> fieldExists(String field, String value) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where(field, isEqualTo: value)
        .get();
    return snapshot.docs.isNotEmpty;
  }
}
