import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/bengali_formatter.dart';
import '../../../auth/domain/models/app_user.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../users/presentation/widgets/create_member_dialog.dart';
import '../../../projects/domain/models/project.dart';
import '../../../projects/presentation/controllers/project_controller.dart';
import '../../../notifications/presentation/widgets/notification_badge_button.dart';

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
        actions: const [
          NotificationBadgeButton(color: Colors.white),
        ],
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
      floatingActionButton: _currentIndex == 1
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/create-project'),
              backgroundColor: AppColors.contractorNavy,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add_business_rounded),
              label: const Text('নতুন প্রজেক্ট তৈরি'),
            )
          : _currentIndex == 2
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
                  value: BengaliFormatter.toBnNumber(
                    ref.watch(projectsListProvider).valueOrNull?.length ?? 0,
                  ),
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
    final projectsAsync = ref.watch(projectsListProvider);

    return projectsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded,
                  size: 48, color: AppColors.error),
              const SizedBox(height: 12),
              Text('প্রজেক্ট লোড করতে ব্যর্থ: $e',
                  textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => ref.invalidate(projectsListProvider),
                icon: const Icon(Icons.refresh),
                label: const Text('পুনরায় চেষ্টা করুন'),
              ),
            ],
          ),
        ),
      ),
      data: (projects) {
        if (projects.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.business_center_outlined,
                    size: 72,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'কোনো প্রজেক্ট পাওয়া যায়নি',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'নতুন কনস্ট্রাকশন বা সাইট প্রজেক্ট যুক্ত করতে নিচের বাটনে চাপুন।',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () => context.push('/create-project'),
                    icon: const Icon(Icons.add_business_rounded),
                    label: const Text('নতুন প্রজেক্ট তৈরি করুন'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.contractorNavy,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(projectsListProvider),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: projects.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, idx) {
              final p = projects[idx];
              return _buildProjectCard(p);
            },
          ),
        );
      },
    );
  }

  Widget _buildProjectCard(Project p) {
    Color statusColor = AppColors.contractorNavy;
    switch (p.status) {
      case ProjectStatus.active:
        statusColor = AppColors.success;
        break;
      case ProjectStatus.planned:
        statusColor = AppColors.info;
        break;
      case ProjectStatus.completed:
        statusColor = Colors.grey;
        break;
      case ProjectStatus.onHold:
        statusColor = AppColors.warning;
        break;
    }

    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/project-details', extra: p),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.name,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (p.address != null && p.address!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined,
                                  size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  p.address!,
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      p.status.displayName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.contractorNavy.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      p.type.displayName,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.contractorNavy,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    p.type == ProjectType.sqft
                        ? '${BengaliFormatter.toCurrency(p.ratePerSqft ?? 0)}/বর্গফুট'
                        : p.type == ProjectType.contract
                            ? 'বাজেট: ${BengaliFormatter.toCurrency(p.budget ?? 0)}'
                            : 'দৈনিক: ${BengaliFormatter.toCurrency(p.dailyWage ?? 0)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.contractorNavy,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.radar_rounded, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    'সাইট ব্যাসার্ধ: ${BengaliFormatter.toBnNumber(p.geofenceRadiusM)} মি.',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                  const Spacer(),
                  const Icon(Icons.arrow_forward_ios_rounded,
                      size: 14, color: Colors.grey),
                ],
              ),
            ],
          ),
        ),
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
    final projectsAsync = ref.watch(projectsListProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Quick Action for Worker Payments
        Card(
          elevation: 2,
          color: AppColors.contractorNavy,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.payment_rounded, color: Colors.white, size: 24),
                    SizedBox(width: 8),
                    Text(
                      'শ্রমিক মজুরি ও পেমেন্ট খাতা',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'শ্রমিকদের মজুরি পরিশোধ করুন। পূর্বের বকেয়া অনুযায়ী FIFO পদ্ধতিতে স্বয়ংক্রিয়ভাবে প্রজেক্টে বরাদ্দ হবে।',
                  style: TextStyle(fontSize: 13, color: Colors.white70),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.contractorNavy,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                    label: const Text(
                      'মজুরি প্রদান ও খাতা দেখুন',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onPressed: () => context.push('/organization-payments'),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Project Accounts Section
        const Text(
          'প্রজেক্ট ভিত্তিক হিসাব ও খতিয়ান',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        projectsAsync.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (err, _) => Center(child: Text('ত্রুটি: $err')),
          data: (projects) {
            if (projects.isEmpty) {
              return const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: Text(
                      'কোনো প্রজেক্ট পাওয়া যায়নি',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              );
            }

            return Column(
              children: projects.map((p) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.contractorNavy,
                      foregroundColor: Colors.white,
                      child: Icon(Icons.calculate_outlined),
                    ),
                    title: Text(
                      p.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          p.type == ProjectType.sqft
                              ? 'রেট: ${BengaliFormatter.toCurrency(p.ratePerSqft ?? 0)}/বর্গফুট'
                              : p.type == ProjectType.contract
                                  ? 'বাজেট: ${BengaliFormatter.toCurrency(p.budget ?? 0)}'
                                  : 'দৈনিক: ${BengaliFormatter.toCurrency(p.dailyWage ?? 0)}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.contractorNavy,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (p.clientName != null)
                          Text('ক্লায়েন্ট: ${p.clientName}',
                              style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                    onTap: () => context.push('/project-accounts', extra: p),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
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
