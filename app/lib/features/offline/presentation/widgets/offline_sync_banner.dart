import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/bengali_formatter.dart';
import '../../../attendance/presentation/providers/attendance_provider.dart';
import '../../domain/offline_sync_queue.dart';

/// PRD সেকশন ১০.৪ অনুযায়ী অফলাইন ব্যানার ও সিঙ্ক স্ট্যাটাস ইন্ডিকেটর
class OfflineSyncBanner extends ConsumerWidget {
  final bool isOffline;

  const OfflineSyncBanner({
    super.key,
    this.isOffline = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingCountAsync = ref.watch(pendingOfflineCountProvider);

    return pendingCountAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (count) {
        if (!isOffline && count == 0) {
          return const SizedBox.shrink();
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isOffline ? AppColors.warning : AppColors.contractorPrimary,
          ),
          child: Row(
            children: [
              Icon(
                isOffline ? Icons.wifi_off_rounded : Icons.sync_rounded,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isOffline
                      ? 'অফলাইন — সেভ হচ্ছে, নেটওয়ার্ক ফিরলে জমা হবে।'
                      : 'অপেক্ষমাণ $countটি আইটেম ক্লাউডে সিঙ্ক হচ্ছে...',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (count > 0 && !isOffline)
                TextButton(
                  onPressed: () async {
                    final repo = ref.read(attendanceRepositoryProvider);
                    await OfflineSyncQueue.syncQueue(repo);
                    ref.invalidate(pendingOfflineCountProvider);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.zero,
                  ),
                  child: const Text('এখনই সিঙ্ক', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
        );
      },
    );
  }
}
