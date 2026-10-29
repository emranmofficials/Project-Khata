import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/bengali_formatter.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../data/accounts_repository.dart';
import '../../domain/models/wage_record.dart';

final workerWagesProvider =
    FutureProvider.family<List<WageRecord>, String>((ref, workerId) async {
  final repo = ref.watch(accountsRepositoryProvider);
  return repo.getWorkerWages(workerId);
});

class WorkerWageHistoryScreen extends ConsumerWidget {
  final bool showAppBar;

  const WorkerWageHistoryScreen({
    super.key,
    this.showAppBar = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).value;
    final workerId = user?.id;

    if (workerId == null) {
      return const Scaffold(
        body: Center(child: Text('ব্যবহারকারী তথ্য পাওয়া যায়নি')),
      );
    }

    final wagesAsync = ref.watch(workerWagesProvider(workerId));

    final content = wagesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('ত্রুটি: $err')),
      data: (wages) {
        if (wages.isEmpty) {
          return const Center(
            child: Text(
              'কোনো কাজের মজুরি রেকর্ড নেই',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        final totalEarned =
            wages.fold<double>(0.0, (s, w) => s + w.totalEarned);
        final totalPaid = wages
            .where((w) => w.isPaid)
            .fold<double>(0.0, (s, w) => s + w.totalEarned);
        final due = (totalEarned - totalPaid).clamp(0, double.infinity);

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              elevation: 2,
              color: AppColors.workerPrimary,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'মোট অর্জিত মজুরি',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      BengaliFormatter.toCurrency(totalEarned),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(color: Colors.white24, height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('পরিশোধিত',
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 12)),
                            const SizedBox(height: 4),
                            Text(
                              BengaliFormatter.toCurrency(totalPaid),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('বকেয়া প্রাপ্য',
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 12)),
                            const SizedBox(height: 4),
                            Text(
                              BengaliFormatter.toCurrency(due.toDouble()),
                              style: const TextStyle(
                                  color: Colors.amberAccent,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'দিনভিত্তিক মজুরি ও কাজের বিবরণ',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...wages.map((item) => Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              BengaliFormatter.toBnDate(item.workDate),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${item.projectName ?? "প্রজেক্ট"}${item.overtimeAmount > 0 ? " • ওটি: ${BengaliFormatter.toCurrency(item.overtimeAmount)}" : ""}',
                              style: TextStyle(
                                  color: Colors.grey.shade600, fontSize: 12),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              BengaliFormatter.toCurrency(item.totalEarned),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Colors.indigo,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: item.isPaid
                                    ? Colors.green.shade100
                                    : Colors.amber.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                item.isPaid ? 'পরিশোধিত' : 'বকেয়া',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: item.isPaid
                                      ? Colors.green.shade800
                                      : Colors.amber.shade900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )),
          ],
        );
      },
    );

    if (!showAppBar) return content;

    return Scaffold(
      appBar: AppBar(title: const Text('আমার মজুরির খতিয়ান')),
      body: content,
    );
  }
}
