import 'package:flutter/material.dart';
import 'package:project_khata/core/constants/contractor_strings.dart';
import 'package:project_khata/widgets/contractor_widgets.dart';

class ProjectEntriesScreen extends StatelessWidget {
  final String projectId;

  const ProjectEntriesScreen({
    super.key,
    required this.projectId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(ContractorStrings.projectEntriesTitle),
      ),
      body: const EmptyState.placeholder(),
    );
  }
}
