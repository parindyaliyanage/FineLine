import 'package:fineline/screens/driver/Hamburger.dart';
import 'package:flutter/material.dart';
import 'package:fineline/screens/driver/Notification.dart';
import 'package:fineline/screens/driver/HistoryPage.dart';
import 'package:fineline/screens/driver/PaymentPage.dart';
import 'package:fineline/screens/driver/SignUpScreen.dart';
import 'package:fineline/screens/driver/ViolationDetails.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  final String username;

  const HomePage({super.key, required this.username});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _pendingViolationId;

  @override
  void initState() {
    super.initState();
    _fetchPendingViolation();
  }

  Future<void> _fetchPendingViolation() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final query = await _firestore.collection('violations')
          .where('identifier', whereIn: [user.uid])
          .where('status', isEqualTo: 'pending')
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        setState(() {
          _pendingViolationId = query.docs.first.id;
        });
      }
    } catch (e) {
      print('Error fetching pending violation: $e');
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
                            builder: (context) => Hamburger(username: widget.username),
                          ),
                        );
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      splashRadius: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Hello, ${widget.username}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
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
                      _buildButton('Notification', Icons.notifications),
                      const SizedBox(height: 16),
                      _buildButton('History', Icons.history),
                      const SizedBox(height: 16),
                      _buildButton('Payments', Icons.payment),
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
      child: ElevatedButton(
        onPressed: () {
          if (text == "Notification") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NotificationPage()),
            );
          }
          if (text == "History") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HistoryPage()),
            );
          }
          if (text == "Payments") {
            if (_pendingViolationId != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PaymentPage(violationId: _pendingViolationId!),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('No pending violations to pay'),
                  backgroundColor: Colors.orange,
                ),
              );
            }
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 2,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}