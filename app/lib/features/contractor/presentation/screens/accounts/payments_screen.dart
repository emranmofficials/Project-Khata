import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/contractor_strings.dart';
import '../../../../core/utils/bengali_formatter.dart';
import '../../../../widgets/contractor_widgets.dart';
import '../../contractor_providers.dart';
import '../../../domain/models/contractor_models.dart';

class PaymentsScreen extends ConsumerStatefulWidget {
  const PaymentsScreen({super.key});

  @override
  ConsumerState<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends ConsumerState<PaymentsScreen> {
  void _showMakePaymentDialog(BuildContext context) {
    String? selectedPayeeId;
    final amountController = TextEditingController();
    final noteController = TextEditingController();
    String? specificProjectId;
    bool isManualAllocation = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final workersAsync = ref.watch(membersProvider(MemberRole.worker));
          final projectsAsync = ref.watch(projectsProvider(null));

          return AlertDialog(
            title: const Text('পেমেন্ট প্রদান ও বরাদ্দ'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('প্রাপক নির্বাচন (শ্রমিক / সুপারভাইজার)', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  workersAsync.when(
                    loading: () => const LinearProgressIndicator(),
                    error: (_, __) => const Text('লোড করা যায়নি'),
                    data: (workers) {
                      return DropdownButtonFormField<String>(
                        value: selectedPayeeId,
                        hint: const Text('কর্মী নির্বাচন করুন'),
                        items: workers.map((w) {
                          return DropdownMenuItem(
                            value: w.id,
                            child: Text('${w.name} (${w.designationName})'),
                          );
                        }).toList(),
                        onChanged: (val) => setDialogState(() => selectedPayeeId = val),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  const Text('টাকার পরিমাণ', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(prefixText: '৳ '),
                  ),
                  const SizedBox(height: 12),
                  const Text('মন্তব্য (ঐচ্ছিক)', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  TextField(controller: noteController),
                  const SizedBox(height: 12),

                  // FIFO বনাম ম্যানুয়াল বরাদ্দ সুইচ
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('বরাদ্দ পরিবর্তন (নির্দিষ্ট প্রজেক্ট)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    subtitle: const Text(ContractorStrings.fifoDefaultNotice, style: TextStyle(fontSize: 11)),
                    value: isManualAllocation,
                    onChanged: (val) => setDialogState(() => isManualAllocation = val),
                  ),

                  if (isManualAllocation) ...[
                    const SizedBox(height: 8),
                    projectsAsync.when(
                      loading: () => const LinearProgressIndicator(),
                      error: (_, __) => const SizedBox.shrink(),
                      data: (projects) {
                        return DropdownButtonFormField<String>(
                          value: specificProjectId,
                          hint: const Text('নির্দিষ্ট প্রজেক্ট নির্বাচন করুন'),
                          items: projects.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name))).toList(),
                          onChanged: (val) => setDialogState(() => specificProjectId = val),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('বাতিল'),
              ),
              FilledButton(
                onPressed: () async {
                  if (selectedPayeeId == null || amountController.text.trim().isEmpty) return;
                  Navigator.pop(ctx);

                  final repo = ref.read(contractorRepositoryProvider);
                  await repo.allocatePayment(
                    payeeId: selectedPayeeId!,
                    amount: double.tryParse(amountController.text.trim()) ?? 0,
                    specificProjectId: isManualAllocation ? specificProjectId : null,
                    note: noteController.text.trim(),
                  );

                  ref.invalidate(paymentsProvider);
                  ref.invalidate(accountsSummaryProvider);
                },
                child: const Text('পেমেন্ট নিশ্চিত করুন'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final paymentsAsync = ref.watch(paymentsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(ContractorStrings.paymentsTitle),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showMakePaymentDialog(context),
        icon: const Icon(Icons.add_card_rounded),
        label: const Text(ContractorStrings.recordPayment),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(paymentsProvider),
        child: paymentsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text(ContractorStrings.errorOccurred)),
          data: (payments) {
            if (payments.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 80),
                  EmptyState(
                    icon: Icons.payments_rounded,
                    title: ContractorStrings.emptyList,
                    subtitle: 'কোনো পেমেন্ট রেকর্ড নেই',
                  ),
                ],
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: payments.length,
              itemBuilder: (context, idx) {
                final pay = payments[idx];
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
                              pay.payeeName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(
                              BengaliFormatter.toCurrency(pay.amount),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'তারিখ: ${toBn(pay.paymentDate.day)}/${toBn(pay.paymentDate.month)}/${toBn(pay.paymentDate.year)} • মাধ্যম: ${pay.method}',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                        ),
                        if (pay.note != null && pay.note!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text('মন্তব্য: ${pay.note}', style: const TextStyle(fontSize: 12)),
                        ],
                        const Divider(height: 20),
                        const Text(
                          'প্রজেক্ট বরাদ্দ অডিট:',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        ...pay.allocations.map((a) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 2),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${a.projectName} (${a.method.toUpperCase()})', style: const TextStyle(fontSize: 12)),
                                Text(BengaliFormatter.toCurrency(a.allocatedAmount), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          );
                        }),
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
