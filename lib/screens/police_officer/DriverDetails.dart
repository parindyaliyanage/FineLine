import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:fineline/repositiries/driver_repository.dart';

class DriverDetails extends StatefulWidget {
  const DriverDetails({super.key});

  @override
  State<DriverDetails> createState() => _DriverDetailsState();
}

class _DriverDetailsState extends State<DriverDetails> {
  final TextEditingController _searchController = TextEditingController();
  final DriverRepository _driverRepo = DriverRepository();
  bool _isLoading = false;
  bool _isIdentifierValid = false;
  Map<String, dynamic>? _driverData;
  List<QueryDocumentSnapshot> _violations = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Details',
        style: TextStyle(color: Colors.white),),
        backgroundColor: const Color(0xFF1a4a7c),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextFormField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Enter License Number or NIC',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF1a4a7c)),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _searchDriver,
                ),
              ),
              onChanged: (value) {
                if (_isIdentifierValid) {
                  setState(() => _isIdentifierValid = false);
                }
              },
              onFieldSubmitted: (_) => _searchDriver(),
            ),
          ),

          if (_isLoading)
            const LinearProgressIndicator()
          else if (_driverData != null)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _buildDriverCard(),
                    const SizedBox(height: 20),
                    _buildViolationsSection(),
                  ],
                ),
              ),
            )
          else if (_searchController.text.isNotEmpty && !_isLoading)
              const Center(child: Text('No driver found'))
            else
              const Center(
                child: Text('Enter a license number or NIC to search'),
              ),
        ],
      ),
    );
  }

  Future<void> _searchDriver() async {
    final identifier = _searchController.text.trim();
    if (identifier.isEmpty) return;

    setState(() {
      _isLoading = true;
      _isIdentifierValid = false;
      _driverData = null;
      _violations = [];
    });

    try {
      // First try to find by license number
      var driverQuery = await FirebaseFirestore.instance
          .collection('drivers')
          .where('licenseNumber', isEqualTo: identifier)
          .limit(1)
          .get();

      // If not found, try by NIC
      if (driverQuery.docs.isEmpty) {
        driverQuery = await FirebaseFirestore.instance
            .collection('drivers')
            .where('nic', isEqualTo: identifier)
            .limit(1)
            .get();
      }

      if (driverQuery.docs.isNotEmpty) {
        _driverData = driverQuery.docs.first.data();

        // Get violations using both license number and NIC as identifier
        final violationsQuery = await FirebaseFirestore.instance
            .collection('violations')
            .where('identifier', whereIn: [
          _driverData!['licenseNumber'],
          _driverData!['nic']
        ])
            .orderBy('dateTime', descending: true)
            .get();

        setState(() {
          _isIdentifierValid = true;
          _violations = violationsQuery.docs;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No driver found with this license/NIC'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildDriverCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Header
            Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.blueGrey,
                  child: Icon(Icons.person, size: 30, color: Colors.white),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _driverData!['fullName'] ?? 'Unknown',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'License: ${_driverData!['licenseNumber'] ?? 'N/A'}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            // Driver Details
            _buildDetailRow('NIC Number', _driverData!['nic'] ?? 'N/A'),
            _buildDetailRow('License Type', _driverData!['licenseType'] ?? 'N/A'),
            _buildDetailRow('Date of Birth', _formatDate(_driverData!['dob'])),
            _buildDetailRow('License Expiry', _formatDate(_driverData!['exp'])),
            _buildDetailRow('Address', _driverData!['address'] ?? 'N/A'),
          ],
        ),
      ),
    );
  }

  Widget _buildViolationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Previous Violations',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (_violations.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('No violations found'),
            ),
          )
        else
          Column(
            children: [
              _buildViolationStats(),
              const SizedBox(height: 12),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _violations.length,
                itemBuilder: (context, index) {
                  final violation = _violations[index];
                  final data = violation.data() as Map<String, dynamic>;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: const Icon(Icons.warning_amber, color: Colors.orange),
                      title: Text(
                        (data['violations'] as List).join(', '),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('LKR ${data['fineAmount']?.toStringAsFixed(2) ?? '0.00'}'),
                          Text(_formatDate(data['dateTime'])),
                          Chip(
                            label: Text(
                              data['status']?.toString().toUpperCase() ?? 'PENDING',
                              style: const TextStyle(fontSize: 12),
                            ),
                            backgroundColor: _getStatusColor(data['status']),
                          ),
                          Text('Issued by: ${data['officerName']} (${data['officerBadge']})'),
                          Text('Vehicle: ${data['vehicleNumber']}'),
                          Text('Location: ${data['venue']}'),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildViolationStats() {
    final paidCount = _violations.where((v) => v['isPaid'] == true).length;
    final pendingCount = _violations.where((v) =>
    v['status'] == 'pending' && v['isPaid'] == false).length;
    final overdueCount = _violations.where((v) =>
    v['status'] == 'pending' && _isOverdue(v['dateTime'])).length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem('Total', _violations.length),
            _buildStatItem('Paid', paidCount),
            _buildStatItem('Pending', pendingCount),
            _buildStatItem('Overdue', overdueCount),
          ],
        ),
      ),
    );
  }

  bool _isOverdue(dynamic dateTime) {
    try {
      final violationDate = dateTime is Timestamp
          ? dateTime.toDate()
          : DateTime.parse(dateTime);
      final dueDate = violationDate.add(const Duration(days: 7));
      return DateTime.now().isAfter(dueDate);
    } catch (e) {
      return false;
    }
  }

  Widget _buildStatItem(String label, int count) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          const Text(': '),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    try {
      final dateTime = date is Timestamp ? date.toDate() : DateTime.parse(date);
      return DateFormat('dd/MM/yyyy').format(dateTime);
    } catch (e) {
      return 'N/A';
    }
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'paid':
        return Colors.green.withOpacity(0.2);
      default:
        return Colors.orange.withOpacity(0.2);
    }
  }
}