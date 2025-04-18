// driver_repository.dart
import 'package:fineline/repositiries/driver_auth_repository.dart';
import 'package:flutter/foundation.dart';

class DriverRepository {
  final DriverAuthRepository _authRepo;

  DriverRepository() : _authRepo = DriverAuthRepository();

  Future<Map<String, dynamic>?> getDriverByIdentifier(String identifier) async {
    return await _authRepo.getDriverByIdentifier(identifier);
  }

  Future<Map<String, dynamic>?> getDriverProfile(String uid) async {
    try {
      final userDoc = await _authRepo.firestore.collection('users').doc(uid).get();
      if (!userDoc.exists) return null;

      return userDoc.data();
    } catch (e) {
      if (kDebugMode) print('Error getting driver profile: $e');
      return null;
    }
  }
}