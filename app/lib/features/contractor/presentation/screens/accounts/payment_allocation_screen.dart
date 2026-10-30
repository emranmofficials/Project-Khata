import 'package:flutter/material.dart';
import 'package:project_khata/core/constants/contractor_strings.dart';
import 'package:project_khata/widgets/contractor_widgets.dart';

class PaymentAllocationScreen extends StatelessWidget {
  const PaymentAllocationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(ContractorStrings.paymentAllocationTitle),
      ),
      body: const EmptyState.placeholder(),
    );
  }
}
