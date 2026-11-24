import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/bengali_formatter.dart';
import '../../../../core/widgets/loading_skeleton.dart';
import '../../domain/models/worker_model.dart';
import '../providers/worker_provider.dart';

class WorkersManagementScreen extends ConsumerStatefulWidget {
  const WorkersManagementScreen({super.key});

  @override
  ConsumerState<WorkersManagementScreen> createState() =>
      _WorkersManagementScreenState();
}

class _WorkersManagementScreenState extends ConsumerState<WorkersManagementScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final workersAsync = ref.watch(workersListProvider);
    final selectedFilter = ref.watch(workerRoleFilterProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('কর্মী ও সুপারভাইজার'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              ref.invalidate(workersListProvider);
              ref.invalidate(designationsListProvider);
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddWorkerDialog(context),
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('নতুন কর্মী'),
        backgroundColor: AppColors.contractorPrimary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // সার্চ বার ও ফিল্টার
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingMedium),
            color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'নাম বা মোবাইল নম্বর দিয়ে খুঁজুন...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () {
                              _searchController.clear();
                              ref.read(workerSearchQueryProvider.notifier).state = '';
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: isDark ? AppColors.darkCard : AppColors.lightCard,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (val) {
                    ref.read(workerSearchQueryProvider.notifier).state = val;
                  },
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildFilterChip('all', 'সকল কর্মী', selectedFilter),
                    const SizedBox(width: 8),
                    _buildFilterChip('worker', 'শ্রমিক', selectedFilter),
                    const SizedBox(width: 8),
                    _buildFilterChip('supervisor', 'সুপারভাইজার', selectedFilter),
                  ],
                ),
              ],
            ),
          ),

          // কর্মী তালিকা
          Expanded(
            child: workersAsync.when(
              loading: () => ListView.builder(
                padding: const EdgeInsets.all(AppSizes.paddingMedium),
                itemCount: 5,
                itemBuilder: (_, __) => const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: LoadingSkeletonCard(height: 90),
                ),
              ),
              error: (err, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline_rounded, color: AppColors.danger, size: 48),
                      const SizedBox(height: 12),
                      Text('তথ্য লোড করা যায়নি: $err', textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref.invalidate(workersListProvider),
                        child: const Text('পুনরায় চেষ্টা করুন'),
                      ),
                    ],
                  ),
                ),
              ),
              data: (workers) {
                if (workers.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.people_outline_rounded,
                            size: 64,
                            color: isDark ? Colors.white30 : Colors.black26,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'কোনো কর্মী পাওয়া যায়নি',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'আপনার প্রতিষ্ঠানে নতুন শ্রমিক বা সুপারভাইজার যোগ করতে নিচের "নতুন কর্মী" বাটনে চাপুন।',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: () => _showAddWorkerDialog(context),
                            icon: const Icon(Icons.person_add_rounded),
                            label: const Text('নতুন কর্মী যোগ করুন'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.contractorPrimary,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(workersListProvider),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(AppSizes.paddingMedium),
                    itemCount: workers.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final worker = workers[index];
                      return _buildWorkerCard(context, worker, isDark);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String key, String label, String current) {
    final isSelected = key == current;
    return FilterChip(
      selected: isSelected,
      label: Text(label),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected ? Colors.white : null,
      ),
      selectedColor: AppColors.contractorPrimary,
      checkmarkColor: Colors.white,
      onSelected: (_) {
        ref.read(workerRoleFilterProvider.notifier).state = key;
      },
    );
  }

  Widget _buildWorkerCard(BuildContext context, WorkerModel worker, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: worker.isSupervisor
                ? AppColors.supervisorPrimary.withOpacity(0.12)
                : AppColors.workerPrimary.withOpacity(0.12),
            child: Icon(
              worker.isSupervisor
                  ? Icons.engineering_rounded
                  : Icons.person_rounded,
              color: worker.isSupervisor
                  ? AppColors.supervisorPrimary
                  : AppColors.workerPrimary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        worker.name,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: worker.isSupervisor
                            ? AppColors.supervisorPrimary.withOpacity(0.12)
                            : AppColors.workerPrimary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        worker.isSupervisor ? 'সুপারভাইজার' : 'শ্রমিক',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: worker.isSupervisor
                              ? AppColors.supervisorPrimary
                              : AppColors.workerPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'মোবাইল: ${worker.mobile}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                if (worker.designationName != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'পদবি: ${worker.designationName} • দৈনিক: ${BengaliFormatter.toCurrency(worker.dailyRate)}',
                    style: const TextStyle(fontSize: 11, color: AppColors.contractorPrimary, fontWeight: FontWeight.w500),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              worker.isActive ? Icons.check_circle_rounded : Icons.block_rounded,
              color: worker.isActive ? AppColors.success : AppColors.danger,
            ),
            tooltip: worker.isActive ? 'সক্রিয় কর্মী' : 'নিষ্ক্রিয় কর্মী',
            onPressed: () {
              ref.read(workerActionProvider.notifier).toggleWorkerStatus(
                workerId: worker.id,
                isActive: !worker.isActive,
              );
            },
          ),
        ],
      ),
    );
  }

  void _showAddWorkerDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _AddWorkerBottomSheet(),
    );
  }
}

