import 'dart:async';
import 'package:fineline/screens/driver/Hamburger.dart';
import 'package:fineline/screens/driver/ViolationDashboard.dart';
import 'package:flutter/material.dart';
import 'package:fineline/screens/driver/Notification.dart';
import 'package:fineline/screens/driver/HistoryPage.dart';
import 'package:fineline/screens/driver/PaymentPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

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
  List<Map<String, dynamic>> _userViolations = [];
  bool _isLoadingViolations = true;

  @override
  void initState() {
    super.initState();
    _fetchPendingViolation();
    _setupViolationListener();
    _fetchUserViolations();
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

  Future<void> _fetchUserViolations() async {
    setState(() => _isLoadingViolations = true);
    final user = _auth.currentUser;
    if (user == null) {
      setState(() => _isLoadingViolations = false);
      return;
    }

    try {
      // First try to get user data to find all possible identifiers
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final userData = userDoc.data();

      // Get all possible identifiers (license, NIC, etc.)
      final identifiers = [
        userData?['license'],
        userData?['nic'],
        userData?['identifier'],
        user.uid  // Also include user ID as identifier
      ].whereType<String>().toList();

      if (identifiers.isEmpty) {
        setState(() {
          _userViolations = [];
          _isLoadingViolations = false;
        });
        return;
      }

      // Query violations with all possible identifiers
      final query = await _firestore.collection('violations')
          .where('identifier', whereIn: identifiers)
          .orderBy('dateTime', descending: true)
          .get();

      setState(() {
        _userViolations = query.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList();
        _isLoadingViolations = false;
      });
    } catch (e) {
      print('Error fetching violations: $e');
      setState(() {
        _userViolations = [];
        _isLoadingViolations = false;
      });
    }
  }

  bool _isSafeDriver() {
    if (_userViolations.isEmpty) return true;

    final now = DateTime.now();
    final threeMonthsAgo = DateTime(now.year, now.month - 3, now.day);

    // Check if any violation is within the last 3 months
    bool hasRecentViolation = _userViolations.any((violation) {
      try {
        final dateString = violation['dateTime'];
        if (dateString == null) return false;

        final date = DateTime.parse(dateString);
        return date.isAfter(threeMonthsAgo);
      } catch (e) {
        print('Error parsing violation date: $e');
        return false;
      }
    });

    return !hasRecentViolation;
  }

  bool _hasRisingViolations() {
    if (_userViolations.isEmpty) return false;

    final now = DateTime.now();
    final oneMonthAgo = DateTime(now.year, now.month - 1, now.day);

    // Count violations in the last month
    int violationsThisMonth = _userViolations.where((violation) {
      try {
        final dateString = violation['dateTime'];
        if (dateString == null) return false;

        final date = DateTime.parse(dateString);
        return date.isAfter(oneMonthAgo);
      } catch (e) {
        print('Error parsing violation date: $e');
        return false;
      }
    }).length;

    return violationsThisMonth >= 2;
  }

  bool _hasCriticalWarning(int demeritPointsLeft) {
    return demeritPointsLeft <= 2;
  }

  Widget _buildWarningCards() {
    if (_isLoadingViolations) {
      return const SizedBox.shrink();
    }

    // Calculate demerit points
    int totalDemeritPoints = 0;
    for (var violation in _userViolations) {
      if (violation['violations'] != null && violation['violations'] is List) {
        totalDemeritPoints += (violation['violations'] as List).length;
      }
    }
    final demeritPointsLeft = 6 - totalDemeritPoints.clamp(0, 6);

    final cards = <Widget>[];

    if (_isSafeDriver()) {
      cards.add(
        Card(
          color: Colors.green[100],
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: const Icon(Icons.thumb_up, color: Colors.green),
            title: const Text("Drive safe! You haven't had a violation in 3 months."),
          ),
        ),
      );
    }

    if (_hasRisingViolations()) {
      cards.add(
        Card(
          color: Colors.orange[100],
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: const Icon(Icons.warning, color: Colors.orange),
            title: const Text("Caution: Your violations are increasing this month."),
          ),
        ),
      );
    }

    if (_hasCriticalWarning(demeritPointsLeft)) {
      cards.add(
        Card(
          color: Colors.red[100],
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: const Icon(Icons.dangerous, color: Colors.red),
            title: Text("Warning: Only $demeritPointsLeft demerit point${demeritPointsLeft == 1 ? '' : 's'} remaining. Drive carefully!"),
          ),
        ),
      );
    }

    return Column(children: cards);
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

              // Logo and warning cards
              Container(
                height: 400,
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Image.asset(
                      'assets/FineLineLogo.png',
                      fit: BoxFit.contain,
                      height: 200,
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: _buildWarningCards(),
                      ),
                    ),
                  ],
                ),
              ),

              // White container with buttons
              Expanded(
                child: Container(
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
                      _buildButton('Violation Dashboard', Icons.payment, () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ViolationDashboard(),
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