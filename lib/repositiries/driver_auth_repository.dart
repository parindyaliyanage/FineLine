import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'base_auth_repository.dart';

class DriverAuthRepository extends BaseAuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseFirestore get firestore => _firestore;

  Future<Map<String, dynamic>?> getDriverByIdentifier(String identifier) async {
    try {
      // First check by license in drivers collection
      final licenseQuery = await _firestore.collection('drivers')
          .where('licenseNumber', isEqualTo: identifier.trim())
          .limit(1)
          .get();

      if (licenseQuery.docs.isNotEmpty) return licenseQuery.docs.first.data();

      // Fallback to NIC search in drivers collection
      final nicQuery = await _firestore.collection('drivers')
          .where('nic', isEqualTo: identifier.trim())
          .limit(1)
          .get();

      return nicQuery.docs.isEmpty ? null : nicQuery.docs.first.data();
    } catch (e) {
      if (kDebugMode) print('Driver lookup error: $e');
      return null;
    }
  }

  Future<bool> isDriverRegistered(String license, String nic) async {
    try {
      final query = await _firestore.collection('drivers')
          .where('licenseNumber', isEqualTo: license.trim())
          .where('nic', isEqualTo: nic.trim())
          .limit(1)
          .get();

      return query.docs.isNotEmpty;
    } catch (e) {
      if (kDebugMode) print('Error checking driver registration: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> getOfficialDriverData(String license, String nic) async {
    try {
      final query = await _firestore.collection('drivers')
          .where('licenseNumber', isEqualTo: license.trim())
          .where('nic', isEqualTo: nic.trim())
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

      final userData = {
        'username': username,
        'license': license.trim(),
        'nic': nic.trim(),
        'phone': phone.trim(),
        'email': email.trim(),
        'uid': user.uid,
        'role': 'driver',
        'registration_date': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('users').doc(user.uid).set(userData);
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

  Future<Map<String, dynamic>?> getAppUserByIdentifier(String identifier) async {
    try {
      final licenseQuery = await _firestore.collection('users')
          .where('license', isEqualTo: identifier.trim())
          .limit(1)
          .get();

      if (licenseQuery.docs.isNotEmpty) return licenseQuery.docs.first.data();

      final nicQuery = await _firestore.collection('users')
          .where('nic', isEqualTo: identifier.trim())
          .limit(1)
          .get();

      return nicQuery.docs.isEmpty ? null : nicQuery.docs.first.data();
    } catch (e) {
      if (kDebugMode) print('User lookup error: $e');
      return null;
    }
  }

  @override
  Future<bool> checkInternet() async {
    return true;
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }
}