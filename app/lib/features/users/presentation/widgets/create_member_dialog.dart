import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../auth/data/auth_repository.dart';
import '../../../auth/domain/models/app_user.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

class CreateMemberDialog extends ConsumerStatefulWidget {
  final VoidCallback? onMemberCreated;

  const CreateMemberDialog({super.key, this.onMemberCreated});

  @override
  ConsumerState<CreateMemberDialog> createState() => _CreateMemberDialogState();
}

class _CreateMemberDialogState extends ConsumerState<CreateMemberDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();

  UserRole _selectedRole = UserRole.worker;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  Future<void> _handleCreateMember() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.createMember(
        name: _nameController.text.trim(),
        mobile: _mobileController.text.trim(),
        role: _selectedRole,
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.memberAddedSuccess),
            backgroundColor: AppColors.success,
          ),
        );
        widget.onMemberCreated?.call();
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
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(AppStrings.addMember),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: AppStrings.nameLabel,
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (val) => val == null || val.trim().isEmpty
                    ? AppStrings.fieldRequired
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _mobileController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: AppStrings.mobileLabel,
                  hintText: AppStrings.mobileHint,
                  prefixIcon: Icon(Icons.phone_android),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return AppStrings.fieldRequired;
                  }
                  if (!RegExp(r'^01[3-9]\d{8}$').hasMatch(val.trim())) {
                    return AppStrings.invalidMobile;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<UserRole>(
                value: _selectedRole,
                decoration: const InputDecoration(
                  labelText: AppStrings.selectRole,
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
                items: const [
                  DropdownMenuItem(
                    value: UserRole.supervisor,
                    child: Text(AppStrings.roleSupervisor),
                  ),
                  DropdownMenuItem(
                    value: UserRole.worker,
                    child: Text(AppStrings.roleWorker),
                  ),
                  DropdownMenuItem(
                    value: UserRole.client,
                    child: Text(AppStrings.roleClient),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _selectedRole = val);
                },
              ),
              const SizedBox(height: 12),
              const Text(
                AppStrings.defaultPasswordNotice,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text(AppStrings.cancel),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleCreateMember,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.contractorNavy,
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text(AppStrings.save),
        ),
      ],
    );
  }
}
