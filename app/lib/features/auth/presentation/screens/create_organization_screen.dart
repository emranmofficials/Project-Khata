import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../controllers/auth_controller.dart';

class CreateOrganizationScreen extends ConsumerWidget {
  const CreateOrganizationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.createOrganizationTitle),
        backgroundColor: AppColors.contractorNavy,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'লগআউট',
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.contractorNavy.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.business_rounded,
                  size: 72,
                  color: AppColors.contractorNavy,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                AppStrings.createOrganizationTitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.contractorNavy,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                AppStrings.createOrganizationNotice,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 36),
              OutlinedButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text('লগআউট করুন'),
                onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
