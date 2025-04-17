import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fineline/screens/driver/PaymentPage.dart';

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
          "Notifications",
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

              return _buildViolationCard(data, violation.id);
            },
          );
        },
      ),
    );
  }

  Widget _buildViolationCard(Map<String, dynamic> data, String violationId) {
    final dateTime = DateTime.parse(data['dateTime'] as String);
    final formattedDate = '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    final formattedTime = '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';

    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Violation Notice',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                Chip(
                  label: Text(
                    data['status'] ?? 'pending',
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: _getStatusColor(data['status'] ?? 'pending'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Issued by: ${data['officerName'] ?? 'Unknown Officer'} (Badge: ${data['officerBadge'] ?? 'N/A'})',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              'Date: $formattedDate at $formattedTime',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              'Location: ${data['venue'] ?? 'Not specified'}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            const Text(
              'Violations:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ...(data['violations'] as List).map((v) =>
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                  child: Text('- $v'),
                )
            ),
            const SizedBox(height: 8),
            Text(
              'Total Fine: LKR ${(data['fineAmount'] as num?)?.toStringAsFixed(2) ?? '0.00'}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            if ((data['status'] as String?) == 'pending') ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PaymentPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1a4a7c),
                  ),
                  child: const Text('Pay Now'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
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