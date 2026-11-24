import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../providers/auth_provider.dart';

/// ঠিকাদার ও প্রতিষ্ঠান এককালীন নিবন্ধন পেজ
class ContractorSignUpScreen extends ConsumerStatefulWidget {
  const ContractorSignUpScreen({super.key});

  @override
  ConsumerState<ContractorSignUpScreen> createState() => _ContractorSignUpScreenState();
}

class _ContractorSignUpScreenState extends ConsumerState<ContractorSignUpScreen> {
  // প্রতিষ্ঠানের তথ্য কন্ট্রোলার
  final _orgNameController = TextEditingController();
  final _orgAddressController = TextEditingController();
  final _orgPhoneController = TextEditingController();

  // ঠিকাদারের ব্যক্তিগত তথ্য কন্ট্রোলার
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _orgNameController.dispose();
    _orgAddressController.dispose();
    _orgPhoneController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSignUp() async {
    final orgName = _orgNameController.text.trim();
    final orgAddress = _orgAddressController.text.trim();
    final orgPhone = _orgPhoneController.text.trim();

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final mobile = _mobileController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // প্রতিষ্ঠানের তথ্য ভ্যালিডেশন
    if (orgName.isEmpty) {
      _showSnackbar('প্রতিষ্ঠানের নাম লেখা আবশ্যক', isError: true);
      return;
    }

    // ঠিকাদারের তথ্য ভ্যালিডেশন
    if (name.isEmpty || email.isEmpty || mobile.isEmpty || password.isEmpty) {
      _showSnackbar('সমস্ত আবশ্যক ফিল্ড পূরণ করা আবশ্যক', isError: true);
      return;
    }

    // বাংলাদেশি মোবাইল ভ্যালিডেশন (০১৩–০১৯, ১১ সংখ্যা)
    final mobileRegExp = RegExp(r'^01[3-9]\d{8}$');
    if (!mobileRegExp.hasMatch(mobile)) {
      _showSnackbar('সঠিক ১১ সংখ্যার বাংলাদেশি মোবাইল নম্বর দিন (যেমন: 017XXXXXXXX)', isError: true);
      return;
    }

    if (password.length < 8) {
      _showSnackbar('পাসওয়ার্ড কমপক্ষে ৮ অক্ষরের হতে হবে', isError: true);
      return;
    }

    if (password != confirmPassword) {
      _showSnackbar('পাসওয়ার্ড দুটি মেলেনি', isError: true);
      return;
    }

    final success = await ref.read(authStateProvider.notifier).contractorSignUp(
      name: name,
      email: email,
      password: password,
      mobile: mobile,
      orgName: orgName,
      orgAddress: orgAddress,
      orgPhone: orgPhone,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('অভিনন্দন! আপনার ঠিকাদার অ্যাকাউন্ট ও "$orgName" সফলভাবে নিবন্ধিত হয়েছে।'),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 4),
        ),
      );
      Navigator.of(context).pop();
    } else if (mounted) {
      final error = ref.read(authStateProvider).errorMessage ?? 'সাইন-আপ ব্যর্থ হয়েছে';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ঠিকাদার ও প্রতিষ্ঠান নিবন্ধন'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // হেডার ব্যানার
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.contractorPrimary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                  border: Border.all(color: AppColors.contractorPrimary.withOpacity(0.2)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.business_center_rounded, color: AppColors.contractorPrimary, size: 36),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'প্রতিষ্ঠান ও ঠিকাদার নিবন্ধন',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'আপনার প্রতিষ্ঠানের তথ্য ও নিজের তথ্য প্রদান করে রেজিস্ট্রেশন সম্পন্ন করুন।',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ================= সেকশন ১: প্রতিষ্ঠানের তথ্য =================
              _buildSectionTitle(
                icon: Icons.apartment_rounded,
                title: '১. প্রতিষ্ঠানের তথ্য',
                color: AppColors.contractorPrimary,
              ),
              const SizedBox(height: 12),

              Card(
                elevation: 0,
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: isDark ? Colors.white12 : Colors.black12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    children: [
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
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ================= সেকশন ২: ঠিকাদারের ব্যক্তিগত তথ্য =================
              _buildSectionTitle(
                icon: Icons.person_rounded,
                title: '২. ঠিকাদারের ব্যক্তিগত ও লগইন তথ্য',
                color: AppColors.contractorPrimary,
              ),
              const SizedBox(height: 12),

              Card(
                elevation: 0,
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: isDark ? Colors.white12 : Colors.black12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'আপনার পূর্ণ নাম *',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                      ),
                      const SizedBox(height: 14),

                      TextField(
                        controller: _mobileController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'আপনার মোবাইল নম্বর *',
                          hintText: '01XXXXXXXXX',
                          prefixIcon: Icon(Icons.phone_android_outlined),
                        ),
                      ),
                      const SizedBox(height: 14),

                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'ইমেইল অ্যাড্রেস *',
                          hintText: 'example@domain.com',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                      ),
                      const SizedBox(height: 14),

                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'পাসওয়ার্ড (কমপক্ষে ৮ অক্ষর) *',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      TextField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirm,
                        decoration: InputDecoration(
                          labelText: 'পাসওয়ার্ড নিশ্চিত করুন *',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility),
                            onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              ElevatedButton(
                onPressed: authState.isLoading ? null : _handleSignUp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.contractorPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: authState.isLoading
                    ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text(
                        'নিবন্ধন ও প্রতিষ্ঠান তৈরি করুন',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle({
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
