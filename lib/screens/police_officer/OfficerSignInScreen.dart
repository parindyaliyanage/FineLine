import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fineline/screens/police_officer/OfficerHomeScreen.dart';
import 'package:fineline/repositiries/officer_auth_repository.dart';
import 'package:fineline/screens/role-selection.dart';

class OfficerSignInScreen extends StatefulWidget {
  const OfficerSignInScreen({super.key});

  @override
  State<OfficerSignInScreen> createState() => _OfficerSignInScreenState();
}

class _OfficerSignInScreenState extends State<OfficerSignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _badgeNumberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final OfficerAuthRepository _officerAuth = OfficerAuthRepository();

  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _signInOfficer() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final officer = await _officerAuth.signInOfficer(
        _badgeNumberController.text.trim(),
        _passwordController.text.trim(),
      );

      // Clear sensitive data before navigation
      _passwordController.clear();

      Get.offAll(() => OfficerHomeScreen(officer: officer),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut);

    } catch (e) {
      debugPrint("Full Error: $e");
      String errorMessage = 'Authentication failed';
      if (e.toString().contains('PERMISSION_DENIED')) {
        errorMessage = 'System maintenance in progress';
      } else if (e.toString().contains('Invalid credentials')) {
        errorMessage = 'Invalid badge number or password';
      }

      Get.snackbar(
        'Sign In Failed',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[400]!,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Back button
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        _passwordController.clear();
                        Get.offAll(() => RoleSelectionScreen());
                      },
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    'Police Officer Sign In',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 50),
                  _buildTextField(
                    label: 'Badge Number',
                    controller: _badgeNumberController,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 25),
                  _buildPasswordField(),
                  const SizedBox(height: 50),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _signInOfficer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 4,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Color(0xFF1a4a7c),
                        strokeWidth: 2,
                      ),
                    )
                        : const Text(
                      'Sign In',
                      style: TextStyle(
                        fontSize: 20,
                        color: Color(0xFF1a4a7c),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.only(top: 16.0),
                      child: LinearProgressIndicator(
                        color: Colors.white,
                        backgroundColor: Colors.transparent,
                        minHeight: 2,
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

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white54),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        errorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
        ),
        errorStyle: const TextStyle(color: Colors.red),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your $label';
        }
        if (label == 'Badge Number' && !RegExp(r'^[0-9]+$').hasMatch(value)) {
          return 'Badge number must contain only digits';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: 'Password',
        labelStyle: const TextStyle(color: Colors.white70),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility : Icons.visibility_off,
            color: Colors.white70,
          ),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white54),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        errorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
        ),
        errorStyle: const TextStyle(color: Colors.red),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your password';
        }
        if (value.length < 6) {
          return 'Password must be at least 6 characters';
        }
        return null;
      },
    );
  }

  @override
  void dispose() {
    _badgeNumberController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}