import 'package:fineline/screens/homePage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../repositiries/authentication_repository.dart';
import 'SignInScreen.dart';


class Hamburger extends StatefulWidget {
  final String username;

  const Hamburger({
    Key? key,
    required this.username,
  }) : super(key: key);

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
                        icon: Icon(Icons.close),
                        onPressed: () {
                          // Navigate to HomePage
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => HomePage(username: widget.username)),
                          );
                        },
                      ),
                    ],
                  ),
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Color(0xFF1a4a7c),
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    widget.username,
                    style: TextStyle(
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
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                    onTap: () async {
                      try {
                        // Get the AuthenticationRepository instance
                        final authRepo = Get.find<AuthenticationRepository>();

                        // Sign out
                        await authRepo.signOut();

                        // Navigate to SignInScreen and clear all routes
                        Get.offAll(() => SignInScreen());

                        // Optional: Show success message
                        Get.snackbar(
                          'Logged Out',
                          'You have been successfully logged out',
                          backgroundColor: Colors.green,
                          colorText: Colors.white,
                        );
                      } catch (e) {
                        // Show error message if logout fails
                        Get.snackbar(
                          'Error',
                          'Failed to log out: ${e.toString()}',
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                        );
                      }
                    },
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
      margin: EdgeInsets.symmetric(vertical: 4),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: ListTile(
          leading: Icon(
            icon,
            color: Color(0xFF1a4a7c),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          onTap: onTap,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        ),
      ),
    );
  }
}