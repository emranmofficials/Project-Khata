import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/audit_repository.dart';
import '../domain/models/audit_log_model.dart';

/// Supabase বাস্তবায়িত AuditRepository
class SupabaseAuditRepository implements AuditRepository {
  final SupabaseClient _client;

  SupabaseAuditRepository(this._client);

  @override
  Future<List<AuditLogModel>> getAuditLogs({int limit = 50}) async {
    final response = await _client.from('audit_logs').select('''
      *,
      profiles:actor_id(name)
    ''').order('created_at', ascending: false).limit(limit);

    return (response as List<dynamic>).map((e) => AuditLogModel.fromJson(Map<String, dynamic>.from(e))).toList();
  }
}
