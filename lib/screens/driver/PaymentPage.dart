import 'package:fineline/services/stripe_service.dart';
import 'package:flutter/material.dart';

class PaymentPage extends StatefulWidget {
  final String? violationId;
  final Map<String, dynamic>? violationData;

  const PaymentPage({
    super.key,
    this.violationId,
    this.violationData,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  bool isProcessing = false;

  @override
  void initState() {
    super.initState();

    // Verify violation data exists
    if (widget.violationData == null || widget.violationId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showNoViolationDataError();
      });
    }
  }

  void _showNoViolationDataError() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('No Violation Found'),
          content: const Text('No violation data was found. You cannot proceed with payment.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Go back to previous screen
              },
              child: const Text('Go Back'),
            ),
          ],
        );
      },
    );
  }

  void _processPayment() async {
    setState(() {
      isProcessing = true;
    });

    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 2));

    // End processing state and navigate back
    if (mounted) {
      setState(() {
        isProcessing = false;
      });

      // Simply navigate back without showing success dialog
      Navigator.of(context).pop();
    }
  }

  // Format date from violation data
  String _formatDate(String? dateTime) {
    if (dateTime == null) return 'N/A';
    try {
      final dt = DateTime.parse(dateTime);
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (e) {
      return 'Invalid date';
    }
  }

  @override
  Widget build(BuildContext context) {
    // If no violation data, show a loading indicator until the dialog appears
    if (widget.violationData == null || widget.violationId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Payment', style: TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFF0D47A1),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Get the fine amount from violation data
    double fineAmount = (widget.violationData!['fineAmount'] as num?)?.toDouble() ?? 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0D47A1),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                // Violation Summary - Using actual violation data
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Violation Summary',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 8),

                      // Display violation details from the passed violation data
                      Text('Violation Type: ${(widget.violationData!['violations'] as List?)?.isNotEmpty == true ?
                      (widget.violationData!['violations'] as List).first : 'Traffic Violation'}'),

                      // Show date from violation data
                      Text('Date: ${_formatDate(widget.violationData!['dateTime'])}'),

                      // Show venue if available
                      if (widget.violationData!['venue'] != null)
                        Text('Venue: ${widget.violationData!['venue']}'),

                      // Show vehicle number
                      if (widget.violationData!['vehicleNumber'] != null)
                        Text('Vehicle: ${widget.violationData!['vehicleNumber']}'),

                      // Show violation ID
                      Text('Violation ID: ${widget.violationId}'),

                      // Show fine amount
                      Text('Fine Amount: LKR ${fineAmount.toStringAsFixed(2)}'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                const Text('Select Payment Method',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 16),

                // Payment button
                ElevatedButton.icon(
                  onPressed: () {
                    StripeService.instance.makePayment();
                  },
                  icon: const Icon(Icons.credit_card),
                  label: const Text('Pay with Credit / Debit Card'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D47A1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),

          // Loading overlay
          if (isProcessing)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFF0D47A1)),
              ),
            ),
        ],
      ),
    );
  }
}