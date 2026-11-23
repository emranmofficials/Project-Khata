import 'models/bill_statement_model.dart';
import 'models/material_model.dart';
import 'models/payment_model.dart';
import 'models/site_expense_model.dart';
import 'models/wage_ledger_model.dart';

/// সম্পূর্ণ হিসাব ও ফাইন্যান্সিয়াল রিপোজিটরি ইন্টারফেস
abstract class AccountingRepository {
  /// সার্বিক আয়, ব্যয় ও বকেয়া সারসংক্ষেপ
  Future<Map<String, dynamic>> getFinancialOverview();

  /// মজুরি খতিয়ান তালিকা
  Future<List<WageLedgerModel>> getWageLedger({
    String? projectId,
    String? workerId,
  });

  /// শ্রমিক/সুপারভাইজার পেমেন্ট ও FIFO বরাদ্দ সম্পাদন
  Future<Map<String, dynamic>> recordWorkerPayment({
    required String payeeId,
    required double amount,
    required DateTime paymentDate,
    String? note,
  });

  /// পেমেন্ট ইতিহাস
  Future<List<PaymentModel>> getPayments({String? payeeId});

  /// প্রজেক্ট মালামাল তালিকা
  Future<List<MaterialModel>> getMaterials(String projectId);

  /// নতুন মালামাল যোগ করা
  Future<void> addMaterial({
    required String projectId,
    required String name,
    required String unit,
    required double qty,
    required double unitPrice,
    required DateTime purchaseDate,
    String? receiptUrl,
  });

  /// মালামাল মোছা (ঠিকাদার ক্লায়েন্টের মালামাল মুছতে পারবে না)
  Future<void> deleteMaterial(String materialId);

  /// সাইট খরচ তালিকা
  Future<List<SiteExpenseModel>> getSiteExpenses(String projectId);

  /// সাইট খরচ যোগ (সুপারভাইজার)
  Future<void> addSiteExpense({
    required String projectId,
    String? entryId,
    required String category,
    required double amount,
    required DateTime expenseDate,
    String? note,
    String? receiptUrl,
  });

  /// সাইট খরচ অনুমোদন বা প্রত্যাখ্যান (ঠিকাদার)
  Future<void> decideSiteExpense({
    required String expenseId,
    required String status,
    String? reason,
  });

  /// শ্রমিক-বিল খতিয়ান তালিকা
  Future<List<BillStatementModel>> getBillStatements(String projectId);

  /// শ্রমিক-বিল খতিয়ান তৈরি, লক ও ক্লায়েন্টকে পাঠানো
  Future<Map<String, dynamic>> generateAndSendBillStatement({
    required String projectId,
    required DateTime periodFrom,
    required DateTime periodTo,
    String preset = 'monthly',
  });
}
