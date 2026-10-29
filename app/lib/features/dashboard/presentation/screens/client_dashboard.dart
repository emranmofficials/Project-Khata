import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/bengali_formatter.dart';
import '../../../auth/domain/models/app_user.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../projects/domain/models/project.dart';
import '../../../projects/presentation/controllers/project_controller.dart';
import 'package:go_router/go_router.dart';

class ClientDashboard extends ConsumerStatefulWidget {
  const ClientDashboard({super.key});

  @override
  ConsumerState<ClientDashboard> createState() => _ClientDashboardState();
}

class _ClientDashboardState extends ConsumerState<ClientDashboard> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider).value;

    final tabs = [
      _buildDashboardTab(user),
      _buildMaterialsTab(),
      _buildBillsTab(),
      _buildProfileTab(user),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitleForIndex(_currentIndex)),
        backgroundColor: AppColors.clientTeal,
        foregroundColor: Colors.white,
      ),
      body: tabs[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        indicatorColor: AppColors.clientTeal.withValues(alpha: 0.15),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard, color: AppColors.clientTeal),
            label: AppStrings.tabDashboard,
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2, color: AppColors.clientTeal),
            label: AppStrings.tabMaterials,
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long, color: AppColors.clientTeal),
            label: AppStrings.tabBills,
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: AppColors.clientTeal),
            label: AppStrings.tabProfile,
          ),
        ],
      ),
    );
  }

  String _getTitleForIndex(int index) {
    switch (index) {
      case 0:
        return 'ক্লায়েন্ট ড্যাশবোর্ড';
      case 1:
        return AppStrings.tabMaterials;
      case 2:
        return AppStrings.tabBills;
      case 3:
        return AppStrings.tabProfile;
      default:
        return AppStrings.appNameBangla;
    }
  }

  Widget _buildDashboardTab(UserProfile? user) {
    final projectsAsync = ref.watch(projectsListProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            color: AppColors.clientTeal,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'স্বাগতম, ${user?.name ?? ""}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'আপনার প্রজেক্টের অগ্রগতি, মালামাল ও বিলের হিসাব এখান থেকে দেখুন।',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'আপনার প্রজেক্টসমূহ',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          projectsAsync.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (e, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text('প্রজেক্ট লোড করতে ব্যর্থ: $e'),
              ),
            ),
            data: (projects) {
              if (projects.isEmpty) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(
                      child: Text(
                        'কোনো সক্রিয় প্রজেক্ট যুক্ত নেই।\nঠিকাদার আপনার নামে প্রজেক্ট তৈরি করলে তা এখানে দেখতে পাবেন।',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                );
              }

              return Column(
                children: projects.map((p) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  p.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Chip(
                                label: Text(
                                  p.type.displayName,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.clientTeal,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                backgroundColor:
                                    AppColors.clientTeal.withValues(alpha: 0.1),
                                side: BorderSide.none,
                              ),
                            ],
                          ),
                          if (p.address != null && p.address!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              p.address!,
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                            ),
                          ],
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'শুরুর তারিখ: ${BengaliFormatter.toDate(p.startDate)}',
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey),
                              ),
                              Text(
                                p.type == ProjectType.sqft
                                    ? '${BengaliFormatter.toCurrency(p.ratePerSqft ?? 0)}/বর্গফুট'
                                    : p.type == ProjectType.contract
                                        ? 'বাজেট: ${BengaliFormatter.toCurrency(p.budget ?? 0)}'
                                        : 'দৈনিক: ${BengaliFormatter.toCurrency(p.dailyWage ?? 0)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.clientTeal,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.clientTeal,
                                side: const BorderSide(color: AppColors.clientTeal),
                              ),
                              icon: const Icon(Icons.receipt_long, size: 18),
                              label: const Text('হিসাব ও বিল খতিয়ান দেখুন'),
                              onPressed: () => context.push('/project-accounts', extra: p),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialsTab() {
    final projectsAsync = ref.watch(projectsListProvider);

    return projectsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('ত্রুটি: $err')),
      data: (projects) {
        if (projects.isEmpty) {
          return const Center(
            child: Text(
              'কোনো প্রজেক্ট যুক্ত নেই।',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'মালামালের খতিয়ান দেখতে প্রজেক্ট নির্বাচন করুন:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...projects.map((p) => Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.clientTeal,
                      foregroundColor: Colors.white,
                      child: Icon(Icons.inventory_2_outlined),
                    ),
                    title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(p.address ?? 'ঠিকানা নির্ধারিত হয়নি'),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                    onTap: () => context.push('/project-accounts', extra: p),
                  ),
                )),
          ],
        );
      },
    );
  }

  Widget _buildBillsTab() {
    final projectsAsync = ref.watch(projectsListProvider);

    return projectsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('ত্রুটি: $err')),
      data: (projects) {
        if (projects.isEmpty) {
          return const Center(
            child: Text(
              'কোনো প্রজেক্ট যুক্ত নেই।',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'বিল স্টেটমেন্ট ও প্রাপ্ত পেমেন্ট দেখতে প্রজেক্ট নির্বাচন করুন:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...projects.map((p) => Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.clientTeal,
                      foregroundColor: Colors.white,
                      child: Icon(Icons.receipt_long_outlined),
                    ),
                    title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      p.type == ProjectType.contract
                          ? 'বাজেট: ${BengaliFormatter.toCurrency(p.budget ?? 0)}'
                          : 'ধরণ: ${p.type.displayName}',
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                    onTap: () => context.push('/project-accounts', extra: p),
                  ),
                )),
          ],
        );
      },
    );
  }

  Widget _buildProfileTab(UserProfile? user) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
        icon: const Icon(Icons.logout),
        label: const Text(AppStrings.logout),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.clientTeal,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
}
