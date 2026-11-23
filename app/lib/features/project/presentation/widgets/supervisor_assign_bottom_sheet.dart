import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../providers/project_provider.dart';

/// PRD সেকশন ৬.৩ (৫) অনুযায়ী সুপারভাইজার অ্যাসাইন বটম শীট
class SupervisorAssignBottomSheet extends ConsumerStatefulWidget {
  final String projectId;
  final List<String> currentAssignedIds;

  const SupervisorAssignBottomSheet({
    super.key,
    required this.projectId,
    required this.currentAssignedIds,
  });

  @override
  ConsumerState<SupervisorAssignBottomSheet> createState() => _SupervisorAssignBottomSheetState();
}

class _SupervisorAssignBottomSheetState extends ConsumerState<SupervisorAssignBottomSheet> {
  late Set<String> _selectedIds;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedIds = Set.from(widget.currentAssignedIds);
  }

  void _handleSave() async {
    // যারা আগে ছিল কিন্তু এখন আনচেক করা হয়েছে তাদের চিহ্নিত করা
    final removedIds = widget.currentAssignedIds.where((id) => !_selectedIds.contains(id)).toList();

    if (removedIds.isNotEmpty) {
      // নিশ্চিতকরণ ডায়ালগ (PRD নিয়ম ২০)
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.cardRadius)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 28),
              SizedBox(width: 8),
              Text('অ্যাসাইনমেন্ট বাতিল নিশ্চিতকরণ'),
            ],
          ),
          content: const Text(
            'সুপারভাইজার সরানোর পর তার খোলা এন্ট্রিগুলো "হস্তান্তর প্রয়োজন" অবস্থায় যাবে। আপনি কি নিশ্চিত?',
            style: TextStyle(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('না, ফিরে যান'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
              child: const Text('হ্যাঁ, সরান', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );

      if (confirmed != true) return;
    }

    setState(() => _isSaving = true);
    try {
      await ref.read(projectActionProvider.notifier).syncSupervisors(
        widget.projectId,
        _selectedIds.toList(),
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('সুপারভাইজার তালিকা সফলভাবে আপডেট হয়েছে'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ত্রুটি: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final supervisorsAsync = ref.watch(allSupervisorsProvider);

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingLarge),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'সুপারভাইজার অ্যাসাইন করুন',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'নির্বাচিত সুপারভাইজাররা এই প্রজেক্টে দৈনিক এন্ট্রি ও দল গঠন করতে পারবেন।',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 16),

          supervisorsAsync.when(
            loading: () => const Center(child: Padding(
              padding: EdgeInsets.all(24.0),
              child: CircularProgressIndicator(),
            )),
            error: (err, _) => Center(child: Text('ডাটা লোড ত্রুটি: $err')),
            data: (supervisors) {
              if (supervisors.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Text('কোনো সক্রিয় সুপারভাইজার পাওয়া যায়নি। আগে শ্রমিক ট্যাব থেকে সুপারভাইজার যোগ করুন।'),
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                itemCount: supervisors.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final sup = supervisors[index];
                  final id = sup['id'] as String;
                  final name = sup['name'] as String;
                  final mobile = sup['mobile'] as String;
                  final isChecked = _selectedIds.contains(id);

                  return CheckboxListTile(
                    value: isChecked,
                    activeColor: AppColors.contractorPrimary,
                    title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(mobile, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    onChanged: (val) {
                      setState(() {
                        if (val == true) {
                          _selectedIds.add(id);
                        } else {
                          _selectedIds.remove(id);
                        }
                      });
                    },
                  );
                },
              );
            },
          ),

          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isSaving ? null : _handleSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.contractorPrimary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: _isSaving
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('সংরক্ষণ করুন', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
