import 'package:AIBudget/features/main_navigation/widgets/cardApproval.dart';
import 'package:flutter/material.dart';

class PaymentDetailSheet extends StatelessWidget {
  final CardApprovalData userData;

  const PaymentDetailSheet({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Scaffold를 사용하여 화면을 구성합니다.
      appBar: AppBar(
        title: const Text("Payment Details"),
      ),
      body: const Center(
        child: Text("여기에 결제정보를 표시합니다"),
      ),
    );
  }
}
