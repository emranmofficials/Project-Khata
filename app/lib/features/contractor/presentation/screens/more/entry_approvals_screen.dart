import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/contractor_strings.dart';
import '../../../../widgets/contractor_widgets.dart';
import '../../contractor_providers.dart';
import '../../../domain/models/contractor_models.dart';

class EntryApprovalsScreen extends ConsumerStatefulWidget {
  const EntryApprovalsScreen({super.key});

  @override
  ConsumerState<EntryApprovalsScreen> createState() => _EntryApprovalsScreenState();
}

class _EntryApprovalsScreenState extends ConsumerState<EntryApprovalsScreen>
    with SingleTickerProviderStateMixin {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(ContractorStrings.entryApprovals),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: ContractorStrings.outsideSiteApprovals),
            Tab(text: ContractorStrings.backdatedApprovals),
            Tab(text: ContractorStrings.handoverRequiredTab),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildApprovalsList(ApprovalType.outsideSite),
          _buildApprovalsList(ApprovalType.backdated),
          _buildApprovalsList(ApprovalType.handoverRequired),
        ],
      ),
    );
  }

  Widget _buildApprovalsList(ApprovalType type) {
    final approvalsAsync = ref.watch(approvalsProvider(type));

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(approvalsProvider(type)),
      child: approvalsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(ContractorStrings.errorOccurred)),
        data: (approvals) {
          if (approvals.isEmpty) {
            return ListView(
              children: [
                const SizedBox(height: 80),
                EmptyState(
                  icon: Icons.check_circle_outline_rounded,
                  title: 'কোনো অনুমোদনের অনুরোধ নেই',
                  subtitle: '${type.label} ক্যাটাগরিতে বর্তমানে কোনো পেন্ডিং এন্ট্রি নেই',
                ),
              ],
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: approvals.length,
            itemBuilder: (context, idx) {
              final a = approvals[idx];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              a.title,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                          StatusChip(label: type.label, color: AppColors.contractorNavy),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text('${a.projectName} • ${a.actorName}', style: const TextStyle(fontSize: 13)),
                      const SizedBox(height: 4),
                      Text(
                        'তারিখ: ${toBn(a.date.day)}/${toBn(a.date.month)}/${toBn(a.date.year)}',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                      ),
                      if (a.reason != null && a.reason!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'কারণ: ${a.reason!}',
                            style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (type == ApprovalType.handoverRequired) ...[
                            FilledButton(
                              onPressed: () async {
                                final repo = ref.read(contractorRepositoryProvider);
                                await repo.approveEntry(a.id);
                                ref.invalidate(approvalsProvider(null));
                                ref.invalidate(dashboardSummaryProvider);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('এন্ট্রি সফলভাবে বন্ধ ও নিষ্পত্তি করা হয়েছে')),
                                  );
                                }
                              },
                              child: const Text('বন্ধ ও নিষ্পত্তি করুন'),
                            ),
                          ] else ...[
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
                              onPressed: () async {
                                final repo = ref.read(contractorRepositoryProvider);
                                await repo.rejectEntry(a.id);
                                ref.invalidate(approvalsProvider(null));
                                ref.invalidate(dashboardSummaryProvider);
                              },
                              child: const Text(ContractorStrings.rejectAction),
                            ),
                            const SizedBox(width: 8),
                            FilledButton(
                              onPressed: () async {
                                final repo = ref.read(contractorRepositoryProvider);
                                await repo.approveEntry(a.id);
                                ref.invalidate(approvalsProvider(null));
                                ref.invalidate(dashboardSummaryProvider);
                              },
                              child: const Text(ContractorStrings.approveAction),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
