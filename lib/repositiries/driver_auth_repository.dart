import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'base_auth_repository.dart';

class DriverAuthRepository extends BaseAuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseFirestore get firestore => _firestore;

  /// Checks if driver exists in official 'drivers' collection
  Future<bool> isDriverRegistered(String license, String nic) async {
    try {
      final query = await _firestore.collection('drivers')
          .where('licenseNumber', isEqualTo: license.trim().toUpperCase())
          .where('nic', isEqualTo: nic.trim().toUpperCase())
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        if (kDebugMode) print('No driver found with license: $license and NIC: $nic');
        return false;
      }

      // Add debug print to verify the found document
      if (kDebugMode) {
        print('Found driver document: ${query.docs.first.data()}');
        print('Document exists in drivers collection');
      }

      return true;
    } catch (e) {
      if (kDebugMode) print('Driver validation error: $e');
      rethrow;
    }
  }

  /// Gets official driver details from 'drivers' collection
  Future<Map<String, dynamic>?> getOfficialDriverData(String license, String nic) async {
    try {
      final query = await _firestore.collection('drivers')
          .where('licenseNumber', isEqualTo: license)
          .where('nic', isEqualTo: nic)
          .limit(1)
          .get();

      return query.docs.isEmpty ? null : query.docs.first.data();
    } catch (e) {
      if (kDebugMode) print('Error getting official driver data: $e');
      return null;
    }
  }

  Future<void> registerWithEmailAndPassword(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      if (kDebugMode) print('Registration error: $e');
      rethrow;
    }
  }

  /// Saves driver details to 'users' collection after validation
  // In driver_auth_repository.dart
  Future<void> saveDriverDetails({
    required String username,
    required String license,
    required String nic,
    required String phone,
    required String email,
    required Map<String, dynamic> officialData,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Only save user-specific data in users collection
      final userData = {
        'username': username,
        'license': license, // Changed from licenseNumber to license
        'nic': nic,
        'phone': phone,
        'email': email,
        'uid': user.uid,
        'role': 'driver',
        'registration_date': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('users').doc(user.uid).set(userData);

      if (kDebugMode) print('Driver data saved to users collection');
    } catch (e) {
      if (kDebugMode) print('Error saving driver details: $e');
      rethrow;
    }
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      if (kDebugMode) print('Sign in error: $e');
      rethrow;
    }
  }

  /// Finds driver in 'users' collection by license or NIC
  Future<Map<String, dynamic>?> getDriverByIdentifier(String identifier) async {
    try {
      // First check by license in drivers collection
      final licenseQuery = await _firestore.collection('drivers')
          .where('licenseNumber', isEqualTo: identifier)
          .limit(1)
          .get();

      if (licenseQuery.docs.isNotEmpty) return licenseQuery.docs.first.data();

      // Fallback to NIC search in drivers collection
      final nicQuery = await _firestore.collection('drivers')
          .where('nic', isEqualTo: identifier)
          .limit(1)
          .get();

      return nicQuery.docs.isEmpty ? null : nicQuery.docs.first.data();
    } catch (e) {
      if (kDebugMode) print('Driver lookup error: $e');
      return null;
    }
  }

  /// Utility method to check internet connection
  @override
  Future<bool> checkInternet() async {
    // Implement your internet check logic
    return true;
  }

  @override
  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }
}