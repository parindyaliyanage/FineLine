import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import 'package:fineline/models/officer_model.dart';
import 'package:fineline/repositiries/violation_repository.dart';

class ReviewViolationsScreen extends StatefulWidget {
  final Officer officer;

  const ReviewViolationsScreen({super.key, required this.officer});

  @override
  _ReviewViolationsScreenState createState() => _ReviewViolationsScreenState();
}

class _ReviewViolationsScreenState extends State<ReviewViolationsScreen> {
  final ViolationRepository _violationRepo = ViolationRepository();
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  List<QueryDocumentSnapshot> _violations = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Violations', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1a4a7c),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Date Selection
          _buildDateSelector(),
          const SizedBox(height: 16),

          // Violations List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _violations.isEmpty
                ? const Center(child: Text('No violations found for selected date'))
                : _buildViolationsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              DateFormat('dd MMM yyyy').format(_selectedDate),
              style: const TextStyle(fontSize: 18),
            ),
            IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: _selectDate,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViolationsList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _violations.length,
      itemBuilder: (context, index) {
        final violation = _violations[index].data() as Map<String, dynamic>;
        return _buildViolationCard(violation);
      },
    );
  }

  Widget _buildViolationCard(Map<String, dynamic> violation) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  violation['driverName'] ?? 'Unknown Driver',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Chip(
                  label: Text(
                    violation['status'] ?? 'pending',
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: _getStatusColor(violation['status']),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildViolationDetailRow('License/NIC', violation['identifier']),
            _buildViolationDetailRow('Vehicle', violation['vehicleNumber']),
            _buildViolationDetailRow('Location', violation['venue']),
            _buildViolationDetailRow('Time', _formatViolationTime(violation)),
            const SizedBox(height: 12),
            const Text(
              'Violations:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ..._buildViolationItems(violation['violations']),
            const SizedBox(height: 12),
            Text(
              'Total Fine: LKR ${violation['fineAmount']?.toStringAsFixed(2) ?? '0.00'}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViolationDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value ?? 'Not provided'),
        ],
      ),
    );
  }

  List<Widget> _buildViolationItems(List<dynamic> violations) {
    return violations.map((v) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Text('- $v'),
      );
    }).toList();
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'paid':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
      default:
        return Colors.orange;
    }
  }

  String _formatViolationTime(Map<String, dynamic> violation) {
    try {
      if (violation['createAt'] != null) {
        final timestamp = violation['createAt'] as Timestamp;
        return DateFormat('hh:mm a').format(timestamp.toDate());
      }
      if (violation['dateTime'] != null) {
        return DateFormat('hh:mm a').format(DateTime.parse(violation['dateTime']));
      }
    } catch (e) {
      print('Error formatting time: $e');
    }
    return 'Unknown time';
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _loadViolations();
      });
    }
  }

  Future<void> _loadViolations() async {
    setState(() => _isLoading = true);

    try {
      final startOfDay = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
      final endOfDay = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, 23, 59, 59);

      debugPrint('Loading violations for ${widget.officer.badgeNumber} on ${_selectedDate}');

      // The query you asked about - implemented properly
      final violations = await FirebaseFirestore.instance
          .collection('violations')
          .where('officerBadge', isEqualTo: widget.officer.badgeNumber)
          .get()
          .then((snapshot) {
        return snapshot.docs.where((doc) {
          final timestamp = doc.data()['createAt'] as Timestamp?;
          if (timestamp == null) return false;
          final date = timestamp.toDate();
          return date.isAfter(startOfDay.subtract(const Duration(days: 1))) &&
              date.isBefore(endOfDay.add(const Duration(days: 1)));
        }).toList();
      });

      // Sort by date (newest first)
      violations.sort((a, b) {
        final aTime = (a.data()['createAt'] as Timestamp).toDate();
        final bTime = (b.data()['createAt'] as Timestamp).toDate();
        return bTime.compareTo(aTime);
      });

      setState(() {
        _violations = violations;
      });

      debugPrint('Found ${violations.length} violations');

    } catch (e) {
      debugPrint('Error loading violations: $e');
      Get.snackbar(
        'Error',
        'Failed to load violations: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadViolations();
  }
}