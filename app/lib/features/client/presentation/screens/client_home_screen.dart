import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/kpi_card.dart';
import '../../../../core/widgets/summary_card.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// PRD সেকশন ৮ অনুযায়ী ক্লায়েন্ট ইন্টারফেস
class ClientHomeScreen extends ConsumerWidget {
  const ClientHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('প্রজেক্ট ড্যাশবোর্ড'),
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
              role: 'client',
              orgName: user?.name ?? 'সম্মানিত ক্লায়েন্ট',
              title: 'কাজের অগ্রগতি',
              kpiValue: '৬৫', // কাজের শতাংশ
              subText: 'প্রজেক্ট: ধানমন্ডি লেকভিউ রেসিডেন্স',
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: KpiCard(
                    title: 'মোট চুক্তি মূল্য',
                    value: '1500000',
                    isCurrency: true,
                    accentColor: AppColors.clientPrimary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: KpiCard(
                    title: 'পরিশোধিত অর্থ',
                    value: '950000',
                    isCurrency: true,
                    accentColor: AppColors.success,
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
