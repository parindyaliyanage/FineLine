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
  final TextEditingController _confirmPasswordController = TextEditingController();

  final DriverAuthRepository _authRepo = Get.find();
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _licenseController.dispose();
    _nicController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1a4a7c),
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1a4a7c), Color(0xFF2c5c8f)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 40),
                const Text('Sign Up', style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
                const SizedBox(height: 40),
                _buildTextField('Username', _usernameController),
                const SizedBox(height: 20),
                _buildTextField('Driving License Number', _licenseController),
                const SizedBox(height: 20),
                _buildTextField('NIC Number', _nicController),
                const SizedBox(height: 20),
                _buildTextField('Phone Number', _phoneController),
                const SizedBox(height: 20),
                _buildTextField('Password', _passwordController, isPassword: true),
                const SizedBox(height: 20),
                _buildTextField('Confirm Password', _confirmPasswordController, isPassword: true),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleSignUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF1a4a7c),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('SIGN UP', style: TextStyle(fontSize: 18)),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => Get.to(() => const SignInScreen()),
                  child: const Text('Already have an account? Sign In',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Colors.white30)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Colors.white)),
      ),
    );
  }

  void _handleSignUp() async {
    final username = _usernameController.text.trim();
    final license = _licenseController.text.trim();
    final nic = _nicController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (username.isEmpty || license.isEmpty || nic.isEmpty ||
        phone.isEmpty || password.isEmpty) {
      _showError('Please fill in all fields');
      return;
    }

    if (password != confirmPassword) {
      _showError('Passwords do not match');
      return;
    }

    if (password.length < 6) {
      _showError('Password must be at least 6 characters');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Check if driver exists in official records
      final isRegistered = await _authRepo.isDriverRegistered(license, nic);
      if (!isRegistered) {
        throw 'No matching driver found with provided license/NIC';
      }

      // Check if email already exists
      final email = '$license$nic@fineline.com';
      final methods = await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
      if (methods.isNotEmpty) {
        throw 'Account already exists for this license/NIC';
      }

      // Get official data
      final officialData = await _authRepo.getOfficialDriverData(license, nic);
      if (officialData == null) {
        throw 'Could not retrieve driver details';
      }

      // Create account
      await _authRepo.registerWithEmailAndPassword(email, password);
      await _authRepo.saveDriverDetails(
        username: username,
        license: license,
        nic: nic,
        phone: phone,
        email: email,
        officialData: officialData,
      );

      Get.off(() => HomePage(username: username));
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      colorText: Colors.white,
      backgroundColor: Colors.red.withOpacity(0.7),
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}