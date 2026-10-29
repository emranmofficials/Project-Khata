class ClientPayment {
  final String id;
  final String organizationId;
  final String projectId;
  final double amount;
  final DateTime paymentDate;
  final String paymentMethod; // cash, bank, cheque, bkash, nagad
  final String? referenceNo;
  final String? note;
  final String? receiptUrl;
  final String receivedBy;
  final DateTime createdAt;
  final String? receivedByName;
  final String? projectName;

  const ClientPayment({
    required this.id,
    required this.organizationId,
    required this.projectId,
    required this.amount,
    required this.paymentDate,
    this.paymentMethod = 'bank',
    this.referenceNo,
    this.note,
    this.receiptUrl,
    required this.receivedBy,
    required this.createdAt,
    this.receivedByName,
    this.projectName,
  });

  factory ClientPayment.fromJson(Map<String, dynamic> json) {
    final profiles = json['profiles'] as Map<String, dynamic>?;
    final projects = json['projects'] as Map<String, dynamic>?;

    return ClientPayment(
      id: json['id'] as String,
      organizationId: json['organization_id'] as String,
      projectId: json['project_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      paymentDate: DateTime.parse(json['payment_date'] as String),
      paymentMethod: json['payment_method'] as String? ?? 'bank',
      referenceNo: json['reference_no'] as String?,
      note: json['note'] as String?,
      receiptUrl: json['receipt_url'] as String?,
      receivedBy: json['received_by'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      receivedByName: profiles?['name'] as String?,
      projectName: projects?['name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'organization_id': organizationId,
      'project_id': projectId,
      'amount': amount,
      'payment_date': paymentDate.toIso8601String().split('T').first,
      'payment_method': paymentMethod,
      'reference_no': referenceNo,
      'note': note,
      'receipt_url': receiptUrl,
      'received_by': receivedBy,
    };
  }
}
