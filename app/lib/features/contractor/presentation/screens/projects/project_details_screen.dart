import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/contractor_routes.dart';
import '../../../../core/constants/contractor_strings.dart';
import '../../../../core/utils/bengali_formatter.dart';
import '../../../../widgets/contractor_widgets.dart';
import '../../contractor_providers.dart';
import '../../../domain/models/contractor_models.dart';

class ContractorProjectDetailsScreen extends ConsumerStatefulWidget {
  final String projectId;

  const ContractorProjectDetailsScreen({
    super.key,
    required this.projectId,
  });

  @override
  ConsumerState<ContractorProjectDetailsScreen> createState() => _ContractProjectDetailsScreenState();
}

class _ContractProjectDetailsScreenState extends ConsumerState<ContractorProjectDetailsScreen> {
  void _showStatusDialog(ProjectDetails project) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(ContractorStrings.changeProjectStatus),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ProjectStatus.values.map((status) {
            return ListTile(
              title: Text(status.displayName),
              leading: Icon(
                project.status == status ? Icons.radio_button_checked : Icons.radio_button_off,
                color: status.color,
              ),
              onTap: () async {
                Navigator.pop(ctx);
                final repo = ref.read(contractorRepositoryProvider);
                await repo.updateProjectStatus(project.id, status);
                ref.invalidate(projectDetailsProvider(project.id));
                ref.invalidate(projectsProvider(null));
                ref.invalidate(dashboardSummaryProvider);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showAssignSupervisorSheet(ProjectDetails project) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Consumer(
          builder: (context, ref, _) {
            final supervisorsAsync = ref.watch(membersProvider(MemberRole.supervisor));

            return Container(
              padding: const EdgeInsets.all(20),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.6,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    ContractorStrings.assignSupervisor,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: supervisorsAsync.when(
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (_, __) => Center(child: Text(ContractorStrings.errorOccurred)),
                      data: (supervisors) {
                        if (supervisors.isEmpty) {
                          return const Center(child: Text('কোনো সুপারভাইজার পাওয়া যায়নি'));
                        }
                        return ListView.builder(
                          itemCount: supervisors.length,
                          itemBuilder: (context, idx) {
                            final sup = supervisors[idx];
                            final isAssigned = project.supervisors.any((s) => s.supervisorId == sup.id);

                            return ListTile(
                              leading: const CircleAvatar(
                                backgroundColor: AppColors.contractorNavy,
                                child: Icon(Icons.person, color: Colors.white),
                              ),
                              title: Text(sup.name),
                              subtitle: Text(toBn(sup.mobile)),
                              trailing: isAssigned
                                  ? const Icon(Icons.check_circle, color: Colors.green)
                                  : OutlinedButton(
                                      onPressed: () async {
                                        Navigator.pop(ctx);
                                        final repo = ref.read(contractorRepositoryProvider);
                                        await repo.assignSupervisor(project.id, sup.id);
                                        ref.invalidate(projectDetailsProvider(project.id));
                                        ref.invalidate(membersProvider(MemberRole.supervisor));
                                      },
                                      child: const Text('যুক্ত করুন'),
                                    ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _confirmRemoveSupervisor(ProjectDetails project, SupervisorAssignment assignment) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(ContractorStrings.removeSupervisor),
        content: const Text(ContractorStrings.handoverWarningConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(ContractorStrings.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(ctx);
              final repo = ref.read(contractorRepositoryProvider);
              await repo.unassignSupervisor(project.id, assignment.supervisorId);
              ref.invalidate(projectDetailsProvider(project.id));
              ref.invalidate(approvalsProvider(null));
              ref.invalidate(dashboardSummaryProvider);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('সুপারভাইজার সরানো হয়েছে। অসমাপ্ত এন্ট্রি হস্তান্তর প্রয়োজন হিসেবে চিহ্নিত হয়েছে।'),
                  ),
                );
              }
            },
            child: const Text('হ্যাঁ, সরান'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final projectAsync = ref.watch(projectDetailsProvider(widget.projectId));

    return projectAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(e.toString()),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => ref.invalidate(projectDetailsProvider(widget.projectId)),
                child: const Text(ContractorStrings.retry),
              ),
            ],
          ),
        ),
      ),
      data: (project) {
        return Scaffold(
          appBar: AppBar(
            title: Text(project.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => context.push(ContractorRoutes.projectEditPath(project.id)),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ১. হিরো কার্ড (নাম, স্ট্যাটাস, অগ্রগতি)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    project.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'ধরন: ${project.type.displayName}',
                                    style: TextStyle(color: Colors.grey.shade600),
                                  ),
                                ],
                              ),
                            ),
                            InkWell(
                              onTap: () => _showStatusDialog(project),
                              borderRadius: BorderRadius.circular(12),
                              child: StatusChip(
                                label: '${project.status.displayName} ▾',
                                color: project.status.color,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (project.budget != null) ...[
                          Text(
                            BengaliFormatter.toCurrency(project.budget!),
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.contractorNavy,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'মোট প্রজেক্ট বাজেট',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // কভার ছবি প্লেসহোল্ডার
                Container(
                  width: double.infinity,
                  height: 140,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate_outlined, size: 36, color: Colors.grey.shade500),
                        const SizedBox(height: 6),
                        Text(
                          'প্রজেক্ট কভার ছবি (পরের ধাপে যুক্ত হবে)',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ২. ক্লায়েন্ট কার্ড (নাম, মোবাইল, কল ও মেসেজ)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          ContractorStrings.clientInfoTitle,
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const CircleAvatar(
                              backgroundColor: AppColors.contractorNavy,
                              child: Icon(Icons.person, color: Colors.white),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    project.client.name,
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    toBn(project.client.mobile),
                                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                            IconButton.filledTonal(
                              icon: const Icon(Icons.call_rounded),
                              tooltip: ContractorStrings.callClient,
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('${project.client.name}-কে কল করা হচ্ছে...')),
                                );
                              },
                            ),
                            const SizedBox(width: 6),
                            IconButton.filledTonal(
                              icon: const Icon(Icons.message_rounded),
                              tooltip: ContractorStrings.messageClient,
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('${project.client.name}-কে মেসেজ পাঠানো হচ্ছে...')),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ৩. সাইট লোকেশন ও জিও-ফেন্স
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.location_on_rounded, color: AppColors.contractorNavy),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                project.address,
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'জিও-ফেন্স রেডিয়াস: ${toBn(project.geofenceRadiusM)} ${ContractorStrings.metersUnit} (সাইট সীমার মধ্যে উপস্থিতি বৈধ)',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ৪. দায়িত্বরত সুপারভাইজার তালিকা
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      ContractorStrings.supervisorsTitle,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('যুক্ত করুন'),
                      onPressed: () => _showAssignSupervisorSheet(project),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (project.supervisors.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: Text(
                          ContractorStrings.noSupervisorsAssigned,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  )
                else
                  ...project.supervisors.map((s) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFC2410C),
                          child: Icon(Icons.shield, color: Colors.white, size: 20),
                        ),
                        title: Text(s.supervisorName),
                        subtitle: Text(toBn(s.supervisorMobile)),
                        trailing: IconButton(
                          icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                          tooltip: ContractorStrings.removeSupervisor,
                          onPressed: () => _confirmRemoveSupervisor(project, s),
                        ),
                      ),
                    );
                  }),

                const SizedBox(height: 16),

                // ৫. বিল খতিয়ান অ্যাকশন বাটন
                FilledButton.icon(
                  onPressed: () {
                    context.push(ContractorRoutes.billStatements);
                  },
                  icon: const Icon(Icons.receipt_long_rounded),
                  label: const Text(ContractorStrings.billStatement),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }
}
