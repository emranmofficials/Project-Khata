import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../providers/auth_provider.dart';

/// PRD সেকশন ৬.১ অনুযায়ী প্রতিষ্ঠান সেটআপ (ধাপ ২: প্রথমবার লগইনের পর বাধ্যতামূলক)
class OrgSetupScreen extends ConsumerStatefulWidget {
  const OrgSetupScreen({super.key});

  @override
  ConsumerState<OrgSetupScreen> createState() => _OrgSetupScreenState();
}

class _OrgSetupScreenState extends ConsumerState<OrgSetupScreen> {
  final _orgNameController = TextEditingController();
  final _orgAddressController = TextEditingController();
  final _orgPhoneController = TextEditingController();
  final _contractorMobileController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final currentUser = ref.read(authStateProvider).user;
    if (currentUser != null && currentUser.mobile.isNotEmpty) {
      _contractorMobileController.text = currentUser.mobile;
    }
  }

  @override
  void dispose() {
    _orgNameController.dispose();
    _orgAddressController.dispose();
    _orgPhoneController.dispose();
    _contractorMobileController.dispose();
    super.dispose();
  }

  void _handleSetupOrg() async {
    final orgName = _orgNameController.text.trim();
    final orgAddress = _orgAddressController.text.trim();
    final orgPhone = _orgPhoneController.text.trim();
    final contractorMobile = _contractorMobileController.text.trim();

    if (orgName.isEmpty) {
      _showSnackbar('প্রতিষ্ঠানের নাম লেখা বাধ্যতামূলক', isError: true);
      return;
    }

    if (contractorMobile.isEmpty) {
      _showSnackbar('ঠিকাদারের মোবাইল নম্বর দেওয়া বাধ্যতামূলক', isError: true);
      return;
    }

    final mobileRegExp = RegExp(r'^01[3-9]\d{8}$');
    if (!mobileRegExp.hasMatch(contractorMobile)) {
      _showSnackbar('সঠিক ১১ সংখ্যার বাংলাদেশি মোবাইল নম্বর দিন (যেমন: 017XXXXXXXX)', isError: true);
      return;
    }

    final success = await ref.read(authStateProvider.notifier).setupOrganization(
      orgName: orgName,
      orgAddress: orgAddress,
      orgPhone: orgPhone,
      contractorMobile: contractorMobile,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('প্রতিষ্ঠান সফলভাবে তৈরি হয়েছে!'),
          backgroundColor: AppColors.success,
        ),
      );
    } else if (mounted) {
      final error = ref.read(authStateProvider).errorMessage ?? 'প্রতিষ্ঠান তৈরিতে ত্রুটি';
      _showSnackbar(error, isError: true);
    }
  }

  void _showSnackbar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.danger : AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.orgSetupTitle),
        automaticallyImplyLeading: false, // সেটআপ শেষ না করে পেছানো যাবে না
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // হেডার কার্ড
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.contractorPrimary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                  border: Border.all(color: AppColors.contractorPrimary.withOpacity(0.2)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.business_rounded, color: AppColors.contractorPrimary, size: 36),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'প্রতিষ্ঠান সেটআপ করুন',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'প্রজেক্ট ও কর্মী হিসাব শুরু করতে আপনার প্রতিষ্ঠানের তথ্য প্রদান করুন।',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              TextField(
                controller: _orgNameController,
                decoration: const InputDecoration(
                  labelText: '${AppStrings.orgName} *',
                  hintText: 'যেমন: মেসার্স রহিম বিল্ডার্স',
                  prefixIcon: Icon(Icons.apartment_outlined),
                ),
              ),
              const SizedBox(height: 14),

              TextField(
                controller: _orgAddressController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: AppStrings.orgAddress,
                  hintText: 'অফিস বা হেডকোয়ার্টারের ঠিকানা',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
              ),
              const SizedBox(height: 14),

              TextField(
                controller: _orgPhoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: AppStrings.orgPhone,
                  hintText: 'ল্যান্ডফোন বা হটলাইন (ঐচ্ছিক)',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: 14),

              TextField(
                controller: _contractorMobileController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: '${AppStrings.contractorMobile} *',
                  hintText: '01XXXXXXXXX',
                  prefixIcon: Icon(Icons.phone_android_outlined),
                ),
              ),

              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: authState.isLoading ? null : _handleSetupOrg,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.contractorPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: authState.isLoading
                    ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text(AppStrings.saveAndContinue, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),

              const SizedBox(height: 16),
              TextButton(
                onPressed: () => ref.read(authStateProvider.notifier).signOut(),
                child: const Text('লগআউট করুন', style: TextStyle(color: Colors.grey)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
