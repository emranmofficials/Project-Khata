class ExpenseItem {
  final String id;
  final String organizationId;
  final String projectId;
  final String category; // পরিবহন, যন্ত্রপাতি, চা-নাস্তা, ইউটিলিটি, অন্যান্য
  final double amount;
  final DateTime expenseDate;
  final String? note;
  final String? receiptUrl;
  final String addedBy;
  final DateTime createdAt;
  final String? addedByName;
  final String? projectName;

  const ExpenseItem({
    required this.id,
    required this.organizationId,
    required this.projectId,
    this.category = 'অন্যান্য',
    required this.amount,
    required this.expenseDate,
    this.note,
    this.receiptUrl,
    required this.addedBy,
    required this.createdAt,
    this.addedByName,
    this.projectName,
  });

  factory ExpenseItem.fromJson(Map<String, dynamic> json) {
    final profiles = json['profiles'] as Map<String, dynamic>?;
    final projects = json['projects'] as Map<String, dynamic>?;

    return ExpenseItem(
      id: json['id'] as String,
      organizationId: json['organization_id'] as String,
      projectId: json['project_id'] as String,
      category: json['category'] as String? ?? 'অন্যান্য',
      amount: (json['amount'] as num).toDouble(),
      expenseDate: DateTime.parse(json['expense_date'] as String),
      note: json['note'] as String?,
      receiptUrl: json['receipt_url'] as String?,
      addedBy: json['added_by'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      addedByName: profiles?['name'] as String?,
      projectName: projects?['name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'organization_id': organizationId,
      'project_id': projectId,
      'category': category,
      'amount': amount,
      'expense_date': expenseDate.toIso8601String().split('T').first,
      'note': note,
      'receipt_url': receiptUrl,
      'added_by': addedBy,
    };
  }
}

export 'client_payment.dart';

