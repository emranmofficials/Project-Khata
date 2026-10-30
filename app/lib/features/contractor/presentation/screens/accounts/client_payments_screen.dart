import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_khata/core/constants/contractor_strings.dart';
import 'package:project_khata/core/utils/bengali_formatter.dart';
import 'package:project_khata/widgets/contractor_widgets.dart';
import '../../contractor_providers.dart';

class ClientPaymentsScreen extends ConsumerStatefulWidget {
  const ClientPaymentsScreen({super.key});

  @override
  ConsumerState<ClientPaymentsScreen> createState() => _ClientPaymentsScreenState();
}

class _ClientPaymentsScreenState extends ConsumerState<ClientPaymentsScreen> {
  String? _selectedProjectId;

  void _showAddPaymentDialog(BuildContext context) {
    String? projectId;
    final amountController = TextEditingController();
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final projectsAsync = ref.watch(projectsProvider(null));

          return AlertDialog(
            title: const Text(ContractorStrings.clientPaymentRecord),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('প্রজেক্ট নির্বাচন (বাধ্যতামূলক)', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  projectsAsync.when(
                    loading: () => const LinearProgressIndicator(),
                    error: (_, __) => const Text('লোড করা যায়নি'),
                    data: (projects) {
                      return DropdownButtonFormField<String>(
                        value: projectId,
                        hint: const Text('প্রজেক্ট নির্বাচন করুন'),
                        items: projects.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name))).toList(),
                        onChanged: (val) => setDialogState(() => projectId = val),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  const Text('প্রাপ্ত টাকার পরিমাণ', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(prefixText: '৳ '),
                  ),
                  const SizedBox(height: 12),
                  const Text('মন্তব্য / মাধ্যম / চেক নং', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  TextField(controller: noteController),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('বাতিল')),
              FilledButton(
                onPressed: () async {
                  if (projectId == null || amountController.text.trim().isEmpty) return;
                  Navigator.pop(ctx);

                  final repo = ref.read(contractorRepositoryProvider);
                  await repo.recordClientPayment(
                    projectId: projectId!,
                    amount: double.tryParse(amountController.text.trim()) ?? 0,
                    note: noteController.text.trim(),
                  );

                  ref.invalidate(clientPaymentsProvider(null));
                  ref.invalidate(accountsSummaryProvider);
                },
                child: const Text('সংরক্ষণ করুন'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final paymentsAsync = ref.watch(clientPaymentsProvider(_selectedProjectId));
    final projectsAsync = ref.watch(projectsProvider(null));

    return Scaffold(
      appBar: AppBar(
        title: const Text(ContractorStrings.clientPaymentsTitle),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddPaymentDialog(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('পেমেন্ট এন্ট্রি'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: projectsAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const SizedBox.shrink(),
              data: (projects) {
                return DropdownButtonFormField<String?>(
                  value: _selectedProjectId,
                  decoration: const InputDecoration(labelText: 'প্রজেক্ট অনুযায়ী ফিল্টার'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('সব প্রজেক্ট')),
                    ...projects.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name))),
                  ],
                  onChanged: (val) => setState(() => _selectedProjectId = val),
                );
              },
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => ref.invalidate(clientPaymentsProvider(_selectedProjectId)),
              child: paymentsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text(ContractorStrings.errorOccurred)),
                data: (payments) {
                  if (payments.isEmpty) {
                    return ListView(
                      children: const [
                        SizedBox(height: 80),
                        EmptyState(
                          icon: Icons.attach_money_rounded,
                          title: ContractorStrings.emptyList,
                          subtitle: 'কোনো ক্লায়েন্ট পেমেন্ট পাওয়া যায়নি',
                        ),
                      ],
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: payments.length,
                    itemBuilder: (context, idx) {
                      final p = payments[idx];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          title: Text(p.projectName, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(
                            'তারিখ: ${toBn(p.paymentDate.day)}/${toBn(p.paymentDate.month)}/${toBn(p.paymentDate.year)}${p.note != null ? ' • ${p.note}' : ''}',
                          ),
                          trailing: Text(
                            BengaliFormatter.toCurrency(p.amount),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF2563EB)),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
