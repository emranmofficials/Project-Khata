import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_khata/core/constants/app_colors.dart';
import 'package:project_khata/core/constants/contractor_strings.dart';
import 'package:project_khata/core/utils/bengali_formatter.dart';
import 'package:project_khata/widgets/contractor_widgets.dart';
import '../../contractor_providers.dart';
import '../../../domain/models/contractor_models.dart';

class WorkerDetailsScreen extends ConsumerWidget {
  final String workerId;

  const WorkerDetailsScreen({
    super.key,
    required this.workerId,
  });

  void _showEditDialog(BuildContext context, WidgetRef ref, MemberDetails worker) {
    final nameController = TextEditingController(text: worker.name);
    final wageController = TextEditingController(text: worker.dailyWage.toStringAsFixed(0));
    final mobileController = TextEditingController(text: worker.mobile);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('শ্রমিক তথ্য সম্পাদনা'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('নাম', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              TextField(controller: nameController),
              const SizedBox(height: 12),
              if (!worker.hasLoggedIn) ...[
                const Text('মোবাইল নম্বর (লগইনের পূর্বে পরিবর্তনযোগ্য)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 6),
                TextField(controller: mobileController),
                const SizedBox(height: 12),
              ],
              const Text('দৈনিক মজুরি (৳)', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              TextField(
                controller: wageController,
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('বাতিল'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final repo = ref.read(contractorRepositoryProvider);
              await repo.updateMember(
                worker.id,
                name: nameController.text.trim(),
                dailyWage: double.tryParse(wageController.text.trim()),
              );
              ref.invalidate(memberDetailsProvider(worker.id));
              ref.invalidate(membersProvider(MemberRole.worker));
            },
            child: const Text('সংরক্ষণ'),
          ),
        ],
      ),
    );
  }

  void _confirmDeactivate(BuildContext context, WidgetRef ref, MemberDetails worker) {
    final isActivating = !worker.isActive;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isActivating ? 'সক্রিয় করুন' : 'নিষ্ক্রিয় করুন'),
        content: Text(
          isActivating
              ? '${worker.name}-কে পুনরায় সক্রিয় করতে চান?'
              : '${worker.name}-কে নিষ্ক্রিয় করতে চান? (পূর্বের কোনো ঐতিহাসিক ডেটা মুছবে না)',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('না'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final repo = ref.read(contractorRepositoryProvider);
              await repo.setMemberActive(worker.id, isActivating);
              ref.invalidate(memberDetailsProvider(worker.id));
              ref.invalidate(membersProvider(MemberRole.worker));
            },
            child: const Text('হ্যাঁ'),
          ),
        ],
      ),
    );
  }

  void _confirmResetPassword(BuildContext context, WidgetRef ref, MemberDetails worker) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('পাসওয়ার্ড রিসেট'),
        content: const Text(
          'পাসওয়ার্ড রিসেট করলে প্রাথমিক পাসওয়ার্ড মোবাইলের শেষ ৬ সংখ্যায় ফেরত যাবে এবং পরবর্তী লগইনে পরিবর্তন বাধ্যতামূলক হবে। আপনি কি নিশ্চিত?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('বাতিল'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final repo = ref.read(contractorRepositoryProvider);
              await repo.resetMemberPassword(worker.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text(ContractorStrings.resetPasswordSuccess)),
                );
              }
            },
            child: const Text('রিসেট করুন'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workerAsync = ref.watch(memberDetailsProvider(workerId));

    return workerAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(e.toString())),
      ),
      data: (worker) {
        return Scaffold(
          appBar: AppBar(
            title: Text(worker.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: ContractorStrings.editMember,
                onPressed: () => _showEditDialog(context, ref, worker),
              ),
              PopupMenuButton<String>(
                onSelected: (val) {
                  if (val == 'deactivate') {
                    _confirmDeactivate(context, ref, worker);
                  } else if (val == 'reset') {
                    _confirmResetPassword(context, ref, worker);
                  }
                },
                itemBuilder: (ctx) => [
                  PopupMenuItem(
                    value: 'deactivate',
                    child: Text(worker.isActive ? 'নিষ্ক্রিয় করুন' : 'সক্রিয় করুন'),
                  ),
                  const PopupMenuItem(
                    value: 'reset',
                    child: Text(ContractorStrings.resetPassword),
                  ),
                ],
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // প্রোফাইল হেডার কার্ড
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 28,
                          backgroundColor: AppColors.contractorNavy,
                          child: Icon(Icons.engineering_rounded, color: Colors.white, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                worker.name,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${worker.designationName} • ${toBn(worker.mobile)}',
                                style: const TextStyle(fontSize: 13, color: Colors.grey),
                              ),
                              const SizedBox(height: 6),
                              StatusChip(
                                label: worker.isActive ? 'সক্রিয় কর্মী' : 'নিষ্ক্রিয়',
                                color: worker.isActive ? const Color(0xFF2563EB) : Colors.grey,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // মেট্রিকস রো
                Row(
                  children: [
                    Expanded(
                      child: KpiCard(
                        title: ContractorStrings.dailyWage,
                        value: '৳ ${toBn(worker.dailyWage.round())}',
                        subtitle: 'ওভারটাইম: ৳ ${toBn(worker.overtimeRate.round())}/ঘণ্টা',
                        icon: Icons.payments_outlined,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: KpiCard(
                        title: ContractorStrings.totalPresentDays,
                        value: '${toBn(worker.totalPresentDays)} দিন',
                        subtitle: 'বকেয়া: ৳ ${toBn(worker.pendingWages.round())}',
                        icon: Icons.event_available_rounded,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // হাজিরার ইতিহাস
                const Text(
                  ContractorStrings.attendanceHistory,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (worker.attendanceHistory.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(
                        child: Text(
                          'সাম্প্রতিক কোনো হাজিরার ইতিহাস পাওয়া যায়নি',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  )
                else
                  ...worker.attendanceHistory.map((att) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: const Icon(Icons.check_circle_outline, color: Color(0xFF2563EB)),
                        title: Text(att.projectName),
                        subtitle: Text(
                          '${toBn(att.workDate.day)}/${toBn(att.workDate.month)}/${toBn(att.workDate.year)} • ওভারটাইম: ${toBn(att.overtimeHours.round())} ঘণ্টা',
                        ),
                        trailing: Text(
                          BengaliFormatter.toCurrency(att.earnedAmount),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
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
