class WorkerModel {
  final String id;
  final String organizationId;
  final String role; // 'worker', 'supervisor'
  final String name;
  final String mobile;
  final String? email;
  final String? designationId;
  final String? designationName;
  final double dailyRate;
  final double overtimeRatePerHour;
  final String status;
  final DateTime? createdAt;

  const WorkerModel({
    required this.id,
    required this.organizationId,
    required this.role,
    required this.name,
    required this.mobile,
    this.email,
    this.designationId,
    this.designationName,
    this.dailyRate = 0.0,
    this.overtimeRatePerHour = 0.0,
    this.status = 'active',
    this.createdAt,
  });

  bool get isActive => status == 'active';
  bool get isSupervisor => role == 'supervisor';
  bool get isWorker => role == 'worker';

  factory WorkerModel.fromJson(Map<String, dynamic> json) {
    final designation = json['designations'] as Map<String, dynamic>?;
    return WorkerModel(
      id: json['id'] as String,
      organizationId: json['organization_id'] as String? ?? '',
      role: json['role'] as String? ?? 'worker',
      name: json['name'] as String? ?? 'নামহীন',
      mobile: json['mobile'] as String? ?? '',
      email: json['email'] as String?,
      designationId: json['designation_id'] as String?,
      designationName: designation?['name'] as String?,
      dailyRate: (designation?['daily_rate'] as num?)?.toDouble() ??
          (json['daily_rate'] as num?)?.toDouble() ??
          0.0,
      overtimeRatePerHour:
          (designation?['overtime_rate_per_hour'] as num?)?.toDouble() ??
              (json['overtime_rate_per_hour'] as num?)?.toDouble() ??
              0.0,
      status: json['status'] as String? ?? 'active',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organization_id': organizationId,
      'role': role,
      'name': name,
      'mobile': mobile,
      if (email != null) 'email': email,
      if (designationId != null) 'designation_id': designationId,
      'status': status,
    };
  }
}
