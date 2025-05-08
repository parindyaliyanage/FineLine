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

              // Add the logo image here
              Container(
                height: 340, // Adjusted height to fit better
                padding: const EdgeInsets.all(20),
                child: Image.asset(
                  'assets/FineLineLogo.png',
                  fit: BoxFit.contain,
                ),
              ),

              // White container with buttons
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 60), // Reduced top margin
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
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: Icon(icon, color: Color(0xFF1a4a7c), size: 28),
        title: Text(
          text,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1a4a7c),
          ),
        ),
        onTap: () {
          if (text == "Violation Submission") {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ViolationSubmission(officer: widget.officer),
              ),
            );
          }
          if (text == "Review Violations") {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ReviewViolationsScreen(officer: widget.officer),
              ),
            );
          }
          if (text == "Driver Details") {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DriverDetails(),
              ),
            );
          }
        },
      ),
    );
  }

}