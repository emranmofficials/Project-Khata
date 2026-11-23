import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/bengali_formatter.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../domain/models/attendance_record_model.dart';

/// দৈনিক এন্ট্রির কর্মীর হাজিরা টাইল
class AttendanceItemTile extends StatelessWidget {
  final AttendanceRecordModel record;
  final bool isEditable;
  final Function(String newStatus, double overtimeHours) onStatusChanged;

  const AttendanceItemTile({
    super.key,
    required this.record,
    required this.isEditable,
    required this.onStatusChanged,
  });

  void _showOvertimeDialog(BuildContext context) {
    double currentHours = record.overtimeHours > 0 ? record.overtimeHours : 2.0;
    final controller = TextEditingController(text: currentHours.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.cardRadius)),
        title: const Text('ওভারটাইম ঘণ্টা নির্ধারণ'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('কর্মী: ${record.workerName}'),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'ওভারটাইম ঘণ্টা (যেমন: ২.৫)',
                suffixText: 'ঘণ্টা',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('বাতিল'),
          ),
          ElevatedButton(
            onPressed: () {
              final hours = double.tryParse(controller.text.trim()) ?? 0.0;
              Navigator.of(ctx).pop();
              onStatusChanged('overtime', hours);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.workerPrimary),
            child: const Text('সংরক্ষণ', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // নাম, পদ ও লোকেশন স্ট্যাটাস
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.contractorPrimary.withOpacity(0.1),
                child: Text(
                  record.workerName.isNotEmpty ? record.workerName[0] : 'শ',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.contractorPrimary),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.workerName,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                    Text(
                      '${record.designationName} • দৈনিক: ${BengaliFormatter.toCurrency(record.dailyRate)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // লোকেশন স্ট্যাটাস চিপ
              _buildLocationBadge(record.locationStatus, record.distanceM),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 10),

          // হাজিরা নির্বাচনের বোতামসমূহ
          if (isEditable) ...[
            Row(
              children: [
                _buildStatusButton(
                  label: 'উপস্থিত',
                  isSelected: record.isPresent,
                  color: AppColors.success,
                  onTap: () => onStatusChanged('present', 0.0),
                ),
                const SizedBox(width: 6),
                _buildStatusButton(
                  label: 'অর্ধদিবস',
                  isSelected: record.isHalfDay,
                  color: const Color(0xFFD97706),
                  onTap: () => onStatusChanged('half', 0.0),
                ),
                const SizedBox(width: 6),
                _buildStatusButton(
                  label: 'অনুপস্থিত',
                  isSelected: record.isAbsent,
                  color: AppColors.danger,
                  onTap: () => onStatusChanged('absent', 0.0),
                ),
                const SizedBox(width: 6),
                _buildStatusButton(
                  label: record.isOvertime
                      ? 'ওভারটাইম (${BengaliFormatter.toBengaliNumber(record.overtimeHours)}ঘ)'
                      : 'ওভারটাইম',
                  isSelected: record.isOvertime,
                  color: AppColors.workerPrimary,
                  onTap: () => _showOvertimeDialog(context),
                ),
              ],
            ),
          ] else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                StatusChip.forStatus(record.statusBengaliLabel),
                if (record.isOvertime)
                  Text(
                    'ওভারটাইম: ${BengaliFormatter.toBengaliNumber(record.overtimeHours)} ঘণ্টা',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.workerPrimary),
                  ),
                if (record.isPendingApproval)
                  const Text(
                    'অনুমোদনের অপেক্ষায়',
                    style: TextStyle(fontSize: 12, color: AppColors.warning, fontWeight: FontWeight.bold),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLocationBadge(String status, double? distanceM) {
    Color color;
    String text;
    IconData icon;

    switch (status) {
      case 'verified':
        color = AppColors.success;
        text = 'সঠিক';
        icon = Icons.check_circle_outline;
        break;
      case 'outside_site':
        color = AppColors.danger;
        text = distanceM != null 
            ? 'বাইরে (${BengaliFormatter.toBengaliNumber(distanceM.toInt())}মি)' 
            : 'বাইরে';
        icon = Icons.wrong_location_outlined;
        break;
      default:
        color = const Color(0xFF64748B);
        text = 'লোকেশন নাই';
        icon = Icons.location_off_outlined;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusButton({
    required String label,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? color : color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? color : color.withOpacity(0.3),
              width: 1,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
