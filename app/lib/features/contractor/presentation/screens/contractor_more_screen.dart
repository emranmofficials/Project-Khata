import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../attendance/presentation/screens/contractor_approval_screen.dart';
import '../../../audit/presentation/screens/audit_log_screen.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/screens/change_password_screen.dart';
import '../../../notifications/presentation/screens/notifications_inbox_screen.dart';
import '../../../reports/presentation/screens/reports_screen.dart';

/// PRD সেকশন ৬.৬ (১) অনুযায়ী ঠিকাদারের 'আরও' (More) মেনু স্ক্রিন
class ContractorMoreScreen extends ConsumerWidget {
  const ContractorMoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('আরও সেটিংস ও নিয়ন্ত্রণ'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          children: [
            // প্রোফাইল ও প্রতিষ্ঠান কার্ড
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingMedium),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: AppColors.contractorPrimary.withOpacity(0.12),
                    child: const Icon(Icons.person, color: AppColors.contractorPrimary, size: 30),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? 'ঠিকাদার',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          user?.mobile ?? '',
                          style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'প্রধান ঠিকাদার ও প্রতিষ্ঠান স্বত্বাধিকারী',
                          style: TextStyle(fontSize: 11, color: AppColors.contractorPrimary, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // মূল মেনু আইটেমসমূহ
            _buildMenuSection(
              title: 'কার্যক্রম ও অনুমোদন',
              isDark: isDark,
              items: [
                _buildMenuItem(
                  icon: Icons.verified_user_outlined,
                  title: 'এন্ট্রি ও হাজিরা অনুমোদন',
                  subtitle: 'সাইটের বাইরে ও ব্যাকডেটেড হাজিরা নিষ্পত্তি',
                  badgeText: '৩টি অপেক্ষমাণ',
                  badgeColor: AppColors.warning,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ContractorApprovalScreen()),
                    );
                  },
                ),
                _buildMenuItem(
                  icon: Icons.notifications_none_rounded,
                  title: 'নোটিফিকেশন ও বার্তা',
                  subtitle: 'সাইটের গুরুত্বপূর্ণ নোটিফিকেশন ইনবক্স',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const NotificationsInboxScreen()),
                    );
                  },
                ),
                _buildMenuItem(
                  icon: Icons.analytics_outlined,
                  title: 'রিপোর্ট ও এক্সপোর্ট',
                  subtitle: 'দৈনিক, সাপ্তাহিক ও মাসিক PDF এবং Excel রিপোর্ট',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ReportsScreen()),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),

            _buildMenuSection(
              title: 'নিরাপত্তা ও নিরীক্ষা',
              isDark: isDark,
              items: [
                _buildMenuItem(
                  icon: Icons.history_edu_rounded,
                  title: 'অপরিবর্তনীয় অডিট লগ',
                  subtitle: 'প্রজেক্ট ও পেমেন্ট পরিবর্তনের সম্পূর্ণ ট্র্যাক রেকর্ড',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AuditLogScreen()),
                    );
                  },
                ),
                _buildMenuItem(
                  icon: Icons.lock_reset_rounded,
                  title: 'পাসওয়ার্ড পরিবর্তন',
                  subtitle: 'অ্যাকাউন্টের পাসওয়ার্ড আপডেট করুন',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ChangePasswordScreen(isMandatory: false),
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // লগআউট বোতাম
            OutlinedButton.icon(
              onPressed: () => ref.read(authStateProvider.notifier).signOut(),
              icon: const Icon(Icons.logout_rounded, color: AppColors.danger),
              label: const Text('লগআউট করুন', style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.danger),
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.buttonRadius)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSection({
    required String title,
    required bool isDark,
    required List<Widget> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Text(
            title,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.lightCard,
            borderRadius: BorderRadius.circular(AppSizes.cardRadius),
            border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
          ),
          child: Column(
            children: items,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    String? badgeText,
    Color? badgeColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: AppColors.contractorPrimary.withOpacity(0.08),
        child: Icon(icon, color: AppColors.contractorPrimary, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      trailing: badgeText != null
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: (badgeColor ?? AppColors.contractorPrimary).withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                badgeText,
                style: TextStyle(
                  color: badgeColor ?? AppColors.contractorPrimary,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : const Icon(Icons.chevron_right_rounded, color: Colors.grey),
    );
  }
}
