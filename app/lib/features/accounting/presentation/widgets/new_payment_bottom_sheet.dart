import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/bengali_formatter.dart';
import '../providers/accounting_provider.dart';

/// PRD সেকশন ৩.৯ ও ৬.৫ (৪) অনুযায়ী শ্রমিক পেমেন্ট ও FIFO বরাদ্দ বটম শীট
class NewPaymentBottomSheet extends ConsumerStatefulWidget {
  final List<Map<String, dynamic>> workers;

  const NewPaymentBottomSheet({
    super.key,
    required this.workers,
  });

  @override
  ConsumerState<NewPaymentBottomSheet> createState() => _NewPaymentBottomSheetState();
}

class _NewPaymentBottomSheetState extends ConsumerState<NewPaymentBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedWorkerId;
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime _paymentDate = DateTime.now();
  bool _isSaving = false;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _handleRecordPayment() async {
    if (!_formKey.currentState!.validate() || _selectedWorkerId == null) return;

    setState(() => _isSaving = true);
    try {
      final amount = double.parse(_amountController.text.trim());
      await ref.read(accountingActionProvider.notifier).recordWorkerPayment(
        payeeId: _selectedWorkerId!,
        amount: amount,
        paymentDate: _paymentDate,
        note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
      );

      if (mounted) {
        Navigator.of(context).pop();
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.cardRadius)),
            title: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: AppColors.success),
                SizedBox(width: 8),
                Text('পেমেন্ট সফল হয়েছে'),
              ],
            ),
            content: Text(
              '৳ ${BengaliFormatter.toBengaliNumber(amount)} টাকার পেমেন্ট রেকর্ড হয়েছে এবং FIFO পদ্ধতিতে পুরোনো অর্জিত বকেয়া মজুরির সাথে বরাদ্দ সমন্বয় করা হয়েছে।',
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.contractorPrimary),
                child: const Text('ঠিক আছে', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ত্রুটি: $e'), backgroundColor: AppColors.danger),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 24,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'নতুন মজুরি পেমেন্ট',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // কর্মী নির্বাচন
              DropdownButtonFormField<String>(
                value: _selectedWorkerId,
                decoration: const InputDecoration(
                  labelText: 'শ্রমিক বা সুপারভাইজার নির্বাচন করুন *',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                items: widget.workers.map((w) {
                  return DropdownMenuItem<String>(
                    value: w['id'] as String,
                    child: Text('${w['name']} (${w['mobile']})'),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() => _selectedWorkerId = val);
                },
                validator: (val) => val == null ? 'কর্মী নির্বাচন বাধ্যতামূলক' : null,
              ),

              const SizedBox(height: 14),

              // টাকার পরিমাণ
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'পেমেন্টের পরিমাণ (টাকা) *',
                  hintText: 'যেমন: ৫০০০',
                  prefixIcon: Icon(Icons.monetization_on_outlined),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'টাকার পরিমাণ আবশ্যক';
                  final numVal = double.tryParse(val.trim());
                  if (numVal == null || numVal <= 0) return 'সঠিক টাকার পরিমাণ দিন';
                  return null;
                },
              ),

              const SizedBox(height: 14),

              // পেমেন্টের তারিখ
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_month_outlined, color: AppColors.contractorPrimary),
                title: Text('পেমেন্টের তারিখ: ${BengaliFormatter.toFullDate(_paymentDate)}'),
                trailing: TextButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _paymentDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() => _paymentDate = picked);
                    }
                  },
                  child: const Text('পরিবর্তন'),
                ),
              ),

              const SizedBox(height: 10),

              // নোট
              TextField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: 'নোট (ঐচ্ছিক)',
                  hintText: 'যেমন: সাপ্তাহিক মজুরি বাবদ ক্যাশ প্রদান',
                  prefixIcon: Icon(Icons.note_alt_outlined),
                ),
              ),

              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.contractorPrimary.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'নোট: পেমেন্টটি FIFO (First-In, First-Out) পদ্ধতিতে স্বয়ংক্রিয়ভাবে কর্মীর সবচেয়ে পুরোনো বকেয়া মজুরির বিপরীতে বরাদ্দ হবে।',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _isSaving ? null : _handleRecordPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.contractorPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _isSaving
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('পেমেন্ট নিশ্চিত করুন', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
