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
      // 1. Get basic user data from 'users' collection
      final userDoc = await _authRepo.firestore.collection('users').doc(uid).get();
      if (!userDoc.exists) return null;
      final userData = userDoc.data()!;

      // 2. Get license and NIC to lookup official data
      final license = userData['license']; // Now using consistent 'license' field
      final nic = userData['nic'];

      if (license == null || nic == null) return userData;

      // 3. Get official driver data from 'drivers' collection
      final driverQuery = await _authRepo.firestore.collection('drivers')
          .where('licenseNumber', isEqualTo: license)
          .where('nic', isEqualTo: nic)
          .limit(1)
          .get();

      if (driverQuery.docs.isEmpty) return userData;

      final officialData = driverQuery.docs.first.data();

      // 4. Return combined data but prioritize user data for any overlapping fields
      return {
        ...officialData,
        ...userData, // User data overrides official data if fields overlap
        'license': license, // Ensure consistent field name
      };
    } catch (e) {
      if (kDebugMode) print('Error getting driver profile: $e');
      return null;
    }
  }
}