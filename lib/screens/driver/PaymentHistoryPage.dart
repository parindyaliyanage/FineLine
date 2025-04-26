import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PaymentHistoryPage extends StatefulWidget {
  const PaymentHistoryPage({super.key});

  @override
  State<PaymentHistoryPage> createState() => _PaymentHistoryPageState();
}

class _PaymentHistoryPageState extends State<PaymentHistoryPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Stream<QuerySnapshot>? _paymentsStream;

  @override
  void initState() {
    super.initState();
    _initializePaymentsStream();
  }

  void _initializePaymentsStream() {
    final user = _auth.currentUser;
    if (user != null) {
      setState(() {
        _paymentsStream = _firestore.collection('payments')
            .where('userId', isEqualTo: user.uid)
            .orderBy('paidAt', descending: true)
            .snapshots();
      });
    }
  }

  Future<void> _refreshPayments() async {
    _initializePaymentsStream();
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please login to view payment history')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment History'),
        backgroundColor: const Color(0xFF1a4a7c),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshPayments,
          ),
        ],
      ),
      body: _paymentsStream == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _refreshPayments,
        child: StreamBuilder<QuerySnapshot>(
          stream: _paymentsStream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return _buildErrorWidget(snapshot.error.toString());
            }

            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return const Center(child: CircularProgressIndicator());
              case ConnectionState.active:
              case ConnectionState.done:
                final payments = snapshot.data?.docs ?? [];
                if (payments.isEmpty) {
                  return _buildEmptyState();
                }
                return _buildPaymentList(payments);
              default:
                return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          const Text('Failed to load payments'),
          Text(
            error,
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _refreshPayments,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.payment, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'No payments found',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            'Your payment history will appear here',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentList(List<QueryDocumentSnapshot> payments) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: payments.length,
      itemBuilder: (context, index) {
        final payment = payments[index].data() as Map<String, dynamic>;
        return _buildPaymentCard(payment);
      },
    );
  }

  Widget _buildPaymentCard(Map<String, dynamic> payment) {
    final dateFormat = DateFormat('dd MMM yyyy - hh:mm a');
    final paidAt = (payment['paidAt'] as Timestamp).toDate();
    final amount = (payment['amount'] as num).toDouble();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'LKR ${amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1a4a7c),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Paid',
                    style: TextStyle(
                      color: Colors.green[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildDetailRow('Date', dateFormat.format(paidAt)),
            if (payment['stripeId'] != null)
              _buildDetailRow('Transaction ID', payment['stripeId']),
            if (payment['violationId'] != null)
              _buildDetailRow('Violation ID', payment['violationId']),
            _buildDetailRow('Method', payment['paymentMethod'] ?? 'Card'),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value,
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}