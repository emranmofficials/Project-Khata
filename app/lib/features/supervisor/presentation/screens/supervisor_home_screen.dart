import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/bengali_formatter.dart';
import '../../../../core/widgets/loading_skeleton.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../../core/widgets/summary_card.dart';
import '../../../attendance/presentation/providers/attendance_provider.dart';
import '../../../attendance/presentation/screens/daily_entry_details_screen.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../notifications/presentation/screens/notifications_inbox_screen.dart';
import '../../../project/domain/models/project_model.dart';
import '../../../project/presentation/providers/project_provider.dart';

/// PRD সেকশন ৭ অনুযায়ী সুপারভাইজার ইন্টারফেস
class SupervisorHomeScreen extends ConsumerWidget {
  const SupervisorHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).user;
    final projectsAsync = ref.watch(projectsListProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('সুপারভাইজার ড্যাশবোর্ড'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NotificationsInboxScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => ref.read(authStateProvider.notifier).signOut(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(projectsListProvider);
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SummaryCard(
                role: 'supervisor',
                orgName: user?.name ?? 'সুপারভাইজার',
                title: 'অ্যাসাইন করা প্রজেক্ট',
                kpiValue: BengaliFormatter.toBengaliNumber(
                  (projectsAsync.valueOrNull?.length ?? 0).toString(),
                ),
                subText: 'সাইটে দল গঠন ও উপস্থিতি পরিচালনা করুন',
              ),
              const SizedBox(height: 24),
              const Text(
                'আপনার দায়িত্বপ্রাপ্ত প্রজেক্ট',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),

              projectsAsync.when(
                loading: () => const LoadingSkeletonCard(height: 140),
                error: (err, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('প্রজেক্ট তথ্য লোড করা যায়নি: $err'),
                  ),
                ),
                data: (projects) {
                  if (projects.isEmpty) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSizes.paddingLarge),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCard : AppColors.lightCard,
                        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                        border: Border.all(
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        ),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.assignment_ind_outlined, size: 48, color: Colors.grey),
                          SizedBox(height: 12),
                          Text(
                            'কোনো প্রজেক্টে অ্যাসাইনমেন্ট নেই',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'প্রধান ঠিকাদার আপনাকে কোনো প্রজেক্টে যুক্ত করলে তা এখানে দেখা যাবে।',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: projects.map((project) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _SupervisorProjectCard(
                          project: project,
                          isDark: isDark,
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SupervisorProjectCard extends ConsumerStatefulWidget {
  final ProjectModel project;
  final bool isDark;

  const _SupervisorProjectCard({
    required this.project,
    required this.isDark,
  });

  @override
  ConsumerState<_SupervisorProjectCard> createState() =>
      _SupervisorProjectCardState();
}

class _SupervisorProjectCardState extends ConsumerState<_SupervisorProjectCard> {
  bool _isOpening = false;

  @override
  Widget build(BuildContext context) {
    final entriesAsync =
        ref.watch(projectDailyEntriesProvider(widget.project.id));

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: widget.isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(
          color: widget.isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.project.name,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              StatusChip.forStatus(widget.project.status),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'ঠিকানা: ${widget.project.address}',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 16),

          entriesAsync.when(
            loading: () => const LinearProgressIndicator(),
            error: (_, __) => const SizedBox.shrink(),
            data: (entries) {
              final openEntry = entries.where((e) => e.status == 'open').firstOrNull;
              if (openEntry != null) {
                return ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            DailyEntryDetailsScreen(entryId: openEntry.id),
                      ),
                    );
                  },
                  icon: const Icon(Icons.group_rounded, size: 18),
                  label: const Text('চলমান শিফট ও হাজিরা পরিচালনা'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.supervisorPrimary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(44),
                  ),
                );
              }

              return ElevatedButton.icon(
                onPressed: _isOpening ? null : () => _openNewShift(context),
                icon: _isOpening
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.add_task_rounded, size: 18),
                label: const Text('আজকের নতুন শিফট / এন্ট্রি খুলুন'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.supervisorPrimary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(44),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _openNewShift(BuildContext context) async {
    setState(() => _isOpening = true);
    try {
      final res = await ref.read(attendanceActionProvider.notifier).openDailyEntry(
        projectId: widget.project.id,
        entryDate: DateTime.now(),
      );

      final entryId = res['entry_id'] as String?;
      if (entryId != null && mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => DailyEntryDetailsScreen(entryId: entryId),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('এন্ট্রি খুলতে সমস্যা: ${e.toString().replaceAll("Exception: ", "")}'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isOpening = false);
    }
  }
}
