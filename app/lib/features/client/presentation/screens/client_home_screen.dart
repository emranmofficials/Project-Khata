import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/bengali_formatter.dart';
import '../../../../core/widgets/kpi_card.dart';
import '../../../../core/widgets/loading_skeleton.dart';
import '../../../../core/widgets/summary_card.dart';
import '../../../accounting/presentation/screens/bill_statements_screen.dart';
import '../../../accounting/presentation/screens/materials_screen.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../notifications/presentation/screens/notifications_inbox_screen.dart';
import '../../../project/presentation/providers/project_provider.dart';

/// PRD সেকশন ৮ অনুযায়ী ক্লায়েন্ট ইন্টারফেস
class ClientHomeScreen extends ConsumerWidget {
  const ClientHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).user;
    final projectsAsync = ref.watch(projectsListProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ক্লায়েন্ট পোর্টাল'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NotificationsInboxScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => ref.read(authStateProvider.notifier).signOut(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(projectsListProvider),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.paddingMedium),
          child: projectsAsync.when(
            loading: () => const LoadingSkeletonCard(height: 200),
            error: (err, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('প্রজেক্ট তথ্য লোড হয়নি: $err'),
              ),
            ),
            data: (projects) {
              if (projects.isEmpty) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSizes.paddingLarge),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : AppColors.lightCard,
                    borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.handshake_outlined, size: 54, color: Colors.grey),
                      SizedBox(height: 12),
                      Text(
                        'কোনো সক্রিয় প্রজেক্ট নেই',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'আপনার ঠিকাদার আপনাকে প্রজেক্টে যুক্ত করার পর এখানে সম্পূর্ণ হিসাব ও অগ্রগতি দেখতে পাবেন।',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              final project = projects.first;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SummaryCard(
                    role: 'client',
                    orgName: user?.name ?? 'সম্মানিত ক্লায়েন্ট',
                    title: 'কাজের অগ্রগতি',
                    kpiValue: BengaliFormatter.toBengaliNumber(
                      project.progressPercentage.toStringAsFixed(0),
                    ),
                    subText: 'প্রজেক্ট: ${project.name}',
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: KpiCard(
                          title: 'মোট চুক্তি বাজেট',
                          value: project.budget.toStringAsFixed(0),
                          isCurrency: true,
                          accentColor: AppColors.clientPrimary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: KpiCard(
                          title: 'কাজের ধরণ',
                          value: project.type,
                          isCurrency: false,
                          accentColor: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'প্রজেক্টের তথ্য ও সেবাসমূহ',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    tileColor: isDark ? AppColors.darkCard : AppColors.lightCard,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                    ),
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.clientPrimary,
                      child: Icon(Icons.receipt_long_rounded, color: Colors.white),
                    ),
                    title: const Text('শ্রমিক-বিল খতিয়ান দেখুন', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('ঠিকাদার কর্তৃক পাঠানো অনুমোদিত বিল স্টেটমেন্ট'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => BillStatementsScreen(
                            projectId: project.id,
                            projectName: project.name,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  ListTile(
                    tileColor: isDark ? AppColors.darkCard : AppColors.lightCard,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                    ),
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.contractorPrimary,
                      child: Icon(Icons.inventory_2_rounded, color: Colors.white),
                    ),
                    title: const Text('সাইটের মালামাল তালিকা', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('সাইটে আসা নির্মাণ সামগ্রী ও চালান ভাউচার'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => MaterialsScreen(
                            projectId: project.id,
                            projectName: project.name,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
