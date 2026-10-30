import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:project_khata/core/constants/app_colors.dart';
import 'package:project_khata/core/constants/contractor_routes.dart';
import 'package:project_khata/core/constants/contractor_strings.dart';
import 'package:project_khata/core/utils/bengali_formatter.dart';
import 'package:project_khata/widgets/contractor_widgets.dart';
import '../../contractor_providers.dart';

class ProjectEntriesScreen extends ConsumerStatefulWidget {
  final String projectId;

  const ProjectEntriesScreen({
    super.key,
    required this.projectId,
  });

  @override
  ConsumerState<ProjectEntriesScreen> createState() => _ProjectEntriesScreenState();
}

class _ProjectEntriesScreenState extends ConsumerState<ProjectEntriesScreen> {
  String _selectedFilter = 'সব';

  @override
  Widget build(BuildContext context) {
    final projectAsync = ref.watch(projectDetailsProvider(widget.projectId));
    final entriesAsync = ref.watch(projectEntriesProvider(widget.projectId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: projectAsync.when(
          data: (p) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                ContractorStrings.projectEntriesTitle,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                p.name,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
          loading: () => const Text(ContractorStrings.projectEntriesTitle),
          error: (_, __) => const Text(ContractorStrings.projectEntriesTitle),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(projectDetailsProvider(widget.projectId));
          ref.invalidate(projectEntriesProvider(widget.projectId));
        },
        child: Column(
          children: [
            // ফিল্টার চিপস
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  for (final filter in ['সব', 'অপেক্ষমাণ', 'অনুমোদিত'])
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        label: Text(filter),
                        selected: _selectedFilter == filter,
                        onSelected: (selected) {
                          if (selected) setState(() => _selectedFilter = filter);
                        },
                      ),
                    ),
                ],
              ),
            ),

            Expanded(
              child: entriesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(ContractorStrings.errorOccurred),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () => ref.invalidate(projectEntriesProvider(widget.projectId)),
                        child: const Text(ContractorStrings.retry),
                      ),
                    ],
                  ),
                ),
                data: (allEntries) {
                  final entries = allEntries.where((e) {
                    if (_selectedFilter == 'অপেক্ষমাণ') {
                      return e.status.contains('অপেক্ষমাণ') || e.status.contains('পেন্ডিং');
                    }
                    if (_selectedFilter == 'অনুমোদিত') {
                      return e.status.contains('অনুমোদিত');
                    }
                    return true;
                  }).toList();

                  if (entries.isEmpty) {
                    return ListView(
                      children: const [
                        SizedBox(height: 80),
                        EmptyState(
                          icon: Icons.assignment_outlined,
                          title: 'কোনো এন্ট্রি পাওয়া যায়নি',
                          subtitle: 'এই প্রজেক্টের জন্য কোনো দৈনিক হাজিরার এন্ট্রি নেই।',
                        ),
                      ],
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: entries.length,
                    itemBuilder: (context, index) {
                      final e = entries[index];
                      final isPending = e.status.contains('অপেক্ষমাণ') || e.status.contains('পেন্ডিং');

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: (isDark
                                              ? const Color(0xFF93A8F4)
                                              : AppColors.contractorNavy)
                                          .withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.calendar_today_rounded,
                                      size: 20,
                                      color: isDark
                                          ? const Color(0xFF93A8F4)
                                          : AppColors.contractorNavy,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          BengaliFormatter.formatDate(e.entryDate),
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'সুপারভাইজার: ${e.supervisorName}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isDark
                                              ? AppColors.darkTextSecondary
                                              : AppColors.lightTextSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  StatusChip(
                                    label: e.status,
                                    color: isPending
                                        ? const Color(0xFFD97706)
                                        : const Color(0xFF0F766E),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              const Divider(height: 1),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Icon(
                                    Icons.people_outline_rounded,
                                    size: 16,
                                    color: isDark ? Colors.white70 : Colors.black87,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${toBn(e.workerCount)} জন শ্রমিক',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const Spacer(),
                                  if (e.isBackdated)
                                    Padding(
                                      padding: const EdgeInsets.only(right: 6.0),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFEF3C7),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Text(
                                          'ব্যাকডেটেড',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Color(0xFF92400E),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  if (e.isOutsideSite)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFEE2E2),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        'সাইটের বাইরে',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Color(0xFF991B1B),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              if (isPending) ...[
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    onPressed: () => context.push(ContractorRoutes.approvals),
                                    icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                                    label: const Text('অনুমোদন রিভিউ করুন'),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
