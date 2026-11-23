/// মজুরি খতিয়ান মডেল (Wage Ledger Model)
class WageLedgerModel {
  final String id;
  final String projectId;
  final String? projectName;
  final String workerId;
  final String workerName;
  final String designationName;
  final DateTime workDate;
  final double dailyAmount;
  final double overtimeAmount;
  final double totalAmount;
  final double allocatedPaid;

  const WageLedgerModel({
    required this.id,
    required this.projectId,
    this.projectName,
    required this.workerId,
    required this.workerName,
    this.designationName = 'শ্রমিক',
    required this.workDate,
    required this.dailyAmount,
    this.overtimeAmount = 0.0,
    required this.totalAmount,
    this.allocatedPaid = 0.0,
  });

  double get dueAmount => (totalAmount - allocatedPaid).clamp(0.0, double.infinity);
  bool get isFullyPaid => dueAmount <= 0.0;

  factory WageLedgerModel.fromJson(Map<String, dynamic> json) {
    final worker = json['profiles'] as Map<String, dynamic>?;
    final project = json['projects'] as Map<String, dynamic>?;
    final designation = json['designations'] as Map<String, dynamic>?;

    return WageLedgerModel(
      id: json['id'] as String,
      projectId: json['project_id'] as String,
      projectName: project?['name'] as String?,
      workerId: json['worker_id'] as String,
      workerName: worker?['name'] as String? ?? 'শ্রমিক',
      designationName: designation?['name'] as String? ?? 'শ্রমিক',
      workDate: DateTime.parse(json['work_date'] as String),
      dailyAmount: (json['daily_amount'] as num?)?.toDouble() ?? 0.0,
      overtimeAmount: (json['overtime_amount'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      allocatedPaid: (json['allocated_paid'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
