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

  String toFormattedReport({String? projectName, String? clientName}) {
    final buffer = StringBuffer();
    buffer.writeln('=========================================');
    buffer.writeln('প্রজেক্ট খাতা — প্রজেক্ট বিল স্টেটমেন্ট');
    buffer.writeln('=========================================');
    buffer.writeln('প্রজেক্ট: ${projectName ?? this.projectName ?? ""}');
    if (clientName != null) buffer.writeln('ক্লায়েন্ট: $clientName');
    buffer.writeln('সময়কাল: ${periodFrom.toIso8601String().split('T').first} হতে ${periodTo.toIso8601String().split('T').first}');
    buffer.writeln('স্ট্যাটাস: ${isLocked ? "লক ও ক্লায়েন্টকে প্রেরিত" : "খসড়া"}');
    buffer.writeln('তৈরির তারিখ: ${createdAt.toIso8601String().split('T').first}');
    buffer.writeln('-----------------------------------------');

    if (lockedSnapshot != null && lockedSnapshot!.isNotEmpty) {
      final s = lockedSnapshot!;
      if (s.containsKey('summary')) {
        final sum = s['summary'] as Map<String, dynamic>;
        buffer.writeln('হিসাব সারসংক্ষেপ:');
        buffer.writeln('  মোট চুক্তি/বাজেট: ৳ ${sum['total_budget'] ?? 0}');
        buffer.writeln('  ক্লায়েন্ট পরিশোধ: ৳ ${sum['total_client_paid'] ?? 0}');
        buffer.writeln('  বর্তমান ক্লায়েন্ট বাকি: ৳ ${sum['client_due'] ?? 0}');
        buffer.writeln('  মোট খরচ: ৳ ${sum['total_project_expenses'] ?? 0}');
        buffer.writeln('    - মোট মজুরি অর্জিত: ৳ ${sum['total_wages_earned'] ?? 0}');
        buffer.writeln('    - মজুরি পরিশোধিত: ৳ ${sum['total_wages_paid'] ?? 0}');
        buffer.writeln('    - মোট মালামাল খরচ: ৳ ${sum['total_materials_cost'] ?? 0}');
        buffer.writeln('    - মোট সাইট খরচ: ৳ ${sum['total_expenses_cost'] ?? 0}');
      }
    }
    buffer.writeln('=========================================');
    return buffer.toString();
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
  double get totalExpenses => totalProjectExpenses;

  double get clientDue =>
      (totalBudgetOrContractValue - totalClientPaid).clamp(0, double.infinity);

  double get workerWagesDue =>
      (totalWagesEarned - totalWagesPaid).clamp(0, double.infinity);
  double get wagesDue => workerWagesDue;

  double get netProfitOrBalance =>
      totalBudgetOrContractValue - totalProjectExpenses;
  double get estimatedProfit => netProfitOrBalance;
}
