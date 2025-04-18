import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthController extends GetxController {
  static AuthController get to => Get.find();

  // Make user observable by using Rx
  final Rx<User?> _user = Rx<User?>(FirebaseAuth.instance.currentUser);

  User? get user => _user.value;

  @override
  void onReady() {
    // Set up auth state listener
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      _user.value = user;
    });
    super.onReady();
  }
}