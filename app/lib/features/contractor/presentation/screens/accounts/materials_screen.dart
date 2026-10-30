import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/contractor_strings.dart';
import '../../../../core/utils/bengali_formatter.dart';
import '../../../../widgets/contractor_widgets.dart';
import '../../contractor_providers.dart';

class MaterialsScreen extends ConsumerStatefulWidget {
  const MaterialsScreen({super.key});

  @override
  ConsumerState<MaterialsScreen> createState() => _MaterialsScreenState();
}

class _MaterialsScreenState extends ConsumerState<MaterialsScreen> {
  String? _selectedProjectId;

  @override
  Widget build(BuildContext context) {
    final materialsAsync = ref.watch(materialsProvider(_selectedProjectId));
    final projectsAsync = ref.watch(projectsProvider(null));

    return Scaffold(
      appBar: AppBar(
        title: const Text(ContractorStrings.materialsTitle),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: projectsAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const SizedBox.shrink(),
              data: (projects) {
                return DropdownButtonFormField<String?>(
                  value: _selectedProjectId,
                  decoration: const InputDecoration(labelText: 'প্রজেক্ট নির্বাচন করুন'),
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
              onRefresh: () async => ref.invalidate(materialsProvider(_selectedProjectId)),
              child: materialsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text(ContractorStrings.errorOccurred)),
                data: (materials) {
                  if (materials.isEmpty) {
                    return ListView(
                      children: const [
                        SizedBox(height: 80),
                        EmptyState(
                          icon: Icons.inventory_2_outlined,
                          title: ContractorStrings.emptyList,
                          subtitle: 'কোনো মালামাল পাওয়া যায়নি',
                        ),
                      ],
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: materials.length,
                    itemBuilder: (context, idx) {
                      final m = materials[idx];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      m.name,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                  ),
                                  if (m.isClientAdded)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF0F766E).withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        'ক্লায়েন্ট যোগ করেছেন (শুধু দর্শন)',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Color(0xFF0F766E),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    )
                                  else
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit_outlined, size: 18),
                                          onPressed: () {},
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                                          onPressed: () {},
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text('${m.projectName} • পরিমাণ: ${toBn(m.qty)} ${m.unit} × ৳${toBn(m.unitPrice.round())}'),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'তারিখ: ${toBn(m.purchaseDate.day)}/${toBn(m.purchaseDate.month)}/${toBn(m.purchaseDate.year)}',
                                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                  ),
                                  Text(
                                    BengaliFormatter.toCurrency(m.totalAmount),
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                ],
                              ),
                            ],
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
