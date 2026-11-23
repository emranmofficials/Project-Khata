import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../../core/widgets/loading_skeleton.dart';
import '../providers/project_provider.dart';
import '../widgets/project_card.dart';
import 'new_project_screen.dart';
import 'project_details_screen.dart';

/// PRD সেকশন ৬.৩ (১) অনুযায়ী প্রজেক্ট তালিকা স্ক্রিন
class ProjectListScreen extends ConsumerWidget {
  const ProjectListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(projectsListProvider);
    final currentFilter = ref.watch(projectStatusFilterProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('প্রজেক্টসমূহ'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const NewProjectScreen()),
          );
        },
        backgroundColor: AppColors.contractorPrimary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'নতুন প্রজেক্ট',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // অনুসন্ধান বার
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              onChanged: (query) {
                ref.read(projectSearchQueryProvider.notifier).state = query;
              },
              decoration: InputDecoration(
                hintText: 'প্রজেক্টের নাম অনুসন্ধান করুন...',
                prefixIcon: const Icon(Icons.search_rounded),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                fillColor: isDark ? AppColors.darkCard : AppColors.lightCard,
              ),
            ),
          ),

          // স্ট্যাটাস ফিল্টার চিপস
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                _buildFilterChip(context, ref, 'all', 'সব', currentFilter),
                const SizedBox(width: 8),
                _buildFilterChip(context, ref, 'active', 'চলমান', currentFilter),
                const SizedBox(width: 8),
                _buildFilterChip(context, ref, 'planned', 'পরিকল্পনা', currentFilter),
                const SizedBox(width: 8),
                _buildFilterChip(context, ref, 'completed', 'সম্পন্ন', currentFilter),
                const SizedBox(width: 8),
                _buildFilterChip(context, ref, 'on_hold', 'স্থগিত', currentFilter),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // প্রজেক্ট তালিকা
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(projectsListProvider);
              },
              child: projectsAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(AppSizes.paddingMedium),
                  child: LoadingSkeletonList(count: 5, itemHeight: 100),
                ),
                error: (error, _) => EmptyStateView(
                  icon: Icons.error_outline_rounded,
                  title: 'ডাটা লোড করতে সমস্যা হয়েছে',
                  subtitle: error.toString(),
                  buttonLabel: AppStrings.retry,
                  isError: true,
                  onButtonPressed: () => ref.invalidate(projectsListProvider),
                ),
                data: (projects) {
                  if (projects.isEmpty) {
                    return EmptyStateView(
                      icon: Icons.apartment_outlined,
                      title: 'এখনো কোনো প্রজেক্ট নেই',
                      subtitle: 'নতুন প্রজেক্ট তৈরি করতে নিচের বাটনে চাপ দিন',
                      buttonLabel: 'নতুন প্রজেক্ট তৈরি করুন',
                      onButtonPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const NewProjectScreen()),
                        );
                      },
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(AppSizes.paddingMedium),
                    itemCount: projects.length,
                    itemBuilder: (context, index) {
                      final project = projects[index];
                      return ProjectCard(
                        project: project,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ProjectDetailsScreen(projectId: project.id),
                            ),
                          );
                        },
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

  Widget _buildFilterChip(
    BuildContext context,
    WidgetRef ref,
    String value,
    String label,
    String currentFilter,
  ) {
    final isSelected = currentFilter == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          ref.read(projectStatusFilterProvider.notifier).state = value;
        }
      },
      selectedColor: AppColors.contractorPrimary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : null,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 13,
      ),
    );
  }
}
