import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:project_khata/core/auth/phone_email.dart';
import 'package:project_khata/core/constants/app_colors.dart';
import 'package:project_khata/core/constants/app_strings.dart';
import 'package:project_khata/core/constants/contractor_routes.dart';
import 'package:project_khata/widgets/contractor_widgets.dart';
import '../../contractor_providers.dart';
import '../../../domain/models/contractor_models.dart';

typedef CreateProjectScreen = ContractorCreateProjectScreen;

class ContractorCreateProjectScreen extends ConsumerStatefulWidget {
  const ContractorCreateProjectScreen({super.key});

  @override
  ConsumerState<ContractorCreateProjectScreen> createState() => _ContractorCreateProjectScreenState();
}

class _ContractorCreateProjectScreenState extends ConsumerState<ContractorCreateProjectScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _clientNameController = TextEditingController();
  final _clientMobileController = TextEditingController();
  final _budgetController = TextEditingController();

  ProjectType _selectedType = ProjectType.sqft;
  double _geofenceRadius = 150;
  bool _isSaving = false;

  // মানচিত্র লোকেশন (ডিফল্ট ঢাকা, Phase 2-এ Google Maps SDK যুক্ত হবে)
  final double _lat = 23.8103;
  final double _lng = 90.4125;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _clientNameController.dispose();
    _clientMobileController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final input = NewProjectInput(
        name: _nameController.text.trim(),
        type: _selectedType,
        address: _addressController.text.trim(),
        lat: _lat,
        lng: _lng,
        geofenceRadiusM: _geofenceRadius.round(),
        budget: double.tryParse(_budgetController.text.trim()),
        clientName: _clientNameController.text.trim(),
        clientMobile: cleanMobile(_clientMobileController.text.trim()),
      );

      final repo = ref.read(contractorRepositoryProvider);
      final created = await repo.createProject(input);

      ref.invalidate(projectsProvider(null));
      ref.invalidate(projectsProvider(ProjectStatus.active));
      ref.invalidate(dashboardSummaryProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('নতুন প্রজেক্ট সফলভাবে তৈরি হয়েছে!'),
            backgroundColor: AppColors.contractorNavy,
          ),
        );
        context.pushReplacement(ContractorRoutes.projectDetailsPath(created.id));
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(ContractorStrings.createNewProject),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // প্রজেক্টের নাম
              const Text(
                ContractorStrings.projectName,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: 'যেমন: মেঘনা ভিউ রেসিডেন্স',
                ),
                validator: (val) => requiredValidator(val, AppStrings.fieldRequired),
              ),

              const SizedBox(height: 20),

              // প্রজেক্টের ধরন (SegmentedButton)
              const Text(
                ContractorStrings.projectType,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<ProjectType>(
                  segments: const [
                    ButtonSegment(
                      value: ProjectType.sqft,
                      label: Text(ContractorStrings.projectTypeSqft),
                    ),
                    ButtonSegment(
                      value: ProjectType.contract,
                      label: Text(ContractorStrings.projectTypeContract),
                    ),
                    ButtonSegment(
                      value: ProjectType.daily,
                      label: Text(ContractorStrings.projectTypeDaily),
                    ),
                  ],
                  selected: {_selectedType},
                  onSelectionChanged: (set) {
                    setState(() => _selectedType = set.first);
                  },
                ),
              ),

              const SizedBox(height: 20),

              // সাইট ঠিকানা
              const Text(
                ContractorStrings.projectAddress,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  hintText: 'সাইটের পূর্ণ ঠিকানা লিখুন',
                ),
                validator: (val) => requiredValidator(val, AppStrings.fieldRequired),
              ),

              const SizedBox(height: 20),

              // মানচিত্র লোকেশন পিকার (প্লেসহোল্ডার)
              const Text(
                ContractorStrings.projectLocation,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.contractorNavy.withValues(alpha: 0.2),
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.map_rounded,
                        color: AppColors.contractorNavy,
                        size: 32,
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'মানচিত্র নির্বাচন (পরের ধাপে যুক্ত হবে)',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'ডিফল্ট কোঅর্ডিনেট: ${toBn(_lat)}, ${toBn(_lng)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // জিও-ফেন্স রেডিয়াস স্লাইডার (100–200, ডিফল্ট 150)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    ContractorStrings.geofenceRadiusLabel,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${toBn(_geofenceRadius.round())} ${ContractorStrings.metersUnit}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.contractorNavy,
                    ),
                  ),
                ],
              ),
              Slider(
                value: _geofenceRadius,
                min: 100,
                max: 200,
                divisions: 10,
                label: '${toBn(_geofenceRadius.round())} মিটার',
                onChanged: (val) => setState(() => _geofenceRadius = val),
              ),

              const SizedBox(height: 20),

              // ক্লায়েন্টের নাম (বাধ্যতামূলক)
              const Text(
                ContractorStrings.clientName,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _clientNameController,
                decoration: const InputDecoration(
                  hintText: 'ক্লায়েন্টের পূর্ণ নাম',
                ),
                validator: (val) => requiredValidator(val, AppStrings.fieldRequired),
              ),

              const SizedBox(height: 20),

              // ক্লায়েন্টের মোবাইল নম্বর (বাধ্যতামূলক, বাংলাদেশি মোবাইল যাচাই)
              const Text(
                ContractorStrings.clientMobile,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _clientMobileController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  hintText: '০১XXXXXXXXX',
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return AppStrings.fieldRequired;
                  }
                  if (!isValidBangladeshiMobile(val)) {
                    return AppStrings.invalidMobile;
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // বাজেট / চুক্তি মূল্য
              const Text(
                ContractorStrings.projectBudget,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _budgetController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'টাকার পরিমাণ (ঐচ্ছিক)',
                  prefixText: '৳ ',
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
                    : const Text(ContractorStrings.createNewProject),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
