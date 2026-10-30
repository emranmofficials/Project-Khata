import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_khata/core/constants/app_colors.dart';
import 'package:project_khata/core/constants/contractor_strings.dart';
import 'package:project_khata/core/utils/bengali_formatter.dart';
import 'package:project_khata/widgets/contractor_widgets.dart';
import '../../contractor_providers.dart';
import '../../../domain/models/contractor_models.dart';

class WorkerEditScreen extends ConsumerStatefulWidget {
  final String workerId;

  const WorkerEditScreen({
    super.key,
    required this.workerId,
  });

  @override
  ConsumerState<WorkerEditScreen> createState() => _WorkerEditScreenState();
}

class _WorkerEditScreenState extends ConsumerState<WorkerEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _wageController;
  String? _selectedDesignationId;
  bool _isActive = true;
  bool _isSaving = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _wageController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _wageController.dispose();
    super.dispose();
  }

  void _initFields(MemberDetails worker) {
    if (_isInitialized) return;
    _nameController.text = worker.name;
    _wageController.text = worker.dailyWage.toStringAsFixed(0);
    _selectedDesignationId = worker.designationId;
    _isActive = worker.isActive;
    _isInitialized = true;
  }

  Future<void> _submit(MemberDetails worker) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final repo = ref.read(contractorRepositoryProvider);
      final wage = double.tryParse(_wageController.text.trim()) ?? worker.dailyWage;

      await repo.updateMember(
        widget.workerId,
        name: _nameController.text.trim(),
        designationId: _selectedDesignationId,
        dailyWage: wage,
      );

      if (_isActive != worker.isActive) {
        await repo.setMemberActive(widget.workerId, _isActive);
      }

      ref.invalidate(memberDetailsProvider(widget.workerId));
      ref.invalidate(membersProvider(MemberRole.worker));
      ref.invalidate(membersProvider(MemberRole.supervisor));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('শ্রমিকের তথ্য সফলভাবে আপডেট করা হয়েছে')),
        );
        Navigator.pop(context);
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
    final workerAsync = ref.watch(memberDetailsProvider(widget.workerId));
    final designationsAsync = ref.watch(designationsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          ContractorStrings.workerEditTitle,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: workerAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(ContractorStrings.errorOccurred),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => ref.invalidate(memberDetailsProvider(widget.workerId)),
                child: const Text(ContractorStrings.retry),
              ),
            ],
          ),
        ),
        data: (worker) {
          _initFields(worker);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // হেডকার্ড
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: (isDark
                                  ? const Color(0xFF93A8F4)
                                  : AppColors.contractorNavy)
                              .withValues(alpha: 0.15),
                          child: Icon(
                            Icons.person_rounded,
                            size: 28,
                            color: isDark
                                ? const Color(0xFF93A8F4)
                                : AppColors.contractorNavy,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                worker.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'মোবাইল: ${toBn(worker.mobile)}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // নাম
                  const Text('শ্রমিকের পূর্ণ নাম', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      hintText: 'নাম লিখুন',
                      prefixIcon: Icon(Icons.badge_outlined),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'নাম লিখুন' : null,
                  ),

                  const SizedBox(height: 20),

                  // পদবী নির্বাচন
                  const Text('পদবী', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  designationsAsync.when(
                    data: (designations) {
                      return DropdownButtonFormField<String>(
                        value: _selectedDesignationId,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.work_outline_rounded),
                        ),
                        hint: const Text('পদবী নির্বাচন করুন'),
                        items: designations.map((d) {
                          return DropdownMenuItem(
                            value: d.id,
                            child: Text('${d.name} (ডিফল্ট: ${BengaliFormatter.toCurrency(d.dailyWage)})'),
                          );
                        }).toList(),
                        onChanged: (id) {
                          setState(() {
                            _selectedDesignationId = id;
                            if (id != null) {
                              final d = designations.firstWhere((item) => item.id == id);
                              _wageController.text = d.dailyWage.toStringAsFixed(0);
                            }
                          });
                        },
                      );
                    },
                    loading: () => const LinearProgressIndicator(),
                    error: (_, __) => const Text('পদবী লোড করা যায়নি'),
                  ),

                  const SizedBox(height: 20),

                  // দৈনিক মজুরি
                  const Text('দৈনিক মজুরি (৳)', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _wageController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: '৫০০',
                      prefixIcon: Icon(Icons.payments_outlined),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'দৈনিক মজুরি লিখুন';
                      if (double.tryParse(v.trim()) == null) return 'সঠিক সংখ্যা লিখুন';
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // সক্রিয় স্ট্যাটাস
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: SwitchListTile(
                      title: const Text('কর্মে সক্রিয় স্ট্যাটাস', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(_isActive ? 'বর্তমানে সক্রিয়' : 'নিষ্ক্রিয়'),
                      value: _isActive,
                      onChanged: (v) => setState(() => _isActive = v),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // সংরক্ষণ বাটন
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _isSaving ? null : () => _submit(worker),
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
                          : const Icon(Icons.save_rounded),
                      label: Text(
                        _isSaving ? 'সংরক্ষণ হচ্ছে...' : 'পরিবর্তন সংরক্ষণ করুন',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
