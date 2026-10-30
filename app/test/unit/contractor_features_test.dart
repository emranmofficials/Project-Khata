import 'package:flutter_test/flutter_test.dart';
import 'package:project_khata/core/constants/contractor_strings.dart';
import 'package:project_khata/features/contractor/data/mock_contractor_repository.dart';
import 'package:project_khata/features/contractor/domain/models/contractor_models.dart';
import 'package:project_khata/widgets/contractor_widgets.dart';

void main() {
  group('Contractor Helpers Unit Tests', () {
    test('toBn converts English digits to Bengali digits and handles strings/null', () {
      expect(toBn(0), '০');
      expect(toBn(1234567890), '১২৩৪৫৬৭৮৯০');
      expect(toBn('100 মিটার'), '১০০ মিটার');
      expect(toBn('৳ 2,50,000'), '৳ ২,৫০,০০০');
      expect(toBn(null), '');
    });

    test('greetingByHour returns appropriate greeting based on hour', () {
      final morning = DateTime(2026, 1, 1, 9, 0);
      final afternoon = DateTime(2026, 1, 1, 14, 0);
      final evening = DateTime(2026, 1, 1, 20, 0);
      final night = DateTime(2026, 1, 1, 2, 0);

      expect(greetingByHour(morning), ContractorStrings.greetingMorning);
      expect(greetingByHour(afternoon), ContractorStrings.greetingAfternoon);
      expect(greetingByHour(evening), ContractorStrings.greetingEvening);
      expect(greetingByHour(night), ContractorStrings.greetingEvening);
    });
  });

  group('MockContractorRepository Business Rules Tests', () {
    late MockContractorRepository repo;

    setUp(() {
      repo = MockContractorRepository();
    });

    test('Creating project with existing client mobile links existing client', () async {
      final existingClientsBefore = await repo.getClients();
      final targetMobile = existingClientsBefore.first.mobile;
      final targetClientId = existingClientsBefore.first.id;

      final project = await repo.createProject(
        NewProjectInput(
          name: 'নতুন ভিউ টাওয়ার',
          type: ProjectType.sqft,
          address: 'মিরপুর, ঢাকা',
          clientName: 'রফিকুল ইসলাম',
          clientMobile: targetMobile,
          lat: 23.8103,
          lng: 90.4125,
          geofenceRadiusM: 150,
        ),
      );

      final existingClientsAfter = await repo.getClients();
      expect(project.client.id, targetClientId);
      expect(existingClientsAfter.length, existingClientsBefore.length);
    });

    test('Creating project with new client mobile creates a new client record', () async {
      final clientsBefore = await repo.getClients();
      const newMobile = '01799998877';

      final project = await repo.createProject(
        NewProjectInput(
          name: 'পদ্মা টাওয়ার',
          type: ProjectType.contract,
          address: 'মতিঝিল, ঢাকা',
          clientName: 'কামাল হোসেন',
          clientMobile: newMobile,
          lat: 23.8103,
          lng: 90.4125,
          geofenceRadiusM: 150,
          budget: 5000000,
        ),
      );

      final clientsAfter = await repo.getClients();
      expect(project.client.mobile, newMobile);
      expect(clientsAfter.length, clientsBefore.length + 1);
      expect(clientsAfter.any((c) => c.mobile == newMobile), isTrue);
    });

    test('updateProject rejects modification of client mobile and throws ContractorException', () async {
      final project = await repo.getProjectDetails('proj-1');
      final originalMobile = project.client.mobile;

      expect(
        () => repo.updateProject(
          UpdateProjectInput(
            id: 'proj-1',
            name: 'মেঘনা ভিউ রেসিডেন্স (আপডেটেড)',
            type: ProjectType.sqft,
            address: 'উত্তরা, ঢাকা',
            lat: 23.8759,
            lng: 90.3795,
            geofenceRadiusM: 150,
            status: ProjectStatus.active,
            clientName: project.client.name,
            clientMobile: '01899999999', // Different mobile
          ),
        ),
        throwsA(isA<ContractorException>().having(
          (e) => e.message,
          'message',
          contains('ক্লায়েন্টের মোবাইল'),
        )),
      );

      // Verify mobile remains unmodified
      final unchanged = await repo.getProjectDetails('proj-1');
      expect(unchanged.client.mobile, originalMobile);
    });

    test('unassignSupervisor adds handover_required approval entry', () async {
      final approvalsBefore = await repo.getPendingApprovals();
      final handoverCountBefore = approvalsBefore
          .where((a) => a.type == ApprovalType.handoverRequired)
          .length;

      await repo.unassignSupervisor('proj-1', 'sup-1');

      final approvalsAfter = await repo.getPendingApprovals();
      final handoverAfter = approvalsAfter
          .where((a) => a.type == ApprovalType.handoverRequired)
          .toList();

      expect(handoverAfter.length, handoverCountBefore + 1);
      expect(handoverAfter.last.type, ApprovalType.handoverRequired);
    });
  });
}
