import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/attendance_record.dart';
import '../../domain/models/daily_entry.dart';
import '../../data/attendance_repository.dart';
import '../../../auth/domain/models/app_user.dart';
import '../../../projects/domain/models/project.dart';
import '../../../../core/services/location_service.dart';

class AttendanceEntryState {
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;
  final Project? selectedProject;
  final DateTime entryDate;
  final String workDescription;
  final String notes;
  final List<AttendanceRecord> teamRecords;
  final LocationResult? locationResult;
  final bool isDraftSaved;

  const AttendanceEntryState({
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
    this.selectedProject,
    required this.entryDate,
    this.workDescription = '',
    this.notes = '',
    this.teamRecords = const [],
    this.locationResult,
    this.isDraftSaved = false,
  });

  AttendanceEntryState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    Project? selectedProject,
    DateTime? entryDate,
    String? workDescription,
    String? notes,
    List<AttendanceRecord>? teamRecords,
    LocationResult? locationResult,
    bool? isDraftSaved,
  }) {
    return AttendanceEntryState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
      selectedProject: selectedProject ?? this.selectedProject,
      entryDate: entryDate ?? this.entryDate,
      workDescription: workDescription ?? this.workDescription,
      notes: notes ?? this.notes,
      teamRecords: teamRecords ?? this.teamRecords,
      locationResult: locationResult ?? this.locationResult,
      isDraftSaved: isDraftSaved ?? this.isDraftSaved,
    );
  }
}

class AttendanceController extends StateNotifier<AttendanceEntryState> {
  final AttendanceRepository _repository;
  final LocationService _locationService;

  AttendanceController(this._repository, this._locationService)
      : super(AttendanceEntryState(entryDate: DateTime.now()));

  void initForProject(Project project, {AppUser? currentUser}) async {
    state = state.copyWith(
      selectedProject: project,
      entryDate: DateTime.now(),
      teamRecords: [],
      workDescription: '',
      notes: '',
      isLoading: true,
    );

    // ১. লোকাল ড্রাফট আছে কিনা পরীক্ষা
    final draft = await _repository.loadLocalDraft(project.id);
    if (draft != null) {
      try {
        final entry = DailyEntry.fromJson(draft['entry'] as Map<String, dynamic>);
        final records = (draft['records'] as List<dynamic>)
            .map((r) => AttendanceRecord.fromJson(r as Map<String, dynamic>))
            .toList();

        state = state.copyWith(
          workDescription: entry.workDescription ?? '',
          notes: entry.notes ?? '',
          teamRecords: records,
          entryDate: entry.entryDate,
          isDraftSaved: true,
          isLoading: false,
        );
        return;
      } catch (_) {
        // ড্রাফট পার্স ব্যর্থ হলে স্বাভাবিক ফ্লো
      }
    }

    state = state.copyWith(isLoading: false);
  }

  void setDate(DateTime date) {
    state = state.copyWith(entryDate: date);
  }

  void setWorkDescription(String description) {
    state = state.copyWith(workDescription: description);
  }

  void setNotes(String notes) {
    state = state.copyWith(notes: notes);
  }

  Future<void> checkLocation() async {
    final project = state.selectedProject;
    if (project == null) return;

    state = state.copyWith(isLoading: true);
    final result = await _locationService.verifySiteLocation(
      siteLat: project.lat,
      siteLng: project.lng,
      geofenceRadiusMeters: project.geofenceRadiusM,
    );

    // সব রেকর্ডে লোকেশন আপডেট
    final updatedRecords = state.teamRecords.map((r) {
      return r.copyWith(
        supervisorLat: result.latitude,
        supervisorLng: result.longitude,
        siteDistanceMeters: result.distanceMeters,
        locationStatus: LocationStatus.fromString(result.locationStatus),
      );
    }).toList();

    state = state.copyWith(
      locationResult: result,
      teamRecords: updatedRecords,
      isLoading: false,
    );
  }

  void addWorker(AppUser worker) {
    // ডুপ্লিকেট চেক
    final exists = state.teamRecords.any((r) => r.workerId == worker.id);
    if (exists) return;

    final project = state.selectedProject;
    final loc = state.locationResult;

    final newRecord = AttendanceRecord(
      id: '',
      organizationId: project?.organizationId ?? worker.organizationId,
      dailyEntryId: '',
      projectId: project?.id ?? '',
      workerId: worker.id,
      entryDate: state.entryDate,
      status: AttendanceStatus.fullDay,
      otHours: 0.0,
      supervisorLat: loc?.latitude,
      supervisorLng: loc?.longitude,
      siteDistanceMeters: loc?.distanceMeters,
      locationStatus: loc != null
          ? LocationStatus.fromString(loc.locationStatus)
          : LocationStatus.insideSite,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      workerName: worker.name,
      workerMobile: worker.mobile,
      designationName: worker.designationTitle,
      dailyWage: worker.dailyWage,
    );

    state = state.copyWith(
      teamRecords: [...state.teamRecords, newRecord],
    );
  }

