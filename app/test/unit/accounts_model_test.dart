import 'package:flutter_test/flutter_test.dart';
import 'package:project_khata/features/accounts/domain/models/wage_record.dart';
import 'package:project_khata/features/accounts/domain/models/payment.dart';
import 'package:project_khata/features/accounts/domain/models/material_item.dart';
import 'package:project_khata/features/accounts/domain/models/expense_item.dart';
import 'package:project_khata/features/accounts/domain/models/client_payment.dart';
import 'package:project_khata/features/accounts/domain/models/bill_statement.dart';

void main() {
  group('WageRecord Model Tests', () {
    test('WageRecord parses fromJson and calculates totalEarned and dueAmount', () {
      final json = {
        'id': 'wage-001',
        'organization_id': 'org-001',
        'project_id': 'proj-001',
        'worker_id': 'worker-001',
        'attendance_record_id': 'att-001',
        'work_date': '2026-10-29',
        'wage_amount': 800.0,
        'overtime_amount': 200.0,
        'total_earned': 1000.0,
        'status': 'unpaid',
        'created_at': '2026-10-29T18:00:00Z',
        'profiles': {
          'name': 'করিম মিয়া',
          'mobile': '01711223344',
          'designations': {'name': 'রাজমিস্ত্রি'},
        },
        'projects': {
          'name': 'ধানমন্ডি লেকভিউ রেসিডেন্স',
        },
      };

      final record = WageRecord.fromJson(json);

      expect(record.id, 'wage-001');
      expect(record.wageAmount, 800.0);
      expect(record.overtimeAmount, 200.0);
      expect(record.totalEarned, 1000.0);
      expect(record.isPaid, false);
      expect(record.dueAmount, 1000.0);
      expect(record.workerName, 'করিম মিয়া');
      expect(record.designationName, 'রাজমিস্ত্রি');
      expect(record.projectName, 'ধানমন্ডি লেকভিউ রেসিডেন্স');
    });

    test('WageRecord marks isPaid true and dueAmount 0 when status is paid', () {
      final record = WageRecord(
        id: 'wage-002',
        organizationId: 'org-1',
        projectId: 'proj-1',
        workerId: 'w-1',
        attendanceRecordId: 'att-1',
        workDate: DateTime(2026, 10, 29),
        wageAmount: 750.0,
        overtimeAmount: 150.0,
        totalEarned: 900.0,
        status: 'paid',
        createdAt: DateTime.now(),
      );

      expect(record.isPaid, true);
      expect(record.dueAmount, 0.0);
    });
  });

  group('Payment & PaymentAllocation Model Tests', () {
    test('Payment parses nested allocations and profiles from JSON', () {
      final json = {
        'id': 'pay-001',
        'organization_id': 'org-001',
        'payee_type': 'worker',
        'payee_id': 'worker-001',
        'amount': 2500.0,
        'payment_date': '2026-10-29',
        'payment_method': 'bkash',
        'note': 'সাপ্তাহিক মজুরি পরিশোধ',
        'created_by': 'contractor-001',
        'created_at': '2026-10-29T12:00:00Z',
        'profiles': {
          'name': 'রফিক উল্লাহ',
          'mobile': '01811223344',
        },
        'payment_allocations': [
          {
            'id': 'alloc-001',
            'organization_id': 'org-001',
            'payment_id': 'pay-001',
            'project_id': 'proj-001',
            'wage_ledger_id': 'wage-001',
            'allocated_amount': 1000.0,
            'method': 'fifo',
            'created_at': '2026-10-29T12:00:00Z',
            'projects': {'name': 'ধানমন্ডি প্রজেক্ট'},
          },
          {
            'id': 'alloc-002',
            'organization_id': 'org-001',
            'payment_id': 'pay-001',
            'project_id': 'proj-002',
            'wage_ledger_id': 'wage-002',
            'allocated_amount': 1500.0,
            'method': 'fifo',
            'created_at': '2026-10-29T12:00:00Z',
            'projects': {'name': 'বনানী প্লাজা'},
          },
        ],
      };

      final payment = Payment.fromJson(json);

      expect(payment.id, 'pay-001');
      expect(payment.amount, 2500.0);
      expect(payment.payeeName, 'রফিক উল্লাহ');
      expect(payment.paymentMethod, 'bkash');
      expect(payment.allocations.length, 2);
      expect(payment.allocations[0].allocatedAmount, 1000.0);
      expect(payment.allocations[0].projectName, 'ধানমন্ডি প্রজেক্ট');
      expect(payment.allocations[1].allocatedAmount, 1500.0);
      expect(payment.allocations[1].method, 'fifo');
    });

    test('Payment toJson formats correctly and omits id if empty', () {
      final payment = Payment(
        id: '',
        organizationId: 'org-001',
        payeeId: 'worker-001',
        amount: 1500.0,
        paymentDate: DateTime(2026, 10, 29),
        paymentMethod: 'cash',
        createdBy: 'user-001',
        createdAt: DateTime.now(),
      );

      final json = payment.toJson();
      expect(json.containsKey('id'), false);
      expect(json['amount'], 1500.0);
      expect(json['payment_date'], '2026-10-29');
      expect(json['payment_method'], 'cash');
    });
  });

  group('MaterialItem & ExpenseItem Model Tests', () {
    test('MaterialItem parses and calculates totalPrice accurately', () {
      final json = {
        'id': 'mat-001',
        'organization_id': 'org-001',
        'project_id': 'proj-001',
        'name': 'হোলসিম সিমেন্ট',
        'unit': 'বস্তা',
        'qty': 100,
        'unit_price': 540,
        'total_price': 54000,
        'purchase_date': '2026-10-29',
        'added_by': 'sup-001',
        'created_at': '2026-10-29T09:00:00Z',
        'profiles': {'name': 'সুপারভাইজার জামিল'},
      };

      final material = MaterialItem.fromJson(json);

      expect(material.id, 'mat-001');
      expect(material.name, 'হোলসিম সিমেন্ট');
      expect(material.qty, 100.0);
      expect(material.unitPrice, 540.0);
      expect(material.totalPrice, 54000.0);
      expect(material.addedByName, 'সুপারভাইজার জামিল');
    });

    test('ExpenseItem parses and serializes correctly', () {
      final json = {
        'id': 'exp-001',
        'organization_id': 'org-001',
        'project_id': 'proj-001',
        'category': 'যন্ত্রপাতি',
        'amount': 3200,
        'expense_date': '2026-10-29',
        'note': 'মিক্সার মেশিন ভাড়া',
        'added_by': 'sup-001',
        'created_at': '2026-10-29T10:00:00Z',
      };

      final expense = ExpenseItem.fromJson(json);

      expect(expense.id, 'exp-001');
      expect(expense.category, 'যন্ত্রপাতি');
      expect(expense.amount, 3200.0);
      expect(expense.note, 'মিক্সার মেশিন ভাড়া');

      final serialized = expense.toJson();
      expect(serialized['category'], 'যন্ত্রপাতি');
      expect(serialized['amount'], 3200.0);
      expect(serialized['expense_date'], '2026-10-29');
    });

    test('ClientPayment parses and calculates amounts', () {
      final json = {
        'id': 'cp-001',
        'organization_id': 'org-001',
        'project_id': 'proj-001',
        'amount': 150000,
        'payment_date': '2026-10-25',
        'payment_method': 'bank',
        'reference_no': 'CHQ-998877',
        'note': '২য় কিস্তির বিল',
        'received_by': 'contractor-001',
        'created_at': '2026-10-25T11:00:00Z',
      };

      final cp = ClientPayment.fromJson(json);

      expect(cp.id, 'cp-001');
      expect(cp.amount, 150000.0);
      expect(cp.paymentMethod, 'bank');
      expect(cp.referenceNo, 'CHQ-998877');
    });
  });

  group('BillStatement & ProjectAccountsSummary Tests', () {
    test('BillStatement parses snapshot and locked flags', () {
      final json = {
        'id': 'stmt-001',
        'organization_id': 'org-001',
        'project_id': 'proj-001',
        'period_from': '2026-10-01',
        'period_to': '2026-10-28',
        'preset': 'monthly',
        'generated_by': 'cont-001',
        'is_locked': true,
        'locked_snapshot': {'total_wages': 45000, 'total_materials': 120000},
        'created_at': '2026-10-29T08:00:00Z',
        'projects': {'name': 'গুলশান ভিলা'},
      };

      final stmt = BillStatement.fromJson(json);

      expect(stmt.id, 'stmt-001');
      expect(stmt.isLocked, true);
      expect(stmt.preset, 'monthly');
      expect(stmt.lockedSnapshot?['total_wages'], 45000);
      expect(stmt.projectName, 'গুলশান ভিলা');
    });

    test('ProjectAccountsSummary financial metrics calculation', () {
      const summary = ProjectAccountsSummary(
        projectId: 'proj-001',
        projectName: 'মিরপুর টাওয়ার',
        totalBudgetOrContractValue: 500000.0,
        totalClientPaid: 300000.0,
        totalWagesEarned: 120000.0,
        totalWagesPaid: 100000.0,
        totalMaterialsCost: 150000.0,
        totalExpensesCost: 20000.0,
      );

      // Total Expenses = Wages + Materials + Other
      // 120,000 + 150,000 + 20,000 = 290,000
      expect(summary.totalExpenses, 290000.0);

      // Client Due = Budget - Client Paid
      // 500,000 - 300,000 = 200,000
      expect(summary.clientDue, 200000.0);

      // Wages Due = Earned - Paid
      // 120,000 - 100,000 = 20,000
      expect(summary.wagesDue, 20000.0);

      // Estimated Profit = Budget - Total Expenses
      // 500,000 - 290,000 = 210,000
      expect(summary.estimatedProfit, 210000.0);
    });
  });
}
