import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_khata/core/constants/app_colors.dart';
import 'package:project_khata/core/constants/contractor_strings.dart';
import 'package:project_khata/widgets/contractor_widgets.dart';
import '../../contractor_providers.dart';
import '../../../domain/models/contractor_models.dart';

class SupervisorDetailsScreen extends ConsumerWidget {
  final String supervisorId;

  const SupervisorDetailsScreen({
    super.key,
    required this.supervisorId,
  });

  void _showAssignProjectsDialog(BuildContext context, WidgetRef ref, MemberDetails supervisor) {
    showDialog(
      context: context,
      builder: (ctx) => Consumer(
        builder: (context, ref, _) {
          final projectsAsync = ref.watch(projectsProvider(null));

          return AlertDialog(
            title: const Text('প্রজেক্টে অ্যাসাইন করুন'),
            content: SizedBox(
              width: double.maxFinite,
              child: projectsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => Center(child: Text(ContractorStrings.errorOccurred)),
                data: (projects) {
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: projects.length,
                    itemBuilder: (context, idx) {
                      final p = projects[idx];
                      final isAssigned = supervisor.assignedProjects.contains(p.id);

                      return CheckboxListTile(
                        title: Text(p.name),
                        subtitle: Text(p.clientName),
                        value: isAssigned,
                        onChanged: (val) async {
                          final repo = ref.read(contractorRepositoryProvider);
                          if (val == true) {
                            await repo.assignSupervisor(p.id, supervisor.id);
                          } else {
                            await repo.unassignSupervisor(p.id, supervisor.id);
                          }
                          ref.invalidate(memberDetailsProvider(supervisor.id));
                          ref.invalidate(membersProvider(MemberRole.supervisor));
                          ref.invalidate(projectDetailsProvider(p.id));
                          ref.invalidate(approvalsProvider(null));
                        },
                      );
                    },
                  );
                },
              ),
            ),
            actions: [
              FilledButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('সম্পন্ন'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supAsync = ref.watch(memberDetailsProvider(supervisorId));

    return supAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(e.toString())),
      ),
      data: (supervisor) {
        return Scaffold(
          appBar: AppBar(
            title: Text(supervisor.name),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // সুপারভাইজার হেডার কার্ড
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 28,
                          backgroundColor: Color(0xFFC2410C),
                          child: Icon(Icons.shield_rounded, color: Colors.white, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                supervisor.name,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${supervisor.designationName} • ${toBn(supervisor.mobile)}',
                                style: const TextStyle(fontSize: 13, color: Colors.grey),
                              ),
                              const SizedBox(height: 6),
                              StatusChip(
                                label: supervisor.isActive ? 'সক্রিয় সুপারভাইজার' : 'নিষ্ক্রিয়',
                                color: supervisor.isActive ? Colors.green : Colors.grey,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // বেতন নোটিশ কার্ড
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFBFDBFE)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, size: 20, color: AppColors.contractorNavy),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          ContractorStrings.supervisorNoSalaryNotice,
                          style: const TextStyle(fontSize: 12, color: AppColors.contractorNavy),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // মেট্রিকস
                Row(
                  children: [
                    Expanded(
                      child: KpiCard(
                        title: ContractorStrings.dailyWage,
                        value: '৳ ${toBn(supervisor.dailyWage.round())}',
                        subtitle: 'ওভারটাইম: ৳ ${toBn(supervisor.overtimeRate.round())}/ঘণ্টা',
                        icon: Icons.payments_outlined,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: KpiCard(
                        title: ContractorStrings.totalPresentDays,
                        value: '${toBn(supervisor.totalPresentDays)} দিন',
                        subtitle: 'অ্যাসাইনড: ${toBn(supervisor.assignedProjects.length)}টি প্রজেক্ট',
                        icon: Icons.event_available_rounded,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // অ্যাসাইন করা প্রজেক্ট তালিকা
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'দায়িত্বরত প্রজেক্ট সমূহ',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('পরিবর্তন'),
                      onPressed: () => _showAssignProjectsDialog(context, ref, supervisor),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (supervisor.assignedProjects.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: Text(
                          'বর্তমানে কোনো প্রজেক্টে অ্যাসাইন করা নেই',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  )
                else
                  ...supervisor.assignedProjects.map((pId) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: const Icon(Icons.apartment_rounded, color: AppColors.contractorNavy),
                        title: Text(pId == 'proj-1' ? 'মেঘনা ভিউ রেসিডেন্স' : (pId == 'proj-2' ? 'কর্ণফুলী কমপ্লেক্স' : 'পদ্মা সেতু সাইট')),
                        trailing: const Icon(Icons.check_circle, color: Colors.green, size: 18),
                      ),
                    );
                  }),
              ],
            ),
          ),
        );
      },
    );
  }
}
