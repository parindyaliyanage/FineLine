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

      _passwordController.clear();
      Get.offAll(() => OfficerHomeScreen(officer: officer));
    } catch (e) {
      debugPrint("Error: $e");
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
            colors: [Color(0xFF1a4a7c), Color(0xFF2c5c8f)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: Column(
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

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        const Text(
                          'Police Officer Sign In',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 40),
                        _buildTextField(
                          label: 'Badge Number',
                          controller: _badgeNumberController,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 25),
                        _buildPasswordField(),
                      ],
                    ),
                  ),
                ),

                // Sign In Button at bottom
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _signInOfficer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Color(0xFF1a4a7c),
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
                  ),
                ),
              ],
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
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
            color: Colors.white70,
          ),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
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