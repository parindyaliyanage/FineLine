import 'package:flutter/material.dart';

class ReviewViolation extends StatelessWidget {
  const ReviewViolation({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review violation'),
      ),
      body: const Center(
        child: Text('Violation review content'),
      ),
    );
  }
}
