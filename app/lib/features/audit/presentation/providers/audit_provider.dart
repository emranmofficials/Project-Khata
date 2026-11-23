import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/supabase_client.dart';
import '../../data/supabase_audit_repository.dart';
import '../../domain/audit_repository.dart';
import '../../domain/models/audit_log_model.dart';

final auditRepositoryProvider = Provider<AuditRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseAuditRepository(client);
});

final auditLogsProvider = FutureProvider<List<AuditLogModel>>((ref) async {
  final repository = ref.watch(auditRepositoryProvider);
  return repository.getAuditLogs();
});
