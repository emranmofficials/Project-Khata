import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/offline_sync_manager.dart';
import '../utils/bengali_formatter.dart';
import '../../features/attendance/data/attendance_repository.dart';

/// অফলাইন পেন্ডিং এন্ট্রি ও সিঙ্ক নোটিফিকেশন ব্যানার
class OfflineSyncBanner extends ConsumerWidget {
  const OfflineSyncBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingItems = ref.watch(pendingSyncNotifierProvider);
    final count = pendingItems.length;

    if (count == 0) {
      return const SizedBox.shrink();
    }

    final isSyncing = ref.watch(isSyncingProvider);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1), // Amber 50
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFD54F), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            color: Color(0xFFE65100),
            size: 26,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: InkWell(
              onTap: () => _showPendingQueueBottomSheet(context, ref, pendingItems),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'অফলাইনে ${BengaliFormatter.toBnNumber(count)}টি এন্ট্রি সিঙ্ক বাকি',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Color(0xFF4E342E),
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'বিস্তারিত দেখতে ট্যাপ করুন',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF795548),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFE65100),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: const Size(48, 38),
            ),
            icon: isSyncing
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.sync_rounded, size: 16),
            label: Text(
              isSyncing ? 'সিঙ্ক...' : 'সিঙ্ক করুন',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            onPressed: isSyncing ? null : () => _performSync(context, ref),
          ),
        ],
      ),
    );
  }

  Future<void> _performSync(BuildContext context, WidgetRef ref) async {
    ref.read(isSyncingProvider.notifier).state = true;
    try {
      final repo = ref.read(attendanceRepositoryProvider);
      final result =
          await ref.read(pendingSyncNotifierProvider.notifier).syncAll(repo);

      if (context.mounted) {
        if (result.isAllSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: const Color(0xFF2E7D32),
              content: Text(
                '${BengaliFormatter.toBnNumber(result.successCount)}টি অফলাইন এন্ট্রি সফলভাবে সার্ভারে সিঙ্ক সম্পন্ন হয়েছে!',
              ),
            ),
          );
        } else if (result.failedCount > 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: const Color(0xFFD84315),
              content: Text(
                '${BengaliFormatter.toBnNumber(result.successCount)}টি সিঙ্ক সফল, ${BengaliFormatter.toBnNumber(result.failedCount)}টি ব্যর্থ হয়েছে। ইন্টারনেট সংযোগ পরীক্ষা করুন।',
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text('সিঙ্ক ব্যর্থ হয়েছে: $e'),
          ),
        );
      }
    } finally {
      ref.read(isSyncingProvider.notifier).state = false;
    }
  }

  void _showPendingQueueBottomSheet(
    BuildContext context,
    WidgetRef ref,
    List<QueuedSyncItem> items,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'অপেক্ষমান অফলাইন এন্ট্রি (${BengaliFormatter.toBnNumber(items.length)})',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      tooltip: 'বন্ধ করুন',
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const Divider(),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFFFF3E0),
                          child: Icon(Icons.edit_note, color: Color(0xFFE65100)),
                        ),
                        title: Text(
                          item.projectName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'তারিখ: ${BengaliFormatter.toDate(item.entryDate)} • শ্রমিক: ${BengaliFormatter.toBnNumber(item.recordsData.length)} জন',
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          tooltip: 'মুছে ফেলুন',
                          onPressed: () async {
                            await ref
                                .read(pendingSyncNotifierProvider.notifier)
                                .removeItem(item.id);
                            if (ctx.mounted) {
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('অফলাইন এন্ট্রিটি তালিকা থেকে মুছে ফেলা হয়েছে।'),
                                ),
                              );
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFE65100),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.sync_rounded),
                    label: const Text(
                      'সবগুলো এখনই সিঙ্ক করুন',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _performSync(context, ref);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
