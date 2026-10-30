import 'package:flutter/material.dart';
import 'package:project_khata/core/constants/contractor_strings.dart';
import 'package:project_khata/widgets/contractor_widgets.dart';

class WorkerEditScreen extends StatelessWidget {
  final String workerId;

  const WorkerEditScreen({
    super.key,
    required this.workerId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(ContractorStrings.workerEditTitle),
      ),
      body: const EmptyState.placeholder(),
    );
  }
}
