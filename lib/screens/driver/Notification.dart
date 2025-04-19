import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fineline/screens/driver/ViolationDetails.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late Stream<QuerySnapshot<Map<String, dynamic>>> _violationsStream;

  @override
  void initState() {
    super.initState();
    _violationsStream = _getViolationsStream();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _getViolationsStream() {
    final user = _auth.currentUser;
    if (user == null) {
      return const Stream.empty();
    }

    return _firestore.collection('users').doc(user.uid).snapshots().asyncExpand((userDoc) {
      final userData = userDoc.data();
      final license = userData?['license'] as String?;
      final nic = userData?['nic'] as String?;

      if (license == null && nic == null) return const Stream.empty();

      return _firestore.collection('violations')
          .where('identifier', whereIn: [license, nic].whereType<String>().toList())
          .orderBy('dateTime', descending: true)
          .snapshots();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Violation History",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1a4a7c),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _violationsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No violations found'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final violation = snapshot.data!.docs[index];
              final data = violation.data();

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ViolationDetailsPage(
                          violationData: data,
                          violationId: violation.id,
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['violations']?.first ?? 'Violation',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'LKR ${(data['fineAmount'] as num?)?.toStringAsFixed(2) ?? '0.00'}',
                              style: TextStyle(
                                color: Colors.red[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Chip(
                              label: Text(
                                data['status'] ?? 'pending',
                                style: const TextStyle(color: Colors.white),
                              ),
                              backgroundColor: _getStatusColor(data['status'] ?? 'pending'),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatDate(data['dateTime']),
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatDate(String? dateTime) {
    if (dateTime == null) return 'N/A';
    try {
      final dt = DateTime.parse(dateTime);
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (e) {
      return 'Invalid date';
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'disputed':
        return Colors.blue;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.red;
    }
  }
}