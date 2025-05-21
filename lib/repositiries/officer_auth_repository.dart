import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert'; // for the utf8.encode method
import '../models/officer_model.dart';

class OfficerAuthRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Helper method to hash passwords
  String _hashPassword(String password) {
    var bytes = utf8.encode(password); // Convert password to bytes
    var digest = sha256.convert(bytes); // Hash the password using SHA-256
    return digest.toString();
  }

  Future<void> registerOfficer({
    required String badgeNumber,
    required String fullName,
    required String department,
    required String station,
    required String mobileNumber,
    required String rank,
    required String password,
  }) async {
    try {
      // Hash the password before storing
      final hashedPassword = _hashPassword(password);

      await _firestore.collection('officers').add({
        'badgeNumber': badgeNumber,
        'fullName': fullName,
        'department': department,
        'station': station,
        'mobileNumber': mobileNumber,
        'rank': rank,
        'password': hashedPassword, // Store the hashed password
      });
    } catch (e) {
      debugPrint("Registration error: ${e.toString()}");
      rethrow;
    }
  }

  Future<Officer> signInOfficer(String badgeNumber, String password) async {
    try {
      final query = await _firestore
          .collection('officers')
          .where('badgeNumber', isEqualTo: badgeNumber)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        throw Exception("No officer found with this badge number");
      }

      final officerData = query.docs.first.data();
      final hashedPassword = _hashPassword(password);

      if (officerData['password'] != hashedPassword) {
        throw Exception("Invalid password");
      }

      return Officer.fromMap(officerData);
    } catch (e) {
      debugPrint("Sign-in error: ${e.toString()}");
      rethrow;
    }
  }

  Future<void> signOut() async {
    debugPrint("Officer signed out");
  }
}