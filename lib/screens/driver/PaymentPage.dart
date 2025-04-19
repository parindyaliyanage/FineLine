import 'package:flutter/material.dart';

class PaymentPage extends StatefulWidget {
  final String violationId;  // Add this parameter

  const PaymentPage({super.key, required this.violationId});  // Update constructor

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        backgroundColor: const Color(0xFF1a4a7c),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Payment for Violation: ${widget.violationId}',  // Display the violation ID
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            // Add your payment UI components here
            ElevatedButton(
              onPressed: () {
                // Handle payment logic here
              },
              child: const Text('Process Payment'),
            ),
          ],
        ),
      ),
    );
  }
}