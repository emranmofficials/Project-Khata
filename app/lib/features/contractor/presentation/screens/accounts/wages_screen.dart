import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/contractor_strings.dart';
import '../../../../core/utils/bengali_formatter.dart';
import '../../../../widgets/contractor_widgets.dart';
import '../../contractor_providers.dart';

class WagesScreen extends ConsumerStatefulWidget {
  const WagesScreen({super.key});

  @override
  ConsumerState<WagesScreen> createState() => _WagesScreenState();
}

class _WagesScreenState extends ConsumerState<WagesScreen> {
  String? _selectedProjectId;

  @override
  Widget build(BuildContext context) {
    final wagesAsync = ref.watch(wagesProvider(_selectedProjectId));
    final projectsAsync = ref.watch(projectsProvider(null));

    return Scaffold(
      appBar: AppBar(
        title: const Text(ContractorStrings.wagesTitle),
      ),
      body: Column(
        children: [
          // প্রজেক্ট ফিল্টার
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: projectsAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const SizedBox.shrink(),
              data: (projects) {
                return DropdownButtonFormField<String?>(
                  value: _selectedProjectId,
                  decoration: const InputDecoration(labelText: 'প্রজেক্ট অনুযায়ী ফিল্টার'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('সব প্রজেক্ট')),
                    ...projects.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name))),
                  ],
                  onChanged: (val) => setState(() => _selectedProjectId = val),
                );
              },
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => ref.invalidate(wagesProvider(_selectedProjectId)),
              child: wagesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text(ContractorStrings.errorOccurred)),
                data: (wages) {
                  if (wages.isEmpty) {
                    return ListView(
                      children: const [
                        SizedBox(height: 80),
                        EmptyState(
                          icon: Icons.payments_outlined,
                          title: ContractorStrings.emptyList,
                          subtitle: 'কোনো মজুরি রেকর্ড পাওয়া যায়নি',
                        ),
                      ],
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: wages.length,
                    itemBuilder: (context, idx) {
                      final w = wages[idx];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          title: Text(w.workerName, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(
                            '${w.designationName} • ${w.projectName}\nতারিখ: ${toBn(w.workDate.day)}/${toBn(w.workDate.month)} • ওটি: ${toBn(w.overtimeHours.round())} ঘণ্টা (৳${toBn(w.overtimeAmount.round())})',
                          ),
                          isThreeLine: true,
                          trailing: Text(
                            BengaliFormatter.toCurrency(w.totalEarned),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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
