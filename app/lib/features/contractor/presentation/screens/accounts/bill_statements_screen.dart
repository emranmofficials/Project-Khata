import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/contractor_strings.dart';
import '../../../../core/utils/bengali_formatter.dart';
import '../../../../widgets/contractor_widgets.dart';
import '../../contractor_providers.dart';

class BillStatementsScreen extends ConsumerStatefulWidget {
  const BillStatementsScreen({super.key});

  @override
  ConsumerState<BillStatementsScreen> createState() => _BillStatementsScreenState();
}

class _BillStatementsScreenState extends ConsumerState<BillStatementsScreen> {
  String? _selectedProjectId;
  String _selectedPreset = 'monthly';
  DateTime _fromDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _toDate = DateTime.now();

  void _generateStatement() async {
    if (_selectedProjectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('অনুগ্রহ করে প্রজেক্ট নির্বাচন করুন')),
      );
      return;
    }

    final repo = ref.read(contractorRepositoryProvider);
    await repo.generateBillStatement(
      projectId: _selectedProjectId!,
      periodFrom: _fromDate,
      periodTo: _toDate,
      preset: _selectedPreset,
    );

    ref.invalidate(billStatementsProvider(_selectedProjectId));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('${ContractorStrings.snapshotLockNotice}\n${ContractorStrings.exportPdfExcelPlaceholder}'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final statementsAsync = ref.watch(billStatementsProvider(_selectedProjectId));
    final projectsAsync = ref.watch(projectsProvider(null));

    return Scaffold(
      appBar: AppBar(
        title: const Text(ContractorStrings.billStatementsTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // প্রজেক্ট ও সময়কাল নির্ধারণ কার্ড
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'নতুন বিল খতিয়ান তৈরি',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    projectsAsync.when(
                      loading: () => const LinearProgressIndicator(),
                      error: (_, __) => const Text('প্রজেক্ট লোড করা যায়নি'),
                      data: (projects) {
                        return DropdownButtonFormField<String>(
                          value: _selectedProjectId,
                          hint: const Text('প্রজেক্ট নির্বাচন করুন'),
                          items: projects.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name))).toList(),
                          onChanged: (val) => setState(() => _selectedProjectId = val),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: 'weekly', label: Text(ContractorStrings.periodWeekly)),
                        ButtonSegment(value: 'monthly', label: Text(ContractorStrings.periodMonthly)),
                        ButtonSegment(value: 'custom', label: Text(ContractorStrings.periodCustom)),
                      ],
                      selected: {_selectedPreset},
                      onSelectionChanged: (set) => setState(() => _selectedPreset = set.first),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: _generateStatement,
                      icon: const Icon(Icons.send_rounded),
                      label: const Text(ContractorStrings.generateAndSendBill),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'সংরক্ষিত ও পাঠানো বিল খতিয়ান সমূহ',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),

            statementsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text(ContractorStrings.errorOccurred)),
              data: (statements) {
                if (statements.isEmpty) {
                  return const EmptyState(
                    icon: Icons.document_scanner_outlined,
                    title: 'কোনো খতিয়ান পাওয়া যায়নি',
                    subtitle: 'উপরে প্রজেক্ট ও সময়কাল বেছে নতুন খতিয়ান তৈরি করুন',
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: statements.length,
                  itemBuilder: (context, idx) {
                    final b = statements[idx];
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
                                  b.projectName,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                if (b.isLocked)
                                  const StatusChip(label: 'স্ন্যাপশট লকড', color: AppColors.contractorNavy),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'সময়কাল: ${toBn(b.periodFrom.day)}/${toBn(b.periodFrom.month)} হতে ${toBn(b.periodTo.day)}/${toBn(b.periodTo.month)} • মোট হাজিরা: ${toBn(b.totalAttendanceDays)} দিন',
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  BengaliFormatter.toCurrency(b.totalAmount),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                OutlinedButton.icon(
                                  icon: const Icon(Icons.picture_as_pdf_rounded, size: 16),
                                  label: const Text('এক্সপোর্ট (প্লেসহোল্ডার)'),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text(ContractorStrings.exportPdfExcelPlaceholder)),
                                    );
                                  },
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
            ),
          ],
        ),
      ),
    );
  }
}
