import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/contractor_strings.dart';
import '../../../../core/utils/bengali_formatter.dart';
import '../../../../widgets/contractor_widgets.dart';
import '../../contractor_providers.dart';
import '../../../domain/models/contractor_models.dart';

class DesignationsScreen extends ConsumerWidget {
  const DesignationsScreen({super.key});

  void _showAddEditDialog(BuildContext context, WidgetRef ref, [Designation? designation]) {
    final nameController = TextEditingController(text: designation?.name ?? '');
    final wageController = TextEditingController(
      text: designation != null ? designation.dailyWage.toStringAsFixed(0) : '',
    );
    final otController = TextEditingController(
      text: designation != null ? designation.overtimeRatePerHour.toStringAsFixed(0) : '100',
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(designation == null ? 'নতুন পদ যোগ' : 'পদ সম্পাদনা'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('পদের নাম', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              TextField(controller: nameController),
              const SizedBox(height: 12),
              const Text('দৈনিক মজুরি (৳)', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              TextField(controller: wageController, keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              const Text('প্রতি ঘণ্টার ওভারটাইম হার (৳)', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              TextField(controller: otController, keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('বাতিল')),
          FilledButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) return;
              Navigator.pop(ctx);

              final repo = ref.read(contractorRepositoryProvider);
              await repo.upsertDesignation(
                id: designation?.id,
                name: nameController.text.trim(),
                dailyWage: double.tryParse(wageController.text.trim()) ?? 800,
                overtimeRatePerHour: double.tryParse(otController.text.trim()) ?? 100,
              );
              ref.invalidate(designationsProvider);
            },
            child: const Text('সংরক্ষণ'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final designationsAsync = ref.watch(designationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(ContractorStrings.designationsAndRates),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('নতুন পদ'),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(designationsProvider),
        child: designationsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text(e.toString())),
          data: (designations) {
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: designations.length,
              itemBuilder: (context, idx) {
                final d = designations[idx];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    title: Text(d.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      'দৈনিক: ${BengaliFormatter.toCurrency(d.dailyWage)} • ওভারটাইম: ৳${toBn(d.overtimeRatePerHour.round())}/ঘণ্টা',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => _showAddEditDialog(context, ref, d),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
