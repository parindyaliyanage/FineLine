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

      await _firestore.collection('users').doc(user.uid).set({
        'username': username,
        'license': license,
        'nic': nic,
        'phone': phone,
        'email': email,
        'uid': user.uid,
        'role': 'driver',
        'registration_date': FieldValue.serverTimestamp(),
        ...officialData, // Include all official data
      });

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
      // First check by license
      final licenseQuery = await _firestore.collection('users')
          .where('role', isEqualTo: 'driver')
          .where('license', isEqualTo: identifier)
          .limit(1)
          .get();

      if (licenseQuery.docs.isNotEmpty) return licenseQuery.docs.first.data();

      // Fallback to NIC search
      final nicQuery = await _firestore.collection('users')
          .where('role', isEqualTo: 'driver')
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