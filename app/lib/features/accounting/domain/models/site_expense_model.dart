/// সাইট খরচ মডেল (Site Expenses Model)
class SiteExpenseModel {
  final String id;
  final String projectId;
  final String category;
  final double amount;
  final DateTime expenseDate;
  final String? note;
  final String? receiptUrl;
  final String status; // 'pending', 'approved', 'rejected'
  final String addedBy;
  final String? addedByName;
  final String? decisionReason;

  const SiteExpenseModel({
    required this.id,
    required this.projectId,
    required this.category,
    required this.amount,
    required this.expenseDate,
    this.note,
    this.receiptUrl,
    required this.status,
    required this.addedBy,
    this.addedByName,
    this.decisionReason,
  });

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';

  String get statusBengaliLabel {
    switch (status) {
      case 'pending':
        return 'অপেক্ষমাণ';
      case 'approved':
        return 'অনুমোদিত';
      case 'rejected':
        return 'প্রত্যাখ্যাত';
      default:
        return status;
    }
  }

  factory SiteExpenseModel.fromJson(Map<String, dynamic> json) {
    final adder = json['profiles'] as Map<String, dynamic>?;

    return SiteExpenseModel(
      id: json['id'] as String,
      projectId: json['project_id'] as String,
      category: json['category'] as String? ?? 'বিবিধ',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      expenseDate: DateTime.parse(json['expense_date'] as String),
      note: json['note'] as String?,
      receiptUrl: json['receipt_url'] as String?,
      status: json['status'] as String? ?? 'pending',
      addedBy: json['added_by'] as String,
      addedByName: adder?['name'] as String?,
      decisionReason: json['decision_reason'] as String?,
    );
  }
}
