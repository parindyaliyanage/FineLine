import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'SignInScreen.dart';
import 'homePage.dart';
import 'package:fineline/repositiries/driver_auth_repository.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

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
        title: const Text('Sign Up'),
      ),
      body: SingleChildScrollView(
        child: Container(
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 60),
                  const Text(
                    'Sign Up',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 50),
                  _buildTextField('Username', controller: _usernameController),
                  const SizedBox(height: 25),
                  _buildTextField('Driving License Number', controller: _licenseController),
                  const SizedBox(height: 25),
                  _buildTextField('NIC Number', controller: _nicController),
                  const SizedBox(height: 25),
                  _buildTextField('Phone Number', controller: _phoneController),
                  const SizedBox(height: 25),
                  _buildTextField(
                    'Password',
                    controller: _passwordController,
                    isPassword: true,
                  ),
                  const SizedBox(height: 50),
                  ElevatedButton(
                    onPressed: _handleSignUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(
                        fontSize: 20,
                        color: Color(0xFF1a4a7c),
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      String label, {
        bool isPassword = false,
        required TextEditingController controller,
      }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white54),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
      style: const TextStyle(color: Colors.white),
    );
  }

  void _handleSignUp() async {
    final String username = _usernameController.text.trim();
    final String license = _licenseController.text.trim();
    final String nic = _nicController.text.trim();
    final String phone = _phoneController.text.trim();
    final String password = _passwordController.text.trim();

    if (username.isEmpty || license.isEmpty || nic.isEmpty || phone.isEmpty || password.isEmpty) {
      Get.snackbar('Error', 'Please fill in all fields');
      return;
    }

    try {
      // 1. Check if driver exists in official records (updated method name)
      final isRegistered = await _authRepo.isDriverRegistered(license, nic);
      if (!isRegistered) {
        throw Exception('Your license/NIC is not registered in our system');
      }

      // 2. Get official driver data
      final officialData = await _authRepo.getOfficialDriverData(license, nic) ?? {};

      // 3. Create account with both username and official data
      final String email = '$license@fineline.com';
      await _authRepo.registerWithEmailAndPassword(email, password);
      await _authRepo.saveDriverDetails(
        username: username,
        license: license,
        nic: nic,
        phone: phone,
        email: email,
        officialData: officialData, // Now includes required parameter
      );

      Get.off(() => HomePage(username: username));
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }
}