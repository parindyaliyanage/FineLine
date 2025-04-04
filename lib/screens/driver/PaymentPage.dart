import 'package:flutter/material.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({Key? key}) : super(key: key);

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Payment",
          style: TextStyle(color: Colors.white), // ✅ Make title text white
        ),
        backgroundColor: const Color(0xFF1a4a7c),
        iconTheme: const IconThemeData(color: Colors.white), // ✅ Make back button white
      ),
      body: const Center(
        child: Text("This is the Payment Page"),
      ),
    );
  }
}
