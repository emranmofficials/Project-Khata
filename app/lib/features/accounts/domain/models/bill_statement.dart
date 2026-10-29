class BillStatement {
  final String id;
  final String organizationId;
  final String projectId;
  final DateTime periodFrom;
  final DateTime periodTo;
  final String preset; // custom, weekly, monthly
  final String generatedBy;
  final DateTime? sentToClientAt;
  final bool isLocked;
  final Map<String, dynamic>? lockedSnapshot;
  final String? fileUrl;
  final DateTime createdAt;
  final String? projectName;

  const BillStatement({
    required this.id,
    required this.organizationId,
    required this.projectId,
    required this.periodFrom,
    required this.periodTo,
    this.preset = 'custom',
    required this.generatedBy,
    this.sentToClientAt,
    this.isLocked = false,
    this.lockedSnapshot,
    this.fileUrl,
    required this.createdAt,
    this.projectName,
  });

  factory BillStatement.fromJson(Map<String, dynamic> json) {
    final projects = json['projects'] as Map<String, dynamic>?;
    return BillStatement(
      id: json['id'] as String,
      organizationId: json['organization_id'] as String,
      projectId: json['project_id'] as String,
      periodFrom: DateTime.parse(json['period_from'] as String),
      periodTo: DateTime.parse(json['period_to'] as String),
      preset: json['preset'] as String? ?? 'custom',
      generatedBy: json['generated_by'] as String,
      sentToClientAt: json['sent_to_client_at'] != null
          ? DateTime.parse(json['sent_to_client_at'] as String)
          : null,
      isLocked: json['is_locked'] as bool? ?? false,
      lockedSnapshot: json['locked_snapshot'] as Map<String, dynamic>?,
      fileUrl: json['file_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      projectName: projects?['name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'organization_id': organizationId,
      'project_id': projectId,
      'period_from': periodFrom.toIso8601String().split('T').first,
      'period_to': periodTo.toIso8601String().split('T').first,
      'preset': preset,
      'generated_by': generatedBy,
      'sent_to_client_at': sentToClientAt?.toIso8601String(),
      'is_locked': isLocked,
      'locked_snapshot': lockedSnapshot,
      'file_url': fileUrl,
    };
  }
}

class ProjectAccountsSummary {
  final String projectId;
  final String projectName;
  final double totalBudgetOrContractValue;
  final double totalClientPaid;
  final double totalWagesEarned;
  final double totalWagesPaid;
  final double totalMaterialsCost;
  final double totalExpensesCost;

  const ProjectAccountsSummary({
    required this.projectId,
    required this.projectName,
    required this.totalBudgetOrContractValue,
    required this.totalClientPaid,
    required this.totalWagesEarned,
    required this.totalWagesPaid,
    required this.totalMaterialsCost,
    required this.totalExpensesCost,
  });

  double get totalProjectExpenses =>
      totalWagesEarned + totalMaterialsCost + totalExpensesCost;

  double get clientDue =>
      (totalBudgetOrContractValue - totalClientPaid).clamp(0, double.infinity);

  double get workerWagesDue =>
      (totalWagesEarned - totalWagesPaid).clamp(0, double.infinity);

  double get netProfitOrBalance =>
      totalBudgetOrContractValue - totalProjectExpenses;
}
