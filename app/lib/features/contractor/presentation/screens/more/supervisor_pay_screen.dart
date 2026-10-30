import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_khata/core/constants/app_colors.dart';
import 'package:project_khata/core/constants/contractor_strings.dart';
import 'package:project_khata/widgets/contractor_widgets.dart';
import '../../contractor_providers.dart';
import '../../../domain/models/contractor_models.dart';

typedef SupervisorPaySettingsScreen = SupervisorPayScreen;

class SupervisorPayScreen extends ConsumerWidget {
  const SupervisorPayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supervisorsAsync = ref.watch(membersProvider(MemberRole.supervisor));

    return Scaffold(
      appBar: AppBar(
        title: const Text(ContractorStrings.supervisorPaySettings),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // গুরুত্বপূর্ণ নিয়ম নোটিশ
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.contractorNavy, size: 28),
                  SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'PRD নিয়ম: সুপারভাইজারের কোনো মাসিক বেতন বা স্থায়ী ভাতা ব্যবস্থা নেই। সুপারভাইজারও উপস্থিতির ভিত্তিতে দৈনিক মজুরি পান। উপস্থিত না থাকলে মজুরি কাটা যাবে।',
                      style: TextStyle(fontSize: 13, color: AppColors.contractorNavy, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'সুপারভাইজারদের দৈনিক মজুরি হার',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            supervisorsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text(e.toString())),
              data: (supervisors) {
                if (supervisors.isEmpty) {
                  return const EmptyState(
                    icon: Icons.shield_outlined,
                    title: 'কোনো সুপারভাইজার পাওয়া যায়নি',
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: supervisors.length,
                  itemBuilder: (context, idx) {
                    final sup = supervisors[idx];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFC2410C),
                          child: Icon(Icons.shield, color: Colors.white, size: 20),
                        ),
                        title: Text(sup.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('মোবাইল: ${toBn(sup.mobile)} • প্রজেক্ট: ${toBn(sup.assignedProjectsCount)}টি'),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '৳ ${toBn(sup.dailyWage.round())}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            const Text('/দিন', style: TextStyle(fontSize: 10, color: Colors.grey)),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
