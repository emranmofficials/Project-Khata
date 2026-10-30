import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/auth/phone_email.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/contractor_strings.dart';
import '../../../../widgets/contractor_widgets.dart';
import '../../contractor_providers.dart';
import '../../../domain/models/contractor_models.dart';

class AddMemberScreen extends ConsumerStatefulWidget {
  final MemberRole initialRole;

  const AddMemberScreen({
    super.key,
    this.initialRole = MemberRole.worker,
  });

  @override
  ConsumerState<AddMemberScreen> createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends ConsumerState<AddMemberScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _wageController = TextEditingController();

  late MemberRole _role;
  String? _selectedDesignationId;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _role = widget.initialRole;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _wageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDesignationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('অনুগ্রহ করে পদ নির্বাচন করুন')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final input = NewMemberInput(
        name: _nameController.text.trim(),
        mobile: cleanMobile(_mobileController.text.trim()),
        role: _role,
        designationId: _selectedDesignationId!,
        dailyWage: double.tryParse(_wageController.text.trim()) ?? 0,
      );

      final repo = ref.read(contractorRepositoryProvider);
      await repo.createMember(input);

      ref.invalidate(membersProvider(_role));
      ref.invalidate(dashboardSummaryProvider);

      if (mounted) {
        final last6 = getInitialPassword(_mobileController.text.trim());
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('সফলভাবে যুক্ত হয়েছে'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${input.name}-কে সফলভাবে ${_role.displayName} হিসেবে যুক্ত করা হয়েছে।'),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'প্রাথমিক লগইন পাসওয়ার্ড:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        toBn(last6),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.contractorNavy,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '(${ContractorStrings.initialPasswordNotice})',
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              FilledButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('ঠিক আছে'),
              ),
            ],
          ),
        );

        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final designationsAsync = ref.watch(designationsProvider);

    final title = _role == MemberRole.worker
        ? ContractorStrings.addNewWorker
        : ContractorStrings.addNewSupervisor;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ভূমিকা নির্বাচন (যদি পরিবর্তন করতে চায়)
              SegmentedButton<MemberRole>(
                segments: const [
                  ButtonSegment(
                    value: MemberRole.worker,
                    label: Text(ContractorStrings.workersTab),
                  ),
                  ButtonSegment(
                    value: MemberRole.supervisor,
                    label: Text('সুপারভাইজার'),
                  ),
                ],
                selected: {_role},
                onSelectionChanged: (set) => setState(() => _role = set.first),
              ),

              const SizedBox(height: 20),

              // নাম
              const Text(
                ContractorStrings.workerName,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(hintText: 'কর্মীর নাম'),
                validator: (val) => requiredValidator(val, AppStrings.fieldRequired),
              ),

              const SizedBox(height: 18),

              // মোবাইল
              const Text(
                ContractorStrings.memberMobile,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _mobileController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(hintText: '০১XXXXXXXXX'),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return AppStrings.fieldRequired;
                  if (!isValidBangladeshiMobile(val)) return AppStrings.invalidMobile;
                  return null;
                },
              ),

              const SizedBox(height: 18),

              // পদ নির্বাচন
              const Text(
                ContractorStrings.designation,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              designationsAsync.when(
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const Text('পদ লোড করা যায়নি'),
                data: (designations) {
                  return DropdownButtonFormField<String>(
                    value: _selectedDesignationId,
                    hint: const Text('পদ নির্বাচন করুন'),
                    items: designations.map((d) {
                      return DropdownMenuItem(
                        value: d.id,
                        child: Text('${d.name} (৳ ${toBn(d.dailyWage.round())}/দিন)'),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedDesignationId = val;
                        final d = designations.firstWhere((x) => x.id == val);
                        _wageController.text = d.dailyWage.toStringAsFixed(0);
                      });
                    },
                    validator: (val) => val == null ? 'পদ নির্বাচন করুন' : null,
                  );
                },
              ),

              const SizedBox(height: 18),

              // দৈনিক মজুরি
              const Text(
                ContractorStrings.dailyWage,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _wageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  prefixText: '৳ ',
                  hintText: 'দৈনিক মজুরি হার',
                ),
                validator: (val) => requiredValidator(val, AppStrings.fieldRequired),
              ),

              const SizedBox(height: 12),

              // প্রাথমিক পাসওয়ার্ড তথ্য
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.amber, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        ContractorStrings.initialPasswordNotice,
                        style: TextStyle(fontSize: 12, color: Colors.amber.shade900),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              FilledButton(
                onPressed: _isSaving ? null : _submit,
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Text('সংরক্ষণ করুন'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
