import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class AuthenticationRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //temperary
  Future<bool> _checkInternet() async {
    try {
      final result = await InternetAddress.lookup('firestore.googleapis.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  // Register with email and password
  Future<void> registerWithEmailAndPassword(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw e;
    }
  }

  // Save user details to Firestore
  Future<void> saveUserDetails(
      String username,
      String license,
      String nic,
      String phone,
      String email,
      ) async {
  try {
  final User? user = _auth.currentUser;
  if (user != null) {
  debugPrint('Attempting to save user data for UID: ${user.uid}');
  if (!await _checkInternet()) {
    throw Exception('No internet connection');
  }

  await _firestore.collection('users').doc(user.uid).set({
  'username': username,
  'license': license,
  'nic': nic,
  'phone': phone,
  'email': email,
  'uid': user.uid,
  });

  debugPrint('User data saved successfully!');
  } else {
  debugPrint('No authenticated user found!');
  }
  } catch (e) {
  debugPrint('🔥 CRITICAL FIREBASE ERROR: $e');
  rethrow; // Keep this to maintain error handling in UI
  }
  }

  // Sign in with email and password
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw e;
    }
  }

  // Auth state changes stream
  Stream<User?> get user => _auth.authStateChanges();

  //get user details
  Future<Map<String, dynamic>?> getUserDetails(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      return doc.data() as Map<String, dynamic>?;
    } catch (e) {
      throw e;
    }
  }
  //sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}