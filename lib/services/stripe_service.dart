import 'package:dio/dio.dart';
import 'package:fineline/consts.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StripeService {
  StripeService._();
  static final StripeService instance = StripeService._();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> makePayment(double amount, String violationId) async {
    try {
      // 1. Create payment intent
      final paymentIntent = await _createPaymentIntent(amount, "lkr");

      // 2. Initialize payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent['client_secret'],
          merchantDisplayName: 'Traffic Fines',
        ),
      );

      // 3. Present payment sheet
      await Stripe.instance.presentPaymentSheet();

      // 4. Update Firestore with payment ID
      await _updateViolationStatus(
        violationId,
        paymentIntent['id'], // Pass the Stripe payment ID
      );

    } catch (e) {
      print('Payment error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> _createPaymentIntent(double amount, String currency) async {
    final Dio dio = Dio();
    final response = await dio.post(
      "https://api.stripe.com/v1/payment_intents",
      data: {
        "amount": (amount * 100).toInt(), // Convert to cents
        "currency": currency,
        "payment_method_types[]": "card",
      },
      options: Options(
        headers: {
          "Authorization": "Bearer $stripeSecretKey",
          "Content-Type": "application/x-www-form-urlencoded",
        },
      ),
    );
    return response.data;
  }

  Future<void> _updateViolationStatus(
      String violationId,
      String stripePaymentId, // Added parameter
      ) async {
    try {
      await _firestore.collection('violations').doc(violationId).update({
        'status': 'paid',
        'isPaid': true,
        'paidAt': FieldValue.serverTimestamp(),
        'paymentMethod': 'card',
        'stripeId': stripePaymentId, // Use the passed parameter
      });
      print('Successfully updated violation $violationId in Firestore');
    } catch (e) {
      print('Failed to update violation status: $e');
      rethrow;
    }
  }


}