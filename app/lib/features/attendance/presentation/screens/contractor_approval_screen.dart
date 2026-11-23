import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/bengali_formatter.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../../core/widgets/loading_skeleton.dart';
import '../providers/attendance_provider.dart';

/// PRD সেকশন ৬.৬ (২) অনুযায়ী ঠিকাদারের এন্ট্রি ও হাজিরা অনুমোদন স্ক্রিন (৩টি ট্যাব)
class ContractorApprovalScreen extends ConsumerStatefulWidget {
  const ContractorApprovalScreen({super.key});

  @override
  ConsumerState<ContractorApprovalScreen> createState() => _ContractorApprovalScreenState();
}

class _ContractorApprovalScreenState extends ConsumerState<ContractorApprovalScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleApproval(String attendanceId, bool approve) async {
    try {
      await ref.read(attendanceActionProvider.notifier).decideApproval(
        attendanceId: attendanceId,
        approved: approve,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(approve ? 'হাজিরা অনুমোদিত হয়েছে' : 'হাজিরা প্রত্যাখ্যাত হয়েছে'),
            backgroundColor: approve ? AppColors.success : AppColors.danger,
          ),
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

  void _handleHandoverResolve(String entryId, String action) async {
    try {
      await ref.read(attendanceActionProvider.notifier).resolveHandover(
        entryId: entryId,
        action: action,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(action == 'close' ? 'এন্ট্রি বন্ধ করা হয়েছে' : 'এন্ট্রি হস্তান্তর হয়েছে'),
            backgroundColor: AppColors.success,
          ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('অনুমোদন ও নিষ্পত্তি'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: isDark ? AppColors.contractorPrimaryDark : AppColors.contractorPrimary,
          indicatorColor: AppColors.contractorPrimary,
          tabs: const [
            Tab(text: 'সাইটের বাইরে'),
            Tab(text: 'ব্যাকডেটেড'),
            Tab(text: 'হস্তান্তর প্রয়োজন'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOutsideSiteTab(),
          _buildBackdatedTab(),
          _buildHandoverTab(),
        ],
      ),
    );
  }

  // ১. সাইটের বাইরে হাজিরার ট্যাব
  Widget _buildOutsideSiteTab() {
    final pendingAsync = ref.watch(pendingAttendanceApprovalsProvider);

    return pendingAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(AppSizes.paddingMedium),
        child: LoadingSkeletonList(count: 4, itemHeight: 100),
      ),
      error: (err, _) => Center(child: Text('লোড ত্রুটি: $err')),
      data: (list) {
        final outsideList = list.where((a) => a.isOutsideSite).toList();
        if (outsideList.isEmpty) {
          return const EmptyStateView(
            icon: Icons.check_circle_outline_rounded,
            title: 'কোনো অপেক্ষমাণ হাজিরা নেই',
            subtitle: 'সাইটের বাইরে উপস্থিতি সংক্রান্ত সব হাজিরা নিষ্পত্তি করা হয়েছে।',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(AppSizes.paddingMedium),
          itemCount: outsideList.length,
          itemBuilder: (context, index) {
            final item = outsideList[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.cardRadius)),
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(item.workerName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text(
                          'দূরত্ব: ${BengaliFormatter.toBengaliNumber((item.distanceM ?? 0).toInt())} মিটার',
                          style: const TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('${item.designationName} • মোবাইল: ${item.workerMobile}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: () => _handleApproval(item.id, false),
                          style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger),
                          child: const Text('প্রত্যাখ্যান'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => _handleApproval(item.id, true),
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                          child: const Text('অনুমোদন করুন', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ২. ব্যাকডেটেড এন্ট্রি ট্যাব
  Widget _buildBackdatedTab() {
    return const Center(
      child: EmptyStateView(
        icon: Icons.history_rounded,
        title: 'কোনো ব্যাকডেটেড আবেদন নেই',
        subtitle: 'গত ৭ দিনের কোনো অপেক্ষমাণ ব্যাকডেটেড এন্ট্রি পাওয়া যায়নি।',
      ),
    );
  }

  // ৩. হস্তান্তর প্রয়োজন ট্যাব
  Widget _buildHandoverTab() {
    final handoverAsync = ref.watch(handoverEntriesProvider);

    return handoverAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(AppSizes.paddingMedium),
        child: LoadingSkeletonList(count: 3, itemHeight: 110),
      ),
      error: (err, _) => Center(child: Text('লোড ত্রুটি: $err')),
      data: (entries) {
        if (entries.isEmpty) {
          return const EmptyStateView(
            icon: Icons.task_alt_rounded,
            title: 'হস্তান্তর প্রয়োজন এমন কোনো এন্ট্রি নেই',
            subtitle: 'সব এন্ট্রি দায়িত্বপ্রাপ্তদের কাছে সঠিকভাবে চলমান রয়েছে।',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(AppSizes.paddingMedium),
          itemCount: entries.length,
          itemBuilder: (context, index) {
            final entry = entries[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.cardRadius)),
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: AppColors.danger),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            entry.projectName ?? 'প্রজেক্ট',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'তারিখ: ${BengaliFormatter.toFullDate(entry.entryDate)}\nসুপারভাইজার অ্যাসাইনমেন্ট সরালে এই এন্ট্রি হস্তান্তরের জন্য রাখা হয়েছে।',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: () => _handleHandoverResolve(entry.id, 'close'),
                          child: const Text('এন্ট্রি বন্ধ করুন'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => _handleHandoverResolve(entry.id, 'reassign'),
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.contractorPrimary),
                          child: const Text('পুনরায় হস্তান্তর', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
