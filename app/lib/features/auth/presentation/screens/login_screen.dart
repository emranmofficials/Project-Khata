import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../providers/auth_provider.dart';
import 'contractor_signup_screen.dart';

/// PRD সেকশন ৬.১ অনুযায়ী লগইন স্ক্রিন (ঠিকাদার ইমেইল ও অন্যান্যদের মোবাইল ভিত্তিক)
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // ঠিকাদার ফর্ম
  final _emailController = TextEditingController();
  final _contractorPasswordController = TextEditingController();

  // মোবাইল ইউজার ফর্ম (শ্রমিক, সুপারভাইজার, ক্লায়েন্ট)
  final _mobileController = TextEditingController();
  final _mobilePasswordController = TextEditingController();

  bool _obscureContractorPassword = true;
  bool _obscureMobilePassword = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _contractorPasswordController.dispose();
    _mobileController.dispose();
    _mobilePasswordController.dispose();
    super.dispose();
  }

  void _handleContractorLogin() async {
    final email = _emailController.text.trim();
    final password = _contractorPasswordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showSnackbar('দয়া করে ইমেইল ও পাসওয়ার্ড প্রদান করুন');
      return;
    }

    final success = await ref.read(authStateProvider.notifier).loginWithEmail(email, password);
    if (!success && mounted) {
      final error = ref.read(authStateProvider).errorMessage ?? 'লগইন ব্যর্থ হয়েছে';
      _showSnackbar(error, isError: true);
    }
  }

  void _handleMobileLogin() async {
    final mobile = _mobileController.text.trim();
    final password = _mobilePasswordController.text;

    if (mobile.isEmpty || password.isEmpty) {
      _showSnackbar('দয়া করে মোবাইল নম্বর ও পাসওয়ার্ড প্রদান করুন');
      return;
    }

    final success = await ref.read(authStateProvider.notifier).loginWithMobile(mobile, password);
    if (!success && mounted) {
      final error = ref.read(authStateProvider).errorMessage ?? 'লগইন ব্যর্থ হয়েছে';
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
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.paddingLarge),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // অ্যাপ লোগো ও হেডার
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.contractorPrimary.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_rounded,
                    color: AppColors.contractorPrimary,
                    size: 38,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  AppStrings.appName,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.contractorPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppStrings.appTagline,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),

                const SizedBox(height: 32),

                // ট্যাব বার (ঠিকাদার বনাম কর্মী/ক্লায়েন্ট)
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: AppColors.contractorPrimary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: Colors.white,
                    unselectedLabelColor: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    tabs: const [
                      Tab(text: 'ঠিকাদার'),
                      Tab(text: 'কর্মী / ক্লায়েন্ট'),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ট্যাব ভিউ কন্টেন্ট
                SizedBox(
                  height: 260,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // ১. ঠিকাদার ফর্ম
                      Column(
                        children: [
                          TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: AppStrings.email,
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                          ),
                          const SizedBox(height: 14),
                          TextField(
                            controller: _contractorPasswordController,
                            obscureText: _obscureContractorPassword,
                            decoration: InputDecoration(
                              labelText: AppStrings.password,
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(_obscureContractorPassword ? Icons.visibility_off : Icons.visibility),
                                onPressed: () => setState(() => _obscureContractorPassword = !_obscureContractorPassword),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: authState.isLoading ? null : _handleContractorLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.contractorPrimary,
                              foregroundColor: Colors.white,
                            ),
                            child: authState.isLoading
                                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Text(AppStrings.loginButton),
                          ),
                        ],
                      ),

                      // ২. মোবাইল ইউজার ফর্ম (শ্রমিক, সুপারভাইজার, ক্লায়েন্ট)
                      Column(
                        children: [
                          TextField(
                            controller: _mobileController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              labelText: AppStrings.mobileNumber,
                              hintText: '০১XXXXXXXXX',
                              prefixIcon: Icon(Icons.phone_android_outlined),
                            ),
                          ),
                          const SizedBox(height: 14),
                          TextField(
                            controller: _mobilePasswordController,
                            obscureText: _obscureMobilePassword,
                            decoration: InputDecoration(
                              labelText: AppStrings.password,
                              helperText: 'প্রাথমিক পাসওয়ার্ড: মোবাইলের শেষ ৬ সংখ্যা',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(_obscureMobilePassword ? Icons.visibility_off : Icons.visibility),
                                onPressed: () => setState(() => _obscureMobilePassword = !_obscureMobilePassword),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: authState.isLoading ? null : _handleMobileLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.workerPrimary,
                              foregroundColor: Colors.white,
                            ),
                            child: authState.isLoading
                                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Text(AppStrings.loginButton),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ঠিকাদার সাইন-আপ বাটন
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ContractorSignUpScreen()),
                    );
                  },
                  child: const Text(
                    'নতুন ঠিকাদার? প্রতিষ্ঠান নিবন্ধন করুন',
                    style: TextStyle(
                      color: AppColors.contractorPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
