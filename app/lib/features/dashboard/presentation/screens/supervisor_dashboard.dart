import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/bengali_formatter.dart';
import '../../../auth/domain/models/app_user.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../projects/presentation/controllers/project_controller.dart';
import 'package:go_router/go_router.dart';

class SupervisorDashboard extends ConsumerStatefulWidget {
  const SupervisorDashboard({super.key});

  @override
  ConsumerState<SupervisorDashboard> createState() =>
      _SupervisorDashboardState();
}

class _SupervisorDashboardState extends ConsumerState<SupervisorDashboard> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider).value;

    final tabs = [
      _buildProjectsTab(user),
      _buildEntriesTab(),
      _buildTeamsTab(),
      _buildAccountsTab(),
      _buildProfileTab(user),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitleForIndex(_currentIndex)),
        backgroundColor: AppColors.supervisorAmber,
        foregroundColor: Colors.white,
      ),
      body: tabs[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        indicatorColor: AppColors.supervisorAmber.withValues(alpha: 0.15),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.folder_outlined),
            selectedIcon: Icon(Icons.folder, color: AppColors.supervisorAmber),
            label: AppStrings.tabProjects,
          ),
          NavigationDestination(
            icon: Icon(Icons.edit_note_outlined),
            selectedIcon: Icon(Icons.edit_note, color: AppColors.supervisorAmber),
            label: AppStrings.tabEntries,
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups, color: AppColors.supervisorAmber),
            label: AppStrings.tabTeams,
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet,
                color: AppColors.supervisorAmber),
            label: AppStrings.tabAccounts,
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: AppColors.supervisorAmber),
            label: AppStrings.tabProfile,
          ),
        ],
      ),
    );
  }

  String _getTitleForIndex(int index) {
    switch (index) {
      case 0:
        return 'অ্যাসাইনড প্রজেক্ট';
      case 1:
        return AppStrings.tabEntries;
      case 2:
        return AppStrings.tabTeams;
      case 3:
        return AppStrings.tabAccounts;
      case 4:
        return AppStrings.tabProfile;
      default:
        return AppStrings.appNameBangla;
    }
  }

  Widget _buildProjectsTab(UserProfile? user) {
    final projectsAsync = ref.watch(projectsListProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            color: AppColors.supervisorAmber,
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
                    'আপনার দায়িত্বপ্রাপ্ত প্রজেক্টে দৈনিক এন্ট্রি ও শ্রমিকের হাজিরা দিন।',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'অ্যাসাইন করা প্রজেক্টসমূহ',
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
                child: Column(
                  children: [
                    Text('প্রজেক্ট লোড করতে ব্যর্থ: $e',
                        textAlign: TextAlign.center),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(projectsListProvider),
                      child: const Text('পুনরায় চেষ্টা করুন'),
                    ),
                  ],
                ),
              ),
            ),
            data: (projects) {
              if (projects.isEmpty) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(
                      child: Text(
                        'বর্তমানে আপনার কোনো প্রজেক্টে অ্যাসাইনমেন্ট নেই।\nঠিকাদার আপনাকে প্রজেক্টে যুক্ত করলে এখানে দেখতে পাবেন।',
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
                                    color: AppColors.supervisorAmber,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                backgroundColor: AppColors.supervisorAmber
                                    .withValues(alpha: 0.1),
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
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.radar,
                                  size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                'সাইট রেডিয়াস: ${BengaliFormatter.toBnNumber(p.geofenceRadiusM)} মি.',
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.supervisorAmber,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              icon: const Icon(Icons.edit_note, size: 18),
                              label: const Text('আজকের দৈনিক এন্ট্রি ও হাজিরা'),
                              onPressed: () => context.push('/daily-entry', extra: p.id),
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

  Widget _buildEntriesTab() {
    final projectsAsync = ref.watch(projectsListProvider);

    return projectsAsync.when(
      data: (projects) {
        if (projects.isEmpty) {
          return const Center(
            child: Text(
              'কোনো প্রজেক্ট নেই। অ্যাসাইন হওয়ার পর এন্ট্রি দিতে পারবেন।',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'দৈনিক এন্ট্রি দিতে প্রজেক্ট নির্বাচন করুন:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...projects.map((p) => Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.supervisorAmber,
                      child: Icon(Icons.edit_document, color: Colors.white, size: 20),
                    ),
                    title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(p.address ?? 'ঠিকানা নির্ধারিত হয়নি'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => context.push('/daily-entry', extra: p.id),
                  ),
                )),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('ত্রুটি: $err')),
    );
  }

  Widget _buildTeamsTab() {
    return const Center(
      child: Text(
        'দল গঠন ও হাজিরা\n(ফেজ ৩-এ চালু হবে)',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.grey),
      ),
    );
  }

  Widget _buildAccountsTab() {
    final projectsAsync = ref.watch(projectsListProvider);

    return projectsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('ত্রুটি: $err')),
      data: (projects) {
        if (projects.isEmpty) {
          return const Center(
            child: Text(
              'কোনো প্রজেক্ট অ্যাসাইন করা নেই।',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'সাইট খরচ, মালামাল ও মজুরি হিসাব:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...projects.map((p) => Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.supervisorAmber,
                      foregroundColor: Colors.white,
                      child: Icon(Icons.account_balance_wallet_outlined),
                    ),
                    title: Text(p.name,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
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

  Widget _buildProfileTab(UserProfile? user) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
        icon: const Icon(Icons.logout),
        label: const Text(AppStrings.logout),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.supervisorAmber,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
}
