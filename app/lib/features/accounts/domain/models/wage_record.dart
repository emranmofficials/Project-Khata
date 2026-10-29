class WageRecord {
  final String id;
  final String organizationId;
  final String projectId;
  final String workerId;
  final DateTime workDate;
  final String? attendanceId;
  final double earnedAmount;
  final double overtimeAmount;
  final double totalEarned;
  final bool isPaid;
  final DateTime createdAt;
  final DateTime updatedAt;
  // Joined fields
  final String? workerName;
  final String? workerMobile;
  final String? designationTitle;
  final String? projectName;

  const WageRecord({
    required this.id,
    required this.organizationId,
    required this.projectId,
    required this.workerId,
    required this.workDate,
    this.attendanceId,
    required this.earnedAmount,
    required this.overtimeAmount,
    required this.totalEarned,
    this.isPaid = false,
    required this.createdAt,
    required this.updatedAt,
    this.workerName,
    this.workerMobile,
    this.designationTitle,
    this.projectName,
  });

  double get dueAmount => isPaid ? 0.0 : totalEarned;
  double get wageAmount => earnedAmount;
  String? get designationName => designationTitle;

  factory WageRecord.fromJson(Map<String, dynamic> json) {
    final profiles = json['profiles'] as Map<String, dynamic>?;
    final designations = profiles?['designations'] as Map<String, dynamic>?;
    final projects = json['projects'] as Map<String, dynamic>?;

    final earned = (json['earned_amount'] as num?)?.toDouble() ??
        (json['wage_amount'] as num?)?.toDouble() ??
        0.0;
    final ot = (json['overtime_amount'] as num?)?.toDouble() ?? 0.0;
    final total = (json['total_earned'] as num?)?.toDouble() ?? (earned + ot);
    final paid = json['is_paid'] as bool? ?? (json['status'] == 'paid');

    return WageRecord(
      id: json['id'] as String,
      organizationId: json['organization_id'] as String,
      projectId: json['project_id'] as String,
      workerId: json['worker_id'] as String,
      workDate: DateTime.parse(json['work_date'] as String),
      attendanceId: (json['attendance_id'] ?? json['attendance_record_id']) as String?,
      earnedAmount: earned,
      overtimeAmount: ot,
      totalEarned: total,
      isPaid: paid,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
      workerName: profiles?['name'] as String?,
      workerMobile: profiles?['mobile'] as String?,
      designationTitle: designations?['name'] as String?,
      projectName: projects?['name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organization_id': organizationId,
      'project_id': projectId,
      'worker_id': workerId,
      'work_date': workDate.toIso8601String().split('T').first,
      'attendance_id': attendanceId,
      'earned_amount': earnedAmount,
      'overtime_amount': overtimeAmount,
      'is_paid': isPaid,
    };
  }
}
