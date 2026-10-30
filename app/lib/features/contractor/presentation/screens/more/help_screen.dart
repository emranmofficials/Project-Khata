import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:project_khata/core/constants/contractor_routes.dart';
import 'package:project_khata/core/constants/contractor_strings.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(ContractorStrings.helpTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF1E3A8A).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.handyman_rounded,
                size: 40,
                color: Color(0xFF1E3A8A),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'Project Khata (প্রজেক্ট খাতা)',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 4),
          const Center(
            child: Text(
              'ভার্সন ২.১',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline_rounded),
                  title: const Text(ContractorStrings.appVersionTitle),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push(ContractorRoutes.appVersion),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.support_agent_rounded),
                  title: const Text(ContractorStrings.supportContactTitle),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push(ContractorRoutes.supportContact),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.verified_user_outlined),
                  title: const Text(ContractorStrings.privacyPolicyTitle),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push(ContractorRoutes.privacyPolicy),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.receipt_long_rounded),
                  title: const Text(ContractorStrings.billTemplateTitle),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push(ContractorRoutes.billTemplate),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