class _AddWorkerBottomSheet extends ConsumerStatefulWidget {
  const _AddWorkerBottomSheet();

  @override
  ConsumerState<_AddWorkerBottomSheet> createState() =>
      _AddWorkerBottomSheetState();
}

class _AddWorkerBottomSheetState extends ConsumerState<_AddWorkerBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  String _selectedRole = 'worker';
  String? _selectedDesignationId;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final designationsAsync = ref.watch(designationsListProvider);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: bottomInset + 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'নতুন কর্মী যুক্ত করুন',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ভূমিকা নির্বাচন (শ্রমিক নাকি সুপারভাইজার)
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'worker',
                    label: Text('শ্রমিক'),
                    icon: Icon(Icons.person_rounded),
                  ),
                  ButtonSegment(
                    value: 'supervisor',
                    label: Text('সুপারভাইজার'),
                    icon: Icon(Icons.engineering_rounded),
                  ),
                ],
                selected: {_selectedRole},
                onSelectionChanged: (val) {
                  setState(() {
                    _selectedRole = val.first;
                  });
                },
              ),
              const SizedBox(height: 16),

              // নাম
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'কর্মীর পূর্ণ নাম *',
                  hintText: 'যেমন: রফিকুল ইসলাম',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                  border: OutlineInputBorder(),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'নাম প্রদান করুন';
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // মোবাইল নম্বর
              TextFormField(
                controller: _mobileController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'মোবাইল নম্বর (১১ ডিজিট) *',
                  hintText: '০১XXXXXXXXX',
                  prefixIcon: Icon(Icons.phone_android_rounded),
                  border: OutlineInputBorder(),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'মোবাইল নম্বর প্রদান করুন';
                  final clean = val.trim();
                  if (!RegExp(r'^01[3-9]\d{8}$').hasMatch(clean)) {
                    return 'সঠিক ১১ সংখ্যার বাংলাদেশি মোবাইল দিন';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // পদবি নির্বাচন
              designationsAsync.when(
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const SizedBox.shrink(),
                data: (designations) {
                  return DropdownButtonFormField<String>(
                    value: _selectedDesignationId,
                    decoration: const InputDecoration(
                      labelText: 'পদবি ও দৈনিক মজুরি রেট',
                      prefixIcon: Icon(Icons.badge_outlined),
                      border: OutlineInputBorder(),
                    ),
                    items: designations.map((d) {
                      final name = d['name'] as String? ?? '';
                      final rate = (d['daily_rate'] as num?)?.toDouble() ?? 0.0;
                      return DropdownMenuItem<String>(
                        value: d['id'] as String,
                        child: Text('$name (${BengaliFormatter.toCurrency(rate)}/দিন)'),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedDesignationId = val;
                      });
                    },
                  );
                },
              ),
              const SizedBox(height: 20),

              // সেভ বাটন
              ElevatedButton(
                onPressed: _isLoading ? null : _saveWorker,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.contractorPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        'সংরক্ষণ করুন',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveWorker() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await ref.read(workerActionProvider.notifier).addWorker(
        name: _nameController.text.trim(),
        mobile: _mobileController.text.trim(),
        role: _selectedRole,
        designationId: _selectedDesignationId,
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('কর্মী সফলভাবে যুক্ত করা হয়েছে!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ত্রুটি: ${e.toString().replaceAll("Exception: ", "")}'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
