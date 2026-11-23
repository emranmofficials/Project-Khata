import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/kpi_card.dart';
import '../../../../core/widgets/summary_card.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../attendance/presentation/screens/worker_mark_attendance_screen.dart';

/// PRD সেকশন ৯ অনুযায়ী শ্রমিক ইন্টারফেস
class WorkerHomeScreen extends ConsumerWidget {
  const WorkerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('শ্রমিক পোর্টাল'),
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
              role: 'worker',
              orgName: user?.name ?? 'শ্রমিক ভাই',
              title: 'এই মাসে উপস্থিত দিন',
              kpiValue: '১৮',
              subText: 'মোট অর্জিত মজুরি: ৳ ১৬,২০০',
            ),
            const SizedBox(height: 24),
            const Text(
              'আজকের হাজিরা',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingLarge),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'প্রজেক্ট: ধানমন্ডি লেকভিউ রেসিডেন্স',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'আজকের এন্ট্রি খোলা রয়েছে। আপনি সাইটে উপস্থিত থাকলে হাজিরা বোতামে চাপুন।',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const WorkerMarkAttendanceScreen()),
                      );
                    },
                    icon: const Icon(Icons.my_location_rounded),
                    label: const Text(
                      AppStrings.markAttendance,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.workerPrimary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: KpiCard(
                    title: 'পরিশোধিত মজুরি',
                    value: '12000',
                    isCurrency: true,
                    accentColor: AppColors.success,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: KpiCard(
                    title: 'বর্তমান বকেয়া',
                    value: '4200',
                    isCurrency: true,
                    accentColor: AppColors.warning,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
