import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/auth/phone_email.dart';
import '../controllers/auth_controller.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();

  bool _obscureNewPass = true;
  bool _obscureConfirmPass = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  String? _resolveUserMobile() {
    final user = ref.read(authControllerProvider).value;
    if (user?.mobile != null && user!.mobile!.isNotEmpty) {
      return user.mobile;
    }
    if (user?.email != null) {
      final match = RegExp(r'^(\d{11})@').firstMatch(user!.email!);
      if (match != null) {
        return match.group(1);
      }
    }
    return null;
  }

  Future<void> _handlePasswordChange() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      await ref.read(authControllerProvider.notifier).updatePassword(
            _newPassController.text,
          );
      if (mounted) {
        final profile = ref.read(authControllerProvider).value;
        if (profile != null) {
          context.go('/${profile.role.name}');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('পাসওয়ার্ড পরিবর্তন ব্যর্থ হয়েছে। অনুগ্রহ করে আবার চেষ্টা করুন।'),
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

    return PopScope(
      canPop: false, // Prevent going back without changing password
      child: Scaffold(
        appBar: AppBar(
          title: const Text(AppStrings.changePasswordRequiredTitle),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              tooltip: 'লগআউট',
              icon: const Icon(Icons.logout),
              onPressed: () =>
                  ref.read(authControllerProvider.notifier).signOut(),
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 12),
                  const Icon(
                    Icons.security_rounded,
                    size: 64,
                    color: AppColors.warning,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppStrings.changePasswordRequiredSubtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _newPassController,
                    obscureText: _obscureNewPass,
                    decoration: InputDecoration(
                      labelText: AppStrings.newPasswordLabel,
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureNewPass
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                        onPressed: () =>
                            setState(() => _obscureNewPass = !_obscureNewPass),
                      ),
                    ),
                    validator: (val) {
                      return validateNewPassword(
                        password: val,
                        mobile: _resolveUserMobile(),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmPassController,
                    obscureText: _obscureConfirmPass,
                    decoration: InputDecoration(
                      labelText: AppStrings.confirmPasswordLabel,
                      prefixIcon: const Icon(Icons.lock_reset_rounded),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPass
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                        onPressed: () => setState(
                            () => _obscureConfirmPass = !_obscureConfirmPass),
                      ),
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return AppStrings.fieldRequired;
                      }
                      if (val != _newPassController.text) {
                        return AppStrings.passwordsDoNotMatch;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handlePasswordChange,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(AppStrings.updatePasswordButton),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
