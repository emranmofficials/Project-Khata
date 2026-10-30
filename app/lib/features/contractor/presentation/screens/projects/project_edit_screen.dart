import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_khata/core/constants/app_colors.dart';
import 'package:project_khata/core/constants/app_strings.dart';
import 'package:project_khata/core/constants/contractor_strings.dart';
import 'package:project_khata/widgets/contractor_widgets.dart';
import '../../contractor_providers.dart';
import '../../../domain/models/contractor_models.dart';

class ProjectEditScreen extends ConsumerStatefulWidget {
  final String projectId;

  const ProjectEditScreen({
    super.key,
    required this.projectId,
  });

  @override
  ConsumerState<ProjectEditScreen> createState() => _ProjectEditScreenState();
}

class _ProjectEditScreenState extends ConsumerState<ProjectEditScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _clientNameController;
  late TextEditingController _budgetController;

  ProjectType _selectedType = ProjectType.sqft;
  ProjectStatus _selectedStatus = ProjectStatus.active;
  double _geofenceRadius = 150;
  bool _isInitialized = false;
  bool _isSaving = false;

  late double _lat;
  late double _lng;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _clientNameController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  void _initFields(ProjectDetails project) {
    if (_isInitialized) return;
    _nameController = TextEditingController(text: project.name);
    _addressController = TextEditingController(text: project.address);
    _clientNameController = TextEditingController(text: project.client.name);
    _budgetController = TextEditingController(
      text: project.budget != null ? project.budget!.toStringAsFixed(0) : '',
    );
    _selectedType = project.type;
    _selectedStatus = project.status;
    _geofenceRadius = project.geofenceRadiusM.toDouble();
    _lat = project.lat;
    _lng = project.lng;
    _isInitialized = true;
  }

  Future<void> _submit(ProjectDetails current) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final input = UpdateProjectInput(
        id: current.id,
        name: _nameController.text.trim(),
        type: _selectedType,
        address: _addressController.text.trim(),
        lat: _lat,
        lng: _lng,
        geofenceRadiusM: _geofenceRadius.round(),
        budget: double.tryParse(_budgetController.text.trim()),
        status: _selectedStatus,
        clientName: _clientNameController.text.trim(), // Note: clientMobile is strictly excluded
      );

      final repo = ref.read(contractorRepositoryProvider);
      await repo.updateProject(input);

      ref.invalidate(projectDetailsProvider(current.id));
      ref.invalidate(projectsProvider(null));
      ref.invalidate(dashboardSummaryProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('প্রজেক্ট সফলভাবে আপডেট করা হয়েছে!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
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
    final projectAsync = ref.watch(projectDetailsProvider(widget.projectId));

    return projectAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text(ContractorStrings.editProject)),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text(ContractorStrings.editProject)),
        body: Center(child: Text(e.toString())),
      ),
      data: (project) {
        _initFields(project);

        return Scaffold(
          appBar: AppBar(
            title: const Text(ContractorStrings.editProject),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // প্রজেক্টের নাম
                  const Text(
                    ContractorStrings.projectName,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameController,
                    validator: (val) => requiredValidator(val, AppStrings.fieldRequired),
                  ),

                  const SizedBox(height: 18),

                  // প্রজেক্টের ধরন
                  const Text(
                    ContractorStrings.projectType,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<ProjectType>(
                      segments: const [
                        ButtonSegment(
                          value: ProjectType.sqft,
                          label: Text(ContractorStrings.projectTypeSqft),
                        ),
                        ButtonSegment(
                          value: ProjectType.contract,
                          label: Text(ContractorStrings.projectTypeContract),
                        ),
                        ButtonSegment(
                          value: ProjectType.daily,
                          label: Text(ContractorStrings.projectTypeDaily),
                        ),
                      ],
                      selected: {_selectedType},
                      onSelectionChanged: (set) => setState(() => _selectedType = set.first),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // স্ট্যাটাস
                  const Text(
                    'প্রজেক্ট স্ট্যাটাস',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<ProjectStatus>(
                    initialValue: _selectedStatus,
                    items: ProjectStatus.values.map((s) {
                      return DropdownMenuItem(
                        value: s,
                        child: Text(s.displayName),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedStatus = val);
                    },
                  ),

                  const SizedBox(height: 18),

                  // ক্লায়েন্টের নাম (সম্পাদনাযোগ্য)
                  const Text(
                    ContractorStrings.clientName,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _clientNameController,
                    validator: (val) => requiredValidator(val, AppStrings.fieldRequired),
                  ),

                  const SizedBox(height: 12),

                  // ক্লায়েন্টের মোবাইল (লকড / অপরিবর্তনীয় তথ্য কার্ড)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.lock_outline, size: 20, color: Colors.grey),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'ক্লায়েন্ট মোবাইল: ${toBn(project.client.mobile)} (${ContractorStrings.clientMobileImmutableWarning})',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // সাইট ঠিকানা
                  const Text(
                    ContractorStrings.projectAddress,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _addressController,
                    validator: (val) => requiredValidator(val, AppStrings.fieldRequired),
                  ),

                  const SizedBox(height: 8),

                  // লোকেশন পরিবর্তন সতর্কবার্তা
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline, size: 16, color: Colors.amber),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          ContractorStrings.locationChangeWarning,
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // জিও-ফেন্স রেডিয়াস
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        ContractorStrings.geofenceRadiusLabel,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${toBn(_geofenceRadius.round())} ${ContractorStrings.metersUnit}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.contractorNavy,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _geofenceRadius,
                    min: 100,
                    max: 200,
                    divisions: 10,
                    onChanged: (val) => setState(() => _geofenceRadius = val),
                  ),

                  const SizedBox(height: 18),

                  // বাজেট
                  const Text(
                    ContractorStrings.projectBudget,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _budgetController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(prefixText: '৳ '),
                  ),

                  const SizedBox(height: 32),

                  FilledButton(
                    onPressed: _isSaving ? null : () => _submit(project),
                    child: _isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text(ContractorStrings.saveChanges),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
