/// মালামাল মডেল (Materials Model)
class MaterialModel {
  final String id;
  final String projectId;
  final String name;
  final String unit;
  final double qty;
  final double unitPrice;
  final double totalPrice;
  final DateTime purchaseDate;
  final String? receiptUrl;
  final String addedBy;
  final String addedByRole; // 'client', 'contractor', 'supervisor'
  final String? addedByName;

  const MaterialModel({
    required this.id,
    required this.projectId,
    required this.name,
    required this.unit,
    required this.qty,
    required this.unitPrice,
    required this.totalPrice,
    required this.purchaseDate,
    this.receiptUrl,
    required this.addedBy,
    required this.addedByRole,
    this.addedByName,
  });

  bool get isAddedByClient => addedByRole.toLowerCase() == 'client';
  bool get canContractorEdit => !isAddedByClient; // PRD নিয়ম ৫৭

  factory MaterialModel.fromJson(Map<String, dynamic> json) {
    final adder = json['profiles'] as Map<String, dynamic>?;

    return MaterialModel(
      id: json['id'] as String,
      projectId: json['project_id'] as String,
      name: json['name'] as String,
      unit: json['unit'] as String,
      qty: (json['qty'] as num?)?.toDouble() ?? 0.0,
      unitPrice: (json['unit_price'] as num?)?.toDouble() ?? 0.0,
      totalPrice: (json['total_price'] as num?)?.toDouble() ?? 0.0,
      purchaseDate: DateTime.parse(json['purchase_date'] as String),
      receiptUrl: json['receipt_url'] as String?,
      addedBy: json['added_by'] as String,
      addedByRole: json['added_by_role'] as String? ?? 'contractor',
      addedByName: adder?['name'] as String?,
    );
  }
}
