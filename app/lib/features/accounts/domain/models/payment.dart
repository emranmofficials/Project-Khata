class PaymentAllocation {
  final String id;
  final String organizationId;
  final String paymentId;
  final String projectId;
  final String wageLedgerId;
  final double allocatedAmount;
  final String method; // fifo, manual
  final DateTime createdAt;
  final String? projectName;

  const PaymentAllocation({
    required this.id,
    required this.organizationId,
    required this.paymentId,
    required this.projectId,
    required this.wageLedgerId,
    required this.allocatedAmount,
    this.method = 'fifo',
    required this.createdAt,
    this.projectName,
  });

  factory PaymentAllocation.fromJson(Map<String, dynamic> json) {
    final projects = json['projects'] as Map<String, dynamic>?;
    return PaymentAllocation(
      id: json['id'] as String,
      organizationId: json['organization_id'] as String,
      paymentId: json['payment_id'] as String,
      projectId: json['project_id'] as String,
      wageLedgerId: json['wage_ledger_id'] as String,
      allocatedAmount: (json['allocated_amount'] as num).toDouble(),
      method: json['method'] as String? ?? 'fifo',
      createdAt: DateTime.parse(json['created_at'] as String),
      projectName: projects?['name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'organization_id': organizationId,
      'payment_id': paymentId,
      'project_id': projectId,
      'wage_ledger_id': wageLedgerId,
      'allocated_amount': allocatedAmount,
      'method': method,
    };
  }
}

class Payment {
  final String id;
  final String organizationId;
  final String payeeType; // worker, supervisor
  final String payeeId;
  final double amount;
  final DateTime paymentDate;
  final String paymentMethod; // cash, bkash, nagad, bank
  final String? note;
  final String createdBy;
  final DateTime createdAt;
  // Joined fields
  final String? payeeName;
  final String? payeeMobile;
  final List<PaymentAllocation> allocations;

  const Payment({
    required this.id,
    required this.organizationId,
    this.payeeType = 'worker',
    required this.payeeId,
    required this.amount,
    required this.paymentDate,
    this.paymentMethod = 'cash',
    this.note,
    required this.createdBy,
    required this.createdAt,
    this.payeeName,
    this.payeeMobile,
    this.allocations = const [],
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    final profiles = json['profiles'] as Map<String, dynamic>?;
    final allocList = (json['payment_allocations'] as List<dynamic>?)
            ?.map((e) => PaymentAllocation.fromJson(e as Map<String, dynamic>))
            .toList() ??
        const [];

    return Payment(
      id: json['id'] as String,
      organizationId: json['organization_id'] as String,
      payeeType: json['payee_type'] as String? ?? 'worker',
      payeeId: json['payee_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      paymentDate: DateTime.parse(json['payment_date'] as String),
      paymentMethod: json['payment_method'] as String? ?? 'cash',
      note: json['note'] as String?,
      createdBy: json['created_by'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      payeeName: profiles?['name'] as String?,
      payeeMobile: profiles?['mobile'] as String?,
      allocations: allocList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'organization_id': organizationId,
      'payee_type': payeeType,
      'payee_id': payeeId,
      'amount': amount,
      'payment_date': paymentDate.toIso8601String().split('T').first,
      'payment_method': paymentMethod,
      'note': note,
      'created_by': createdBy,
    };
  }
}
