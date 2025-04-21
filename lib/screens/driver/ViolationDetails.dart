import 'package:flutter/material.dart';
import 'package:fineline/screens/driver/PaymentPage.dart';

class ViolationDetailsPage extends StatelessWidget {
  final Map<String, dynamic> violationData;
  final String violationId;

  const ViolationDetailsPage({
    super.key,
    required this.violationData,
    required this.violationId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Violation Details',
        style: TextStyle(color: Colors.white),),
        backgroundColor: const Color(0xFF1a4a7c),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailCard(),
            const SizedBox(height: 20),
            if ((violationData['status'] as String?) == 'pending')
              _buildPayButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Violation Number:', violationId),
            const Divider(),
            _buildDetailRow('Date:', _formatDate(violationData['dateTime'], includeTime: false)),
            const Divider(),
            _buildDetailRow('Time:', _formatTime(violationData['dateTime'])),
            const Divider(),
            _buildDetailRow('Venue:', violationData['venue'] ?? 'Not specified'),
            const Divider(),
            _buildDetailRow('Vehicle Number:', violationData['vehicleNumber'] ?? 'N/A'),
            const Divider(),
            _buildDetailRow('Issued by:',
                '${violationData['officerName'] ?? 'Unknown'} (Badge: ${violationData['officerBadge'] ?? 'N/A'}'),
            const Divider(),
            const Text(
              'Violations:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ...(violationData['violations'] as List?)?.map((v) =>
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                  child: Text('- $v'),
                )
            ) ?? [const Text('- No violations listed')],
            const Divider(),
            _buildDetailRow('Total Fine:',
                'LKR ${(violationData['fineAmount'] as num?)?.toStringAsFixed(2) ?? '0.00'}'),
            const Divider(),
            _buildDetailRow('Status:',
                violationData['status'] ?? 'pending',
                statusColor: _getStatusColor(violationData['status'] ?? 'pending')),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? statusColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: statusColor != null
                  ? TextStyle(color: statusColor, fontWeight: FontWeight.bold)
                  : null,
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayButton(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentPage(violationId: violationId),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1a4a7c),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        ),
        child: const Text(
          'PAY NOW',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }

  String _formatDate(String? dateTime, {bool includeTime = false}) {
    if (dateTime == null) return 'N/A';
    try {
      final dt = DateTime.parse(dateTime);
      if (includeTime) {
        return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
      } else {
        return '${dt.day}/${dt.month}/${dt.year}';
      }
    } catch (e) {
      return 'Invalid date';
    }
  }

  String _formatTime(String? dateTime) {
    if (dateTime == null) return 'N/A';
    try {
      final dt = DateTime.parse(dateTime);
      final hour = dt.hour > 12 ? dt.hour - 12 : dt.hour;
      final period = dt.hour >= 12 ? 'p.m.' : 'a.m.';
      return '$hour:${dt.minute.toString().padLeft(2, '0')} $period';
    } catch (e) {
      return 'Invalid time';
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