import 'package:cloud_firestore/cloud_firestore.dart';

class ViolationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> submitViolation(Map<String, dynamic> violationData) async {
    try {
      await _firestore.collection('violations').add(violationData);
    } catch (e) {
      throw Exception('Failed to submit violation: $e');
    }
  }

// You can add more methods here later for fetching violations, etc.
}