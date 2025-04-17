import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/officer_model.dart';

class OfficerAuthRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Officer> signInOfficer(String badgeNumber, String password) async {
    try {
      // Clear any existing auth state
      await _auth.signOut();  // Add this line

      debugPrint("Attempting sign in with: $badgeNumber");

      final query = await _firestore
          .collection('officers')
          .where('badgeNumber', isEqualTo: badgeNumber)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        throw Exception("No officer found with this badge number");
      }

      final officerData = query.docs.first.data();

      // Verify password before Firebase Auth
      if (officerData['password'] != password) {
        throw Exception("Invalid password");
      }

      // Only proceed with Firebase Auth if email exists
      if (officerData['email'] != null) {
        await _auth.signInWithEmailAndPassword(
          email: officerData['email'],
          password: password,
        );
      }

      return Officer.fromMap(officerData);
    } catch (e) {
      debugPrint("Sign-in error: ${e.toString()}");
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut(); // Uses the FirebaseAuth instance
      debugPrint("Officer signed out successfully");
    } catch (e) {
      debugPrint("Error signing out: ${e.toString()}");
      rethrow;
    }
  }

  Future<String?> _getClientIP() async {
    return null;
  }
}