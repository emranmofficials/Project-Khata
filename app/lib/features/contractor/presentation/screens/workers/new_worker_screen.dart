import 'package:flutter/material.dart';
import '../../../domain/models/contractor_models.dart';
import 'add_member_screen.dart';

class NewWorkerScreen extends StatelessWidget {
  const NewWorkerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AddMemberScreen(initialRole: MemberRole.worker);
  }
}
