import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/bengali_formatter.dart';
import '../../../auth/domain/models/app_user.dart';
import '../controllers/attendance_controller.dart';

class AddWorkerDialog extends ConsumerStatefulWidget {
  final String orgId;
  final List<String> existingWorkerIds;
  final ValueChanged<AppUser> onWorkerSelected;

  const AddWorkerDialog({
    super.key,
    required this.orgId,
    required this.existingWorkerIds,
    required this.onWorkerSelected,
  });

  @override
  ConsumerState<AddWorkerDialog> createState() => _AddWorkerDialogState();
}

class _AddWorkerDialogState extends ConsumerState<AddWorkerDialog> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final workersAsync = ref.watch(orgWorkersProvider(widget.orgId));

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(maxHeight: 500, maxWidth: 400),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.group_add, color: AppColors.supervisorPrimary),
                const SizedBox(width: 8),
                const Text(
                  'টিমে শ্রমিক যুক্ত করুন',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                hintText: 'নাম বা মোবাইল নম্বর দিয়ে খুঁজুন...',
                prefixIcon: const Icon(Icons.search),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: workersAsync.when(
                data: (workers) {
                  final filtered = workers.where((w) {
                    final matchesSearch = w.name.toLowerCase().contains(_searchQuery) ||
                        (w.mobile != null && w.mobile!.contains(_searchQuery));
                    return matchesSearch;
                  }).toList();

                  if (filtered.isEmpty) {
                    return const Center(
                      child: Text(
                        'কোনো শ্রমিক পাওয়া যায়নি',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final worker = filtered[index];
                      final isAlreadyAdded = widget.existingWorkerIds.contains(worker.id);

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isAlreadyAdded
                              ? Colors.grey.shade200
                              : AppColors.supervisorPrimary.withValues(alpha: 0.1),
                          child: Text(
                            worker.name.isNotEmpty ? worker.name[0] : 'শ',
                            style: TextStyle(
                              color: isAlreadyAdded
                                  ? Colors.grey
                                  : AppColors.supervisorPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          worker.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: isAlreadyAdded ? Colors.grey : Colors.black,
                          ),
                        ),
                        subtitle: Text(
                          '${worker.designationTitle ?? "পদহীন"} • ${worker.mobile ?? ""}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isAlreadyAdded ? Colors.grey : AppColors.textSecondary,
                          ),
                        ),
                        trailing: isAlreadyAdded
                            ? const Chip(
                                label: Text('যুক্ত আছে', style: TextStyle(fontSize: 11)),
                                padding: EdgeInsets.zero,
                              )
                            : worker.dailyWage != null
                                ? Text(
                                    BengaliFormatter.toCurrency(worker.dailyWage!),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  )
                                : null,
                        enabled: !isAlreadyAdded,
                        onTap: () {
                          widget.onWorkerSelected(worker);
                          Navigator.of(context).pop();
                        },
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('ত্রুটি: $err')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
