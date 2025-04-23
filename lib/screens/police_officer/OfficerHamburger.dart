import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fineline/models/officer_model.dart';
import 'package:fineline/repositiries/officer_auth_repository.dart';
import 'OfficerSignInScreen.dart';

class OfficerHamburger extends StatelessWidget {
  final Officer officer;

  const OfficerHamburger({super.key, required this.officer});

  Future<void> _handleLogout() async {
    try {
      // Show loading indicator
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      // Create new instance with explicit type
      final OfficerAuthRepository authRepo = OfficerAuthRepository();
      await authRepo.signOut();

      // Close dialog and navigate
      if (Get.isDialogOpen!) Get.back();
      Get.offAll(() => const OfficerSignInScreen());

      Get.snackbar('Success', 'Logged out successfully',
          backgroundColor: Colors.green);
    } catch (e) {
      if (Get.isDialogOpen!) Get.back();
      Get.snackbar('Error', 'Logout failed: ${e.toString()}',
          backgroundColor: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with back button and officer info
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              color: const Color(0xFF1a4a7c),
              height: 80,
              child: Row(
                children: [
                  // Back button
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                    iconSize: 24,
                  ),
                  const SizedBox(width: 8),
                  // Officer info with avatar and text side by side
                  const CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 34,
                      color: Color(0xFF1a4a7c),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Officer details
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        officer.fullName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Badge : ${officer.badgeNumber}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        officer.department,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Menu items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(top: 20),
                children: [
                  _buildMenuItem(
                    context,
                    icon: Icons.business,
                    title: 'Office Name',
                    onTap: () {
                      // Handle office name tap
                    },
                  ),
                  const Divider(height: 1),
                  _buildMenuItem(
                    context,
                    icon: Icons.edit,
                    title: 'Edit Profile',
                    onTap: () {
                      // Handle edit profile tap
                    },
                  ),
                  const Divider(height: 1),
                  _buildMenuItem(
                    context,
                    icon: Icons.help,
                    title: 'Support',
                    onTap: () {
                      // Handle support tap
                    },
                  ),
                  const Divider(height: 1),
                  _buildMenuItem(
                    context,
                    icon: Icons.description,
                    title: 'Terms & Conditions',
                    onTap: () {
                      // Handle terms tap
                    },
                  ),
                  const Divider(height: 1),
                  _buildMenuItem(
                    context,
                    icon: Icons.settings,
                    title: 'Settings',
                    onTap: () {
                      // Handle settings tap
                    },
                  ),
                  const Divider(height: 1),
                  _buildMenuItem(
                    context,
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

  Widget _buildMenuItem(
      BuildContext context, {
        required IconData icon,
        required String title,
        required VoidCallback onTap,
      }) {
    return ListTile(
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
      trailing: const Icon(
        Icons.chevron_right,
        color: Colors.grey,
      ),
      onTap: onTap,
    );
  }
}