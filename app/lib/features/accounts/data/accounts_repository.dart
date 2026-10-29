import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../auth/domain/models/app_user.dart';
import '../domain/models/wage_record.dart';
import '../domain/models/payment.dart';
import '../domain/models/material_item.dart';
import '../domain/models/expense_item.dart';
import '../domain/models/bill_statement.dart';

final accountsRepositoryProvider = Provider<AccountsRepository>((ref) {
  return AccountsRepository(Supabase.instance.client);
});

class AccountsRepository {
  final SupabaseClient _supabase;

  AccountsRepository(this._supabase);

  // 1. Fetch Project Wages (খতিয়ানের দিনভিত্তিক মজুরি)
  Future<List<WageRecord>> getProjectWages(
    String projectId, {
    DateTime? from,
    DateTime? to,
  }) async {
    var query = _supabase
        .from('wage_ledger')
        .select('*, profiles(name, mobile, designations(name))')
        .eq('project_id', projectId);

    if (from != null) {
      query = query.gte('work_date', from.toIso8601String().split('T').first);
    }
    if (to != null) {
      query = query.lte('work_date', to.toIso8601String().split('T').first);
    }

    final data = await query.order('work_date', ascending: false);
    return (data as List<dynamic>)
        .map((e) => WageRecord.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // 2. Fetch Worker's Personal Wage History (শ্রমিকের নিজের মজুরির হিসাব)
  Future<List<WageRecord>> getWorkerWages(String workerId) async {
    final data = await _supabase
        .from('wage_ledger')
        .select('*, projects(name), profiles(name, mobile, designations(name))')
        .eq('worker_id', workerId)
        .order('work_date', ascending: false);

    return (data as List<dynamic>)
        .map((e) => WageRecord.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // 3. Materials (মালামাল হিসাব)
  Future<List<MaterialItem>> getProjectMaterials(String projectId) async {
    final data = await _supabase
        .from('materials')
        .select('*, profiles(name)')
        .eq('project_id', projectId)
        .order('purchase_date', ascending: false);

    return (data as List<dynamic>)
        .map((e) => MaterialItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> addMaterial(MaterialItem item) async {
    await _supabase.from('materials').insert(item.toJson());
  }

  Future<void> deleteMaterial(String materialId) async {
    await _supabase.from('materials').delete().eq('id', materialId);
  }

  // 4. Expenses (সাইট খরচ)
  Future<List<ExpenseItem>> getProjectExpenses(String projectId) async {
    final data = await _supabase
        .from('expenses')
        .select('*, profiles(name)')
        .eq('project_id', projectId)
        .order('expense_date', ascending: false);

    return (data as List<dynamic>)
        .map((e) => ExpenseItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> addExpense(ExpenseItem item) async {
    await _supabase.from('expenses').insert(item.toJson());
  }

  Future<void> deleteExpense(String expenseId) async {
    await _supabase.from('expenses').delete().eq('id', expenseId);
  }

  // 5. Client Payments (ক্লায়েন্ট বিল জমা)
  Future<List<ClientPayment>> getClientPayments(String projectId) async {
    final data = await _supabase
        .from('client_payments')
        .select('*, profiles(name)')
        .eq('project_id', projectId)
        .order('payment_date', ascending: false);

    return (data as List<dynamic>)
        .map((e) => ClientPayment.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> recordClientPayment(ClientPayment payment) async {
    await _supabase.from('client_payments').insert(payment.toJson());
  }

  // 6. Organization Payments to Workers & Supervisors (মজুরি পরিশোধ)
  Future<List<Payment>> getOrganizationPayments(String orgId) async {
    final data = await _supabase
        .from('payments')
        .select('*, profiles!payments_payee_id_fkey(name, mobile), payment_allocations(*, projects(name))')
        .eq('organization_id', orgId)
        .order('payment_date', ascending: false);

    return (data as List<dynamic>)
        .map((e) => Payment.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> recordPayment(Payment payment, {bool autoFifo = true}) async {
    final res = await _supabase
        .from('payments')
        .insert(payment.toJson())
        .select('id')
        .single();

    final paymentId = res['id'] as String;

    if (autoFifo) {
      // Call Postgres stored procedure for FIFO project/wage allocation
      await _supabase.rpc('allocate_payment_fifo', params: {
        'p_payment_id': paymentId,
      });
    }
  }

  Future<List<UserProfile>> getOrganizationWorkers(String orgId) async {
    final data = await _supabase
        .from('profiles')
        .select()
        .eq('organization_id', orgId)
        .inFilter('role', ['worker', 'supervisor'])
        .order('name');

    return (data as List<dynamic>)
        .map((e) => UserProfile.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // 7. Bill Statements & Snapshots (শ্রমিক-বিল খতিয়ান স্টেটমেন্ট)
  Future<List<BillStatement>> getBillStatements(String projectId) async {
    final data = await _supabase
        .from('bill_statements')
        .select('*, projects(name)')
        .eq('project_id', projectId)
        .order('period_from', ascending: false);

    return (data as List<dynamic>)
        .map((e) => BillStatement.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> createBillStatement(BillStatement statement) async {
    await _supabase.from('bill_statements').insert(statement.toJson());
  }

  Future<void> lockAndSendStatementToClient(
    String statementId,
    Map<String, dynamic> snapshot,
  ) async {
    await _supabase.from('bill_statements').update({
      'is_locked': true,
      'locked_snapshot': snapshot,
      'sent_to_client_at': DateTime.now().toIso8601String(),
    }).eq('id', statementId);
  }

  // 8. Project Accounts Aggregated Summary
  Future<ProjectAccountsSummary> getProjectAccountsSummary(
    String projectId,
    String projectName,
    double budgetOrContractValue,
  ) async {
    // 1. Total Client Payments
    final clientPayments = await _supabase
        .from('client_payments')
        .select('amount')
        .eq('project_id', projectId);
    final totalClientPaid = (clientPayments as List<dynamic>).fold<double>(
      0.0,
      (sum, item) => sum + ((item['amount'] as num?)?.toDouble() ?? 0.0),
    );

    // 2. Total Wages Earned
    final wages = await _supabase
        .from('wage_ledger')
        .select('total_earned')
        .eq('project_id', projectId);
    final totalWagesEarned = (wages as List<dynamic>).fold<double>(
      0.0,
      (sum, item) => sum + ((item['total_earned'] as num?)?.toDouble() ?? 0.0),
    );

    // 3. Total Wages Paid (Allocations to this project)
    final allocations = await _supabase
        .from('payment_allocations')
        .select('allocated_amount')
        .eq('project_id', projectId);
    final totalWagesPaid = (allocations as List<dynamic>).fold<double>(
      0.0,
      (sum, item) =>
          sum + ((item['allocated_amount'] as num?)?.toDouble() ?? 0.0),
    );

    // 4. Total Materials Cost
    final materials = await _supabase
        .from('materials')
        .select('total_price')
        .eq('project_id', projectId);
    final totalMaterialsCost = (materials as List<dynamic>).fold<double>(
      0.0,
      (sum, item) => sum + ((item['total_price'] as num?)?.toDouble() ?? 0.0),
    );

    // 5. Total Other Expenses
    final expenses = await _supabase
        .from('expenses')
        .select('amount')
        .eq('project_id', projectId);
    final totalExpensesCost = (expenses as List<dynamic>).fold<double>(
      0.0,
      (sum, item) => sum + ((item['amount'] as num?)?.toDouble() ?? 0.0),
    );

    return ProjectAccountsSummary(
      projectId: projectId,
      projectName: projectName,
      totalBudgetOrContractValue: budgetOrContractValue,
      totalClientPaid: totalClientPaid,
      totalWagesEarned: totalWagesEarned,
      totalWagesPaid: totalWagesPaid,
      totalMaterialsCost: totalMaterialsCost,
      totalExpensesCost: totalExpensesCost,
    );
  }
}
