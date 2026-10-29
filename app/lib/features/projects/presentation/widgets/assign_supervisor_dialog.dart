import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/bengali_formatter.dart';
import '../../../auth/domain/models/app_user.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../data/project_repository.dart';

class AssignSupervisorDialog extends ConsumerStatefulWidget {
  final String projectId;
  final List<String> activeSupervisorIds;
  final VoidCallback? onAssigned;

  const AssignSupervisorDialog({
    super.key,
    required this.projectId,
    required this.activeSupervisorIds,
    this.onAssigned,
  });

  @override
  ConsumerState<AssignSupervisorDialog> createState() =>
      _AssignSupervisorDialogState();
}

class _AssignSupervisorDialogState
    extends ConsumerState<AssignSupervisorDialog> {
  String? _selectedSupervisorId;
  List<UserProfile> _availableSupervisors = [];
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadSupervisors();
  }

  Future<void> _loadSupervisors() async {
    final user = ref.read(authControllerProvider).value;
    if (user == null) return;

    try {
      final repo = ref.read(projectRepositoryProvider);
      final all = await repo.getSupervisors(user.organizationId);
      final available = all
          .where((s) => !widget.activeSupervisorIds.contains(s.id))
          .toList();

      if (mounted) {
        setState(() {
          _availableSupervisors = available;
          if (available.isNotEmpty) {
            _selectedSupervisorId = available.first.id;
          }
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleAssign() async {
    if (_selectedSupervisorId == null) return;
    final user = ref.read(authControllerProvider).value;
    if (user == null) return;

    setState(() => _isSaving = true);
    try {
      final repo = ref.read(projectRepositoryProvider);
      await repo.assignSupervisor(
        organizationId: user.organizationId,
        projectId: widget.projectId,
        supervisorId: _selectedSupervisorId!,
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('সুপারভাইজার সফলভাবে অ্যাসাইন করা হয়েছে!'),
            backgroundColor: AppColors.success,
          ),
        );
        widget.onAssigned?.call();
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
    return AlertDialog(
      title: const Text('সুপারভাইজার অ্যাসাইন করুন'),
      content: _isLoading
          ? const SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator()),
            )
          : _availableSupervisors.isEmpty
              ? const Text(
                  'অ্যাসাইন করার মতো কোনো নতুন সুপারভাইজার নেই। সকল সুপারভাইজার ইতিমধ্যে এই প্রজেক্টে যুক্ত আছেন।',
                )
              : DropdownButtonFormField<String>(
                  value: _selectedSupervisorId,
                  decoration: const InputDecoration(
                    labelText: 'সুপারভাইজার নির্বাচন করুন',
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                  items: _availableSupervisors
                      .map(
                        (s) => DropdownMenuItem(
                          value: s.id,
                          child: Text(
                            '${s.name} (${s.mobile != null ? BengaliFormatter.toBnNumber(s.mobile) : ""})',
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (val) =>
                      setState(() => _selectedSupervisorId = val),
                ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: const Text('বাতিল'),
        ),
        if (_availableSupervisors.isNotEmpty)
          ElevatedButton(
            onPressed: _isSaving ? null : _handleAssign,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.contractorNavy,
              foregroundColor: Colors.white,
            ),
            child: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('অ্যাসাইন করুন'),
          ),
      ],
    );
  }
}
