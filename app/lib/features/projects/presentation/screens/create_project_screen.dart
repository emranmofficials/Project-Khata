import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/bengali_formatter.dart';
import '../../../auth/domain/models/app_user.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../domain/models/project.dart';
import '../controllers/project_controller.dart';

class CreateProjectScreen extends ConsumerStatefulWidget {
  const CreateProjectScreen({super.key});

  @override
  ConsumerState<CreateProjectScreen> createState() => _CreateProjectScreenState();
}

class _CreateProjectScreenState extends ConsumerState<CreateProjectScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _latController = TextEditingController(text: '23.8103'); // Default Dhaka center
  final _lngController = TextEditingController(text: '90.4125');
  final _budgetController = TextEditingController();
  final _sqftController = TextEditingController();
  final _ratePerSqftController = TextEditingController();
  final _dailyWageController = TextEditingController();
  final _noteController = TextEditingController();

  ProjectType _selectedType = ProjectType.sqft;
  double _geofenceRadius = 150.0; // Default 150m (100-200m per PRD)
  final DateTime _startDate = DateTime.now();
  DateTime? _endDate;

  String? _selectedClientId;
  List<UserProfile> _clients = [];
  bool _isLoadingClients = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadClients();
  }

  Future<void> _loadClients() async {
    final user = ref.read(authControllerProvider).value;
    if (user == null) return;
    try {
      final repo = ref.read(projectRepositoryProvider);
      final clients = await repo.getClients(user.organizationId);
      if (mounted) {
        setState(() {
          _clients = clients;
          if (clients.isNotEmpty) _selectedClientId = clients.first.id;
          _isLoadingClients = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingClients = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _latController.dispose();
    _lngController.dispose();
    _budgetController.dispose();
    _sqftController.dispose();
    _ratePerSqftController.dispose();
    _dailyWageController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedClientId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('অনুগ্রহ করে একজন ক্লায়েন্ট নির্বাচন করুন'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final lat = double.tryParse(_latController.text.trim());
    final lng = double.tryParse(_lngController.text.trim());
    if (lat == null || lng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('সাইটের বৈধ ম্যাপ লোকেশন (Latitude ও Longitude) আবশ্যক'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final user = ref.read(authControllerProvider).value;
    if (user == null) return;

    setState(() => _isSaving = true);

    try {
      final ratePerSqft = double.tryParse(_ratePerSqftController.text.trim());
      final totalSqft = double.tryParse(_sqftController.text.trim());
      final dailyWage = double.tryParse(_dailyWageController.text.trim());
      var budget = double.tryParse(_budgetController.text.trim());

      // Auto compute budget for sqft type if not given
      if (_selectedType == ProjectType.sqft && totalSqft != null && ratePerSqft != null) {
        budget ??= totalSqft * ratePerSqft;
      }

      await ref.read(projectsListProvider.notifier).addProject(
            organizationId: user.organizationId,
            clientId: _selectedClientId!,
            name: _nameController.text.trim(),
            type: _selectedType,
            address: _addressController.text.trim(),
            lat: lat,
            lng: lng,
            geofenceRadiusM: _geofenceRadius.round(),
            startDate: _startDate,
            endDate: _endDate,
            budget: budget,
            ratePerSqft: ratePerSqft,
            totalSqft: totalSqft,
            dailyWage: dailyWage,
            note: _noteController.text.trim(),
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('প্রজেক্ট সফলভাবে তৈরি হয়েছে!'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('নতুন প্রজেক্ট তৈরি'),
        backgroundColor: AppColors.contractorNavy,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Client Selection
                _isLoadingClients
                    ? const Center(child: CircularProgressIndicator())
                    : _clients.isEmpty
                        ? Card(
                            color: Colors.amber.shade50,
                            child: const Padding(
                              padding: EdgeInsets.all(12),
                              child: Text(
                                'কোনো ক্লায়েন্ট পাওয়া যায়নি। প্রজেক্ট তৈরির আগে ইউজার মেন্যু থেকে একজন ক্লায়েন্ট যুক্ত করুন।',
                                style: TextStyle(color: Colors.black87),
                              ),
                            ),
                          )
                        : DropdownButtonFormField<String>(
                            value: _selectedClientId,
                            decoration: const InputDecoration(
                              labelText: 'ক্লায়েন্ট নির্বাচন করুন *',
                              prefixIcon: Icon(Icons.person_pin_rounded),
                            ),
                            items: _clients
                                .map(
                                  (c) => DropdownMenuItem(
                                    value: c.id,
                                    child: Text(
                                      '${c.name} (${c.mobile != null ? BengaliFormatter.toBnNumber(c.mobile) : ""})',
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) =>
                                setState(() => _selectedClientId = val),
                          ),
                const SizedBox(height: 16),

                // 2. Project Name
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'প্রজেক্টের নাম *',
                    hintText: 'উদা: ধানমন্ডি ৬ তলা বাড়ি',
                    prefixIcon: Icon(Icons.domain_rounded),
                  ),
                  validator: (val) => val == null || val.trim().isEmpty
                      ? AppStrings.fieldRequired
                      : null,
                ),
                const SizedBox(height: 16),

                // 3. Project Type (৩ ধরন)
                const Text(
                  'প্রজেক্টের ধরন নির্বাচন করুন *',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                SegmentedButton<ProjectType>(
                  segments: const [
                    ButtonSegment(
                      value: ProjectType.sqft,
                      label: Text('স্কয়ার ফিট'),
                    ),
                    ButtonSegment(
                      value: ProjectType.contract,
                      label: Text('চুক্তি ভিত্তিক'),
                    ),
                    ButtonSegment(
                      value: ProjectType.daily,
                      label: Text('রোজ ভিত্তিক'),
                    ),
                  ],
                  selected: {_selectedType},
                  onSelectionChanged: (val) =>
                      setState(() => _selectedType = val.first),
                ),
                const SizedBox(height: 20),

                // 4. Type specific cost/rate inputs
                if (_selectedType == ProjectType.sqft) ...[
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _sqftController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'মোট স্কয়ার ফিট *',
                            hintText: 'উদা: ৪২০০',
                          ),
                          validator: (val) => val == null || val.trim().isEmpty
                              ? AppStrings.fieldRequired
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _ratePerSqftController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'প্রতি স্কয়ার ফিট রেট *',
                            hintText: 'উদা: ১২০০',
                          ),
                          validator: (val) => val == null || val.trim().isEmpty
                              ? AppStrings.fieldRequired
                              : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ] else if (_selectedType == ProjectType.contract) ...[
                  TextFormField(
                    controller: _budgetController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'মোট চুক্তি মূল্য (বাজেট) *',
                      hintText: 'উদা: ২৫০০০০০',
                      prefixIcon: Icon(Icons.currency_lira_rounded),
                    ),
                    validator: (val) => val == null || val.trim().isEmpty
                        ? AppStrings.fieldRequired
                        : null,
                  ),
                  const SizedBox(height: 16),
                ] else ...[
                  TextFormField(
                    controller: _dailyWageController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'প্রস্তাবিত দৈনিক মজুরি',
                      hintText: 'উদা: ৮০০',
                      prefixIcon: Icon(Icons.payments_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // 5. Site Address & Location (Mandatory GPS)
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'সাইটের ঠিকানা',
                    hintText: 'উদা: বাড়ি ১২, রোড ৪, মিরপুর',
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                ),
                const SizedBox(height: 16),

                // Map Coordinates Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.map_rounded,
                                color: AppColors.contractorNavy),
                            SizedBox(width: 8),
                            Text(
                              'সাইট লোকেশন ও জিও-ফেন্স (বাধ্যতামূলক)',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _latController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: const InputDecoration(
                                  labelText: 'Latitude *',
                                ),
                                validator: (val) => val == null || val.trim().isEmpty
                                    ? AppStrings.fieldRequired
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _lngController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: const InputDecoration(
                                  labelText: 'Longitude *',
                                ),
                                validator: (val) => val == null || val.trim().isEmpty
                                    ? AppStrings.fieldRequired
                                    : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('হাজিরা ভেরিফিকেশন রেডিয়াস:'),
                            Text(
                              '${BengaliFormatter.toBnNumber(_geofenceRadius.round())} মিটার',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.contractorNavy),
                            ),
                          ],
                        ),
                        Slider(
                          value: _geofenceRadius,
                          min: 100.0,
                          max: 200.0,
                          divisions: 10,
                          activeColor: AppColors.contractorNavy,
                          onChanged: (val) =>
                              setState(() => _geofenceRadius = val),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Save Button
                ElevatedButton(
                  onPressed: _isSaving ? null : _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.contractorNavy,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'প্রজেক্ট সংরক্ষণ করুন',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
