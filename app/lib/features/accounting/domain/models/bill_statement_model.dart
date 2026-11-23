/// শ্রমিক-বিল খতিয়ান স্ন্যাপশট মডেল (Bill Statements Model)
class BillStatementModel {
  final String id;
  final String projectId;
  final String? projectName;
  final DateTime periodFrom;
  final DateTime periodTo;
  final String preset; // 'custom', 'monthly', 'weekly'
  final DateTime? sentToClientAt;
  final Map<String, dynamic> snapshot;
  final bool locked;
  final DateTime createdAt;

  const BillStatementModel({
    required this.id,
    required this.projectId,
    this.projectName,
    required this.periodFrom,
    required this.periodTo,
    this.preset = 'monthly',
    this.sentToClientAt,
    required this.snapshot,
    this.locked = true,
    required this.createdAt,
  });

  double get totalWage => (snapshot['total_wage'] as num?)?.toDouble() ?? 0.0;
  double get totalMaterial => (snapshot['total_material'] as num?)?.toDouble() ?? 0.0;
  double get totalSiteExpense => (snapshot['total_site_expense'] as num?)?.toDouble() ?? 0.0;
  double get totalBilled => (snapshot['total_billed'] as num?)?.toDouble() ?? 0.0;
  double get totalClientPaid => (snapshot['total_client_paid'] as num?)?.toDouble() ?? 0.0;
  double get netDue => (snapshot['net_due'] as num?)?.toDouble() ?? 0.0;
  int get totalWorkingDays => (snapshot['total_working_days'] as num?)?.toInt() ?? 0;

  factory BillStatementModel.fromJson(Map<String, dynamic> json) {
    final project = json['projects'] as Map<String, dynamic>?;

    return BillStatementModel(
      id: json['id'] as String,
      projectId: json['project_id'] as String,
      projectName: project?['name'] as String?,
      periodFrom: DateTime.parse(json['period_from'] as String),
      periodTo: DateTime.parse(json['period_to'] as String),
      preset: json['preset'] as String? ?? 'monthly',
      sentToClientAt: json['sent_to_client_at'] != null ? DateTime.tryParse(json['sent_to_client_at']) : null,
      snapshot: (json['snapshot_json'] as Map<String, dynamic>?) ?? {},
      locked: json['locked'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String? ?? DateTime.now().toIso8601String()),
    );
  }
}
