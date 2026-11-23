/// অডিট লগ মডেল (অপরিবর্তনীয় অডিট ট্রেইল)
class AuditLogModel {
  final String id;
  final String? actorId;
  final String actorName;
  final String actorRole;
  final String action;
  final String tableName;
  final String? recordId;
  final Map<String, dynamic>? newData;
  final DateTime createdAt;

  const AuditLogModel({
    required this.id,
    this.actorId,
    required this.actorName,
    required this.actorRole,
    required this.action,
    required this.tableName,
    this.recordId,
    this.newData,
    required this.createdAt,
  });

  String get actionBengaliDescription {
    switch (action.toUpperCase()) {
      case 'CREATE_ORGANIZATION':
        return 'নতুন প্রতিষ্ঠান তৈরি';
      case 'CREATE_PROJECT':
        return 'নতুন প্রজেক্ট তৈরি';
      case 'RECORD_WORKER_PAYMENT':
        return 'শ্রমিক মজুরি পেমেন্ট ও FIFO বরাদ্দ';
      case 'RECORD_CLIENT_PAYMENT':
        return 'ক্লায়েন্ট পেমেন্ট গ্রহণ রেকর্ড';
      case 'OPEN_DAILY_ENTRY':
        return 'দৈনিক কাজের এন্ট্রি খোলা';
      case 'SUBMIT_DAILY_ENTRY':
        return 'দৈনিক এন্ট্রি জমা প্রদান';
      case 'APPROVE_DAILY_ENTRY':
        return 'এন্ট্রি অনুমোদন ও লক';
      default:
        return action;
    }
  }

  factory AuditLogModel.fromJson(Map<String, dynamic> json) {
    final actor = json['profiles'] as Map<String, dynamic>?;

    return AuditLogModel(
      id: json['id'] as String,
      actorId: json['actor_id'] as String?,
      actorName: actor?['name'] as String? ?? 'সিস্টেম',
      actorRole: json['actor_role'] as String? ?? 'contractor',
      action: json['action'] as String? ?? 'MUTATION',
      tableName: json['table_name'] as String? ?? '',
      recordId: json['record_id'] as String?,
      newData: json['new_data'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String? ?? DateTime.now().toIso8601String()),
    );
  }
}
