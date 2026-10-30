import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/contractor_routes.dart';
import '../../../../core/constants/contractor_strings.dart';
import '../../../../widgets/contractor_widgets.dart';
import '../../contractor_providers.dart';
import '../../../domain/models/contractor_models.dart';

class WorkersScreen extends ConsumerStatefulWidget {
  const WorkersScreen({super.key});

  @override
  ConsumerState<WorkersScreen> createState() => _WorkersScreenState();
}

class _WorkersScreenState extends ConsumerState<WorkersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedDesignationId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWorkerTab = _tabController.index == 0;
    final designationsAsync = ref.watch(designationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(ContractorStrings.workersTab),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'শ্রমিক তালিকা'),
            Tab(text: 'সুপারভাইজার তালিকা'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (isWorkerTab) {
            context.push(ContractorRoutes.workerNew);
          } else {
            context.push(ContractorRoutes.supervisorNew);
          }
        },
        icon: const Icon(Icons.person_add_rounded),
        label: Text(
          isWorkerTab ? ContractorStrings.addNewWorker : ContractorStrings.addNewSupervisor,
        ),
      ),
      body: Column(
        children: [
          // অনুসন্ধান বার
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: isWorkerTab ? 'শ্রমিক খুঁজুন...' : 'সুপারভাইজার খুঁজুন...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),

          // শুধু শ্রমিক ট্যাবে পদ অনুযায়ী ফিল্টার চিপস
          if (isWorkerTab)
            designationsAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (designations) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text('সব পদ'),
                        selected: _selectedDesignationId == null,
                        onSelected: (sel) {
                          if (sel) setState(() => _selectedDesignationId = null);
                        },
                      ),
                      const SizedBox(width: 8),
                      ...designations.map((d) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: FilterChip(
                            label: Text(d.name),
                            selected: _selectedDesignationId == d.id,
                            onSelected: (sel) {
                              setState(() => _selectedDesignationId = sel ? d.id : null);
                            },
                          ),
                        );
                      }),
                    ],
                  ),
                );
              },
            ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMemberList(MemberRole.worker),
                _buildMemberList(MemberRole.supervisor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberList(MemberRole role) {
    final membersAsync = ref.watch(membersProvider(role));

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(membersProvider(role)),
      child: membersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(ContractorStrings.errorOccurred)),
        data: (allMembers) {
          var members = allMembers;

          if (role == MemberRole.worker && _selectedDesignationId != null) {
            // Filter by designation
          }

          if (_searchQuery.isNotEmpty) {
            final q = _searchQuery.toLowerCase();
            members = members.where((m) {
              return m.name.toLowerCase().contains(q) ||
                  m.mobile.contains(q) ||
                  m.designationName.toLowerCase().contains(q);
            }).toList();
          }

          if (members.isEmpty) {
            return ListView(
              children: [
                const SizedBox(height: 60),
                EmptyState(
                  icon: role == MemberRole.worker ? Icons.engineering_rounded : Icons.shield_rounded,
                  title: ContractorStrings.emptyList,
                  subtitle: role == MemberRole.worker
                      ? 'নতুন শ্রমিক যুক্ত করতে নিচের বাটনে ট্যাপ করুন'
                      : 'নতুন সুপারভাইজার যুক্ত করতে নিচের বাটনে ট্যাপ করুন',
                ),
              ],
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: members.length,
            itemBuilder: (context, index) {
              final m = members[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  onTap: () {
                    if (role == MemberRole.worker) {
                      context.push(ContractorRoutes.workerDetailsPath(m.id));
                    } else {
                      context.push(ContractorRoutes.supervisorDetailsPath(m.id));
                    }
                  },
                  leading: CircleAvatar(
                    backgroundColor: role == MemberRole.worker
                        ? AppColors.contractorNavy
                        : const Color(0xFFC2410C),
                    child: Icon(
                      role == MemberRole.worker ? Icons.person : Icons.shield,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          m.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: m.isActive ? Colors.green : Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        m.isActive ? ContractorStrings.activeBadge : ContractorStrings.inactiveBadge,
                        style: TextStyle(
                          fontSize: 10,
                          color: m.isActive ? Colors.green : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 2),
                      Text('${m.designationName} • ${toBn(m.mobile)}'),
                      if (role == MemberRole.supervisor)
                        Text(
                          'অ্যাসাইন করা প্রজেক্ট: ${toBn(m.assignedProjectsCount)}টি',
                          style: const TextStyle(fontSize: 11, color: AppColors.contractorNavy),
                        ),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '৳ ${toBn(m.dailyWage.round())}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const Text(
                        '/দিন',
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
