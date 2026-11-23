import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../providers/project_provider.dart';

/// PRD সেকশন ৬.৩ (৪) অনুযায়ী প্রজেক্ট স্ট্যাটাস পরিবর্তন বটম শীট
class ChangeStatusBottomSheet extends ConsumerWidget {
  final String projectId;
  final String currentStatus;

  const ChangeStatusBottomSheet({
    super.key,
    required this.projectId,
    required this.currentStatus,
  });

  void _updateStatus(BuildContext context, WidgetRef ref, String newStatus, String label) async {
    if (newStatus == currentStatus) {
      Navigator.of(context).pop();
      return;
    }

    if (newStatus == 'completed' || newStatus == 'on_hold') {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.cardRadius)),
          title: Text('$label নিশ্চিতকরণ'),
          content: Text(
            newStatus == 'completed'
                ? 'প্রজেক্টটি "সম্পন্ন" হিসেবে চিহ্নিত করলে এতে আর নতুন দৈনিক এন্ট্রি খোলা যাবে না। আপনি কি নিশ্চিত?'
                : 'প্রজেক্টটি "স্থগিত" হিসেবে চিহ্নিত করলে এতে সাময়িকভাবে নতুন দৈনিক এন্ট্রি খোলা বন্ধ থাকবে। আপনি কি নিশ্চিত?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('না'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: newStatus == 'completed' ? AppColors.success : AppColors.warning,
              ),
              child: const Text('হ্যাঁ, পরিবর্তন করুন', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );

      if (confirmed != true) return;
    }

    try {
      await ref.read(projectActionProvider.notifier).updateProjectStatus(projectId, newStatus);
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('প্রজেক্ট স্ট্যাটাস "$label" করা হয়েছে'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ত্রুটি: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingLarge),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'প্রজেক্ট স্ট্যাটাস পরিবর্তন',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _buildStatusTile(context, ref, 'planned', 'পরিকল্পনা', Icons.schedule_rounded, const Color(0xFF64748B)),
          _buildStatusTile(context, ref, 'active', 'চলমান', Icons.play_circle_fill_rounded, AppColors.success),
          _buildStatusTile(context, ref, 'completed', 'সম্পন্ন', Icons.task_alt_rounded, const Color(0xFF0D9488)),
          _buildStatusTile(context, ref, 'on_hold', 'স্থগিত', Icons.pause_circle_filled_rounded, AppColors.warning),
        ],
      ),
    );
  }

  Widget _buildStatusTile(
    BuildContext context,
    WidgetRef ref,
    String status,
    String label,
    IconData icon,
    Color color,
  ) {
    final isCurrent = currentStatus == status;

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: isCurrent ? const Icon(Icons.check_circle_rounded, color: AppColors.success) : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      tileColor: isCurrent ? color.withOpacity(0.08) : null,
      onTap: () => _updateStatus(context, ref, status, label),
    );
  }
}
