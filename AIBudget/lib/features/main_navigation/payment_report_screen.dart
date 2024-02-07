import 'package:flutter/material.dart';

class PaymentReportScreen extends StatelessWidget {
  const PaymentReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('결제 보고서'),
      ),
      body: const Center(
        child: Text('여기에 결제 보고서 내용을 표시합니다.'),
      ),
    );
  }
}
