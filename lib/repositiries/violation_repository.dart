import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';

class ViolationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> submitViolation(Map<String, dynamic> violationData) async {
    try {
      await _firestore.collection('violations').add(violationData);
      await _sendViolationNotification(
        violationData['identifier'],
        violationData['driverName'],
        violationData['fineAmount'],
      );
    } catch (e) {
      throw Exception('Failed to submit violation: $e');
    }
  }

  Future<void> _sendViolationNotification(
      String identifier,
      String driverName,
      double fineAmount,
      ) async {
    try {
      // Solution 1: Use separate queries and combine results
      final licenseQuery = await _firestore.collection('users')
          .where('license', isEqualTo: identifier)
          .limit(1)
          .get();

      final nicQuery = await _firestore.collection('users')
          .where('nic', isEqualTo: identifier)
          .limit(1)
          .get();

      // Combine results
      final driverDocs = [...licenseQuery.docs, ...nicQuery.docs];
      debugPrint('Found ${driverDocs.length} driver records');

      if (driverDocs.isNotEmpty) {
        final driverData = driverDocs.first.data();
        //
        debugPrint('Driver data: ${driverData.toString()}');


        final fcmToken = driverData['fcmToken'];
        //
        debugPrint('FCM Token from Firestore: $fcmToken');

        if (fcmToken != null) {
          // For actual implementation, use Cloud Functions
          debugPrint('Sending notification to token: $fcmToken');
        }
      }

      // Alternative Solution 2: Use whereIn with all possible identifiers
      // final query = await _firestore.collection('users')
      //     .where('identifier', whereIn: [identifier])
      //     .limit(1)
      //     .get();
    } catch (e) {
      debugPrint('Error sending notification: $e');
    }
  }
}