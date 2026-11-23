import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../providers/auth_provider.dart';

/// PRD সেকশন ৬.১ অনুযায়ী ঠিকাদার রেজিস্ট্রেশন (ধাপ ১: অ্যাকাউন্ট তৈরি)
class ContractorSignUpScreen extends ConsumerStatefulWidget {
  const ContractorSignUpScreen({super.key});

  @override
  ConsumerState<ContractorSignUpScreen> createState() => _ContractorSignUpScreenState();
}

class _ContractorSignUpScreenState extends ConsumerState<ContractorSignUpScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSignUp() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final mobile = _mobileController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (name.isEmpty || email.isEmpty || mobile.isEmpty || password.isEmpty) {
      _showSnackbar('সমস্ত ফিল্ড পূরণ করা আবশ্যক', isError: true);
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
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('অ্যাকাউন্ট তৈরি হয়েছে! আপনার ইমেইলে ভেরিফিকেশন লিংক পাঠানো হয়েছে।'),
          backgroundColor: AppColors.success,
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('ঠিকাদার সাইন-আপ'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'প্রতিষ্ঠান পরিচালনার জন্য অ্যাকাউন্ট তৈরি করুন',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              const Text(
                'একজন ঠিকাদার একটিমাত্র প্রতিষ্ঠান পরিচালনা করতে পারবেন। অন্য ব্যবহারকারীদের ঠিকাদার নিজে যুক্ত করবেন।',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),

              const SizedBox(height: 24),

              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'আপনার পূর্ণ নাম',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 14),

              TextField(
                controller: _mobileController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'আপনার মোবাইল নম্বর',
                  hintText: '01XXXXXXXXX',
                  prefixIcon: Icon(Icons.phone_android_outlined),
                ),
              ),
              const SizedBox(height: 14),

              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'ইমেইল অ্যাড্রেস',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 14),

              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'পাসওয়ার্ড (কমপক্ষে ৮ অক্ষর)',
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
                  labelText: 'পাসওয়ার্ড নিশ্চিত করুন',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              ElevatedButton(
                onPressed: authState.isLoading ? null : _handleSignUp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.contractorPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: authState.isLoading
                    ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('নিবন্ধন সম্পন্ন করুন', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
