import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:project_khata/core/constants/app_colors.dart';
import 'package:project_khata/core/constants/contractor_routes.dart';
import 'package:project_khata/core/constants/contractor_strings.dart';
import 'package:project_khata/features/auth/presentation/controllers/auth_controller.dart';
import '../../contractor_providers.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(ContractorStrings.logout),
        content: const Text('আপনি কি নিশ্চিত যে লগআউট করতে চান?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('না'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(authControllerProvider.notifier).signOut();
            },
            child: const Text('হ্যাঁ, লগআউট'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(dashboardSummaryProvider);
    final pendingCount = summaryAsync.valueOrNull?.pendingApprovalsCount ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text(ContractorStrings.more),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // ১. এন্ট্রি অনুমোদন
          _buildListTile(
            context,
            icon: Icons.fact_check_rounded,
            title: ContractorStrings.entryApprovals,
            badgeCount: pendingCount,
            onTap: () => context.push(ContractorRoutes.approvals),
          ),

          // ২. প্রতিষ্ঠানের প্রোফাইল
          _buildListTile(
            context,
            icon: Icons.business_rounded,
            title: ContractorStrings.companyProfile,
            onTap: () => context.push(ContractorRoutes.company),
          ),

          // ৩. পদ ও মজুরি হার
          _buildListTile(
            context,
            icon: Icons.badge_rounded,
            title: ContractorStrings.designationsAndRates,
            onTap: () => context.push(ContractorRoutes.designations),
          ),

          // ৪. সুপারভাইজার দৈনিক মজুরি সেটিংস
          _buildListTile(
            context,
            icon: Icons.shield_rounded,
            title: ContractorStrings.supervisorPaySettings,
            onTap: () => context.push(ContractorRoutes.supervisorPay),
          ),

          // ৫. ঠিকাদারের প্রোফাইল
          _buildListTile(
            context,
            icon: Icons.person_rounded,
            title: ContractorStrings.myProfile,
            onTap: () => context.push(ContractorRoutes.profile),
          ),

          // ৬. নোটিফিকেশন
          _buildListTile(
            context,
            icon: Icons.notifications_rounded,
            title: ContractorStrings.notifications,
            onTap: () => context.push(ContractorRoutes.notifications),
          ),

          // ৭. অডিট লগ
          _buildListTile(
            context,
            icon: Icons.history_edu_rounded,
            title: ContractorStrings.auditLog,
            onTap: () => context.push(ContractorRoutes.auditLog),
          ),

          // ৮. অ্যাপ সেটিংস
          _buildListTile(
            context,
            icon: Icons.settings_rounded,
            title: ContractorStrings.appSettings,
            onTap: () => context.push(ContractorRoutes.settings),
          ),

          // ৯. সহায়তা ও তথ্য
          _buildListTile(
            context,
            icon: Icons.help_outline_rounded,
            title: ContractorStrings.helpAndInfo,
            onTap: () => context.push(ContractorRoutes.help),
          ),

          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 12),

          // ১০. লগআউট
          Card(
            child: ListTile(
              leading: const Icon(Icons.logout_rounded, color: AppColors.error),
              title: const Text(
                ContractorStrings.logout,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.error,
                ),
              ),
              onTap: () => _confirmLogout(context, ref),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    int? badgeCount,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: AppColors.contractorNavy),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (badgeCount != null && badgeCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badgeCount.toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
