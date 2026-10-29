import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/bengali_formatter.dart';
import '../../../auth/domain/models/app_user.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../users/presentation/widgets/create_member_dialog.dart';

class ContractorDashboard extends ConsumerStatefulWidget {
  const ContractorDashboard({super.key});

  @override
  ConsumerState<ContractorDashboard> createState() =>
      _ContractorDashboardState();
}

class _ContractorDashboardState extends ConsumerState<ContractorDashboard> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider).value;

    final tabs = [
      _buildOverviewTab(user),
      _buildProjectsTab(),
      _buildUsersTab(user),
      _buildAccountsTab(),
      _buildProfileTab(user),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitleForIndex(_currentIndex)),
        backgroundColor: AppColors.contractorNavy,
        foregroundColor: Colors.white,
      ),
      body: tabs[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        indicatorColor: AppColors.contractorNavy.withValues(alpha: 0.15),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard, color: AppColors.contractorNavy),
            label: AppStrings.tabDashboard,
          ),
          NavigationDestination(
            icon: Icon(Icons.folder_outlined),
            selectedIcon: Icon(Icons.folder, color: AppColors.contractorNavy),
            label: AppStrings.tabProjects,
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people, color: AppColors.contractorNavy),
            label: AppStrings.tabUsers,
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet,
                color: AppColors.contractorNavy),
            label: AppStrings.tabAccounts,
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: AppColors.contractorNavy),
            label: AppStrings.tabProfile,
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 2
          ? FloatingActionButton.extended(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => CreateMemberDialog(
                  onMemberCreated: () => setState(() {}),
                ),
              ),
              backgroundColor: AppColors.contractorNavy,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.person_add_rounded),
              label: const Text(AppStrings.addMember),
            )
          : null,
    );
  }

  String _getTitleForIndex(int index) {
    switch (index) {
      case 0:
        return '${AppStrings.appNameBangla} — ${AppStrings.tabDashboard}';
      case 1:
        return AppStrings.tabProjects;
      case 2:
        return 'ইউজার ব্যবস্থাপনা';
      case 3:
        return AppStrings.tabAccounts;
      case 4:
        return AppStrings.tabProfile;
      default:
        return AppStrings.appNameBangla;
    }
  }

  Widget _buildOverviewTab(UserProfile? user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Banner
          Card(
            color: AppColors.contractorNavy,
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
                    'আপনার প্রতিষ্ঠানের সকল প্রজেক্ট, হাজিরা ও হিসাব এখান থেকে পরিচালনা করুন।',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Quick Stats
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'চলমান প্রজেক্ট',
                  value: BengaliFormatter.toBnNumber(0),
                  icon: Icons.business_rounded,
                  color: AppColors.info,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  title: 'আজকের হাজিরা',
                  value: BengaliFormatter.toBnNumber(0),
                  icon: Icons.how_to_reg_rounded,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'মোট কর্মী',
                  value: BengaliFormatter.toBnNumber(0),
                  icon: Icons.groups_rounded,
                  color: AppColors.workerIndigo,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  title: 'আজকের এন্ট্রি',
                  value: BengaliFormatter.toBnNumber(0),
                  icon: Icons.edit_note_rounded,
                  color: AppColors.supervisorAmber,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.15),
              radius: 20,
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(fontSize: 13, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectsTab() {
    return const Center(
      child: Text(
        'কোনো প্রজেক্ট পাওয়া যায়নি।\n(ফেজ ২-এ প্রজেক্ট তৈরি যুক্ত হবে)',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.grey),
      ),
    );
  }

  Widget _buildUsersTab(UserProfile? user) {
    if (user == null) return const Center(child: CircularProgressIndicator());

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: Supabase.instance.client
          .from('profiles')
          .select()
          .eq('organization_id', user.organizationId)
          .order('created_at', ascending: false),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('ত্রুটি: ${snapshot.error}'));
        }
        final list = snapshot.data ?? [];
        if (list.isEmpty) {
          return const Center(
            child: Text(
              'কোনো ইউজার যুক্ত করা হয়নি।\nনিচের বাটন চেপে নতুন সদস্য যোগ করুন।',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, idx) {
            final profile = UserProfile.fromJson(list[idx]);
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      profile.role.brandColor.withValues(alpha: 0.2),
                  child: Icon(
                    Icons.person,
                    color: profile.role.brandColor,
                  ),
                ),
                title: Text(
                  profile.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${profile.role.displayName} • ${profile.mobile != null ? BengaliFormatter.toBnNumber(profile.mobile) : (profile.email ?? "")}',
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: Chip(
                  label: Text(
                    profile.status == 'active' ? 'সক্রিয়' : 'নিষ্ক্রিয়',
                    style: TextStyle(
                      fontSize: 11,
                      color: profile.status == 'active'
                          ? AppColors.success
                          : AppColors.error,
                    ),
                  ),
                  backgroundColor: (profile.status == 'active'
                          ? AppColors.success
                          : AppColors.error)
                      .withValues(alpha: 0.1),
                  side: BorderSide.none,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAccountsTab() {
    return const Center(
      child: Text(
        'হিসাব ও খতিয়ান\n(ফেজ ৪-এ পূর্ণাঙ্গ হিসাব চালু হবে)',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.grey),
      ),
    );
  }

  Widget _buildProfileTab(UserProfile? user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.contractorNavy.withValues(alpha: 0.15),
            child: const Icon(
              Icons.business_center_rounded,
              size: 44,
              color: AppColors.contractorNavy,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user?.name ?? '',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            user?.email ?? '',
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Chip(
            label: Text(user?.role.displayName ?? ''),
            backgroundColor: AppColors.contractorNavy.withValues(alpha: 0.1),
          ),
          const SizedBox(height: 32),
          ListTile(
            leading: const Icon(Icons.lock_reset_rounded),
            title: const Text('পাসওয়ার্ড পরিবর্তন'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // open change password
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: AppColors.error),
            title: const Text(
              AppStrings.logout,
              style: TextStyle(color: AppColors.error),
            ),
            onTap: () async {
              await ref.read(authControllerProvider.notifier).signOut();
            },
          ),
        ],
      ),
    );
  }
}
