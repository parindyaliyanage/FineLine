import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ViolationDashboard extends StatefulWidget {
  const ViolationDashboard({super.key});

  @override
  State<ViolationDashboard> createState() => _ViolationDashboardState();
}

class _ViolationDashboardState extends State<ViolationDashboard> {
  bool _isLoading = true;
  int _totalViolations = 0;
  double _totalFinesPaid = 0.0;
  int _demeritPoints = 0;
  final int _maxDemeritPoints = 6;
  String _driverName = '';
  String? _driverIdentifier;
  String _debugInfo = '';

  @override
  void initState() {
    super.initState();
    _getCurrentUserData();
  }

  Future<void> _getCurrentUserData() async {
    setState(() {
      _isLoading = true;
      _debugInfo = 'Loading user data...';
    });

    try {
      // Get current user
      final User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        setState(() {
          _debugInfo = 'No user logged in';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _debugInfo = 'User found: ${currentUser.email}';
      });

      // Get user details from Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (!userDoc.exists) {
        // Try to find user record by email
        final userQuery = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: currentUser.email)
            .limit(1)
            .get();

        if (userQuery.docs.isEmpty) {
          setState(() {
            _debugInfo = 'User profile not found';
            _isLoading = false;
          });
          return;
        } else {
          // Use the first result
          final userData = userQuery.docs.first.data();
          _processUserData(userData, currentUser);
        }
      } else {
        // User doc exists
        final userData = userDoc.data();
        _processUserData(userData, currentUser);
      }
    } catch (e) {
      setState(() {
        _debugInfo = 'Error loading user data: $e';
        _isLoading = false;
      });
      print('Error loading user data: $e');
    }
  }

  void _processUserData(Map<String, dynamic>? userData, User currentUser) async {
    // Try multiple fields that might contain the identifier
    String? identifier = userData?['licenseNumber'] ??
        userData?['nic'] ??
        userData?['identifier'] ??
        userData?['drivingLicense'];

    _driverName = userData?['fullName'] ?? userData?['name'] ?? currentUser.email ?? 'Driver';

    if (identifier == null) {
      // Try to get the identifier from the drivers collection
      try {
        // Search by userId
        var driverQuery = await FirebaseFirestore.instance
            .collection('drivers')
            .where('userId', isEqualTo: currentUser.uid)
            .limit(1)
            .get();

        if (driverQuery.docs.isEmpty) {
          // Try by email
          driverQuery = await FirebaseFirestore.instance
              .collection('drivers')
              .where('email', isEqualTo: currentUser.email)
              .limit(1)
              .get();
        }

        if (driverQuery.docs.isNotEmpty) {
          final driverData = driverQuery.docs.first.data();
          identifier = driverData['licenseNumber'] ?? driverData['nic'];
          _driverName = driverData['fullName'] ?? _driverName;

          setState(() {
            _debugInfo = 'Found in drivers collection. Identifier: $identifier';
          });
        } else {
          setState(() {
            _debugInfo = 'No driver record found';
          });
        }
      } catch (e) {
        setState(() {
          _debugInfo = 'Error querying drivers: $e';
        });
      }
    } else {
      setState(() {
        _debugInfo = 'Found identifier in user data: $identifier';
      });
    }

    setState(() => _driverIdentifier = identifier);

    if (_driverIdentifier != null) {
      await _loadViolationsData();
    } else {
      setState(() {
        _debugInfo = 'Driver identifier not found';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadViolationsData() async {
    if (_driverIdentifier == null) return;

    setState(() {
      _debugInfo = 'Loading violations for $_driverIdentifier...';
    });

    try {
      // Try to find the driver document first to get BOTH identifiers
      final driverQueryByLicense = await FirebaseFirestore.instance
          .collection('drivers')
          .where('licenseNumber', isEqualTo: _driverIdentifier)
          .limit(1)
          .get();

      final driverQueryByNIC = await FirebaseFirestore.instance
          .collection('drivers')
          .where('nic', isEqualTo: _driverIdentifier)
          .limit(1)
          .get();

      // List to store both potential identifiers
      List<String> possibleIdentifiers = [_driverIdentifier!];

      // Add both licenseNumber and NIC to possible identifiers
      if (driverQueryByLicense.docs.isNotEmpty) {
        final driverData = driverQueryByLicense.docs.first.data();
        final license = driverData['licenseNumber'] as String?;
        final nic = driverData['nic'] as String?;

        if (license != null && !possibleIdentifiers.contains(license)) {
          possibleIdentifiers.add(license);
        }
        if (nic != null && !possibleIdentifiers.contains(nic)) {
          possibleIdentifiers.add(nic);
        }
      }

      if (driverQueryByNIC.docs.isNotEmpty) {
        final driverData = driverQueryByNIC.docs.first.data();
        final license = driverData['licenseNumber'] as String?;
        final nic = driverData['nic'] as String?;

        if (license != null && !possibleIdentifiers.contains(license)) {
          possibleIdentifiers.add(license);
        }
        if (nic != null && !possibleIdentifiers.contains(nic)) {
          possibleIdentifiers.add(nic);
        }
      }

      setState(() {
        _debugInfo = 'Searching with identifiers: ${possibleIdentifiers.join(", ")}';
      });

      // Now query violations with ALL possible identifiers
      final violationsSnapshot = await FirebaseFirestore.instance
          .collection('violations')
          .where('identifier', whereIn: possibleIdentifiers)
          .get();

      setState(() {
        _debugInfo = 'Found ${violationsSnapshot.docs.length} total violations for identifier $_driverIdentifier';
      });

      // Now filter for this year only in memory
      final currentYear = DateTime.now().year;
      final thisYearViolations = violationsSnapshot.docs.where((doc) {
        final data = doc.data();

        // Try multiple date fields
        Timestamp? timestamp;
        if (data['createAt'] is Timestamp) {
          timestamp = data['createAt'];
        } else if (data['dateTime'] is String) {
          try {
            final dt = DateTime.parse(data['dateTime']);
            // Convert to timestamp
            timestamp = Timestamp.fromDate(dt);
          } catch (e) {
            // Parsing failed, ignore
          }
        }

        if (timestamp != null) {
          final date = timestamp.toDate();
          return date.year == currentYear;
        }
        return false;
      }).toList();

      int violationCount = thisYearViolations.length;
      double finesPaid = 0.0;
      int demeritPoints = 0;

      setState(() {
        _debugInfo = '$_debugInfo\nFiltered to $violationCount violations for this year';
      });

      for (var doc in thisYearViolations) {
        final data = doc.data();

        // Calculate fines paid
        if (data['status'] == 'paid' && data['fineAmount'] != null) {
          finesPaid += (data['fineAmount'] as num).toDouble();
        }

        // Calculate demerit points based on violations
        if (data['violations'] != null && data['violations'] is List) {
          List<dynamic> violations = data['violations'];

          setState(() {
            _debugInfo = '$_debugInfo\nViolation ${doc.id} has ${violations.length} violation types';
          });

          for (var violation in violations) {
            String violationStr = violation.toString();

            // Extract violation type (parsing your format "Type: Amount")
            String violationType = violationStr.split(':').first.trim().toLowerCase();

            // Assign demerit points based on violation type
            if (violationType.contains('speeding')) {
              demeritPoints += 1;
            } else if (violationType.contains('traffic signal')) {
              demeritPoints += 1;
            } else if (violationType.contains('wrong way')) {
              demeritPoints += 1;
            } else if (violationType.contains('seatbelt')) {
              demeritPoints += 1;
            } else if (violationType.contains('license')) {
              demeritPoints += 1;
            } else if (violationType.contains('parking')) {
              demeritPoints += 1;
            } else if (violationType.contains('helmet')) {
              demeritPoints += 1;
            } else {
              demeritPoints += 1; // Default for any other violation types
            }
          }
        }
      }

      // Ensure demerit points don't exceed maximum
      demeritPoints = demeritPoints > _maxDemeritPoints ? _maxDemeritPoints : demeritPoints;

      setState(() {
        _totalViolations = violationCount;
        _totalFinesPaid = finesPaid;
        _demeritPoints = demeritPoints;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading violations data: $e');
      setState(() {
        _debugInfo = 'Error loading violations: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Violation Dashboard',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1a4a7c),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(_debugInfo),
            ),
          ],
        ),
      )
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_driverName.isNotEmpty) ...[
                Text(
                  _driverName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
              ],
              const Text(
                'Violation Statistics',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              _buildDemeritPointsIndicator(),
              const SizedBox(height: 30),
              _buildStatisticsCard(),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _getCurrentUserData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1a4a7c),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Refresh Data',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              // Development mode: Show debug info
              const SizedBox(height: 30),
              const Divider(),

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDemeritPointsIndicator() {
    final pointsLeft = _maxDemeritPoints - _demeritPoints;
    Color progressColor;

    // Set color based on points left
    if (pointsLeft > 4) {
      progressColor = Colors.green;
    } else if (pointsLeft >= 2 && pointsLeft <= 3) {
      progressColor = Colors.orange;
    } else {
      progressColor = Colors.red.shade800;
    }

    return Column(
      children: [
        const Text(
          'Active Demerit Points',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 200,
                height: 200,
                child: CircularProgressIndicator(
                  value: _demeritPoints / _maxDemeritPoints,
                  strokeWidth: 15,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$pointsLeft/$_maxDemeritPoints',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text('points left'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticsCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This Year:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildStatRow('Total Violations:', _totalViolations.toString()),
            const SizedBox(height: 8),
            _buildStatRow('Total Fines Paid:',
                'LKR ${_totalFinesPaid.toStringAsFixed(2)}'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}