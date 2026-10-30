import 'package:flutter/material.dart';
import '../../../domain/models/contractor_models.dart';
import 'add_member_screen.dart';

class NewSupervisorScreen extends StatelessWidget {
  const NewSupervisorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AddMemberScreen(initialRole: MemberRole.supervisor);
  }
}
