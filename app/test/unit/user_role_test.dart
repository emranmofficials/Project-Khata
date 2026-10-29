import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_khata/core/constants/app_colors.dart';
import 'package:project_khata/features/auth/domain/models/app_user.dart';

void main() {
  group('UserRole & Brand Colors Tests', () {
    test('UserRole parsing from string', () {
      expect(UserRole.fromString('contractor'), UserRole.contractor);
      expect(UserRole.fromString('client'), UserRole.client);
      expect(UserRole.fromString('supervisor'), UserRole.supervisor);
      expect(UserRole.fromString('worker'), UserRole.worker);
      expect(UserRole.fromString('unknown'), UserRole.worker);
    });

    test('Brand colors match AGENTS.md requirements', () {
      expect(UserRole.contractor.brandColor, AppColors.contractorNavy);
      expect(UserRole.contractor.brandColor.toARGB32(), const Color(0xFF1E3A8A).toARGB32());

      expect(UserRole.client.brandColor, AppColors.clientTeal);
      expect(UserRole.client.brandColor.toARGB32(), const Color(0xFF0F766E).toARGB32());

      expect(UserRole.supervisor.brandColor, AppColors.supervisorAmber);
      expect(UserRole.supervisor.brandColor.toARGB32(), const Color(0xFFC2410C).toARGB32());

      expect(UserRole.worker.brandColor, AppColors.workerIndigo);
      expect(UserRole.worker.brandColor.toARGB32(), const Color(0xFF6D28D9).toARGB32());
    });
  });
}
