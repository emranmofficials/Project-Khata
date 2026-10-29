import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/bengali_formatter.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/attendance_controller.dart';
import '../../domain/models/attendance_record.dart';

class AttendanceHistoryScreen extends ConsumerWidget {
  final String? workerId;
  final bool showAppBar;

  const AttendanceHistoryScreen({
    super.key,
    this.workerId,
    this.showAppBar = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider).value;
    final targetWorkerId = workerId ?? currentUser?.id ?? '';

    final historyAsync = ref.watch(workerAttendanceHistoryProvider(targetWorkerId));

    return Scaffold(
      appBar: showAppBar
          ? AppBar(title: const Text('হাজিরা ও কাজের ইতিহাস'))
          : null,
      body: historyAsync.when(
        data: (records) {
          if (records.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_outlined, size: 60, color: Colors.grey),
                  SizedBox(height: 12),
                  Text(
                    'কোনো হাজিরার রেকর্ড পাওয়া যায়নি',
                    style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
                  ),
                ],
              ),
            );
          }

          // সামারি ক্যালকুলেশন
          int fullDays = 0;
          int halfDays = 0;
          double totalOt = 0.0;
          double totalEarnings = 0.0;

          for (final r in records) {
            if (r.status == AttendanceStatus.fullDay) {
              fullDays++;
            } else if (r.status == AttendanceStatus.halfDay) {
              halfDays++;
            }
            totalOt += r.otHours;

            if (r.dailyWage != null) {
              final wage = r.dailyWage! * r.status.wageMultiplier;
              final otRate = r.dailyWage! / 8.0; // আদর্শ ৮ ঘণ্টা শিফট
              totalEarnings += wage + (r.otHours * otRate);
            }
          }

          return Column(
            children: [
              // ১. সারসংক্ষেপ কার্ড
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.workerPrimary, Color(0xFF4C1D95)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.workerPrimary.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'মোট হাজিরা সামারি',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'মোট: ${BengaliFormatter.toBnNumber(records.length)} দিন',
                            style: const TextStyle(fontSize: 12, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const Divider(color: Colors.white24, height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildSummaryItem(
                          title: 'পূর্ণদিবস',
                          value: '${BengaliFormatter.toBnNumber(fullDays)} দিন',
                        ),
                        _buildSummaryItem(
                          title: 'অর্ধদিবস',
                          value: '${BengaliFormatter.toBnNumber(halfDays)} দিন',
                        ),
                        _buildSummaryItem(
                          title: 'ওভারটাইম',
                          value: '${BengaliFormatter.toBnNumber(totalOt)} ঘণ্টা',
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ২. হাজিরার তালিকা
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: records.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final record = records[index];

                    Color statusBg;
                    Color statusColor;
                    if (record.status == AttendanceStatus.fullDay) {
                      statusBg = Colors.green.shade50;
                      statusColor = Colors.green.shade800;
                    } else if (record.status == AttendanceStatus.halfDay) {
                      statusBg = Colors.amber.shade50;
                      statusColor = Colors.amber.shade900;
                    } else {
                      statusBg = Colors.red.shade50;
                      statusColor = Colors.red.shade800;
                    }

                    return Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: statusBg,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                record.status == AttendanceStatus.absent
                                    ? Icons.cancel_outlined
                                    : Icons.check_circle_outline,
                                color: statusColor,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    BengaliFormatter.toDate(record.entryDate),
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Text(
                                        record.status.bengaliLabel,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: statusColor,
                                        ),
                                      ),
                                      if (record.otHours > 0) ...[
                                        const Text(' • ',
                                            style: TextStyle(color: Colors.grey)),
                                        Text(
                                          'ওভারটাইম: ${BengaliFormatter.toBnNumber(record.otHours)} ঘণ্টা',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            if (record.locationStatus == LocationStatus.outsideSite)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.amber.shade100,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'সাইটের বাইরে',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.brown,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('ত্রুটি: $err')),
      ),
    );
  }

  Widget _buildSummaryItem({required String title, required String value}) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          title,
          style: const TextStyle(fontSize: 12, color: Colors.white70),
        ),
      ],
    );
  }
}
