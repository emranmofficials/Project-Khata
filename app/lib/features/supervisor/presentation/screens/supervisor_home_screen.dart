import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../../core/widgets/summary_card.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../attendance/presentation/screens/daily_entry_details_screen.dart';

/// PRD সেকশন ৭ অনুযায়ী সুপারভাইজার ইন্টারফেস
class SupervisorHomeScreen extends ConsumerWidget {
  const SupervisorHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('সুপারভাইজার ড্যাশবোর্ড'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => ref.read(authStateProvider.notifier).signOut(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SummaryCard(
              role: 'supervisor',
              orgName: user?.name ?? 'সুপারভাইজার',
              title: 'আজকের নির্ধারিত দল',
              kpiValue: '১৪',
              subText: '২টি প্রজেক্টে অ্যাসাইনমেন্ট সক্রিয়',
            ),
            const SizedBox(height: 24),
            const Text(
              'অ্যাসাইন করা প্রজেক্ট ও এন্ট্রি',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingMedium),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'ধানমন্ডি লেকভিউ রেসিডেন্স',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                      StatusChip.forStatus('খোলা'),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text('সাইটের ঠিকানা: রোড ১২/এ, ধানমন্ডি', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const DailyEntryDetailsScreen(entryId: 'demo-entry-1'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.group_add_rounded, size: 18),
                    label: const Text('দল গঠন ও হাজিরা দিন'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.supervisorPrimary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
