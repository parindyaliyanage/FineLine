import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting

class ViolationHistoryPage extends StatelessWidget {
  // Sample data - in real app, this would come from Firestore
  final List<Violation> violations = [
    Violation(
      type: 'Speeding',
      amount: 5000.00,
      date: DateTime.now().subtract(Duration(days: 2)),
      status: ViolationStatus.paid,
    ),
    Violation(
      type: 'Traffic Signal Violation',
      amount: 8000.00,
      date: DateTime.now().subtract(Duration(days: 3)),
      status: ViolationStatus.pending,
    ),
    Violation(
      type: 'Illegal Parking',
      amount: 3000.00,
      date: DateTime.now().subtract(Duration(days: 10)),
      status: ViolationStatus.overdue,
    ),
    Violation(
      type: 'No Seatbelt',
      amount: 1000.00,
      date: DateTime.now().subtract(Duration(days: 1)),
      status: ViolationStatus.pending,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // Calculate summary counts
    final totalCount = violations.length;
    final paidCount = violations.where((v) => v.status == ViolationStatus.paid).length;
    final unpaidCount = violations.where((v) => v.status != ViolationStatus.paid).length;

    return Scaffold(
      appBar: AppBar(
        title: Text('Violation History'),
        backgroundColor: Color(0xFF0D47A1), // Deep Blue
      ),
      body: Column(
        children: [
          // Summary Card
          Container(
            margin: EdgeInsets.all(16),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFFE3F2FD),
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
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: violations.length,
              itemBuilder: (context, index) {
                final violation = violations[index];
                return _buildViolationCard(violation);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String count, IconData icon, Color iconColor) {
    return Column(
      children: [
        Icon(icon, color: iconColor),
        SizedBox(height: 4),
        Text(count, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 4),
        Text(label, textAlign: TextAlign.center),
      ],
    );
  }

  Widget _buildViolationCard(Violation violation) {
    // Get appropriate icon for violation type
    final iconData = _getViolationIcon(violation.type);
    final iconColor = _getViolationColor(violation.type);

    // Format date
    final dateFormat = DateFormat('d/M/yyyy');
    final dateString = dateFormat.format(violation.date);

    // Calculate days remaining/overdue
    final dueDate = violation.date.add(Duration(days: 7));
    final daysDifference = dueDate.difference(DateTime.now()).inDays;

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(iconData, color: iconColor, size: 30),
        title: Text(violation.type, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('LKR ${violation.amount.toStringAsFixed(2)}'),
            SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(violation.status).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _getStatusText(violation.status),
                    style: TextStyle(
                      color: _getStatusColor(violation.status),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                if (violation.status != ViolationStatus.paid)
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
      ),
    );
  }

  // Helper methods
  IconData _getViolationIcon(String type) {
    switch (type) {
      case 'Speeding': return Icons.speed;
      case 'Traffic Signal Violation': return Icons.traffic;
      case 'Illegal Parking': return Icons.local_parking;
      case 'No Seatbelt': return Icons.airline_seat_recline_normal;
      case 'Not Carrying License': return Icons.badge;
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
      case 'Not Carrying License': return Colors.brown;
      case 'Wrong Way Driving': return Colors.teal;
      case 'No Helmets': return Colors.black;
      default: return Colors.grey;
    }
  }

  Color _getStatusColor(ViolationStatus status) {
    switch (status) {
      case ViolationStatus.paid: return Colors.green;
      case ViolationStatus.pending: return Colors.orange;
      case ViolationStatus.overdue: return Colors.red;
    }
  }

  String _getStatusText(ViolationStatus status) {
    switch (status) {
      case ViolationStatus.paid: return 'Paid ✅';
      case ViolationStatus.pending: return 'Pending 🕒';
      case ViolationStatus.overdue: return 'Overdue ⚠️';
    }
  }
}

// Data model
class Violation {
  final String type;
  final double amount;
  final DateTime date;
  final ViolationStatus status;

  Violation({
    required this.type,
    required this.amount,
    required this.date,
    required this.status,
  });
}

enum ViolationStatus {
  paid,
  pending,
  overdue,
}