import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_khata/core/constants/app_colors.dart';
import 'package:project_khata/core/constants/contractor_strings.dart';
import 'package:project_khata/core/utils/bengali_formatter.dart';
import 'package:project_khata/widgets/contractor_widgets.dart';
import '../../contractor_providers.dart';
import '../../../domain/models/contractor_models.dart';

class PaymentAllocationScreen extends ConsumerStatefulWidget {
  const PaymentAllocationScreen({super.key});

  @override
  ConsumerState<PaymentAllocationScreen> createState() => _PaymentAllocationScreenState();
}

class _PaymentAllocationScreenState extends ConsumerState<PaymentAllocationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  String? _selectedMemberId;
  String? _selectedProjectId;
  String _allocationStrategy = 'fifo'; // 'fifo' or 'specific'
  String _paymentMethod = 'ক্যাশ';
  bool _isSaving = false;

  final List<String> _paymentMethods = ['ক্যাশ', 'বিকাশ', 'নগদ', 'ব্যাংক ট্রান্সফার'];

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedMemberId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('অনুগ্রহ করে প্রাপক কর্মী নির্বাচন করুন')),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('সঠিক টাকার পরিমাণ লিখুন')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final repo = ref.read(contractorRepositoryProvider);
      final note = '${_paymentMethod} মারফত পরিশোধ। ${_noteController.text.trim()}';

      await repo.allocatePayment(
        payeeId: _selectedMemberId!,
        amount: amount,
        specificProjectId: _allocationStrategy == 'specific' ? _selectedProjectId : null,
        note: note,
      );

      ref.invalidate(paymentsProvider);
      ref.invalidate(wagesProvider(null));
      ref.invalidate(accountsSummaryProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('পেমেন্ট সফলভাবে বরাদ্দ করা হয়েছে')),
        );
        _amountController.clear();
        _noteController.clear();
        setState(() {
          _selectedMemberId = null;
          _selectedProjectId = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ত্রুটি: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final workersAsync = ref.watch(membersProvider(MemberRole.worker));
    final projectsAsync = ref.watch(projectsProvider(ProjectStatus.active));
    final paymentsAsync = ref.watch(paymentsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          ContractorStrings.paymentAllocationTitle,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // তথ্য ব্যানার
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, size: 20, color: Color(0xFF2563EB)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'ডিফল্ট হিসেবে বকেয়া পুরনো তারিখ অনুযায়ী (FIFO) স্বয়ংক্রিয়ভাবে পরিশোধ সমন্বয় হবে।',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // প্রাপক কর্মী নির্বাচন
              const Text('প্রাপক নির্বাচন করুন', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              workersAsync.when(
                data: (workers) => DropdownButtonFormField<String>(
                  value: _selectedMemberId,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.person_outline_rounded),
                  ),
                  hint: const Text('কর্মী নির্বাচন করুন'),
                  items: workers.map((w) {
                    return DropdownMenuItem(
                      value: w.id,
                      child: Text('${w.name} (বকেয়া: ${BengaliFormatter.toCurrency(w.pendingWages)})'),
                    );
                  }).toList(),
                  onChanged: (id) => setState(() => _selectedMemberId = id),
                ),
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const Text('কর্মী লোড করা যায়নি'),
              ),

              const SizedBox(height: 18),

              // টাকার পরিমাণ
              const Text('টাকার পরিমাণ (৳)', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: '০.০০',
                  prefixIcon: Icon(Icons.attach_money_rounded),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'টাকার পরিমাণ লিখুন';
                  if (double.tryParse(v.trim()) == null) return 'সঠিক সংখ্যা লিখুন';
                  return null;
                },
              ),

              // দ্রুত পরিমাণ বাটন
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [500, 1000, 2000, 5000].map((quick) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ActionChip(
                        label: Text(BengaliFormatter.toCurrency(quick.toDouble())),
                        onPressed: () => _amountController.text = quick.toString(),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 18),

              // বরাদ্দের কৌশল (FIFO vs Specific Project)
              const Text('বরাদ্দের কৌশল', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('স্বয়ংক্রিয় (FIFO)')),
                      selected: _allocationStrategy == 'fifo',
                      onSelected: (s) {
                        if (s) setState(() => _allocationStrategy = 'fifo');
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('নির্দিষ্ট প্রজেক্ট')),
                      selected: _allocationStrategy == 'specific',
                      onSelected: (s) {
                        if (s) setState(() => _allocationStrategy = 'specific');
                      },
                    ),
                  ),
                ],
              ),

              if (_allocationStrategy == 'specific') ...[
                const SizedBox(height: 16),
                const Text('প্রজেক্ট নির্বাচন করুন', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                projectsAsync.when(
                  data: (projects) => DropdownButtonFormField<String>(
                    value: _selectedProjectId,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.apartment_rounded),
                    ),
                    hint: const Text('প্রজেক্ট বাছাই করুন'),
                    items: projects.map((p) {
                      return DropdownMenuItem(value: p.id, child: Text(p.name));
                    }).toList(),
                    onChanged: (id) => setState(() => _selectedProjectId = id),
                  ),
                  loading: () => const LinearProgressIndicator(),
                  error: (_, __) => const Text('প্রজেক্ট লোড করা যায়নি'),
                ),
              ],

              const SizedBox(height: 18),

              // পেমেন্ট মাধ্যম
              const Text('পেমেন্ট মাধ্যম', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _paymentMethod,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.payment_rounded),
                ),
                items: _paymentMethods.map((m) {
                  return DropdownMenuItem(value: m, child: Text(m));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _paymentMethod = val);
                },
              ),

              const SizedBox(height: 18),

              // নোট / বিবরণ
              const Text('বিবরণ / নোট (ঐচ্ছিক)', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _noteController,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: 'পেমেন্টের কোনো বিশেষ নোট থাকলে লিখুন',
                  prefixIcon: Icon(Icons.notes_rounded),
                ),
              ),

              const SizedBox(height: 24),

              // সাবমিট বাটন
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? const Color(0xFF93A8F4) : AppColors.contractorNavy,
                    foregroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.check_circle_rounded),
                  label: Text(
                    _isSaving ? 'বরাদ্দ হচ্ছে...' : 'পেমেন্ট বরাদ্দ নিশ্চিত করুন',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // সাম্প্রতিক পেমেন্ট বরাদ্দের ইতিহাস
              const Text(
                'সাম্প্রতিক পেমেন্ট হিস্ট্রি',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              paymentsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const Text('হিস্ট্রি লোড করা যায়নি'),
                data: (payments) {
                  if (payments.isEmpty) {
                    return const EmptyState(
                      icon: Icons.history_rounded,
                      title: 'কোনো পেমেন্ট রেকর্ড নেই',
                    );
                  }
                  return Column(
                    children: payments.take(5).map((p) {
                      return IconTile(
                        icon: Icons.receipt_long_rounded,
                        title: p.recipientName,
                        subtitle: '${BengaliFormatter.formatDate(p.paymentDate)} • ${p.method}',
                        trailingTitle: BengaliFormatter.toCurrency(p.amount),
                        trailingSubtitle: p.status,
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
