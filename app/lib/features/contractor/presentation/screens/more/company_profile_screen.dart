import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_khata/core/constants/app_colors.dart';
import 'package:project_khata/core/constants/contractor_strings.dart';
import '../../contractor_providers.dart';
import '../../../domain/models/contractor_models.dart';

class CompanyProfileScreen extends ConsumerStatefulWidget {
  const CompanyProfileScreen({super.key});

  @override
  ConsumerState<CompanyProfileScreen> createState() => _CompanyProfileScreenState();
}

class _CompanyProfileScreenState extends ConsumerState<CompanyProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  bool _isInitialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _initFields(ContractorCompanyProfile company) {
    if (_isInitialized) return;
    _nameController = TextEditingController(text: company.name);
    _addressController = TextEditingController(text: company.address);
    _phoneController = TextEditingController(text: company.phone);
    _isInitialized = true;
  }

  @override
  Widget build(BuildContext context) {
    final companyAsync = ref.watch(companyProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(ContractorStrings.companyProfile),
      ),
      body: companyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (company) {
          _initFields(company);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // লোগো প্লেসহোল্ডার
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: AppColors.contractorNavy.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.contractorNavy, width: 2),
                          ),
                          child: const Icon(
                            Icons.business_rounded,
                            size: 48,
                            color: AppColors.contractorNavy,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor: AppColors.contractorNavy,
                            child: IconButton(
                              icon: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('লোগো পরিবর্তন পরের ধাপে যুক্ত হবে')),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(ContractorStrings.orgName, style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameController,
                  ),

                  const SizedBox(height: 18),

                  const Text(ContractorStrings.orgAddress, style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _addressController,
                  ),

                  const SizedBox(height: 18),

                  const Text(ContractorStrings.orgPhone, style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                  ),

                  const SizedBox(height: 32),

                  FilledButton(
                    onPressed: () async {
                      final updated = ContractorCompanyProfile(
                        name: _nameController.text.trim(),
                        address: _addressController.text.trim(),
                        phone: _phoneController.text.trim(),
                        logoUrl: company.logoUrl,
                      );
                      final repo = ref.read(contractorRepositoryProvider);
                      await repo.updateCompanyProfile(updated);
                      ref.invalidate(companyProfileProvider);
                      ref.invalidate(dashboardSummaryProvider);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('প্রতিষ্ঠানের প্রোফাইল সংরক্ষিত হয়েছে')),
                        );
                      }
                    },
                    child: const Text('সংরক্ষণ করুন'),
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
