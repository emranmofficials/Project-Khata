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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pendingCount = summaryAsync.valueOrNull?.pendingApprovalsCount ?? 0;
    final companyName = summaryAsync.valueOrNull?.companyName ?? ContractorStrings.defaultCompanyName;

    return Scaffold(
      appBar: AppBar(
        title: const Text(ContractorStrings.more),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          // প্রফেশনাল প্রোফাইল সামারি কার্ড
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [
                        AppColors.contractorNavy,
                        Color(0xFF2563EB),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.contractorNavy.withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.business_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              companyName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.verified_rounded,
                            size: 16,
                            color: isDark ? const Color(0xFF93A8F4) : const Color(0xFF2563EB),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'প্রজেক্ট খাতা ঠিকাদার • সংস্করণ ১.০.০',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

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
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.logout_rounded, color: AppColors.error, size: 20),
              ),
              title: const Text(
                ContractorStrings.logout,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.error,
                ),
              ),
              trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.error, size: 20),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xFF93A8F4) : AppColors.contractorNavy;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: primaryColor, size: 22),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (badgeCount != null && badgeCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badgeCount.toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right_rounded,
              color: isDark ? Colors.white38 : Colors.grey,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
