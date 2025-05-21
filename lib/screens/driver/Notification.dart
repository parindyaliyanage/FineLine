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
    if (user == null) return const Stream.empty();

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

  Future<void> _markAsViewed(String violationId) async {
    try {
      await _firestore.collection('violations').doc(violationId).update({
        'isViewed': true,
      });
    } catch (e) {
      debugPrint('Error marking violation as viewed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Violation Notification",
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
              final isNew = data['isViewed'] == false;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                color: isNew ? Colors.blue[50] : null, // Highlight new violations
                child: InkWell(
                  onTap: () {
                    if (isNew) {
                      _markAsViewed(violation.id);
                    }
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
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  if (isNew)
                                    Container(
                                      margin: const EdgeInsets.only(right: 8),
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  Expanded(
                                    child: Text(
                                      data['violations']?.first ?? 'Violation',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
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
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (isNew)
                              const Chip(
                                label: Text('NEW',
                                    style: TextStyle(color: Colors.white)),
                                backgroundColor: const Color(0xFF1a4a7c),
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
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Invalid date';
    }
  }
}