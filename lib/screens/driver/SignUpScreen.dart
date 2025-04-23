import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'SignInScreen.dart';
import 'homePage.dart';
import 'package:fineline/repositiries/driver_auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _licenseController = TextEditingController();
  final TextEditingController _nicController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final DriverAuthRepository _authRepo = Get.find();

  @override
  void dispose() {
    _usernameController.dispose();
    _licenseController.dispose();
    _nicController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sign Up',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1a4a7c),
        elevation: 0,
      ),
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1a4a7c),
              Color(0xFF2c5c8f),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  const Text(
                    'Sign Up',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  _buildRoundedTextField('Username',
                      controller: _usernameController, height: 50),
                  const SizedBox(height: 30),
                  _buildRoundedTextField('Driving License Number',
                      controller: _licenseController, height: 50),
                  const SizedBox(height: 30),
                  _buildRoundedTextField('NIC Number',
                      controller: _nicController, height: 50),
                  const SizedBox(height: 30),
                  _buildRoundedTextField('Phone Number',
                      controller: _phoneController, height: 50),
                  const SizedBox(height: 30),
                  _buildRoundedTextField(
                    'Password',
                    controller: _passwordController,
                    height: 50,
                    isPassword: true,
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: _handleSignUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF1a4a7c),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 3,
                    ),
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      // Navigate to SignInScreen
                      Get.to(() => SignInScreen());
                    },
                    child: const Text(
                      'Already have an account? Sign In',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoundedTextField(
    String label, {
    bool isPassword = false,
    required TextEditingController controller,
    double height = 60,
    double width = double.infinity,
  }) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white30),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
        child: TextField(
          controller: controller,
          obscureText: isPassword,
          decoration: InputDecoration(
            hintText: label,
            hintStyle: const TextStyle(color: Colors.white),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
          ),
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  void _handleSignUp() async {
    final String username = _usernameController.text.trim();
    final String license = _licenseController.text.trim().toUpperCase();
    final String nic = _nicController.text.trim().toUpperCase();
    final String phone = _phoneController.text.trim();
    final String password = _passwordController.text.trim();

    // Validate fields
    if (username.isEmpty ||
        license.isEmpty ||
        nic.isEmpty ||
        phone.isEmpty ||
        password.isEmpty) {
      Get.snackbar(
        'Error',
        'Please fill in all fields',
        colorText: Colors.white,
        backgroundColor: Colors.red.withOpacity(0.7),
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (password.length < 6) {
      Get.snackbar(
        'Error',
        'Password must be at least 6 characters',
        colorText: Colors.white,
        backgroundColor: Colors.red.withOpacity(0.7),
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      // Show loading indicator
      Get.dialog(
        const Center(
            child: CircularProgressIndicator(
          color: Colors.white,
        )),
        barrierDismissible: false,
      );

      // 1. Validate driver credentials
      final isRegistered = await _authRepo.isDriverRegistered(license, nic);
      if (!isRegistered) {
        Get.back();
        Get.snackbar(
          'Registration Failed',
          'No matching driver found with provided license/NIC',
          duration: const Duration(seconds: 5),
          colorText: Colors.white,
          backgroundColor: Colors.red.withOpacity(0.7),
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // 2. Get official data (now that we know they're registered)
      final officialData = await _authRepo.getOfficialDriverData(license, nic);
      if (officialData == null) {
        Get.back();
        Get.snackbar(
          'Error',
          'Could not retrieve driver details',
          duration: const Duration(seconds: 5),
          colorText: Colors.white,
          backgroundColor: Colors.red.withOpacity(0.7),
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // 3. Create account
      final String email = '$license@fineline.com';
      await _authRepo.registerWithEmailAndPassword(email, password);
      await _authRepo.saveDriverDetails(
        username: username,
        license: license,
        nic: nic,
        phone: phone,
        email: email,
        officialData: officialData,
      );

      Get.back();
      Get.off(() => HomePage(username: username));
    } catch (e) {
      Get.back();
      String errorMessage = 'Registration failed';

      if (e is FirebaseAuthException) {
        errorMessage = 'Auth error: ${e.message}';
      } else {
        errorMessage = 'Error: ${e.toString()}';
      }

      Get.snackbar(
        'Error',
        errorMessage,
        duration: const Duration(seconds: 5),
        colorText: Colors.white,
        backgroundColor: Colors.red.withOpacity(0.7),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