  void removeWorker(String workerId) {
    state = state.copyWith(
      teamRecords: state.teamRecords.where((r) => r.workerId != workerId).toList(),
    );
  }

  void updateWorkerStatus(String workerId, AttendanceStatus status) {
    final updated = state.teamRecords.map((r) {
      if (r.workerId == workerId) {
        return r.copyWith(status: status);
      }
      return r;
    }).toList();

    state = state.copyWith(teamRecords: updated);
  }

  void updateWorkerOt(String workerId, double otHours) {
    final updated = state.teamRecords.map((r) {
      if (r.workerId == workerId) {
        return r.copyWith(otHours: otHours);
      }
      return r;
    }).toList();

    state = state.copyWith(teamRecords: updated);
  }

  Future<void> saveDraftLocally(String supervisorId) async {
    final project = state.selectedProject;
    if (project == null) return;

    state = state.copyWith(isLoading: true);

    final entry = DailyEntry(
      id: '',
      organizationId: project.organizationId,
      projectId: project.id,
      supervisorId: supervisorId,
      entryDate: state.entryDate,
      workDescription: state.workDescription,
      status: EntryStatus.draft,
      notes: state.notes,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _repository.saveLocalDraft(
      projectId: project.id,
      entry: entry,
      records: state.teamRecords,
    );

    state = state.copyWith(
      isLoading: false,
      isDraftSaved: true,
      successMessage: 'ড্রাফট সফলভাবে ডিভাইসে সংরক্ষিত হয়েছে',
    );
  }

  Future<bool> submitEntry({
    required String supervisorId,
  }) async {
    final project = state.selectedProject;
    if (project == null) {
      state = state.copyWith(errorMessage: 'প্রজেক্ট নির্বাচন করা হয়নি');
      return false;
    }

    if (state.teamRecords.isEmpty) {
      state = state.copyWith(errorMessage: 'কমপক্ষে একজন শ্রমিকের হাজিরা দিন');
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final entry = DailyEntry(
        id: '',
        organizationId: project.organizationId,
        projectId: project.id,
        supervisorId: supervisorId,
        entryDate: state.entryDate,
        workDescription: state.workDescription,
        status: EntryStatus.submitted,
        notes: state.notes,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _repository.submitDailyEntry(
        entry: entry,
        records: state.teamRecords,
      );

      state = state.copyWith(
        isLoading: false,
        successMessage: 'দৈনিক এন্ট্রি ও হাজিরা সফলভাবে জমা হয়েছে!',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'সাবমিট ব্যর্থ: $e',
      );
      return false;
    }
  }
}

final attendanceControllerProvider =
    StateNotifierProvider<AttendanceController, AttendanceEntryState>((ref) {
  final repo = ref.watch(attendanceRepositoryProvider);
  final locationService = ref.watch(locationServiceProvider);
  return AttendanceController(repo, locationService);
});

// প্রোজেক্টের এন্ট্রি তালিকা প্রোভাইডার
final projectEntriesProvider =
    FutureProvider.family<List<DailyEntry>, String>((ref, projectId) async {
  final repo = ref.watch(attendanceRepositoryProvider);
  return repo.getDailyEntries(projectId);
});

// নির্দিষ্ট এন্ট্রির হাজিরা রেকর্ড প্রোভাইডার
final entryAttendanceProvider =
    FutureProvider.family<List<AttendanceRecord>, String>((ref, entryId) async {
  final repo = ref.watch(attendanceRepositoryProvider);
  return repo.getAttendanceForEntry(entryId);
});

// প্রতিষ্ঠানের শ্রমিক তালিকা প্রোভাইডার
final orgWorkersProvider =
    FutureProvider.family<List<AppUser>, String>((ref, orgId) async {
  final repo = ref.watch(attendanceRepositoryProvider);
  return repo.getOrganizationWorkers(orgId);
});

// শ্রমিকের হাজিরা ইতিহাস প্রোভাইডার
final workerAttendanceHistoryProvider =
    FutureProvider.family<List<AttendanceRecord>, String>((ref, workerId) async {
  final repo = ref.watch(attendanceRepositoryProvider);
  return repo.getWorkerAttendanceHistory(workerId);
});
