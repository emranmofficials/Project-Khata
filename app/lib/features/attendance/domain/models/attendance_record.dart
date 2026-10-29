enum AttendanceStatus {
  fullDay,
  halfDay,
  absent;

  String get value {
    switch (this) {
      case AttendanceStatus.fullDay:
        return 'full_day';
      case AttendanceStatus.halfDay:
        return 'half_day';
      case AttendanceStatus.absent:
        return 'absent';
    }
  }

  String get bengaliLabel {
    switch (this) {
      case AttendanceStatus.fullDay:
        return 'পূর্ণদিবস';
      case AttendanceStatus.halfDay:
        return 'অর্ধদিবস';
      case AttendanceStatus.absent:
        return 'অনুপস্থিত';
    }
  }

  double get wageMultiplier {
    switch (this) {
      case AttendanceStatus.fullDay:
        return 1.0;
      case AttendanceStatus.halfDay:
        return 0.5;
      case AttendanceStatus.absent:
        return 0.0;
    }
  }

  static AttendanceStatus fromString(String? value) {
    switch (value) {
      case 'half_day':
        return AttendanceStatus.halfDay;
      case 'absent':
        return AttendanceStatus.absent;
      case 'full_day':
      default:
        return AttendanceStatus.fullDay;
    }
  }
}

enum LocationStatus {
  insideSite,
  outsideSite,
  locationUnavailable;

  String get value {
    switch (this) {
      case LocationStatus.insideSite:
        return 'inside_site';
      case LocationStatus.outsideSite:
        return 'outside_site';
      case LocationStatus.locationUnavailable:
        return 'location_unavailable';
    }
  }

  String get bengaliLabel {
    switch (this) {
      case LocationStatus.insideSite:
        return 'সাইটের ভিতরে';
      case LocationStatus.outsideSite:
        return 'সাইটের বাইরে';
      case LocationStatus.locationUnavailable:
        return 'লোকেশন পাওয়া যায়নি';
    }
  }

  static LocationStatus fromString(String? value) {
    switch (value) {
      case 'outside_site':
        return LocationStatus.outsideSite;
      case 'location_unavailable':
        return LocationStatus.locationUnavailable;
      case 'inside_site':
      default:
        return LocationStatus.insideSite;
    }
  }
}

class AttendanceRecord {
  final String id;
  final String organizationId;
  final String dailyEntryId;
  final String projectId;
  final String workerId;
  final DateTime entryDate;
  final AttendanceStatus status;
  final double otHours;
  final double? supervisorLat;
  final double? supervisorLng;
  final double? siteDistanceMeters;
  final LocationStatus locationStatus;
  final bool isApproved;
  final String? remarks;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Joined fields for display
  final String? workerName;
  final String? workerMobile;
  final String? designationName;
  final double? dailyWage;

  const AttendanceRecord({
    required this.id,
    required this.organizationId,
    required this.dailyEntryId,
    required this.projectId,
    required this.workerId,
    required this.entryDate,
    this.status = AttendanceStatus.fullDay,
    this.otHours = 0.0,
    this.supervisorLat,
    this.supervisorLng,
    this.siteDistanceMeters,
    this.locationStatus = LocationStatus.insideSite,
    this.isApproved = false,
    this.remarks,
    required this.createdAt,
    required this.updatedAt,
    this.workerName,
    this.workerMobile,
    this.designationName,
    this.dailyWage,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    final profile = json['profiles'] as Map<String, dynamic>?;
    final designation = profile?['designations'] as Map<String, dynamic>?;

    return AttendanceRecord(
      id: json['id'] as String,
      organizationId: json['organization_id'] as String,
      dailyEntryId: json['daily_entry_id'] as String,
      projectId: json['project_id'] as String,
      workerId: json['worker_id'] as String,
      entryDate: json['entry_date'] != null
          ? DateTime.parse(json['entry_date'] as String)
          : DateTime.now(),
      status: AttendanceStatus.fromString(json['status'] as String?),
      otHours: (json['ot_hours'] != null)
          ? double.tryParse(json['ot_hours'].toString()) ?? 0.0
          : 0.0,
      supervisorLat: json['supervisor_lat'] != null
          ? (json['supervisor_lat'] as num).toDouble()
          : null,
      supervisorLng: json['supervisor_lng'] != null
          ? (json['supervisor_lng'] as num).toDouble()
          : null,
      siteDistanceMeters: json['site_distance_meters'] != null
          ? (json['site_distance_meters'] as num).toDouble()
          : null,
      locationStatus: LocationStatus.fromString(json['location_status'] as String?),
      isApproved: json['is_approved'] as bool? ?? false,
      remarks: json['remarks'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
      workerName: profile?['name'] as String?,
      workerMobile: profile?['mobile'] as String?,
      designationName: designation?['title'] as String?,
      dailyWage: designation?['daily_wage'] != null
          ? (designation!['daily_wage'] as num).toDouble()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organization_id': organizationId,
      'daily_entry_id': dailyEntryId,
      'project_id': projectId,
      'worker_id': workerId,
      'entry_date':
          "${entryDate.year.toString().padLeft(4, '0')}-${entryDate.month.toString().padLeft(2, '0')}-${entryDate.day.toString().padLeft(2, '0')}",
      'status': status.value,
      'ot_hours': otHours,
      'supervisor_lat': supervisorLat,
      'supervisor_lng': supervisorLng,
      'site_distance_meters': siteDistanceMeters,
      'location_status': locationStatus.value,
      'is_approved': isApproved,
      'remarks': remarks,
    };
  }

  AttendanceRecord copyWith({
    String? id,
    String? organizationId,
    String? dailyEntryId,
    String? projectId,
    String? workerId,
    DateTime? entryDate,
    AttendanceStatus? status,
    double? otHours,
    double? supervisorLat,
    double? supervisorLng,
    double? siteDistanceMeters,
    LocationStatus? locationStatus,
    bool? isApproved,
    String? remarks,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? workerName,
    String? workerMobile,
    String? designationName,
    double? dailyWage,
  }) {
    return AttendanceRecord(
      id: id ?? this.id,
      organizationId: organizationId ?? this.organizationId,
      dailyEntryId: dailyEntryId ?? this.dailyEntryId,
      projectId: projectId ?? this.projectId,
      workerId: workerId ?? this.workerId,
      entryDate: entryDate ?? this.entryDate,
      status: status ?? this.status,
      otHours: otHours ?? this.otHours,
      supervisorLat: supervisorLat ?? this.supervisorLat,
      supervisorLng: supervisorLng ?? this.supervisorLng,
      siteDistanceMeters: siteDistanceMeters ?? this.siteDistanceMeters,
      locationStatus: locationStatus ?? this.locationStatus,
      isApproved: isApproved ?? this.isApproved,
      remarks: remarks ?? this.remarks,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      workerName: workerName ?? this.workerName,
      workerMobile: workerMobile ?? this.workerMobile,
      designationName: designationName ?? this.designationName,
      dailyWage: dailyWage ?? this.dailyWage,
    );
  }
}
