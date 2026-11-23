/// হাজিরা রেকর্ড মডেল (Attendance Record Model)
class AttendanceRecordModel {
  final String id;
  final String entryId;
  final String workerId;
  final String workerName;
  final String workerMobile;
  final String designationName;
  final double dailyRate;
  final double overtimeRatePerHour;
  final DateTime entryDate;
  final String status; // 'present', 'absent', 'half', 'overtime'
  final double overtimeHours;
  final String markedBy;
  final DateTime markedAt;
  final double? latitude;
  final double? longitude;
  final double? distanceM;
  final String locationStatus; // 'verified', 'outside_site', 'not_available'
  final String approvalStatus; // 'auto', 'pending', 'approved', 'rejected'
  final String? approvedBy;

  const AttendanceRecordModel({
    required this.id,
    required this.entryId,
    required this.workerId,
    required this.workerName,
    required this.workerMobile,
    this.designationName = 'সাধারণ শ্রমিক',
    this.dailyRate = 0.0,
    this.overtimeRatePerHour = 0.0,
    required this.entryDate,
    required this.status,
    this.overtimeHours = 0.0,
    required this.markedBy,
    required this.markedAt,
    this.latitude,
    this.longitude,
    this.distanceM,
    this.locationStatus = 'not_available',
    this.approvalStatus = 'auto',
    this.approvedBy,
  });

  bool get isPresent => status == 'present';
  bool get isAbsent => status == 'absent';
  bool get isHalfDay => status == 'half';
  bool get isOvertime => status == 'overtime';

  bool get isLocationVerified => locationStatus == 'verified';
  bool get isOutsideSite => locationStatus == 'outside_site';
  bool get isLocationNotAvailable => locationStatus == 'not_available';

  bool get isPendingApproval => approvalStatus == 'pending';
  bool get isApproved => approvalStatus == 'approved' || approvalStatus == 'auto';
  bool get isRejected => approvalStatus == 'rejected';

  String get statusBengaliLabel {
    switch (status) {
      case 'present':
        return 'উপস্থিত';
      case 'absent':
        return 'অনুপস্থিত';
      case 'half':
        return 'অর্ধদিবস';
      case 'overtime':
        return 'ওভারটাইম';
      default:
        return status;
    }
  }

  String get locationBengaliLabel {
    switch (locationStatus) {
      case 'verified':
        return 'সঠিক';
      case 'outside_site':
        return 'সাইটের বাইরে';
      case 'not_available':
        return 'পাওয়া যায়নি';
      default:
        return locationStatus;
    }
  }

  factory AttendanceRecordModel.fromJson(Map<String, dynamic> json) {
    final worker = json['profiles'] as Map<String, dynamic>?;
    final designation = worker?['designations'] as Map<String, dynamic>?;

    return AttendanceRecordModel(
      id: json['id'] as String,
      entryId: json['entry_id'] as String,
      workerId: json['worker_id'] as String,
      workerName: worker?['name'] as String? ?? 'শ্রমিক',
      workerMobile: worker?['mobile'] as String? ?? '',
      designationName: designation?['name'] as String? ?? 'শ্রমিক',
      dailyRate: (designation?['daily_rate'] as num?)?.toDouble() ?? 0.0,
      overtimeRatePerHour: (designation?['overtime_rate_per_hour'] as num?)?.toDouble() ?? 0.0,
      entryDate: DateTime.parse(json['entry_date'] as String),
      status: json['status'] as String? ?? 'present',
      overtimeHours: (json['overtime_hours'] as num?)?.toDouble() ?? 0.0,
      markedBy: json['marked_by'] as String,
      markedAt: DateTime.parse(json['marked_at'] as String? ?? DateTime.now().toIso8601String()),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      distanceM: (json['distance_m'] as num?)?.toDouble(),
      locationStatus: json['location_status'] as String? ?? 'not_available',
      approvalStatus: json['approval_status'] as String? ?? 'auto',
      approvedBy: json['approved_by'] as String?,
    );
  }
}
