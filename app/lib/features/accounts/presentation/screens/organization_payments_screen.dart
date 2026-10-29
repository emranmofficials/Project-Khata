import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/bengali_formatter.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../auth/domain/models/app_user.dart';
import '../../data/accounts_repository.dart';
import '../../domain/models/payment.dart';

final organizationPaymentsProvider =
    FutureProvider.family<List<Payment>, String>((ref, orgId) async {
  final repo = ref.watch(accountsRepositoryProvider);
  return repo.getOrganizationPayments(orgId);
});

class OrganizationPaymentsScreen extends ConsumerStatefulWidget {
  const OrganizationPaymentsScreen({super.key});

  @override
  ConsumerState<OrganizationPaymentsScreen> createState() =>
      _OrganizationPaymentsScreenState();
}

class _OrganizationPaymentsScreenState
    extends ConsumerState<OrganizationPaymentsScreen> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider).value;
    final orgId = user?.organizationId;

    if (orgId == null) {
      return const Scaffold(
        body: Center(child: Text('প্রতিষ্ঠান তথ্য পাওয়া যায়নি')),
      );
    }

    final paymentsAsync = ref.watch(organizationPaymentsProvider(orgId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('শ্রমিক মজুরি ও পেমেন্ট খাতা'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showRecordPaymentDialog(context, orgId),
        icon: const Icon(Icons.payment),
        label: const Text('মজুরি পরিশোধ করুন'),
        backgroundColor: AppColors.primary,
      ),
      body: paymentsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('ত্রুটি: $err')),
        data: (payments) {
          if (payments.isEmpty) {
            return const Center(
              child: Text(
                'কোনো মজুরি পেমেন্ট রেকর্ড নেই',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          final totalPaid =
              payments.fold<double>(0.0, (sum, p) => sum + p.amount);

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.indigo.shade50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'মোট পরিশোধিত মজুরি:',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      BengaliFormatter.toCurrency(totalPaid),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: payments.length,
                  itemBuilder: (ctx, index) {
                    final item = payments[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ExpansionTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.indigo.shade100,
                          child: const Icon(Icons.check,
                              color: Colors.indigo, size: 20),
                        ),
                        title: Text(
                          item.payeeName ?? 'কর্মী',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Text(
                          '${BengaliFormatter.toBnDate(item.paymentDate)} • মাধ্যম: ${item.paymentMethod}',
                        ),
                        trailing: Text(
                          BengaliFormatter.toCurrency(item.amount),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.indigo,
                          ),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (item.note != null &&
                                    item.note!.isNotEmpty) ...[
                                  Text('নোট: ${item.note}'),
                                  const SizedBox(height: 6),
                                ],
                                const Text(
                                  'প্রজেক্টে বরাদ্দ বিবরণ (FIFO):',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                if (item.allocations.isEmpty)
                                  const Text(
                                    'কোনো প্রজেক্ট বরাদ্দ নেই',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                  )
                                else
                                  ...item.allocations.map(
                                    (a) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 2),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            a.projectName ?? 'প্রজেক্ট',
                                            style: const TextStyle(
                                                fontSize: 13),
                                          ),
                                          Text(
                                            BengaliFormatter.toCurrency(
                                                a.allocatedAmount),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showRecordPaymentDialog(BuildContext context, String orgId) async {
    final repo = ref.read(accountsRepositoryProvider);
    final user = ref.read(currentUserProvider).value;
    final workers = await repo.getOrganizationWorkers(orgId);

    if (!context.mounted) return;

    if (workers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('প্রতিষ্ঠানে কোনো শ্রমিক বা সুপারভাইজার নেই')),
      );
      return;
    }

    UserProfile selectedWorker = workers.first;
    String method = 'cash';
    final amountCtrl = TextEditingController();
    final noteCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('কর্মী মজুরি পরিশোধ'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<UserProfile>(
                  value: selectedWorker,
                  decoration: const InputDecoration(labelText: 'কর্মী নির্বাচন'),
                  items: workers
                      .map((w) => DropdownMenuItem(
                            value: w,
                            child: Text('${w.name} (${w.role == UserRole.supervisor ? "সুপারভাইজার" : "শ্রমিক"})'),
                          ))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setDialogState(() => selectedWorker = v);
                  },
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: amountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'টাকার পরিমাণ (৳)'),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: method,
                  decoration: const InputDecoration(labelText: 'পেমেন্ট মাধ্যম'),
                  items: const [
                    DropdownMenuItem(value: 'cash', child: Text('ক্যাশ')),
                    DropdownMenuItem(value: 'bkash', child: Text('বিকাশ')),
                    DropdownMenuItem(value: 'nagad', child: Text('নগদ')),
                    DropdownMenuItem(value: 'bank', child: Text('ব্যাংক')),
                  ],
                  onChanged: (v) => setDialogState(() => method = v ?? 'cash'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: noteCtrl,
                  decoration: const InputDecoration(labelText: 'নোট (ঐচ্ছিক)'),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '💡 স্বয়ংক্রিয়ভাবে পুরোনো বকেয়া মজুরি অনুযায়ী FIFO পদ্ধতিতে প্রজেক্টে বরাদ্দ হবে।',
                    style: TextStyle(fontSize: 12, color: Colors.blueGrey),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('বাতিল'),
            ),
            ElevatedButton(
              onPressed: () async {
                final amount = double.tryParse(amountCtrl.text.trim()) ?? 0.0;
                if (amount <= 0 || user == null) return;

                final payment = Payment(
                  id: '',
                  organizationId: orgId,
                  payeeType: selectedWorker.role == UserRole.supervisor ? 'supervisor' : 'worker',
                  payeeId: selectedWorker.id,
                  amount: amount,
                  paymentDate: DateTime.now(),
                  paymentMethod: method,
                  note: noteCtrl.text.trim().isEmpty ? null : noteCtrl.text.trim(),
                  createdBy: user.id,
                  createdAt: DateTime.now(),
                );

                Navigator.pop(ctx);
                final repo = ref.read(accountsRepositoryProvider);
                await repo.recordPayment(payment, autoFifo: true);
                ref.invalidate(organizationPaymentsProvider(orgId));

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('মজুরি পরিশোধ ও FIFO বরাদ্দ সম্পন্ন হয়েছে!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: const Text('পরিশোধ নিশ্চিত করুন'),
            ),
          ],
        ),
      ),
    );
  }
}
