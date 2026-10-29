import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/bengali_formatter.dart';
import '../../../auth/domain/models/app_user.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../data/project_repository.dart';
import '../../domain/models/project.dart';
import '../../domain/models/supervisor_assignment.dart';
import '../widgets/assign_supervisor_dialog.dart';

class ProjectDetailsScreen extends ConsumerStatefulWidget {
  final Project project;

  const ProjectDetailsScreen({super.key, required this.project});

  @override
  ConsumerState<ProjectDetailsScreen> createState() =>
      _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends ConsumerState<ProjectDetailsScreen> {
  late Project _project;
  List<SupervisorAssignment> _assignments = [];
  bool _isLoadingAssignments = true;

  @override
  void initState() {
    super.initState();
    _project = widget.project;
    _loadAssignments();
  }

  Future<void> _loadAssignments() async {
    try {
      final repo = ref.read(projectRepositoryProvider);
      final assignments = await repo.getActiveAssignments(_project.id);
      if (mounted) {
        setState(() {
          _assignments = assignments;
          _isLoadingAssignments = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingAssignments = false);
    }
  }

  Future<void> _handleUnassign(SupervisorAssignment assignment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('অ্যাসাইনমেন্ট সরাতে চান?'),
        content: Text(
          '${assignment.supervisorName ?? "এই সুপারভাইজার"}-কে প্রজেক্ট থেকে সরিয়ে নিলে তিনি আর নতুন এন্ট্রি বা হাজিরা দিতে পারবেন না। পূর্বের রেকর্ড অপরিবর্তিত থাকবে।',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('বাতিল'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('অ্যাসাইনমেন্ট সরান'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final repo = ref.read(projectRepositoryProvider);
      await repo.unassignSupervisor(assignment.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('অ্যাসাইনমেন্ট সফলভাবে সরানো হয়েছে'),
            backgroundColor: AppColors.success,
          ),
        );
        _loadAssignments();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ত্রুটি: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider).value;
    final isContractor = user?.role == UserRole.contractor;

    return Scaffold(
      appBar: AppBar(
        title: Text(_project.name),
        backgroundColor: user?.role.brandColor ?? AppColors.contractorNavy,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status and Type Badges
            Row(
              children: [
                Chip(
                  label: Text(_project.type.displayName),
                  backgroundColor: AppColors.info.withValues(alpha: 0.1),
                  side: BorderSide.none,
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text(_project.status.displayName),
                  backgroundColor: AppColors.success.withValues(alpha: 0.1),
                  side: BorderSide.none,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Basic Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'প্রজেক্টের বিবরণ',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const Divider(height: 20),
                    if (_project.clientName != null) ...[
                      _buildInfoRow('ক্লায়েন্ট', _project.clientName!),
                      if (_project.clientMobile != null)
                        _buildInfoRow('মোবাইল',
                            BengaliFormatter.toBnNumber(_project.clientMobile)),
                    ],
                    if (_project.budget != null)
                      _buildInfoRow('চুক্তি / বাজেট',
                          BengaliFormatter.formatCurrency(_project.budget!)),
                    if (_project.totalSqft != null)
                      _buildInfoRow('মোট আয়তন',
                          '${BengaliFormatter.toBnNumber(_project.totalSqft)} স্কয়ার ফিট'),
                    if (_project.ratePerSqft != null)
                      _buildInfoRow('প্রতি স্কয়ার ফিট রেট',
                          BengaliFormatter.formatCurrency(_project.ratePerSqft!)),
                    _buildInfoRow('শুরুর তারিখ',
                        BengaliFormatter.formatDate(_project.startDate)),
                    if (_project.address != null && _project.address!.isNotEmpty)
                      _buildInfoRow('ঠিকানা', _project.address!),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Map and Geofence Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.location_on, color: AppColors.error),
                        SizedBox(width: 8),
                        Text(
                          'সাইট লোকেশন ও জিও-ফেন্স',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    _buildInfoRow('অক্ষাংশ (Lat)', '${_project.lat}'),
                    _buildInfoRow('দ্রাঘিমাংশ (Lng)', '${_project.lng}'),
                    _buildInfoRow(
                      'ভেরিফিকেশন রেডিয়াস',
                      '${BengaliFormatter.toBnNumber(_project.geofenceRadiusM)} মিটার',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Assigned Supervisors Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'দায়িত্বপ্রাপ্ত সুপারভাইজার',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        if (isContractor)
                          TextButton.icon(
                            onPressed: () => showDialog(
                              context: context,
                              builder: (_) => AssignSupervisorDialog(
                                projectId: _project.id,
                                activeSupervisorIds:
                                    _assignments.map((a) => a.supervisorId).toList(),
                                onAssigned: _loadAssignments,
                              ),
                            ),
                            icon: const Icon(Icons.add_circle_outline, size: 18),
                            label: const Text('যুক্ত করুন'),
                          ),
                      ],
                    ),
                    const Divider(height: 16),
                    _isLoadingAssignments
                        ? const Center(child: CircularProgressIndicator())
                        : _assignments.isEmpty
                            ? const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: Text(
                                  'এই প্রজেক্টে এখনও কোনো সুপারভাইজার অ্যাসাইন করা হয়নি।',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              )
                            : ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _assignments.length,
                                separatorBuilder: (_, __) =>
                                    const Divider(height: 8),
                                itemBuilder: (ctx, i) {
                                  final item = _assignments[i];
                                  return ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: const CircleAvatar(
                                      backgroundColor: AppColors.supervisorAmber,
                                      foregroundColor: Colors.white,
                                      child: Icon(Icons.person, size: 20),
                                    ),
                                    title: Text(item.supervisorName ?? 'সুপারভাইজার'),
                                    subtitle: Text(
                                      item.supervisorMobile != null
                                          ? BengaliFormatter.toBnNumber(
                                              item.supervisorMobile)
                                          : '',
                                    ),
                                    trailing: isContractor
                                        ? IconButton(
                                            icon: const Icon(
                                              Icons.remove_circle_outline,
                                              color: AppColors.error,
                                            ),
                                            tooltip: 'অ্যাসাইনমেন্ট সরান',
                                            onPressed: () =>
                                                _handleUnassign(item),
                                          )
                                        : null,
                                  );
                                },
                              ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
