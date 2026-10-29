import 'package:flutter_test/flutter_test.dart';
import 'package:project_khata/features/projects/domain/models/project.dart';
import 'package:project_khata/features/projects/domain/models/supervisor_assignment.dart';

void main() {
  group('Project Models & Enums Tests (Phase 2)', () {
    test('ProjectType parsing and display names', () {
      expect(ProjectType.fromString('sqft'), ProjectType.sqft);
      expect(ProjectType.fromString('contract'), ProjectType.contract);
      expect(ProjectType.fromString('daily'), ProjectType.daily);
      expect(ProjectType.fromString('unknown'), ProjectType.sqft);

      expect(ProjectType.sqft.displayName, 'স্কয়ারফিট চুক্তি');
      expect(ProjectType.contract.displayName, 'এককালীন চুক্তি');
      expect(ProjectType.daily.displayName, 'দৈনিক হাজিরা');
    });

    test('ProjectStatus parsing and display names', () {
      expect(ProjectStatus.fromString('planned'), ProjectStatus.planned);
      expect(ProjectStatus.fromString('active'), ProjectStatus.active);
      expect(ProjectStatus.fromString('completed'), ProjectStatus.completed);
      expect(ProjectStatus.fromString('on_hold'), ProjectStatus.onHold);
      expect(ProjectStatus.fromString('unknown'), ProjectStatus.active);

      expect(ProjectStatus.planned.displayName, 'পরিকল্পিত');
      expect(ProjectStatus.active.displayName, 'চলমান');
      expect(ProjectStatus.completed.displayName, 'সম্পন্ন');
      expect(ProjectStatus.onHold.displayName, 'স্থগিত');
    });

    test('Project fromJson and toJson round trip', () {
      final json = {
        'id': 'proj-123',
        'organization_id': 'org-456',
        'client_id': 'client-789',
        'name': 'বাড়ি নির্মাণ প্রজেক্ট',
        'type': 'sqft',
        'address': 'মিরপুর ১০, ঢাকা',
        'lat': 23.8071,
        'lng': 90.3686,
        'geofence_radius_m': 150,
        'start_date': '2026-10-29',
        'end_date': '2027-04-30',
        'status': 'active',
        'budget': 500000.0,
        'rate_per_sqft': 450.0,
        'total_sqft': 2500.0,
        'daily_wage': null,
        'note': 'গ্রাউন্ড ফ্লোর কাজ শুরু',
        'created_at': '2026-10-29T10:00:00Z',
      };

      final project = Project.fromJson(json);
      expect(project.id, 'proj-123');
      expect(project.name, 'বাড়ি নির্মাণ প্রজেক্ট');
      expect(project.type, ProjectType.sqft);
      expect(project.status, ProjectStatus.active);
      expect(project.geofenceRadiusM, 150);
      expect(project.ratePerSqft, 450.0);
      expect(project.totalSqft, 2500.0);

      final outJson = project.toJson();
      expect(outJson['name'], 'বাড়ি নির্মাণ প্রজেক্ট');
      expect(outJson['type'], 'sqft');
      expect(outJson['geofence_radius_m'], 150);
    });

    test('SupervisorAssignment isActive logic', () {
      final activeAssignment = SupervisorAssignment.fromJson({
        'id': 'assign-1',
        'organization_id': 'org-1',
        'project_id': 'proj-1',
        'supervisor_id': 'sup-1',
        'assigned_at': '2026-10-29T10:00:00Z',
        'unassigned_at': null,
      });

      expect(activeAssignment.isActive, isTrue);

      final unassignedAssignment = SupervisorAssignment.fromJson({
        'id': 'assign-2',
        'organization_id': 'org-1',
        'project_id': 'proj-1',
        'supervisor_id': 'sup-1',
        'assigned_at': '2026-10-20T10:00:00Z',
        'unassigned_at': '2026-10-29T10:00:00Z',
      });

      expect(unassignedAssignment.isActive, isFalse);
    });
  });
}
