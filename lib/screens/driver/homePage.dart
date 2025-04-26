import 'dart:async';
import 'package:fineline/screens/driver/Hamburger.dart';
import 'package:flutter/material.dart';
import 'package:fineline/screens/driver/Notification.dart';
import 'package:fineline/screens/driver/HistoryPage.dart';
import 'package:fineline/screens/driver/PaymentPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'PaymentHistoryPage.dart';

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
  int _unseenViolations = 0;
  StreamSubscription? _violationSubscription;

  @override
  void initState() {
    super.initState();
    _fetchPendingViolation();
    _setupViolationListener();
  }

  @override
  void dispose() {
    _violationSubscription?.cancel();
    super.dispose();
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

  void _setupViolationListener() {
    final user = _auth.currentUser;
    if (user == null) return;

    _violationSubscription = _firestore.collection('violations')
        .where('identifier', whereIn: [user.uid])
        .where('isViewed', isEqualTo: false)
        .snapshots()
        .listen((snapshot) {
      setState(() => _unseenViolations = snapshot.size);
    });
  }

  Future<void> _markViolationsAsSeen() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final query = await _firestore.collection('violations')
          .where('identifier', whereIn: [user.uid])
          .where('isViewed', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (var doc in query.docs) {
        batch.update(doc.reference, {'isViewed': true});
      }
      await batch.commit();

      setState(() => _unseenViolations = 0);
    } catch (e) {
      print('Error marking violations as seen: $e');
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


              Container(
                height: 400,
                padding: const EdgeInsets.all(20),
                child: Image.asset(
                  'assets/FineLineLogo.png',
                  fit: BoxFit.contain,
                ),
              ),

              // White container with buttons
              Expanded(
                child: Container(
                  // Change margin to 100 to accommodate the image
                  margin: const EdgeInsets.only(top: 30),
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
                      _buildNotificationButton(),
                      const SizedBox(height: 16),
                      _buildButton('History', Icons.history, () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ViolationHistoryPage()),
                        );
                      }),
                      const SizedBox(height: 16),
                  // In your build method, update the Payments button section:
                  _buildButton('Payments', Icons.payment, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PaymentHistoryPage(),
                      ),
                    );
                  }),
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

  Widget _buildNotificationButton() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          ElevatedButton(
            onPressed: () async {
              await _markViolationsAsSeen();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationPage()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2c5c8f),
              foregroundColor: Colors.white,
              elevation: 2,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
                side: BorderSide(color: Colors.white),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.notifications, color: Colors.white),
                const SizedBox(width: 8),
                const Text(
                  'Notifications',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (_unseenViolations > 0)
            Positioned(
              right: 8,
              top: 8,
              child: CircleAvatar(
                radius: 10,
                backgroundColor: Colors.red,
                child: Text(
                  _unseenViolations.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildButton(String text, IconData icon, VoidCallback onPressed) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2c5c8f),
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: BorderSide(color: Colors.white),
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