import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../providers/auth_provider.dart';

/// PRD সেকশন ৬.১ ও ৩.১ অনুযায়ী প্রথম লগইনে বাধ্যতামূলক পাসওয়ার্ড পরিবর্তন স্ক্রিন
class ChangePasswordScreen extends ConsumerStatefulWidget {
  final bool isMandatory;

  const ChangePasswordScreen({
    super.key,
    this.isMandatory = true,
  });

  @override
  ConsumerState<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleChangePassword() async {
    final newPass = _newPasswordController.text;
    final confirmPass = _confirmPasswordController.text;

    if (newPass.isEmpty || confirmPass.isEmpty) {
      _showSnackbar('দয়া করে নতুন পাসওয়ার্ড লিখুন', isError: true);
      return;
    }

    if (newPass.length < 6) {
      _showSnackbar('পাসওয়ার্ড কমপক্ষে ৬ সংখ্যার হতে হবে', isError: true);
      return;
    }

    if (newPass != confirmPass) {
      _showSnackbar('পাসওয়ার্ড দুটি মেলেনি', isError: true);
      return;
    }

    final success = await ref.read(authStateProvider.notifier).changePassword(newPass);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('পাসওয়ার্ড সফলভাবে পরিবর্তিত হয়েছে!'),
          backgroundColor: AppColors.success,
        ),
      );
      if (!widget.isMandatory) {
        Navigator.of(context).pop();
      }
    } else if (mounted) {
      final error = ref.read(authStateProvider).errorMessage ?? 'পাসওয়ার্ড পরিবর্তনে ত্রুটি';
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
        title: const Text('পাসওয়ার্ড পরিবর্তন'),
        automaticallyImplyLeading: !widget.isMandatory,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.isMandatory) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                    border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.security_rounded, color: AppColors.warning, size: 36),
                      SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.mustChangePasswordTitle,
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.warning),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'নিরাপত্তার স্বার্থে প্রাথমিক পাসওয়ার্ড পরিবর্তন না করা পর্যন্ত পরবর্তী স্ক্রিনে যাওয়া যাবে না।',
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              TextField(
                controller: _newPasswordController,
                obscureText: _obscureNew,
                decoration: InputDecoration(
                  labelText: AppStrings.newPassword,
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureNew ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscureNew = !_obscureNew),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirm,
                decoration: InputDecoration(
                  labelText: AppStrings.confirmPassword,
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: authState.isLoading ? null : _handleChangePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.contractorPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: authState.isLoading
                    ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text(AppStrings.changePasswordButton, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),

              if (widget.isMandatory) ...[
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => ref.read(authStateProvider.notifier).signOut(),
                  child: const Text('লগআউট করুন', style: TextStyle(color: Colors.grey)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
