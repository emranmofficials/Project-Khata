import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/bengali_formatter.dart';
import '../providers/accounting_provider.dart';

/// PRD সেকশন ৩.১০ অনুযায়ী নতুন মালামাল যোগ করার ডায়ালগ
class AddMaterialDialog extends ConsumerStatefulWidget {
  final String projectId;

  const AddMaterialDialog({
    super.key,
    required this.projectId,
  });

  @override
  ConsumerState<AddMaterialDialog> createState() => _AddMaterialDialogState();
}

class _AddMaterialDialogState extends ConsumerState<AddMaterialDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _unitController = TextEditingController(text: 'বস্তা');
  final _qtyController = TextEditingController();
  final _priceController = TextEditingController();
  DateTime _purchaseDate = DateTime.now();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _unitController.dispose();
    _qtyController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _handleAddMaterial() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final qty = double.parse(_qtyController.text.trim());
      final price = double.parse(_priceController.text.trim());

      await ref.read(accountingActionProvider.notifier).addMaterial(
        projectId: widget.projectId,
        name: _nameController.text.trim(),
        unit: _unitController.text.trim(),
        qty: qty,
        unitPrice: price,
        purchaseDate: _purchaseDate,
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('মালামাল সফলভাবে যুক্ত হয়েছে!'), backgroundColor: AppColors.success),
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
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.cardRadius)),
      title: const Text('নতুন মালামাল যোগ করুন', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'মালামালের নাম *',
                  hintText: 'যেমন: সিমেন্ট (শাহ সিমেন্ট)',
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'নাম লেখা আবশ্যক' : null,
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _qtyController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'পরিমাণ *'),
                      validator: (val) => val == null || double.tryParse(val.trim()) == null ? 'সঠিক সংখ্যা' : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _unitController,
                      decoration: const InputDecoration(labelText: 'একক *', hintText: 'বস্তা, টন, সিএফটি'),
                      validator: (val) => val == null || val.trim().isEmpty ? 'একক আবশ্যক' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'প্রতি এককের দর (টাকা) *',
                  hintText: 'যেমন: ৫৫০',
                ),
                validator: (val) => val == null || double.tryParse(val.trim()) == null ? 'সঠিক দর দিন' : null,
              ),
              const SizedBox(height: 12),

              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today_outlined, size: 20),
                title: Text(BengaliFormatter.toShortDate(_purchaseDate), style: const TextStyle(fontSize: 13)),
                trailing: TextButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _purchaseDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() => _purchaseDate = picked);
                    }
                  },
                  child: const Text('তারিখ বদলান'),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('বাতিল')),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleAddMaterial,
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.contractorPrimary),
          child: _isLoading
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('সংরক্ষণ করুন', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
