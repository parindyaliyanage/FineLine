import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fineline/models/officer_model.dart';
import 'package:fineline/repositiries/officer_auth_repository.dart';
import 'OfficerDetailsScreen.dart';
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
                          Navigator.pop(context);
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
                    officer.fullName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Badge: ${officer.badgeNumber}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    officer.department,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
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
                    title: 'View Profile',
                    onTap: () {
                      Navigator.pop(context);
                      Get.to(() => OfficerDetailsScreen(officer: officer));
                    },
                  ),

                  _buildMenuItem(
                    icon: Icons.help,
                    title: 'Support',
                    onTap: () {
                      Navigator.pop(context);
                      // Handle support
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.description,
                    title: 'Terms & Conditions',
                    onTap: () {
                      Navigator.pop(context);
                      // Handle terms
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.settings,
                    title: 'Settings',
                    onTap: () {
                      Navigator.pop(context);
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