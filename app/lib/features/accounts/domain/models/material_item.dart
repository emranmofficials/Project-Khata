class MaterialItem {
  final String id;
  final String organizationId;
  final String projectId;
  final String name;
  final String unit;
  final double qty;
  final double unitPrice;
  final double totalPrice;
  final DateTime purchaseDate;
  final String? receiptUrl;
  final String addedBy;
  final String? notes;
  final DateTime createdAt;
  final String? addedByName;
  final String? projectName;

  const MaterialItem({
    required this.id,
    required this.organizationId,
    required this.projectId,
    required this.name,
    this.unit = 'বস্তা',
    required this.qty,
    required this.unitPrice,
    required this.totalPrice,
    required this.purchaseDate,
    this.receiptUrl,
    required this.addedBy,
    this.notes,
    required this.createdAt,
    this.addedByName,
    this.projectName,
  });

  factory MaterialItem.fromJson(Map<String, dynamic> json) {
    final profiles = json['profiles'] as Map<String, dynamic>?;
    final projects = json['projects'] as Map<String, dynamic>?;

    final q = (json['qty'] as num).toDouble();
    final p = (json['unit_price'] as num).toDouble();
    final total = (json['total_price'] as num?)?.toDouble() ?? (q * p);

    return MaterialItem(
      id: json['id'] as String,
      organizationId: json['organization_id'] as String,
      projectId: json['project_id'] as String,
      name: json['name'] as String,
      unit: json['unit'] as String? ?? 'বস্তা',
      qty: q,
      unitPrice: p,
      totalPrice: total,
      purchaseDate: DateTime.parse(json['purchase_date'] as String),
      receiptUrl: json['receipt_url'] as String?,
      addedBy: json['added_by'] as String,
      notes: json['notes'] as String?,
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
      'name': name,
      'unit': unit,
      'qty': qty,
      'unit_price': unitPrice,
      'purchase_date': purchaseDate.toIso8601String().split('T').first,
      'receipt_url': receiptUrl,
      'added_by': addedBy,
      'notes': notes,
    };
  }
}
