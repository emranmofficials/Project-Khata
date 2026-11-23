import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/bengali_formatter.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../../core/widgets/loading_skeleton.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/attendance_provider.dart';
import '../widgets/attendance_item_tile.dart';

/// PRD সেকশন ৭.২ অনুযায়ী দৈনিক এন্ট্রি ও দল পরিচালনা স্ক্রিন
class DailyEntryDetailsScreen extends ConsumerStatefulWidget {
  final String entryId;

  const DailyEntryDetailsScreen({
    super.key,
    required this.entryId,
  });

  @override
  ConsumerState<DailyEntryDetailsScreen> createState() => _DailyEntryDetailsScreenState();
}

class _DailyEntryDetailsScreenState extends ConsumerState<DailyEntryDetailsScreen> {
  bool _isMarkingSelf = false;

  void _handleSupervisorSelfAttendance(String projectId) async {
    setState(() => _isMarkingSelf = true);
    final user = ref.read(authStateProvider).user;
    if (user == null) return;

    try {
      double? lat;
      double? lng;
      double? accuracy;

      // জিপিএস পারমিশন ও লোকেশন গ্রহণ
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        Position pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        lat = pos.latitude;
        lng = pos.longitude;
        accuracy = pos.accuracy;
      }

      final res = await ref.read(attendanceActionProvider.notifier).markAttendance(
        entryId: widget.entryId,
        workerId: user.id,
        status: 'present',
        lat: lat,
        lng: lng,
        accuracy: accuracy,
      );

      if (mounted) {
        final locStatus = res['location_status'];
        final isVerified = locStatus == 'verified';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isVerified
                  ? 'আপনার নিজের উপস্থিতি সাইটে সঠিক হিসেবে রেকর্ড হয়েছে!'
                  : 'আপনি সাইটের বাইরে অবস্থান করছেন। হাজিরার জন্য ঠিকাদারের অনুমোদন প্রয়োজন হবে।',
            ),
            backgroundColor: isVerified ? AppColors.success : AppColors.warning,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ত্রুটি: $e'), backgroundColor: AppColors.danger),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isMarkingSelf = false);
      }
    }
  }

  void _updateWorkerStatus(String workerId, String newStatus, double overtimeHours) async {
    try {
      await ref.read(attendanceActionProvider.notifier).markAttendance(
        entryId: widget.entryId,
        workerId: workerId,
        status: newStatus,
        overtimeHours: overtimeHours,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  void _handleSubmitEntry(String projectId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.cardRadius)),
        title: const Text('এন্ট্রি জমা দিন'),
        content: const Text(
          'আজকের এন্ট্রি জমা দিলে আপনি আর এতে পরিবর্তন করতে পারবেন না এবং এটি ঠিকাদারের অনুমোদনের জন্য চলে যাবে। আপনি কি নিশ্চিত?',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('না')),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            child: const Text('হ্যাঁ, জমা দিন', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await ref.read(attendanceActionProvider.notifier).submitDailyEntry(widget.entryId, projectId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('এন্ট্রি সফলভাবে জমা দেওয়া হয়েছে!'), backgroundColor: AppColors.success),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('ত্রুটি: $e'), backgroundColor: AppColors.danger),
          );
        }
      }
    }
  }

  void _handleApproveEntry(String projectId) async {
    try {
      await ref.read(attendanceActionProvider.notifier).approveDailyEntry(widget.entryId, projectId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('এন্ট্রি অনুমোদিত ও লক করা হয়েছে!'), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ত্রুটি: $e'), backgroundColor: AppColors.danger),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final entryAsync = ref.watch(dailyEntryDetailsProvider(widget.entryId));
    final attendanceAsync = ref.watch(entryAttendanceListProvider(widget.entryId));
    final user = ref.watch(authStateProvider).user;
    final isContractor = user?.isContractor ?? false;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('দৈনিক কাজের এন্ট্রি'),
      ),
      body: entryAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => EmptyStateView(
          icon: Icons.error_outline_rounded,
          title: 'এন্ট্রি লোড ত্রুটি',
          subtitle: err.toString(),
          buttonLabel: AppStrings.retry,
          isError: true,
          onButtonPressed: () => ref.invalidate(dailyEntryDetailsProvider(widget.entryId)),
        ),
        data: (entry) {
          final isEditable = entry.isOpen;

          return Column(
            children: [
              // হেডার তথ্য কার্ড
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSizes.paddingMedium),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightCard,
                  border: Border(bottom: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          BengaliFormatter.toFullDate(entry.entryDate),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        StatusChip.forStatus(entry.statusBengaliLabel),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'প্রজেক্ট: ${entry.projectName ?? 'লোড হচ্ছে...'}',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                    if (entry.isBackdated) ...[
                      const SizedBox(height: 4),
                      Text(
                        'ব্যাকডেটেড কারণ: ${entry.backdateReason ?? 'নাই'}',
                        style: const TextStyle(fontSize: 11, color: AppColors.warning, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ],
                ),
              ),

              // হাজিরা তালিকা
              Expanded(
                child: attendanceAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: LoadingSkeletonList(count: 4, itemHeight: 80),
                  ),
                  error: (err, _) => Center(child: Text('হাজিরা তালিকা লোড ত্রুটি: $err')),
                  data: (records) {
                    if (records.isEmpty) {
                      return EmptyStateView(
                        icon: Icons.people_outline_rounded,
                        title: 'দলে কোনো কর্মী অন্তর্ভুক্ত নেই',
                        subtitle: 'নিচের বোতাম ব্যবহার করে কর্মীদের হাজিরা নেওয়া শুরু করুন।',
                        buttonLabel: isEditable ? 'নিজের হাজিরা নিশ্চিত করুন' : null,
                        onButtonPressed: isEditable ? () => _handleSupervisorSelfAttendance(entry.projectId) : null,
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(AppSizes.paddingMedium),
                      itemCount: records.length,
                      itemBuilder: (context, index) {
                        final record = records[index];
                        return AttendanceItemTile(
                          record: record,
                          isEditable: isEditable,
                          onStatusChanged: (newStatus, otHours) => _updateWorkerStatus(record.workerId, newStatus, otHours),
                        );
                      },
                    );
                  },
                ),
              ),

              // নিচের অ্যাকশন বার
              Container(
                padding: const EdgeInsets.all(AppSizes.paddingMedium),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightCard,
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, -2))],
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      if (isEditable && !isContractor) ...[
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _isMarkingSelf ? null : () => _handleSupervisorSelfAttendance(entry.projectId),
                            icon: const Icon(Icons.my_location_rounded, size: 18),
                            label: const Text('নিজের হাজিরা'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.supervisorPrimary,
                              side: const BorderSide(color: AppColors.supervisorPrimary),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _handleSubmitEntry(entry.projectId),
                            icon: const Icon(Icons.send_rounded, size: 18),
                            label: const Text('জমা দিন'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.success,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ] else if (isContractor && entry.isSubmitted) ...[
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _handleApproveEntry(entry.projectId),
                            icon: const Icon(Icons.verified_rounded, size: 18),
                            label: const Text('অনুমোদন ও লক করুন'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.contractorPrimary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ] else ...[
                        Expanded(
                          child: Text(
                            entry.isLocked
                                ? 'এই এন্ট্রি অনুমোদিত ও লক করা আছে। পরিবর্তন সম্ভব নয়।'
                                : 'এন্ট্রি জমা দেওয়া হয়েছে। ঠিকাদারের অনুমোদনের অপেক্ষায় রয়েছে।',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
