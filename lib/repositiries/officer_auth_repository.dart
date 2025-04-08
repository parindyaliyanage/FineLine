import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/officer_model.dart';

class OfficerAuthRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Officer> signInOfficer(String badgeNumber, String password) async {
    try {
      debugPrint("Attempting sign in with: $badgeNumber / $password");

      final query = await _firestore
          .collection('officers')
          .where('badgeNumber', isEqualTo: badgeNumber)
          .where('password', isEqualTo: password)
          .limit(1)
          .get();

      debugPrint("Found ${query.docs.length} matching documents");

      if (query.docs.isEmpty) {
        throw Exception("No officer found with these credentials");
      }

      return Officer.fromMap(query.docs.first.data());
    } catch (e) {
      debugPrint("Sign-in error: ${e.toString()}");
      rethrow;
    }
  }

  Future<void> _logAttempt(String badgeNumber, bool success) async {
    try {
      await _firestore.collection('auth_logs').add({
        'badgeNumber': badgeNumber,
        'success': success,
        'timestamp': FieldValue.serverTimestamp(),
        'ip': await _getClientIP() ?? 'unknown',
      });
    } catch (e) {
      debugPrint("Failed to log attempt: $e");
    }
  }

  Future<String?> _getClientIP() async {
    return null;
  }
}