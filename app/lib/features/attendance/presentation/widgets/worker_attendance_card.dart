import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/bengali_formatter.dart';
import '../../domain/models/attendance_record.dart';

class WorkerAttendanceCard extends StatelessWidget {
  final AttendanceRecord record;
  final ValueChanged<AttendanceStatus> onStatusChanged;
  final ValueChanged<double> onOtChanged;
  final VoidCallback onRemove;

  const WorkerAttendanceCard({
    super.key,
    required this.record,
    required this.onStatusChanged,
    required this.onOtChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: record.status == AttendanceStatus.absent
              ? Colors.red.shade200
              : Colors.grey.shade200,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Worker Info Header
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.supervisorPrimary.withValues(alpha: 0.1),
                  child: Text(
                    record.workerName != null && record.workerName!.isNotEmpty
                        ? record.workerName![0]
                        : 'শ',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.supervisorPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.workerName ?? 'অজানা শ্রমিক',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          if (record.designationName != null)
                            Text(
                              record.designationName!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          if (record.dailyWage != null) ...[
                            const Text(' • ',
                                style: TextStyle(
                                    fontSize: 12, color: AppColors.textSecondary)),
                            Text(
                              '${BengaliFormatter.toCurrency(record.dailyWage!)}/দিন',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20, color: Colors.grey),
                  onPressed: onRemove,
                  tooltip: 'টিম থেকে সরান',
                ),
              ],
            ),
            const Divider(height: 16),

            // Attendance Status Segmented Buttons
            Row(
              children: [
                _buildStatusButton(
                  context,
                  title: 'পূর্ণদিবস',
                  status: AttendanceStatus.fullDay,
                  activeColor: Colors.green,
                ),
                const SizedBox(width: 6),
                _buildStatusButton(
                  context,
                  title: 'অর্ধদিবস',
                  status: AttendanceStatus.halfDay,
                  activeColor: Colors.amber.shade800,
                ),
                const SizedBox(width: 6),
                _buildStatusButton(
                  context,
                  title: 'অনুপস্থিত',
                  status: AttendanceStatus.absent,
                  activeColor: Colors.red,
                ),
              ],
            ),

            // OT Hours Section (Only if present)
            if (record.status != AttendanceStatus.absent) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'ওভারটাইম:',
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, size: 20),
                        color: record.otHours > 0 ? AppColors.supervisorPrimary : Colors.grey,
                        onPressed: record.otHours > 0
                            ? () => onOtChanged((record.otHours - 0.5).clamp(0.0, 24.0))
                            : null,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Text(
                          '${BengaliFormatter.toBnNumber(record.otHours)} ঘণ্টা',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline, size: 20),
                        color: AppColors.supervisorPrimary,
                        onPressed: () => onOtChanged((record.otHours + 0.5).clamp(0.0, 24.0)),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusButton(
    BuildContext context, {
    required String title,
    required AttendanceStatus status,
    required Color activeColor,
  }) {
    final isSelected = record.status == status;

    return Expanded(
      child: InkWell(
        onTap: () => onStatusChanged(status),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? activeColor.withValues(alpha: 0.15) : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? activeColor : Colors.grey.shade300,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? activeColor : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
