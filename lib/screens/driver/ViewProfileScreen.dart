import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fineline/repositiries/driver_repository.dart';
import '../auth_controller.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Add this import

class ViewProfileScreen extends StatefulWidget {
  const ViewProfileScreen({super.key});

  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {
  final DriverRepository _driverRepo = DriverRepository();
  Map<String, dynamic>? _driverData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDriverData();
  }

  Future<void> _loadDriverData() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      print('Current UID: $userId');

      if (userId == null) {
        setState(() {
          _errorMessage = 'User not authenticated';
          _isLoading = false;
        });
        return;
      }

      final data = await _driverRepo.getDriverProfile(userId);
      print('Fetched data: $data');

      setState(() {
        _driverData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  // Updated formatDate method to handle Timestamp
  String _formatDate(dynamic dateValue) {
    if (dateValue == null) return 'N/A';

    try {
      DateTime date;

      if (dateValue is Timestamp) {
        date = dateValue.toDate();
      } else if (dateValue is String) {
        date = DateTime.parse(dateValue);
      } else {
        return 'Invalid date';
      }

      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return 'Invalid date';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Profile'),
        backgroundColor: const Color(0xFF1a4a7c),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _driverData == null
          ? const Center(child: Text('No profile data available'))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildProfileCard(),
            const SizedBox(height: 20),
            _buildProfileDetails(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: Color(0xFF1a4a7c),
              child: Icon(
                Icons.person,
                size: 50,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _driverData?['fullName'] ?? _driverData?['username'] ?? 'No Name',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Driver - ${_driverData?['licenseType']?.toString().toUpperCase() ?? 'N/A'}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileDetails() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailItem('Full Name', _driverData?['fullName'] ?? _driverData?['username'] ?? 'N/A'),
            const Divider(),
            _buildDetailItem('NIC', _driverData?['nic'] ?? 'N/A'),
            const Divider(),
            _buildDetailItem('Driver License', _driverData?['licenseNumber'] ?? _driverData?['license'] ?? 'N/A'),
            const Divider(),
            _buildDetailItem('License Type', _driverData?['licenceType']?.toString().toUpperCase() ?? 'N/A'),
            const Divider(),
            _buildDetailItem('Date of Birth', _formatDate(_driverData?['dob'])),
            const Divider(),
            _buildDetailItem('License Expiry', _formatDate(_driverData?['exp'])),
            const Divider(),
            _buildDetailItem('Phone Number', _driverData?['phone'] ?? 'N/A'),
            const Divider(),
            _buildDetailItem('Address', _driverData?['address'] ?? 'N/A'),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}