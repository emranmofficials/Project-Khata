import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/bengali_formatter.dart';
import '../../../../core/widgets/kpi_card.dart';
import '../../../../core/widgets/loading_skeleton.dart';
import '../../../../core/widgets/summary_card.dart';
import '../../../accounting/presentation/providers/accounting_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../attendance/presentation/screens/worker_mark_attendance_screen.dart';
import '../../../project/presentation/providers/project_provider.dart';

/// PRD সেকশন ৯ অনুযায়ী শ্রমিক ইন্টারফেস
class WorkerHomeScreen extends ConsumerWidget {
  const WorkerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).user;
    final projectsAsync = ref.watch(projectsListProvider);
    final wagesAsync = ref.watch(wageLedgerListProvider(null));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // শ্রমিকের অর্জিত ও বকেয়া মজুরি গণনা
    double totalEarned = 0.0;
    double totalPaid = 0.0;
    int attendedDays = 0;

    wagesAsync.whenData((wages) {
      attendedDays = wages.length;
      for (var w in wages) {
        totalEarned += w.totalAmount;
        totalPaid += w.allocatedPaid;
      }
    });

    final dueAmount = (totalEarned - totalPaid).clamp(0.0, double.infinity);

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
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(projectsListProvider);
          ref.invalidate(wageLedgerListProvider(null));
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SummaryCard(
                role: 'worker',
                orgName: user?.name ?? 'শ্রমিক ভাই',
                title: 'এই মাসে কাজের দিন',
                kpiValue: BengaliFormatter.toBengaliNumber(attendedDays.toString()),
                subText: 'মোট অর্জিত মজুরি: ${BengaliFormatter.toCurrency(totalEarned)}',
              ),
              const SizedBox(height: 24),
              const Text(
                'আজকের হাজিরা',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),

              projectsAsync.when(
                loading: () => const LoadingSkeletonCard(height: 140),
                error: (err, _) => Text('প্রজেক্ট তথ্য লোড হয়নি: $err'),
                data: (projects) {
                  final activeProject = projects.where((p) => p.status == 'active').firstOrNull ??
                      projects.firstOrNull;

                  if (activeProject == null) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSizes.paddingLarge),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCard : AppColors.lightCard,
                        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.location_off_rounded, size: 40, color: Colors.grey),
                          SizedBox(height: 8),
                          Text(
                            'বর্তমানে কোনো সক্রিয় প্রজেক্ট নেই',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'সুপারভাইজার কাজ শুরু করলে আপনি হাজিরা দিতে পারবেন।',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  return Container(
                    padding: const EdgeInsets.all(AppSizes.paddingLarge),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : AppColors.lightCard,
                      borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                      border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'প্রজেক্ট: ${activeProject.name}',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'সাইটের ঠিকানা: ${activeProject.address} (১৫০ মি. জিও-ফেন্স)',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const WorkerMarkAttendanceScreen(),
                              ),
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
                  );
                },
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: KpiCard(
                      title: 'পরিশোধিত মজুরি',
                      value: totalPaid.toStringAsFixed(0),
                      isCurrency: true,
                      accentColor: AppColors.success,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: KpiCard(
                      title: 'বর্তমান বকেয়া',
                      value: dueAmount.toStringAsFixed(0),
                      isCurrency: true,
                      accentColor: AppColors.warning,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
