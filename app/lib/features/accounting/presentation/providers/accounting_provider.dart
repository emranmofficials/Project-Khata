import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/supabase_client.dart';
import '../../data/supabase_accounting_repository.dart';
import '../../domain/accounting_repository.dart';
import '../../domain/models/bill_statement_model.dart';
import '../../domain/models/material_model.dart';
import '../../domain/models/payment_model.dart';
import '../../domain/models/site_expense_model.dart';
import '../../domain/models/wage_ledger_model.dart';

final accountingRepositoryProvider = Provider<AccountingRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseAccountingRepository(client);
});

// সার্বিক ফাইন্যান্সিয়াল ওভারভিউ
final financialOverviewProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repository = ref.watch(accountingRepositoryProvider);
  return repository.getFinancialOverview();
});

// মজুরি খতিয়ান তালিকা
final wageLedgerListProvider = FutureProvider.family<List<WageLedgerModel>, String?>((ref, projectId) async {
  final repository = ref.watch(accountingRepositoryProvider);
  return repository.getWageLedger(projectId: projectId);
});

// পেমেন্ট তালিকা
final paymentsListProvider = FutureProvider<List<PaymentModel>>((ref) async {
  final repository = ref.watch(accountingRepositoryProvider);
  return repository.getPayments();
});

// মালামাল তালিকা
final projectMaterialsProvider = FutureProvider.family<List<MaterialModel>, String>((ref, projectId) async {
  final repository = ref.watch(accountingRepositoryProvider);
  return repository.getMaterials(projectId);
});

// সাইট খরচ তালিকা
final projectSiteExpensesProvider = FutureProvider.family<List<SiteExpenseModel>, String>((ref, projectId) async {
  final repository = ref.watch(accountingRepositoryProvider);
  return repository.getSiteExpenses(projectId);
});

// বিল খতিয়ান তালিকা
final projectBillStatementsProvider = FutureProvider.family<List<BillStatementModel>, String>((ref, projectId) async {
  final repository = ref.watch(accountingRepositoryProvider);
  return repository.getBillStatements(projectId);
});

// অ্যাকশন নোটিফায়ার
class AccountingActionNotifier extends StateNotifier<AsyncValue<void>> {
  final AccountingRepository _repository;
  final Ref _ref;

  AccountingActionNotifier(this._repository, this._ref) : super(const AsyncValue.data(null));

  Future<Map<String, dynamic>> recordWorkerPayment({
    required String payeeId,
    required double amount,
    required DateTime paymentDate,
    String? note,
  }) async {
    state = const AsyncValue.loading();
    try {
      final res = await _repository.recordWorkerPayment(
        payeeId: payeeId,
        amount: amount,
        paymentDate: paymentDate,
        note: note,
      );
      state = const AsyncValue.data(null);
      _ref.invalidate(paymentsListProvider);
      _ref.invalidate(financialOverviewProvider);
      _ref.invalidate(wageLedgerListProvider(null));
      return res;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> addMaterial({
    required String projectId,
    required String name,
    required String unit,
    required double qty,
    required double unitPrice,
    required DateTime purchaseDate,
    String? receiptUrl,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _repository.addMaterial(
        projectId: projectId,
        name: name,
        unit: unit,
        qty: qty,
        unitPrice: unitPrice,
        purchaseDate: purchaseDate,
        receiptUrl: receiptUrl,
      );
      state = const AsyncValue.data(null);
      _ref.invalidate(projectMaterialsProvider(projectId));
      _ref.invalidate(financialOverviewProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> deleteMaterial(String materialId, String projectId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.deleteMaterial(materialId);
      state = const AsyncValue.data(null);
      _ref.invalidate(projectMaterialsProvider(projectId));
      _ref.invalidate(financialOverviewProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> addSiteExpense({
    required String projectId,
    String? entryId,
    required String category,
    required double amount,
    required DateTime expenseDate,
    String? note,
    String? receiptUrl,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _repository.addSiteExpense(
        projectId: projectId,
        entryId: entryId,
        category: category,
        amount: amount,
        expenseDate: expenseDate,
        note: note,
        receiptUrl: receiptUrl,
      );
      state = const AsyncValue.data(null);
      _ref.invalidate(projectSiteExpensesProvider(projectId));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> decideSiteExpense({
    required String expenseId,
    required String status,
    required String projectId,
    String? reason,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _repository.decideSiteExpense(
        expenseId: expenseId,
        status: status,
        reason: reason,
      );
      state = const AsyncValue.data(null);
      _ref.invalidate(projectSiteExpensesProvider(projectId));
      _ref.invalidate(financialOverviewProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> generateAndSendBillStatement({
    required String projectId,
    required DateTime periodFrom,
    required DateTime periodTo,
    String preset = 'monthly',
  }) async {
    state = const AsyncValue.loading();
    try {
      final res = await _repository.generateAndSendBillStatement(
        projectId: projectId,
        periodFrom: periodFrom,
        periodTo: periodTo,
        preset: preset,
      );
      state = const AsyncValue.data(null);
      _ref.invalidate(projectBillStatementsProvider(projectId));
      return res;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final accountingActionProvider = StateNotifierProvider<AccountingActionNotifier, AsyncValue<void>>((ref) {
  final repository = ref.watch(accountingRepositoryProvider);
  return AccountingActionNotifier(repository, ref);
});
