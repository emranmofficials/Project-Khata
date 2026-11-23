import 'package:flutter_test/flutter_test.dart';
import 'package:project_khata/features/auth/domain/models/user_profile.dart';
import 'package:project_khata/features/project/domain/models/project_model.dart';
import 'package:project_khata/features/attendance/domain/models/attendance_record_model.dart';
import 'package:project_khata/features/accounting/domain/models/wage_ledger_model.dart';
import 'package:project_khata/features/accounting/domain/models/material_model.dart';

void main() {
  group('Domain Models Serialization & Business Rules Tests', () {
    test('UserProfile role detection and serialization test', () {
      final contractorJson = {
        'id': 'usr-001',
        'organization_id': 'org-001',
        'role': 'contractor',
        'name': 'কামাল হোসেন',
        'mobile': '01711000001',
        'email': 'kamal@contractor.com',
        'must_change_password': false,
        'status': 'active',
      };

      final profile = UserProfile.fromJson(contractorJson);
      expect(profile.isContractor, isTrue);
      expect(profile.isSupervisor, isFalse);
      expect(profile.isClient, isFalse);
      expect(profile.isWorker, isFalse);
      expect(profile.hasOrganization, isTrue);
      expect(profile.isActive, isTrue);
      expect(profile.name, 'কামাল হোসেন');

      final serialized = profile.toJson();
      expect(serialized['id'], 'usr-001');
      expect(serialized['role'], 'contractor');
      expect(serialized['must_change_password'], isFalse);

      // Test copyWith
      final updated = profile.copyWith(name: 'কামাল আহমেদ');
      expect(updated.name, 'কামাল আহমেদ');
      expect(updated.id, 'usr-001');
    });

    test('ProjectModel types, status labels and geofence defaults', () {
      final projectJson = {
        'id': 'prj-101',
        'organization_id': 'org-001',
        'name': 'উত্তরা রেসিডেন্সিয়াল টাওয়ার',
        'type': 'sqft',
        'address': 'সেক্টর ৪, উত্তরা, ঢাকা',
        'lat': 23.8759,
        'lng': 90.3795,
        'geofence_radius_m': 150,
        'status': 'active',
        'budget': 5000000.0,
        'client_name': 'রফিক সাহেব',
        'client_mobile': '01819000002',
        'today_workers_count': 14,
        'assigned_supervisors_count': 2,
        'progress_percentage': 45.5,
      };

      final project = ProjectModel.fromJson(projectJson);
      expect(project.isActive, isTrue);
      expect(project.isCompleted, isFalse);
      expect(project.typeBengaliLabel, 'স্কয়ার ফিট ভিত্তিক');
      expect(project.statusBengaliLabel, 'চলমান');
      expect(project.geofenceRadiusM, 150);
      expect(project.budget, 5000000.0);
    });

    test('AttendanceRecordModel status and location flags test', () {
      final attendance = AttendanceRecordModel(
        id: 'att-501',
        entryId: 'ent-201',
        workerId: 'wrk-001',
        workerName: 'করিম মিয়া',
        workerMobile: '01911000003',
        designationName: 'রাজমিস্ত্রি',
        dailyRate: 800.0,
        overtimeRatePerHour: 100.0,
        entryDate: DateTime(2026, 11, 23),
        status: 'present',
        overtimeHours: 2.0,
        markedBy: 'sup-001',
        markedAt: DateTime(2026, 11, 23, 8, 30),
        latitude: 23.7330,
        longitude: 90.4172,
        distanceM: 45.0,
        locationStatus: 'verified',
        approvalStatus: 'approved',
      );

      expect(attendance.isPresent, isTrue);
      expect(attendance.isAbsent, isFalse);
      expect(attendance.isLocationVerified, isTrue);
      expect(attendance.isOutsideSite, isFalse);
      expect(attendance.isApproved, isTrue);
      expect(attendance.statusBengaliLabel, 'উপস্থিত');
    });

    test('WageLedgerModel calculation of due amount and payment status', () {
      final wage = WageLedgerModel(
        id: 'wg-901',
        projectId: 'prj-101',
        workerId: 'wrk-001',
        workerName: 'করিম মিয়া',
        workDate: DateTime(2026, 11, 23),
        dailyAmount: 800.0,
        overtimeAmount: 200.0,
        totalAmount: 1000.0,
        allocatedPaid: 600.0,
      );

      expect(wage.dueAmount, 400.0);
      expect(wage.isFullyPaid, isFalse);

      final fullyPaidWage = WageLedgerModel(
        id: 'wg-902',
        projectId: 'prj-101',
        workerId: 'wrk-001',
        workerName: 'করিম মিয়া',
        workDate: DateTime(2026, 11, 22),
        dailyAmount: 800.0,
        totalAmount: 800.0,
        allocatedPaid: 800.0,
      );

      expect(fullyPaidWage.dueAmount, 0.0);
      expect(fullyPaidWage.isFullyPaid, isTrue);
    });

    test('MaterialModel PRD Rule 57 Client Protection Enforcement', () {
      // Client added material: contractor CANNOT edit or delete
      final clientMaterial = MaterialModel(
        id: 'mat-001',
        projectId: 'prj-101',
        name: 'রড ৬০ গ্রেড',
        unit: 'টন',
        qty: 5.0,
        unitPrice: 95000.0,
        totalPrice: 475000.0,
        purchaseDate: DateTime(2026, 11, 20),
        addedBy: 'clt-001',
        addedByRole: 'client',
        addedByName: 'রফিক সাহেব',
      );

      expect(clientMaterial.isAddedByClient, isTrue);
      expect(clientMaterial.canContractorEdit, isFalse); // Rule 57 enforced!

      // Contractor added material: contractor CAN edit
      final contractorMaterial = MaterialModel(
        id: 'mat-002',
        projectId: 'prj-101',
        name: 'সিমেন্ট পোর্টল্যান্ড',
        unit: 'ব্যাগ',
        qty: 100.0,
        unitPrice: 550.0,
        totalPrice: 55000.0,
        purchaseDate: DateTime(2026, 11, 22),
        addedBy: 'usr-001',
        addedByRole: 'contractor',
        addedByName: 'কামাল হোসেন',
      );

      expect(contractorMaterial.isAddedByClient, isFalse);
      expect(contractorMaterial.canContractorEdit, isTrue);
    });
  });
}
