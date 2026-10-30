import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/contractor_strings.dart';
import '../../../../core/utils/bengali_formatter.dart';
import '../../../../widgets/contractor_widgets.dart';
import '../../contractor_providers.dart';

class SiteExpensesScreen extends ConsumerStatefulWidget {
  const SiteExpensesScreen({super.key});

  @override
  ConsumerState<SiteExpensesScreen> createState() => _SiteExpensesScreenState();
}

class _SiteExpensesScreenState extends ConsumerState<SiteExpensesScreen> {
  String? _selectedProjectId;

  @override
  Widget build(BuildContext context) {
    final expensesAsync = ref.watch(siteExpensesProvider(_selectedProjectId));

    return Scaffold(
      appBar: AppBar(
        title: const Text(ContractorStrings.siteExpensesTitle),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(siteExpensesProvider(_selectedProjectId)),
        child: expensesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text(ContractorStrings.errorOccurred)),
          data: (expenses) {
            if (expenses.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 80),
                  EmptyState(
                    icon: Icons.receipt_long_outlined,
                    title: ContractorStrings.emptyList,
                    subtitle: 'কোনো সাইট খরচ এন্ট্রি নেই',
                  ),
                ],
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: expenses.length,
              itemBuilder: (context, idx) {
                final exp = expenses[idx];
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
                            Text(
                              exp.category,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(
                              BengaliFormatter.toCurrency(exp.amount),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${exp.projectName} • সুপারভাইজার: ${exp.supervisorName}',
                          style: const TextStyle(fontSize: 13),
                        ),
                        if (exp.note != null) ...[
                          const SizedBox(height: 2),
                          Text('বিবরণ: ${exp.note}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                        ],
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (exp.isApproved)
                              const StatusChip(label: 'অনুমোদিত', color: Colors.green)
                            else ...[
                              OutlinedButton(
                                style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
                                onPressed: () async {
                                  final repo = ref.read(contractorRepositoryProvider);
                                  await repo.reviewSiteExpense(exp.id, false);
                                  ref.invalidate(siteExpensesProvider(_selectedProjectId));
                                },
                                child: const Text(ContractorStrings.rejectSiteExpense),
                              ),
                              const SizedBox(width: 8),
                              FilledButton(
                                onPressed: () async {
                                  final repo = ref.read(contractorRepositoryProvider);
                                  await repo.reviewSiteExpense(exp.id, true);
                                  ref.invalidate(siteExpensesProvider(_selectedProjectId));
                                },
                                child: const Text(ContractorStrings.approveSiteExpense),
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
      ),
    );
  }
}
