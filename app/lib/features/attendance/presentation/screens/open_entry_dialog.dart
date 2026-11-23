import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/bengali_formatter.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/attendance_provider.dart';

/// PRD সেকশন ৩.৬ ও ৭.২ অনুযায়ী দৈনিক এন্ট্রি খোলার ডায়ালগ
class OpenDailyEntryDialog extends ConsumerStatefulWidget {
  final String projectId;
  final String projectName;

  const OpenDailyEntryDialog({
    super.key,
    required this.projectId,
    required this.projectName,
  });

  @override
  ConsumerState<OpenDailyEntryDialog> createState() => _OpenDailyEntryDialogState();
}

class _OpenDailyEntryDialogState extends ConsumerState<OpenDailyEntryDialog> {
  DateTime _selectedDate = DateTime.now();
  final _reasonController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  bool get _isBackdated {
    final now = DateTime.now();
    return _selectedDate.year != now.year ||
        _selectedDate.month != now.month ||
        _selectedDate.day != now.day;
  }

  void _handleOpenEntry() async {
    final reason = _reasonController.text.trim();

    if (_isBackdated && reason.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ব্যাকডেটেড এন্ট্রির জন্য কারণ লেখা বাধ্যতামূলক।'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final res = await ref.read(attendanceActionProvider.notifier).openDailyEntry(
        projectId: widget.projectId,
        entryDate: _selectedDate,
        backdateReason: _isBackdated ? reason : null,
      );

      if (mounted) {
        Navigator.of(context).pop(res['entry_id']);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('আজকের দৈনিক এন্ট্রি খোলা হয়েছে!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).user;
    final isContractor = user?.isContractor ?? false;
    final maxBackDays = isContractor ? 7 : 1; // সুপারভাইজার ১ দিন, ঠিকাদার ৭ দিন

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.cardRadius)),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('দৈনিক এন্ট্রি খুলুন', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(
            widget.projectName,
            style: const TextStyle(fontSize: 13, color: AppColors.contractorPrimary, fontWeight: FontWeight.w600),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('এন্ট্রির তারিখ নির্ধারণ করুন:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    BengaliFormatter.toFullDate(_selectedDate),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime.now().subtract(Duration(days: maxBackDays)),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() {
                          _selectedDate = picked;
                        });
                      }
                    },
                    icon: const Icon(Icons.calendar_today_rounded, size: 16),
                    label: const Text('পরিবর্তন'),
                  ),
                ],
              ),
            ),

            if (_isBackdated) ...[
              const SizedBox(height: 16),
              TextField(
                controller: _reasonController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'ব্যাকডেটেড এন্ট্রির কারণ লিখুন *',
                  hintText: 'কেন পূর্ববর্তী তারিখে এন্ট্রি খুলছেন তা লিখুন...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'সাহায্য: ব্যাকডেটেড এন্ট্রির কারণ ঠিকাদারের অডিট লগে সংরক্ষিত থাকবে।',
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('বাতিল'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleOpenEntry,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.supervisorPrimary,
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('এন্ট্রি খুলুন'),
        ),
      ],
    );
  }
}
