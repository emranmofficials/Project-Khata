import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/accounting_repository.dart';
import '../domain/models/bill_statement_model.dart';
import '../domain/models/material_model.dart';
import '../domain/models/payment_model.dart';
import '../domain/models/site_expense_model.dart';
import '../domain/models/wage_ledger_model.dart';

/// Supabase বাস্তবায়িত AccountingRepository
class SupabaseAccountingRepository implements AccountingRepository {
  final SupabaseClient _client;

  SupabaseAccountingRepository(this._client);

  @override
  Future<Map<String, dynamic>> getFinancialOverview() async {
    // মোট আয় (ক্লায়েন্ট পেমেন্ট)
    final clientPayments = await _client.from('client_payments').select('amount');
    double totalIncome = 0.0;
    for (var row in clientPayments as List<dynamic>) {
      totalIncome += (row['amount'] as num?)?.toDouble() ?? 0.0;
    }

    // মোট অর্জিত মজুরি
    final wages = await _client.from('wage_ledger').select('total_amount');
    double totalWage = 0.0;
    for (var row in wages as List<dynamic>) {
      totalWage += (row['total_amount'] as num?)?.toDouble() ?? 0.0;
    }

    // মোট পরিশোধিত মজুরি
    final payments = await _client.from('payments').select('amount');
    double totalPaidWage = 0.0;
    for (var row in payments as List<dynamic>) {
      totalPaidWage += (row['amount'] as num?)?.toDouble() ?? 0.0;
    }

    // মালামাল খরচ
    final materials = await _client.from('materials').select('total_price');
    double totalMaterial = 0.0;
    for (var row in materials as List<dynamic>) {
      totalMaterial += (row['total_price'] as num?)?.toDouble() ?? 0.0;
    }

    // সাইট খরচ
    final expenses = await _client.from('site_expenses').select('amount').eq('status', 'approved');
    double totalExpense = 0.0;
    for (var row in expenses as List<dynamic>) {
      totalExpense += (row['amount'] as num?)?.toDouble() ?? 0.0;
    }

    final double totalCost = totalWage + totalMaterial + totalExpense;
    final double dueWage = (totalWage - totalPaidWage).clamp(0.0, double.infinity);
    final double netProfit = totalIncome - totalCost;

    return {
      'total_income': totalIncome,
      'total_cost': totalCost,
      'total_wage': totalWage,
      'total_paid_wage': totalPaidWage,
      'due_wage': dueWage,
      'total_material': totalMaterial,
      'total_site_expense': totalExpense,
      'net_profit': netProfit,
    };
  }

