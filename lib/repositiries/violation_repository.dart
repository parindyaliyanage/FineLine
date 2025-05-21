import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';

class ViolationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> submitViolation(Map<String, dynamic> violationData) async {
    try {
      // Add the violation with isViewed: false to mark as unread
      await _firestore.collection('violations').add({
        ...violationData,
        'isViewed': false, // Mark as unread
      });

      await _sendViolationNotification(
        violationData['identifier'],
        violationData['driverName'],
        violationData['fineAmount'],
      );
    } catch (e) {
      throw Exception('Failed to submit violation: $e');
    }
  }

  // Update the _sendViolationNotification method in violation_repository.dart
  Future<void> _sendViolationNotification(
      String identifier,
      String driverName,
      double fineAmount,
      ) async {
    try {
      // Find all users that might match this identifier (license or NIC)
      final usersQuery = await _firestore.collection('users')
          .where('license', isEqualTo: identifier)
          .get();

      final nicQuery = await _firestore.collection('users')
          .where('nic', isEqualTo: identifier)
          .get();

      // Combine results and get unique users
      final allUsers = [...usersQuery.docs, ...nicQuery.docs]
          .map((doc) => doc.data())
          .toSet();

      for (final user in allUsers) {
        final fcmToken = user['fcmToken'];
        if (fcmToken != null && fcmToken is String) {
          // Send actual notification
          await _messaging.sendMessage(
            to: fcmToken,
            data: {
              'type': 'violation',
              'title': 'New Traffic Violation',
              'body': 'New violation for $driverName - LKR $fineAmount',
            },
          );
        }
      }
    } catch (e) {
      debugPrint('Error sending notification: $e');

    }
  }
}