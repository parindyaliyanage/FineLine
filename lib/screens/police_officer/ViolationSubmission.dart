import 'package:flutter/material.dart';
import 'package:fineline/models/officer_model.dart';
import 'package:fineline/repositiries/driver_repository.dart';
import 'package:fineline/repositiries/violation_repository.dart';

class ViolationSubmission extends StatefulWidget {
  final Officer officer;

  const ViolationSubmission({super.key, required this.officer});

  @override
  _ViolationSubmissionState createState() => _ViolationSubmissionState();
}

class _ViolationSubmissionState extends State<ViolationSubmission> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _driverNameController = TextEditingController();
  final TextEditingController _vehicleNumberController = TextEditingController();
  final TextEditingController _venueController = TextEditingController();
  final List<String> _selectedViolations = [];
  final DateTime _currentDateTime = DateTime.now();
  bool _isLoading = false;
  bool _isIdentifierValid = false;

  final List<String> _violationTypes = [
    'Speeding',
    'Traffic Signal Violation',
    'Illegal Parking',
    'No Seatbelt',
    'Not Carrying Driving License',
    'Wrong Way Driving',
    'No Helmets',
  ];

  final DriverRepository _driverRepo = DriverRepository();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Violation Submission'),
        backgroundColor: const Color(0xFF1a4a7c),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionHeader('Driver License/NIC Number'),
              _buildIdentifierField(),

              const SizedBox(height: 20),
              _buildSectionHeader('Driver Name'),
              _buildDriverNameField(),

              const SizedBox(height: 20),
              _buildSectionHeader('Violation'),
              _buildViolationSelection(),

              const SizedBox(height: 20),
              _buildSectionHeader('Vehicle Number'),
              _buildTextField(_vehicleNumberController, 'Enter Vehicle Number'),

              const SizedBox(height: 20),
              _buildSectionHeader('Date and Time'),
              _buildDateTimeDisplay(),

              const SizedBox(height: 20),
              _buildSectionHeader('Venue'),
              _buildTextField(_venueController, 'Enter Violation Location'),

              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _submitViolation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1a4a7c),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  'SUBMIT',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1a4a7c),
        ),
      ),
    );
  }

  Widget _buildIdentifierField() {
    return TextFormField(
      controller: _identifierController,
      decoration: InputDecoration(
        hintText: 'Enter Driving License or NIC Number',
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
          onPressed: _validateDriverIdentifier,
        ),
      ),
      validator: (value) {
        if (value!.isEmpty) return 'Please enter license/NIC number';
        if (!_isIdentifierValid) return 'Invalid license/NIC number';
        return null;
      },
      onChanged: (value) {
        if (_isIdentifierValid) {
          setState(() => _isIdentifierValid = false);
        }
      },
    );
  }

  Widget _buildDriverNameField() {
    return TextFormField(
      controller: _driverNameController,
      readOnly: true,
      decoration: InputDecoration(
        hintText: _isLoading ? 'Searching...' : 'Will auto-populate',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        filled: true,
        fillColor: Colors.grey[200],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF1a4a7c)),
        ),
      ),
    );
  }

  Widget _buildViolationSelection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Select Violation(s)'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _violationTypes.map((violation) {
              return FilterChip(
                label: Text(violation),
                selected: _selectedViolations.contains(violation),
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedViolations.add(violation);
                    } else {
                      _selectedViolations.remove(violation);
                    }
                  });
                },
                selectedColor: const Color(0xFF1a4a7c).withOpacity(0.2),
                checkmarkColor: const Color(0xFF1a4a7c),
                labelStyle: TextStyle(
                  color: _selectedViolations.contains(violation)
                      ? const Color(0xFF1a4a7c)
                      : Colors.black,
                ),
              );
            }).toList(),
          ),
          if (_selectedViolations.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text('Selected Violations:'),
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _selectedViolations
                  .map((v) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text('- $v'),
              ))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDateTimeDisplay() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '${_currentDateTime.day}/${_currentDateTime.month}/${_currentDateTime.year} '
            '${_currentDateTime.hour}:${_currentDateTime.minute.toString().padLeft(2, '0')}',
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  Future<void> _validateDriverIdentifier() async {
    if (_identifierController.text.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final driver = await _driverRepo.getDriverByIdentifier(_identifierController.text.trim());
      setState(() {
        _isIdentifierValid = driver != null;
        if (driver != null) {
          _driverNameController.text = driver['username'] ?? 'Unknown';
        // } else {
        //   _driverNameController.clear();
        }
      });

      if (!_isIdentifierValid) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid driving license/NIC number'),
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

  void _submitViolation() async {
    if (_formKey.currentState!.validate() && _selectedViolations.isNotEmpty) {
      setState(() => _isLoading = true);

      final violationData = {
        'officerBadge': widget.officer.badgeNumber,
        'officerName': widget.officer.fullName,
        'identifier': _identifierController.text,
        'driverName': _driverNameController.text,
        'violations': _selectedViolations,
        'vehicleNumber': _vehicleNumberController.text,
        'dateTime': _currentDateTime.toString(),
        'venue': _venueController.text,
        'status': 'pending',
        'fineAmount': _calculateFineAmount(), // Add this method
        'isPaid': false,
      };

      try {
        final ViolationRepository violationRepo = ViolationRepository();
        await violationRepo.submitViolation(violationData);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Violation submitted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit violation: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    } else if (_selectedViolations.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one violation'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

//calculate fine amount based on violations
  double _calculateFineAmount() {
    //fine amounts for each violation type
    const violationFines = {
      'Speeding': 5000.0,
      'Traffic Signal Violation': 3000.0,
      'Illegal Parking': 2000.0,
      'No Seatbelt': 1000.0,
      'Not Carrying Driving License': 2500.0,
      'Wrong Way Driving': 4000.0,
      'No Helmets': 1500.0,
    };

    double total = 0.0;
    for (var violation in _selectedViolations) {
      total += violationFines[violation] ?? 0.0;
    }
    return total;
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _driverNameController.dispose();
    _vehicleNumberController.dispose();
    _venueController.dispose();
    super.dispose();
  }
}