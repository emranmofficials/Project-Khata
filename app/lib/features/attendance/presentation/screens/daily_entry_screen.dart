import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/bengali_formatter.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../projects/data/project_repository.dart';
import '../controllers/attendance_controller.dart';
import '../widgets/add_worker_dialog.dart';
import '../widgets/geofence_status_badge.dart';
import '../widgets/worker_attendance_card.dart';
import '../../../../core/widgets/offline_sync_banner.dart';

class DailyEntryScreen extends ConsumerStatefulWidget {
  final String? projectId;

  const DailyEntryScreen({super.key, this.projectId});

  @override
  ConsumerState<DailyEntryScreen> createState() => _DailyEntryScreenState();
}

class _DailyEntryScreenState extends ConsumerState<DailyEntryScreen> {
  late TextEditingController _workDescController;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _workDescController = TextEditingController();
    _notesController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initScreen();
    });
  }

  void _initScreen() async {
    final user = ref.read(currentUserProvider).value;
    if (user == null) return;

    if (widget.projectId != null) {
      final projectRepo = ref.read(projectRepositoryProvider);
      try {
        final project = await projectRepo.getProjectById(widget.projectId!);
        ref.read(attendanceControllerProvider.notifier).initForProject(project, currentUser: user);
        ref.read(attendanceControllerProvider.notifier).checkLocation();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('প্রজেক্ট লোড করতে ব্যর্থ: $e')),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _workDescController.disposeDisposeSafe();
    _notesController.disposeDisposeSafe();
    super.dispose();
  }

  void _pickDate(BuildContext context, DateTime currentDate, String role) async {
    final now = DateTime.now();
    final int maxDaysAgo = (role == 'contractor') ? 7 : 2; // PRD Rule 8 & 159
    final firstDate = now.subtract(Duration(days: maxDaysAgo));

    final picked = await showDatePicker(
      context: context,
      initialDate: currentDate.isBefore(firstDate) ? firstDate : currentDate,
      firstDate: firstDate,
      lastDate: now,
      helpText: 'এন্ট্রির তারিখ নির্বাচন করুন (সর্বোচ্চ $maxDaysAgo দিন পূর্বের)',
      cancelText: AppStrings.cancel,
      confirmText: AppStrings.confirm,
    );

    if (picked != null) {
      ref.read(attendanceControllerProvider.notifier).setDate(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider).value;
    final state = ref.watch(attendanceControllerProvider);
    final controller = ref.read(attendanceControllerProvider.notifier);

    // টেক্সট কন্ট্রোলার সিঙ্ক
    if (_workDescController.text != state.workDescription && state.workDescription.isNotEmpty) {
      _workDescController.text = state.workDescription;
    }
    if (_notesController.text != state.notes && state.notes.isNotEmpty) {
      _notesController.text = state.notes;
    }

    ref.listen<AttendanceEntryState>(attendanceControllerProvider, (prev, next) {
      if (next.errorMessage != null && next.errorMessage != prev?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!), backgroundColor: Colors.red),
        );
      }
      if (next.successMessage != null && next.successMessage != prev?.successMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.successMessage!), backgroundColor: Colors.green),
        );
      }
    });

    final project = state.selectedProject;

    return Scaffold(
      appBar: AppBar(
        title: Text(project?.name ?? AppStrings.createDailyEntry),
        actions: [
          if (project != null && user != null)
            IconButton(
              icon: const Icon(Icons.save_outlined),
              tooltip: AppStrings.saveDraft,
              onPressed: state.isLoading ? null : () => controller.saveDraftLocally(user.id),
            ),
        ],
      ),
      body: state.isLoading && project == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const OfflineSyncBanner(),
                  // ১. তারিখ নির্বাচন
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: ListTile(
                      leading: const Icon(Icons.calendar_today, color: AppColors.supervisorPrimary),
                      title: const Text('এন্ট্রির তারিখ', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      subtitle: Text(
                        BengaliFormatter.toDate(state.entryDate),
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _pickDate(context, state.entryDate, user?.role.toDbString() ?? 'supervisor'),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ২. GPS লোকেশন ও জিওফেন্সিং স্ট্যাটাস
                  if (project != null) ...[
                    GeofenceStatusBadge(
                      locationResult: state.locationResult,
                      onRefresh: () => controller.checkLocation(),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ৩. কাজের বিবরণ
                  TextFormField(
                    controller: _workDescController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: AppStrings.workDescription,
                      hintText: AppStrings.workDescriptionHint,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onChanged: (val) => controller.setWorkDescription(val),
                  ),
                  const SizedBox(height: 12),

                  // ৪. মন্তব্য
                  TextFormField(
                    controller: _notesController,
                    maxLines: 1,
                    decoration: InputDecoration(
                      labelText: AppStrings.notesOptional,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onChanged: (val) => controller.setNotes(val),
                  ),
                  const SizedBox(height: 20),

                  // ৫. দলের হাজিরা সেকশন হেডার
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.people, color: AppColors.supervisorPrimary),
                          const SizedBox(width: 8),
                          Text(
                            'দলের হাজিরা (${BengaliFormatter.toBnNumber(state.teamRecords.length)} জন)',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.supervisorPrimary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        icon: const Icon(Icons.person_add, size: 18),
                        label: const Text('শ্রমিক যোগ'),
                        onPressed: () {
                          final orgId = user?.organizationId;
                          if (orgId == null) return;
                          showDialog(
                            context: context,
                            builder: (ctx) => AddWorkerDialog(
                              orgId: orgId,
                              existingWorkerIds: state.teamRecords.map((r) => r.workerId).toList(),
                              onWorkerSelected: (w) => controller.addWorker(w),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // ৬. দলের শ্রমিক তালিকা
                  if (state.teamRecords.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.group_outlined, size: 40, color: Colors.grey),
                          SizedBox(height: 8),
                          Text(
                            'আজকের দলে কোনো শ্রমিক যুক্ত করা হয়নি',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '"শ্রমিক যোগ" বাটনে ট্যাপ করে তালিকা থেকে শ্রমিক যুক্ত করুন',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  else
                    ...state.teamRecords.map((record) {
                      return WorkerAttendanceCard(
                        record: record,
                        onStatusChanged: (status) =>
                            controller.updateWorkerStatus(record.workerId, status),
                        onOtChanged: (ot) =>
                            controller.updateWorkerOt(record.workerId, ot),
                        onRemove: () => controller.removeWorker(record.workerId),
                      );
                    }),
                  const SizedBox(height: 30),
                ],
              ),
            ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              offset: const Offset(0, -2),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: state.isLoading || user == null
                    ? null
                    : () => controller.saveDraftLocally(user.id),
                child: const Text(AppStrings.saveDraft),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.supervisorPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: state.isLoading || user == null
                    ? null
                    : () async {
                        final navigator = Navigator.of(context);
                        final ok = await controller.submitEntry(supervisorId: user.id);
                        if (ok && mounted) {
                          navigator.pop();
                        }
                      },
                child: state.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        AppStrings.submitEntry,
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension on TextEditingController {
  void disposeDisposeSafe() {
    try {
      dispose();
    } catch (_) {}
  }
}
