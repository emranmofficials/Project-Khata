import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/auth/phone_email.dart';
import '../controllers/auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Mobile Tab Controllers
  final _mobileFormKey = GlobalKey<FormState>();
  final _mobileController = TextEditingController();
  final _mobilePasswordController = TextEditingController();
  bool _obscureMobilePass = true;

  // Contractor Tab Controllers
  final _contractorFormKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _contractorPasswordController = TextEditingController();
  bool _obscureContractorPass = true;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _mobileController.dispose();
    _mobilePasswordController.dispose();
    _emailController.dispose();
    _contractorPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleMobileLogin() async {
    if (!_mobileFormKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      await ref.read(authControllerProvider.notifier).loginMember(
            mobile: _mobileController.text.trim(),
            password: _mobilePasswordController.text,
          );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleContractorLogin() async {
    if (!_contractorFormKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      await ref.read(authControllerProvider.notifier).loginContractor(
            email: _emailController.text.trim(),
            password: _contractorPasswordController.text,
          );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header & Logo
                Center(
                  child: Image.asset(
                    'assets/branding/app-icon.png',
                    width: 80,
                    height: 80,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.architecture_rounded,
                      size: 64,
                      color: AppColors.contractorNavy,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    AppStrings.appNameBangla,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.contractorNavy,
                        ),
                  ),
                ),
                const SizedBox(height: 4),
                Center(
                  child: Text(
                    AppStrings.loginTitle,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                  ),
                ),
                const SizedBox(height: 28),

                // Tabs for Mobile vs Contractor
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    indicator: BoxDecoration(
                      color: AppColors.contractorNavy,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                    tabs: const [
                      Tab(text: AppStrings.mobileLoginTab),
                      Tab(text: AppStrings.contractorLoginTab),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Tab View
                SizedBox(
                  height: 340,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Tab 1: Member Mobile Login
                      Form(
                        key: _mobileFormKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextFormField(
                              controller: _mobileController,
                              keyboardType: TextInputType.phone,
                              decoration: const InputDecoration(
                                labelText: AppStrings.mobileLabel,
                                hintText: AppStrings.mobileHint,
                                prefixIcon: Icon(Icons.phone_android_rounded),
                              ),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return AppStrings.fieldRequired;
                                }
                                if (!RegExp(r'^01[3-9]\d{8}$').hasMatch(val.trim())) {
                                  return AppStrings.invalidMobile;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _mobilePasswordController,
                              obscureText: _obscureMobilePass,
                              decoration: InputDecoration(
                                labelText: AppStrings.passwordLabel,
                                hintText: AppStrings.passwordHint,
                                prefixIcon: const Icon(Icons.lock_outline_rounded),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureMobilePass
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                  ),
                                  onPressed: () => setState(
                                      () => _obscureMobilePass = !_obscureMobilePass),
                                ),
                              ),
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return AppStrings.fieldRequired;
                                }
                                if (val.length < 6) {
                                  return AppStrings.passwordMinLength;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 8),
                            Text(
                              AppStrings.defaultPasswordNotice,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                            ),
                            const Spacer(),
                            ElevatedButton(
                              onPressed: _isLoading ? null : _handleMobileLogin,
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(AppStrings.loginButton),
                            ),
                          ],
                        ),
                      ),

                      // Tab 2: Contractor Email Login
                      Form(
                        key: _contractorFormKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                labelText: AppStrings.emailLabel,
                                hintText: AppStrings.emailHint,
                                prefixIcon: Icon(Icons.email_outlined),
                              ),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return AppStrings.fieldRequired;
                                }
                                if (!val.contains('@') || !val.contains('.')) {
                                  return AppStrings.invalidEmail;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _contractorPasswordController,
                              obscureText: _obscureContractorPass,
                              decoration: InputDecoration(
                                labelText: AppStrings.passwordLabel,
                                hintText: AppStrings.passwordHint,
                                prefixIcon: const Icon(Icons.lock_outline_rounded),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureContractorPass
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                  ),
                                  onPressed: () => setState(() =>
                                      _obscureContractorPass =
                                          !_obscureContractorPass),
                                ),
                              ),
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return AppStrings.fieldRequired;
                                }
                                if (val.length < 6) {
                                  return AppStrings.passwordMinLength;
                                }
                                return null;
                              },
                            ),
                            const Spacer(),
                            ElevatedButton(
                              onPressed: _isLoading ? null : _handleContractorLogin,
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(AppStrings.loginButton),
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton(
                              onPressed: () => context.push('/register-contractor'),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size.fromHeight(48),
                                side: const BorderSide(
                                    color: AppColors.contractorNavy),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(AppStrings.registerButton),
                            ),
                          ],
                        ),
                      ),
                    ],
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
