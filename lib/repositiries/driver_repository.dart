import 'package:fineline/repositiries/driver_auth_repository.dart';

class DriverRepository {
  final DriverAuthRepository _authRepo;

  DriverRepository() : _authRepo = DriverAuthRepository();

  Future<Map<String, dynamic>?> getDriverByIdentifier(String identifier) async {
    return await _authRepo.getDriverByIdentifier(identifier);
  }

}