  @override
  Future<List<WageLedgerModel>> getWageLedger({
    String? projectId,
    String? workerId,
  }) async {
    var query = _client.from('wage_ledger').select('''
      *,
      projects:project_id(name),
      profiles:worker_id(
        name,
        designations:designation_id(name)
      )
    ''');

    if (projectId != null && projectId.isNotEmpty) {
      query = query.eq('project_id', projectId);
    }
    if (workerId != null && workerId.isNotEmpty) {
      query = query.eq('worker_id', workerId);
    }

    final response = await query.order('work_date', ascending: false);
    return (response as List<dynamic>).map((e) => WageLedgerModel.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  @override
  Future<Map<String, dynamic>> recordWorkerPayment({
    required String payeeId,
    required double amount,
    required DateTime paymentDate,
    String? note,
  }) async {
    final result = await _client.rpc('record_worker_payment', params: {
      'p_payee_id': payeeId,
      'p_amount': amount,
      'p_payment_date': paymentDate.toIso8601String().substring(0, 10),
      'p_note': note,
    });

    if (result == null || result['success'] != true) {
      throw Exception('পেমেন্ট রেকর্ডে সমস্যা হয়েছে।');
    }

    return Map<String, dynamic>.from(result);
  }

  @override
  Future<List<PaymentModel>> getPayments({String? payeeId}) async {
    var query = _client.from('payments').select('''
      *,
      profiles:payee_id(name),
      payment_allocations(id)
    ''');

    if (payeeId != null && payeeId.isNotEmpty) {
      query = query.eq('payee_id', payeeId);
    }

    final response = await query.order('payment_date', ascending: false);
    return (response as List<dynamic>).map((e) => PaymentModel.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  @override
  Future<List<MaterialModel>> getMaterials(String projectId) async {
    final response = await _client.from('materials').select('''
      *,
      profiles:added_by(name)
    ''').eq('project_id', projectId).order('purchase_date', ascending: false);

    return (response as List<dynamic>).map((e) => MaterialModel.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  @override
  Future<void> addMaterial({
    required String projectId,
    required String name,
    required String unit,
    required double qty,
    required double unitPrice,
    required DateTime purchaseDate,
    String? receiptUrl,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('অননুমোদিত অ্যাক্সেস।');

    final profile = await _client.from('profiles').select('organization_id, role').eq('id', user.id).single();

    await _client.from('materials').insert({
      'organization_id': profile['organization_id'],
      'project_id': projectId,
      'name': name.trim(),
      'unit': unit.trim(),
      'qty': qty,
      'unit_price': unitPrice,
      'purchase_date': purchaseDate.toIso8601String().substring(0, 10),
      'receipt_url': receiptUrl,
      'added_by': user.id,
      'added_by_role': profile['role'],
    });
  }

  @override
  Future<void> deleteMaterial(String materialId) async {
    await _client.from('materials').delete().eq('id', materialId);
  }

  @override
  Future<List<SiteExpenseModel>> getSiteExpenses(String projectId) async {
    final response = await _client.from('site_expenses').select('''
      *,
      profiles:added_by(name)
    ''').eq('project_id', projectId).order('expense_date', ascending: false);

    return (response as List<dynamic>).map((e) => SiteExpenseModel.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  @override
  Future<void> addSiteExpense({
    required String projectId,
    String? entryId,
    required String category,
    required double amount,
    required DateTime expenseDate,
    String? note,
    String? receiptUrl,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('অননুমোদিত অ্যাক্সেস।');

    final profile = await _client.from('profiles').select('organization_id').eq('id', user.id).single();

    await _client.from('site_expenses').insert({
      'organization_id': profile['organization_id'],
      'project_id': projectId,
      'entry_id': entryId,
      'category': category.trim(),
      'amount': amount,
      'expense_date': expenseDate.toIso8601String().substring(0, 10),
      'note': note,
      'receipt_url': receiptUrl,
      'status': 'pending',
      'added_by': user.id,
    });
  }

  @override
  Future<void> decideSiteExpense({
    required String expenseId,
    required String status,
    String? reason,
  }) async {
    await _client.rpc('decide_site_expense', params: {
      'p_expense_id': expenseId,
      'p_status': status,
      'p_reason': reason,
    });
  }

  @override
  Future<List<BillStatementModel>> getBillStatements(String projectId) async {
    final response = await _client.from('bill_statements').select('''
      *,
      projects:project_id(name)
    ''').eq('project_id', projectId).order('created_at', ascending: false);

    return (response as List<dynamic>).map((e) => BillStatementModel.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  @override
  Future<Map<String, dynamic>> generateAndSendBillStatement({
    required String projectId,
    required DateTime periodFrom,
    required DateTime periodTo,
    String preset = 'monthly',
  }) async {
    final result = await _client.rpc('generate_and_send_bill_statement', params: {
      'p_project_id': projectId,
      'p_period_from': periodFrom.toIso8601String().substring(0, 10),
      'p_period_to': periodTo.toIso8601String().substring(0, 10),
      'p_preset': preset,
    });

    if (result == null || result['success'] != true) {
      throw Exception('বিল খতিয়ান তৈরিতে সমস্যা হয়েছে।');
    }

    return Map<String, dynamic>.from(result);
  }
}
