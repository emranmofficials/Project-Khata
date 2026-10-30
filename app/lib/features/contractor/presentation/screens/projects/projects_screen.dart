import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:project_khata/core/constants/app_colors.dart';
import 'package:project_khata/core/constants/contractor_routes.dart';
import 'package:project_khata/core/constants/contractor_strings.dart';
import 'package:project_khata/core/utils/bengali_formatter.dart';
import 'package:project_khata/widgets/contractor_widgets.dart';
import '../../contractor_providers.dart';
import '../../../domain/models/contractor_models.dart';

class ProjectsScreen extends ConsumerStatefulWidget {
  const ProjectsScreen({super.key});

  @override
  ConsumerState<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends ConsumerState<ProjectsScreen> {
  ProjectStatus? _selectedStatus;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final projectsAsync = ref.watch(projectsProvider(_selectedStatus));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          ContractorStrings.projects,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(ContractorRoutes.projectNew),
        backgroundColor: isDark ? const Color(0xFF93A8F4) : AppColors.contractorNavy,
        foregroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          ContractorStrings.createNewProject,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // সার্চ বার
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: ContractorStrings.searchProjects,
                prefixIcon: const Icon(Icons.search_rounded),
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

          // স্ট্যাটাস ফিল্টার চিপস
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                FilterChip(
                  label: const Text(ContractorStrings.allProjects),
                  selected: _selectedStatus == null,
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedStatus = null);
                  },
                ),
                const SizedBox(width: 8),
                ...ProjectStatus.values.map((status) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      label: Text(status.displayName),
                      selected: _selectedStatus == status,
                      onSelected: (selected) {
                        setState(() => _selectedStatus = selected ? status : null);
                      },
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // প্রজেক্ট তালিকা
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => ref.invalidate(projectsProvider(_selectedStatus)),
              child: projectsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(ContractorStrings.errorOccurred),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () => ref.invalidate(projectsProvider(_selectedStatus)),
                        child: const Text(ContractorStrings.retry),
                      ),
                    ],
                  ),
                ),
                data: (allProjects) {
                  final projects = _searchQuery.isEmpty
                      ? allProjects
                      : allProjects.where((p) {
                          final q = _searchQuery.toLowerCase();
                          return p.name.toLowerCase().contains(q) ||
                              p.clientName.toLowerCase().contains(q) ||
                              p.clientMobile.contains(q);
                        }).toList();

                  if (projects.isEmpty) {
                    return ListView(
                      children: [
                        const SizedBox(height: 80),
                        EmptyState(
                          icon: Icons.apartment_rounded,
                          title: ContractorStrings.emptyList,
                          subtitle: ContractorStrings.createProjectPrompt,
                          actionLabel: ContractorStrings.createNewProject,
                          onActionTap: () => context.push(ContractorRoutes.projectNew),
                        ),
                      ],
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: projects.length,
                    itemBuilder: (context, index) {
                      final p = projects[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          onTap: () => context.push(ContractorRoutes.projectDetailsPath(p.id)),
                          borderRadius: BorderRadius.circular(20),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: (isDark ? const Color(0xFF93A8F4) : AppColors.contractorNavy)
                                            .withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Icon(
                                        Icons.apartment_rounded,
                                        size: 24,
                                        color: isDark ? const Color(0xFF93A8F4) : AppColors.contractorNavy,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            p.name,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'ক্লায়েন্ট: ${p.clientName} (${toBn(p.clientMobile)})',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: isDark
                                                  ? AppColors.darkTextSecondary
                                                  : AppColors.lightTextSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    StatusChip(
                                      label: p.status.displayName,
                                      color: p.status.color,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                // প্রজেক্ট প্রগ্রেস বার
                                ProjectProgressBar(
                                  progress: p.status == ProjectStatus.completed ? 1.0 : 0.65,
                                  label: 'কাজের অগ্রগতি',
                                  percentageText: p.status == ProjectStatus.completed ? '১০০%' : '৬৫%',
                                  height: 6,
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        p.type.displayName,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                          color: isDark ? Colors.white70 : Colors.black87,
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.people_outline_rounded,
                                          size: 15,
                                          color: isDark ? Colors.white60 : Colors.grey.shade600,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${toBn(p.workerCount)} জন',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (p.budget != null) ...[
                                      const SizedBox(width: 14),
                                      Text(
                                        BengaliFormatter.toCurrency(p.budget!),
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: isDark ? const Color(0xFF93A8F4) : AppColors.contractorNavy,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
