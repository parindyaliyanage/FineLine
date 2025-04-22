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
  bool rememberCard = false;
  bool isProcessing = false;
  String? cardNumber;
  String? expiryDate;
  String? cvv;
  String? cardholderName;

  // Form key to validate inputs
  final _formKey = GlobalKey<FormState>();

  // Controllers for text fields
  final _cardNumberController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _cvvController = TextEditingController();
  final _cardholderNameController = TextEditingController();

  // Get the fine amount from violation data
  double get fineAmount {
    if (widget.violationData == null) {
      // Show an error and navigate back if there's no violation data
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showNoViolationDataError();
      });
      return 0.0;
    }
    return (widget.violationData!['fineAmount'] as num?)?.toDouble() ?? 0.0;
  }

  // Processing fee (2.5% of fine amount)
  double get processingFee {
    return (fineAmount * 0.025).roundToDouble();
  }

  // Total payable amount
  double get totalPayable {
    return fineAmount + processingFee;
  }

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
    if (_formKey.currentState!.validate()) {
      setState(() {
        isProcessing = true;
      });

      // Simulate payment processing
      await Future.delayed(const Duration(seconds: 2));

      // Display success dialog
      if (mounted) {
        setState(() {
          isProcessing = false;
        });

        _showPaymentSuccessDialog();
      }
    }
  }

  void _showPaymentSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Payment Successful'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 60),
              const SizedBox(height: 16),
              const Text('Your payment has been processed successfully.'),
              const SizedBox(height: 8),
              Text('Receipt #: PMT${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}'),
              const SizedBox(height: 8),
              const Text('An e-receipt has been sent to your email.'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate back to previous screen
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  String? _validateCardNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Card number is required';
    }
    if (value.replaceAll(' ', '').length != 16) {
      return 'Card number must be 16 digits';
    }
    return null;
  }

  String? _validateExpiryDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Expiry date is required';
    }
    // Check if format is MM/YY
    RegExp dateFormat = RegExp(r'^\d{2}/\d{2}$');
    if (!dateFormat.hasMatch(value)) {
      return 'Use format MM/YY';
    }

    final parts = value.split('/');
    final month = int.tryParse(parts[0]);
    final year = int.tryParse(parts[1]);

    if (month == null || year == null || month < 1 || month > 12) {
      return 'Invalid date';
    }

    // Check if card is not expired
    final now = DateTime.now();
    final cardYear = 2000 + year; // Convert YY to 20YY

    if (cardYear < now.year || (cardYear == now.year && month < now.month)) {
      return 'Card has expired';
    }

    return null;
  }

  String? _validateCVV(String? value) {
    if (value == null || value.isEmpty) {
      return 'CVV is required';
    }
    if (value.length < 3 || value.length > 4) {
      return 'CVV must be 3 or 4 digits';
    }
    return null;
  }

  String? _validateCardholderName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Cardholder name is required';
    }
    return null;
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
  void dispose() {
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    _cardholderNameController.dispose();
    super.dispose();
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
            child: Form(
              key: _formKey,
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
                  const SizedBox(height: 8),

                  Card(
                    child: RadioListTile<int>(
                      title: const Row(
                        children: [
                          Icon(Icons.credit_card),
                          SizedBox(width: 10),
                          Text('Credit / Debit Card'),
                        ],
                      ),
                      value: 1,
                      groupValue: 1, // Default selected
                      onChanged: (value) {
                        // For future implementation of multiple payment methods
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text('Card Details',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 8),

                  TextFormField(
                    controller: _cardNumberController,
                    decoration: const InputDecoration(
                      labelText: 'Card Number',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.credit_card),
                      hintText: '1234 5678 9012 3456',
                    ),
                    keyboardType: TextInputType.number,
                    validator: _validateCardNumber,
                    onChanged: (value) {
                      // Format card number to show spaces every 4 digits
                      if (value.isNotEmpty && !value.contains(" ")) {
                        String formattedValue = '';
                        for (int i = 0; i < value.length; i++) {
                          formattedValue += value[i];
                          if ((i + 1) % 4 == 0 && i != value.length - 1) {
                            formattedValue += ' ';
                          }
                        }
                        _cardNumberController.value = TextEditingValue(
                          text: formattedValue,
                          selection: TextSelection.collapsed(offset: formattedValue.length),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _expiryDateController,
                          decoration: const InputDecoration(
                            labelText: 'Expiry Date',
                            border: OutlineInputBorder(),
                            hintText: 'MM/YY',
                          ),
                          keyboardType: TextInputType.datetime,
                          validator: _validateExpiryDate,
                          onChanged: (value) {
                            // Format expiry date to MM/YY
                            if (value.length == 2 && !value.contains('/')) {
                              _expiryDateController.text = '$value/';
                              _expiryDateController.selection = TextSelection.fromPosition(
                                TextPosition(offset: _expiryDateController.text.length),
                              );
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _cvvController,
                          decoration: const InputDecoration(
                            labelText: 'CVV',
                            border: OutlineInputBorder(),
                            hintText: '123',
                          ),
                          keyboardType: TextInputType.number,
                          obscureText: true,
                          validator: _validateCVV,
                          maxLength: 4,
                          buildCounter: (BuildContext context,
                              {required int currentLength, required bool isFocused, required int? maxLength}) => null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _cardholderNameController,
                    decoration: const InputDecoration(
                      labelText: 'Cardholder Name',
                      border: OutlineInputBorder(),
                      hintText: 'John Smith',
                    ),
                    textCapitalization: TextCapitalization.words,
                    validator: _validateCardholderName,
                  ),
                  const SizedBox(height: 12),

                  // Remember Card Checkbox
                  CheckboxListTile(
                    value: rememberCard,
                    onChanged: (bool? value) {
                      setState(() {
                        rememberCard = value ?? false;
                      });
                    },
                    title: const Text('Remember my card for future payments'),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 20),

                  // Payment Breakdown - Using calculated values
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Fine Amount'),
                            Text('LKR ${fineAmount.toStringAsFixed(2)}')
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Processing Fee'),
                            Text('LKR ${processingFee.toStringAsFixed(2)}')
                          ],
                        ),
                        const Divider(thickness: 1),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total Payable', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('LKR ${totalPayable.toStringAsFixed(2)}',
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  ElevatedButton.icon(
                    onPressed: isProcessing ? null : _processPayment,
                    icon: const Icon(Icons.payment),
                    label: Text(isProcessing ? 'Processing...' : 'Pay Now'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D47A1),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontSize: 16),
                      disabledBackgroundColor: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'Note: You will receive an e-receipt upon successful payment. Payments are non-refundable.',
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
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