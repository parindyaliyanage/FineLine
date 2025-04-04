import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'base_auth_repository.dart';

class DriverAuthRepository extends BaseAuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> registerWithEmailAndPassword(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Registration error: $e');
      }
      rethrow; // Fixed: Using rethrow instead of throw
    }
  }

  Future<void> saveDriverDetails({
    required String username,
    required String license,
    required String nic,
    required String phone,
    required String email,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        if (!await checkInternet()) {
          throw Exception('No internet connection');
        }

        await _firestore.collection('users').doc(user.uid).set({
          'username': username,
          'license': license,
          'nic': nic,
          'phone': phone,
          'email': email,
          'uid': user.uid,
          'role': 'driver',
        });

        if (kDebugMode) {
          print('Driver data saved successfully!');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('🔥 Error saving driver details: $e');
      }
      rethrow;
    }
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      if (kDebugMode) {
        print('Sign in error: $e');
      }
      rethrow;
    }
  }
}