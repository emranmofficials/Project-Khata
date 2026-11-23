/// শ্রমিক ও সুপারভাইজার পেমেন্ট মডেল
class PaymentModel {
  final String id;
  final String payeeId;
  final String payeeName;
  final String payeeRole;
  final double amount;
  final DateTime paymentDate;
  final String? note;
  final int allocationsCount;

  const PaymentModel({
    required this.id,
    required this.payeeId,
    required this.payeeName,
    required this.payeeRole,
    required this.amount,
    required this.paymentDate,
    this.note,
    this.allocationsCount = 0,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    final payee = json['profiles'] as Map<String, dynamic>?;

    return PaymentModel(
      id: json['id'] as String,
      payeeId: json['payee_id'] as String,
      payeeName: payee?['name'] as String? ?? 'কর্মী',
      payeeRole: json['payee_role'] as String? ?? 'worker',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      paymentDate: DateTime.parse(json['payment_date'] as String),
      note: json['note'] as String?,
      allocationsCount: (json['payment_allocations'] as List<dynamic>?)?.length ?? 0,
    );
  }
}
