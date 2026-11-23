import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

/// PRD সেকশন ১১.১ অনুযায়ী স্ট্যাটাস চিপ (লেখা ও রঙের সমন্বয়)
class StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const StatusChip({
    super.key,
    required this.label,
    required this.color,
    this.icon,
  });

  factory StatusChip.forStatus(String status) {
    switch (status.toLowerCase()) {
      case 'open':
      case 'খোলা':
        return const StatusChip(
          label: 'খোলা',
          color: Color(0xFF2563EB),
          icon: Icons.lock_open_rounded,
        );
      case 'submitted':
      case 'জমা':
        return const StatusChip(
          label: 'জমা',
          color: AppColors.warning,
          icon: Icons.send_rounded,
        );
      case 'locked':
      case 'approved':
      case 'অনুমোদিত':
        return const StatusChip(
          label: 'অনুমোদিত',
          color: AppColors.success,
          icon: Icons.check_circle_rounded,
        );
      case 'handover_required':
      case 'হস্তান্তর প্রয়োজন':
        return const StatusChip(
          label: 'হস্তান্তর প্রয়োজন',
          color: AppColors.danger,
          icon: Icons.swap_horiz_rounded,
        );
      case 'active':
      case 'চলমান':
        return const StatusChip(
          label: 'চলমান',
          color: AppColors.success,
          icon: Icons.play_circle_fill_rounded,
        );
      case 'planned':
      case 'পরিকল্পনা':
        return const StatusChip(
          label: 'পরিকল্পনা',
          color: Color(0xFF64748B),
          icon: Icons.schedule_rounded,
        );
      case 'completed':
      case 'সম্পন্ন':
        return const StatusChip(
          label: 'সম্পন্ন',
          color: Color(0xFF0D9488),
          icon: Icons.task_alt_rounded,
        );
      case 'on_hold':
      case 'স্থগিত':
        return const StatusChip(
          label: 'স্থগিত',
          color: AppColors.warning,
          icon: Icons.pause_circle_filled_rounded,
        );
      default:
        return StatusChip(
          label: status,
          color: const Color(0xFF64748B),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppSizes.chipRadius),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
