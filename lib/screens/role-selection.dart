import 'package:fineline/screens/police_officer/OfficerSignInScreen.dart';
import 'package:flutter/material.dart';
import 'package:fineline/screens/driver/SignUpScreen.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Select Your Role")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RoleCard(
              icon: Icons.directions_car,
              title: "Driver",
              onTap: () {
                Get.to(() => SignUpScreen());
              },
            ),
            SizedBox(height: 20),
            RoleCard(
              icon: Icons.local_police,
              title: "Police Officer",
              onTap: () {
                Get.to(() => OfficerSignInScreen());
              },
            ),
          ],
        ),
      ),
    );
  }
}

class RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const RoleCard({super.key, required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 5,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(icon, size: 60, color: Colors.blue[800]),
              SizedBox(height: 10),
              Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}