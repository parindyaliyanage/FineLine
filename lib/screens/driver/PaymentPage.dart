import 'package:fineline/services/stripe_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart' show StripeException;

class PaymentPage extends StatefulWidget {
  final String violationId;
  final Map<String, dynamic> violationData;

  const PaymentPage({
    super.key,
    required this.violationId,
    required this.violationData,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  bool isProcessing = false;
  String? paymentError;

  @override
  Widget build(BuildContext context) {
    // Get the fine amount directly from violationData
    // Ensure we're using the same value that was shown in ViolationDetails
    final fineAmount = widget.violationData['fineAmount'] as double;

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
                      Text('Violation Type: ${_getMainViolation()}'),
                      Text('Date: ${_formatDate(widget.violationData['dateTime'])}'),
                      if (widget.violationData['venue'] != null)
                        Text('Venue: ${widget.violationData['venue']}'),
                      if (widget.violationData['vehicleNumber'] != null)
                        Text('Vehicle: ${widget.violationData['vehicleNumber']}'),
                      Text('Violation ID: ${widget.violationId}'),
                      Text('Fine Amount: LKR ${fineAmount.toStringAsFixed(2)}'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Select Payment Method',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 16),
                if (paymentError != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      paymentError!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ElevatedButton.icon(
                  onPressed: isProcessing ? null : () => _handlePayment(fineAmount),
                  icon: const Icon(Icons.credit_card),
                  label: const Text('Pay with Credit/Debit Card'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D47A1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
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

  String _getMainViolation() {
    final violations = widget.violationData['violations'] as List?;
    if (violations == null || violations.isEmpty) return 'Traffic Violation';
    return violations.first.toString().split(':')[0].trim();
  }

  Future<void> _handlePayment(double amount) async {
    setState(() {
      isProcessing = true;
      paymentError = null;
    });

    try {
      await StripeService.instance.makePayment(amount, widget.violationId);

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment successful! Database updated.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on StripeException catch (e) {
      setState(() {
        paymentError = 'Payment failed: ${e.error.localizedMessage}';
      });
    } catch (e) {
      setState(() {
        paymentError = 'Error: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() => isProcessing = false);
      }
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
}