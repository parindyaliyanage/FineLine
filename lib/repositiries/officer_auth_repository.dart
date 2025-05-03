import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/officer_model.dart';


class OfficerAuthRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

      // Keep password verification as-is
      if (officerData['password'] != password) {
        throw Exception("Invalid password");
      }

      return Officer.fromMap(officerData);
    } catch (e) {
      debugPrint("Sign-in error: ${e.toString()}");
      rethrow;
    }
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
      await _firestore.collection('officers').add({
        'badgeNumber': badgeNumber,
        'fullName': fullName,
        'department': department,
        'station': station,
        'mobileNumber': mobileNumber,
        'rank': rank,
        'password': password, // Keep plain password
      });
    } catch (e) {
      debugPrint("Registration error: ${e.toString()}");
      rethrow;
    }
  }

  Future<void> updateOfficer({
    required String badgeNumber,
    String? station,
    String? mobileNumber,
    String? rank,
    String? password,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      if (station != null) updateData['station'] = station;
      if (mobileNumber != null) updateData['mobileNumber'] = mobileNumber;
      if (rank != null) updateData['rank'] = rank;
      if (password != null) updateData['password'] = password;

      await _firestore
          .collection('officers')
          .where('badgeNumber', isEqualTo: badgeNumber)
          .limit(1)
          .get()
          .then((query) {
        if (query.docs.isNotEmpty) {
          return query.docs.first.reference.update(updateData);
        }
        throw Exception("Officer not found");
      });
    } catch (e) {
      debugPrint("Update error: ${e.toString()}");
      rethrow;
    }
  }

  Future<void> signOut() async {
    // No Firebase Auth to sign out from
    debugPrint("Officer signed out");
  }
}