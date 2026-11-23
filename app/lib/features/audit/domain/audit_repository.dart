import 'models/audit_log_model.dart';

/// অডিট রিপোজিটরি ইন্টারফেস (শুধু পড়া যাবে)
abstract class AuditRepository {
  Future<List<AuditLogModel>> getAuditLogs({int limit = 50});
}
