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
  bool _obscurePassword = true;  // Default to true to hide password
  bool _obscureConfirmPassword = true;  // Default to true to hide confirm password

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
      backgroundColor: const Color(0xFF1a4a7c),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Sign Up', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
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
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    kToolbarHeight,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      const SizedBox(height: 20),
                      const Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Fill in your details to get started',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 40),
                      _buildTextField('Username', _usernameController),
                      const SizedBox(height: 20),
                      _buildTextField('Driving License Number', _licenseController),
                      const SizedBox(height: 20),
                      _buildTextField('NIC Number', _nicController),
                      const SizedBox(height: 20),
                      _buildTextField('Phone Number', _phoneController),
                      const SizedBox(height: 20),
                      _buildPasswordField('Password', _passwordController, _obscurePassword, (value) {
                        setState(() => _obscurePassword = value);
                      }),
                      const SizedBox(height: 20),
                      _buildPasswordField('Confirm Password', _confirmPasswordController, _obscureConfirmPassword, (value) {
                        setState(() => _obscureConfirmPassword = value);
                      }),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _handleSignUp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF1a4a7c),
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF1a4a7c),
                          ),
                        )
                            : const Text(
                          'SIGN UP',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20, top: 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Already have an account? ",
                          style: TextStyle(color: Colors.white70),
                        ),
                        GestureDetector(
                          onTap: () => Get.to(() => const SignInScreen()),
                          child: const Text(
                            'Sign In',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.white),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
      ),
    );
  }

  Widget _buildPasswordField(
      String label,
      TextEditingController controller,
      bool obscureText,
      Function(bool) onVisibilityChanged,
      ) {
    return TextField(
      controller: controller,
      obscureText: obscureText,  // This will hide password by default
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.white),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_off : Icons.visibility,
            color: Colors.white70,
          ),
          onPressed: () {
            onVisibilityChanged(!obscureText);
          },
        ),
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