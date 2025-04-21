import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fineline/screens/driver/ViolationDetails.dart';

class ViolationHistoryPage extends StatefulWidget {
  const ViolationHistoryPage({Key? key}) : super(key: key);

  @override
  _ViolationHistoryPageState createState() => _ViolationHistoryPageState();
}

class _ViolationHistoryPageState extends State<ViolationHistoryPage> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Violation History',
        style: TextStyle(color: Colors.white),),
        backgroundColor: const Color(0xFF0D47A1),
        iconTheme: const IconThemeData(color: Colors.white),// Deep Blue
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

          final violations = snapshot.data!.docs;

          // Calculate summary counts
          final totalCount = violations.length;
          final paidCount = violations.where((doc) => doc.data()['status'] == 'paid').length;
          final unpaidCount = totalCount - paidCount;

          return Column(
            children: [
              // Summary Card
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSummaryItem('Total Violations', totalCount.toString(), Icons.list_alt, Colors.black),
                    _buildSummaryItem('Paid', paidCount.toString(), Icons.check_circle, Colors.green),
                    _buildSummaryItem('Unpaid', unpaidCount.toString(), Icons.warning_amber_rounded, Colors.orange),
                  ],
                ),
              ),

              // Violation List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: violations.length,
                  itemBuilder: (context, index) {
                    final violation = violations[index];
                    final data = violation.data();
                    return _buildViolationCard(context, data, violation.id);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummaryItem(String label, String count, IconData icon, Color iconColor) {
    return Column(
      children: [
        Icon(icon, color: iconColor),
        const SizedBox(height: 4),
        Text(count, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, textAlign: TextAlign.center),
      ],
    );
  }

  Widget _buildViolationCard(BuildContext context, Map<String, dynamic> violation, String violationId) {
    // Get the first violation type
    final violationType = (violation['violations'] as List?)?.isNotEmpty == true
        ? (violation['violations'] as List).first
        : 'Unknown Violation';

    // Get appropriate icon for violation type
    final iconData = _getViolationIcon(violationType);
    final iconColor = _getViolationColor(violationType);

    // Format date
    final dateString = _formatDate(violation['dateTime']);

    // Get status
    final status = violation['status'] ?? 'pending';

    // Calculate days remaining/overdue
    final dueDate = _calculateDueDate(violation['dateTime']);
    final daysDifference = dueDate.difference(DateTime.now()).inDays;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(iconData, color: iconColor, size: 30),
        title: Text(violationType, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('LKR ${(violation['fineAmount'] as num?)?.toStringAsFixed(2) ?? '0.00'}'),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _getStatusText(status),
                    style: TextStyle(
                      color: _getStatusColor(status),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (status != 'paid')
                  Text(
                    daysDifference >= 0
                        ? '${daysDifference}d left'
                        : '${-daysDifference}d overdue',
                    style: TextStyle(
                      color: daysDifference >= 0 ? Colors.grey[700] : Colors.red,
                    ),
                  ),
              ],
            ),
          ],
        ),
        trailing: Text(
          dateString,
          style: TextStyle(color: Colors.grey[700]),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ViolationDetailsPage(
                violationData: violation,
                violationId: violationId,
              ),
            ),
          );
        },
      ),
    );
  }

  DateTime _calculateDueDate(String? dateTime) {
    if (dateTime == null) return DateTime.now();
    try {
      final dt = DateTime.parse(dateTime);
      return dt.add(const Duration(days: 7)); // Assuming a 7-day payment window
    } catch (e) {
      return DateTime.now();
    }
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

  IconData _getViolationIcon(String type) {
    switch (type) {
      case 'Speeding': return Icons.speed;
      case 'Traffic Signal Violation': return Icons.traffic;
      case 'Illegal Parking': return Icons.local_parking;
      case 'No Seatbelt': return Icons.airline_seat_recline_normal;
      case 'Not Carrying Driving License': return Icons.badge;
      case 'Wrong Way Driving': return Icons.sync_problem;
      case 'No Helmets': return Icons.sports_motorsports;
      default: return Icons.warning;
    }
  }

  Color _getViolationColor(String type) {
    switch (type) {
      case 'Speeding': return Colors.red;
      case 'Traffic Signal Violation': return Colors.orange;
      case 'Illegal Parking': return Colors.blue;
      case 'No Seatbelt': return Colors.purple;
      case 'Not Carrying Driving License': return Colors.brown;
      case 'Wrong Way Driving': return Colors.teal;
      case 'No Helmets': return Colors.black;
      default: return Colors.grey;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid': return Colors.green;
      case 'pending': return Colors.orange;
      case 'overdue': return Colors.red;
      default: return Colors.orange;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'paid': return 'Paid ✅';
      case 'pending': return 'Pending 🕒';
      case 'overdue': return 'Overdue ⚠️';
      default: return status;
    }
  }
}