import 'package:flutter/material.dart';
import 'package:project_khata/core/constants/contractor_strings.dart';
import 'package:project_khata/widgets/contractor_widgets.dart';

class NewSupervisorScreen extends StatelessWidget {
  const NewSupervisorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(ContractorStrings.newSupervisorTitle),
      ),
      body: const EmptyState.placeholder(),
    );
  }
}
