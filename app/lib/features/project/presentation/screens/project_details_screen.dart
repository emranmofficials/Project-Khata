import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/bengali_formatter.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../../core/widgets/loading_skeleton.dart';
import '../../../../core/widgets/status_chip.dart';
import '../providers/project_provider.dart';
import '../widgets/change_status_bottom_sheet.dart';
import '../widgets/supervisor_assign_bottom_sheet.dart';
import '../../../accounting/presentation/screens/bill_statements_screen.dart';
import '../../../accounting/presentation/screens/materials_screen.dart';

/// PRD সেকশন ৬.৩ (৩) অনুযায়ী প্রজেক্ট ডিটেইলস স্ক্রিন
class ProjectDetailsScreen extends ConsumerWidget {
  final String projectId;

  const ProjectDetailsScreen({
    super.key,
    required this.projectId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectAsync = ref.watch(projectDetailsProvider(projectId));
    final supervisorsAsync = ref.watch(projectSupervisorsProvider(projectId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('প্রজেক্ট বিস্তারিত'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            onSelected: (value) {
              if (value == 'status') {
                projectAsync.whenData((project) {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
                    builder: (_) => ChangeStatusBottomSheet(
                      projectId: project.id,
                      currentStatus: project.status,
                    ),
                  );
                });
              } else if (value == 'edit') {
                // প্রজেক্ট সম্পাদনা
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'status', child: Row(children: [Icon(Icons.tune_rounded, size: 20), SizedBox(width: 8), Text('স্ট্যাটাস পরিবর্তন')])),
              const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_outlined, size: 20), SizedBox(width: 8), Text('সম্পাদনা')])),
            ],
          ),
        ],
      ),
      body: projectAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(AppSizes.paddingMedium),
          child: LoadingSkeletonList(count: 6, itemHeight: 90),
        ),
        error: (err, _) => EmptyStateView(
          icon: Icons.error_outline_rounded,
          title: 'প্রজেক্ট লোড করতে সমস্যা হয়েছে',
          subtitle: err.toString(),
          buttonLabel: AppStrings.retry,
          isError: true,
          onButtonPressed: () => ref.invalidate(projectDetailsProvider(projectId)),
        ),
        data: (project) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // -----------------------------------------------------------
                // ১. হিরো কার্ড: নাম, স্ট্যাটাস, ধরন ও অগ্রগতি রিং
                // -----------------------------------------------------------
                Container(
                  padding: const EdgeInsets.all(AppSizes.paddingLarge),
                  decoration: BoxDecoration(
                    gradient: AppColors.getGradientForRole('contractor'),
                    borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            StatusChip.forStatus(project.status),
                            const SizedBox(height: 10),
                            Text(
                              project.name,
                              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              project.typeBengaliLabel,
                              style: const TextStyle(color: Colors.white70, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      // অগ্রগতি রিং
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 68,
                            height: 68,
                            child: CircularProgressIndicator(
                              value: (project.progressPercentage > 0 ? project.progressPercentage : 45) / 100,
                              strokeWidth: 6,
                              backgroundColor: Colors.white24,
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          Text(
                            '${BengaliFormatter.toBengaliNumber((project.progressPercentage > 0 ? project.progressPercentage : 45).toInt())}%',
                            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // -----------------------------------------------------------
                // ২. ক্লায়েন্ট কার্ড: নাম, মোবাইল ও যোগাযোগ বোতাম
                // -----------------------------------------------------------
                _buildCardContainer(
                  isDark: isDark,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.person_rounded, color: AppColors.clientPrimary, size: 20),
                          SizedBox(width: 8),
                          Text('ক্লায়েন্ট তথ্য', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        project.clientName ?? 'নির্ধারিত হয়নি',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'মোবাইল: ${project.clientMobile != null ? BengaliFormatter.toBengaliNumber(project.clientMobile) : 'নাই'}',
                        style: TextStyle(fontSize: 13, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.call_outlined, size: 16),
                            label: const Text('কল করুন'),
                            style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.message_outlined, size: 16),
                            label: const Text('মেসেজ পাঠান'),
                            style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // -----------------------------------------------------------
                // ৩. সাইট লোকেশন কার্ড ও জিও-ফেন্স
                // -----------------------------------------------------------
                _buildCardContainer(
                  isDark: isDark,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.location_on_rounded, color: AppColors.danger, size: 20),
                          SizedBox(width: 8),
                          Text('সাইট লোকেশন ও জিও-ফেন্স', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(project.address, style: const TextStyle(fontSize: 14)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.contractorPrimary.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'রেডিয়াস: ${BengaliFormatter.toBengaliNumber(project.geofenceRadiusM)} মিটার',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.contractorPrimary),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '(${BengaliFormatter.toBengaliNumber(project.lat.toStringAsFixed(4))}, ${BengaliFormatter.toBengaliNumber(project.lng.toStringAsFixed(4))})',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // -----------------------------------------------------------
                // ৪. বাজেট ও চুক্তি কার্ড
                // -----------------------------------------------------------
                _buildCardContainer(
                  isDark: isDark,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.account_balance_wallet_rounded, color: AppColors.success, size: 20),
                          SizedBox(width: 8),
                          Text('চুক্তি ও বাজেট', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('মোট বাজেট', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                const SizedBox(height: 2),
                                Text(
                                  BengaliFormatter.toCurrency(project.budget),
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('বর্তমান ব্যয়', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                const SizedBox(height: 2),
                                Text(
                                  BengaliFormatter.toCurrency(project.budget * 0.45),
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.warning),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // -----------------------------------------------------------
                // ৫. সুপারভাইজার বিভাগ
                // -----------------------------------------------------------
                _buildCardContainer(
                  isDark: isDark,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.supervisor_account_rounded, color: AppColors.supervisorPrimary, size: 20),
                              SizedBox(width: 8),
                              Text('দায়িত্বপ্রাপ্ত সুপারভাইজার', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          TextButton.icon(
                            onPressed: () {
                              supervisorsAsync.whenData((supervisors) {
                                final assignedIds = supervisors.map((s) => s.supervisorId).toList();
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
                                  builder: (_) => SupervisorAssignBottomSheet(
                                    projectId: project.id,
                                    currentAssignedIds: assignedIds,
                                  ),
                                );
                              });
                            },
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('অ্যাসাইন করুন'),
                          ),
                        ],
                      ),
                      supervisorsAsync.when(
                        loading: () => const LinearProgressIndicator(),
                        error: (err, _) => Text('লোড ত্রুটি: $err'),
                        data: (supervisors) {
                          if (supervisors.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                'বর্তমানে কোনো সুপারভাইজার অ্যাসাইন করা নেই।',
                                style: TextStyle(fontSize: 13, color: Colors.grey),
                              ),
                            );
                          }

                          return Column(
                            children: supervisors.map((s) {
                              return ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                leading: CircleAvatar(
                                  backgroundColor: AppColors.supervisorPrimary.withOpacity(0.1),
                                  child: const Icon(Icons.person, color: AppColors.supervisorPrimary, size: 18),
                                ),
                                title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                                subtitle: Text(s.mobile, style: const TextStyle(fontSize: 12)),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.success.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text('সক্রিয়', style: TextStyle(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.bold)),
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // -----------------------------------------------------------
                // ৬. প্রজেক্ট অ্যাকশন বাটনসমূহ (হিসাব ও খতিয়ান)
                // -----------------------------------------------------------
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => MaterialsScreen(
                                projectId: project.id,
                                projectName: project.name,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.calculate_outlined, size: 18),
                        label: const Text('মালামাল ও হিসাব'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.contractorPrimary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => BillStatementsScreen(
                                projectId: project.id,
                                projectName: project.name,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.receipt_long_outlined, size: 18),
                        label: const Text('শ্রমিক-বিল খতিয়ান'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.contractorPrimary,
                          side: const BorderSide(color: AppColors.contractorPrimary),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCardContainer({required Widget child, required bool isDark}) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: child,
    );
  }
}
