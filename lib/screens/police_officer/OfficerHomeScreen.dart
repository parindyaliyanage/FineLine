import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fineline/models/officer_model.dart';

class OfficerHomeScreen extends StatelessWidget {
  final Officer officer;

  const OfficerHomeScreen({Key? key, required this.officer}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${officer.fullName}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Get.offAllNamed('/role-selection');
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Badge Number: ${officer.badgeNumber}'),
            Text('Department: ${officer.department}'),
            Text('data')

          ],
        ),
      ),
    );
  }
}