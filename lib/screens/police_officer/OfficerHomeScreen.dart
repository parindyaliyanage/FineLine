import 'package:flutter/material.dart';
import 'package:fineline/models/officer_model.dart';
import 'package:fineline/screens/police_officer/OfficerHamburger.dart';
import 'package:fineline/screens/police_officer/ReviewViolationsScreen.dart';

import 'DriverDetails.dart';
import 'ViolationSubmission.dart';

class OfficerHomeScreen extends StatefulWidget {
  final Officer officer;

  const OfficerHomeScreen({super.key, required this.officer});

  @override
  _OfficerHomeScreenState createState() => _OfficerHomeScreenState();
}

class _OfficerHomeScreenState extends State<OfficerHomeScreen> {
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
          child: Column(
            children: [
              // Top greeting section
              Container(
                padding: const EdgeInsets.all(16.0),
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.menu,
                        color: Colors.white,
                        size: 24,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OfficerHamburger(officer: widget.officer),
                          ),
                        );
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      splashRadius: 24,
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Officer ${widget.officer.badgeNumber}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          widget.officer.station,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // White container with buttons
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 300),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildButton('Violation Submission', Icons.report),
                      const SizedBox(height: 16),
                      _buildButton('Review Violations', Icons.list_alt),
                      const SizedBox(height: 16),
                      _buildButton('Driver Details', Icons.person_search),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(String text, IconData icon) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ElevatedButton.icon(
        onPressed: () {
          if (text == "Violation Submission") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ViolationSubmission(officer: widget.officer)),
            );
          }
          if (text == "Review Violations") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ReviewViolationsScreen(officer: widget.officer)),
            );
          }
          if (text == "Driver Details") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DriverDetails()),
            );
          }
        },
        icon: Icon(icon, color: Color(0xFF1a4a7c)),
        label: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1a4a7c),
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: Colors.grey.shade300),
          ),
        ),
      ),
    );
  }
}