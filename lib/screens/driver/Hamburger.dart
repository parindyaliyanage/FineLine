import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fineline/repositiries/driver_auth_repository.dart';
import 'SignInScreen.dart';

class Hamburger extends StatefulWidget {
  final String username;

  const Hamburger({
    super.key,
    required this.username,
  });

  @override
  State<Hamburger> createState() => _HamburgerState();
}

class _HamburgerState extends State<Hamburger> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            // User profile section
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          Navigator.pop(context); // Just close the drawer
                        },
                      ),
                    ],
                  ),
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Color(0xFF1a4a7c),
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.username,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            // Menu items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                children: [
                  _buildMenuItem(
                    icon: Icons.edit,
                    title: 'Edit Profile',
                    onTap: () {
                      // Handle edit profile
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.headphones,
                    title: 'Support',
                    onTap: () {
                      // Handle support
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.description,
                    title: 'Terms & Conditions',
                    onTap: () {
                      // Handle terms and conditions
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.settings,
                    title: 'Settings',
                    onTap: () {
                      // Handle settings
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.logout,
                    title: 'Log Out',
                    onTap: _handleLogout,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogout() async {
    try {
      // Show loading indicator
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      // Create a new instance of the repository
      final authRepo = DriverAuthRepository();
      await authRepo.signOut();

      // Close any open dialogs
      if (Get.isDialogOpen!) Get.back();

      // Navigate to SignInScreen and clear all routes
      Get.offAll(() => const SignInScreen());

      // Show success message
      Get.snackbar(
        'Logged Out',
        'You have been successfully logged out',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      // Close any open dialogs
      if (Get.isDialogOpen!) Get.back();

      // Show error message
      Get.snackbar(
        'Error',
        'Failed to log out: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: ListTile(
          leading: Icon(
            icon,
            color: const Color(0xFF1a4a7c),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        ),
      ),
    );
  }
}