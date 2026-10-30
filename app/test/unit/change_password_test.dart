import 'package:flutter_test/flutter_test.dart';
import 'package:project_khata/core/auth/phone_email.dart';
import 'package:project_khata/core/constants/app_strings.dart';

void main() {
  group('Change Password Validation Tests (PRD Rule 2.0 & Phase 1)', () {
    const testMobile = '01712345678';
    final initialPass = PhoneEmailHelper.getInitialPassword(testMobile); // '345678'

    test('Rejects null or empty password', () {
      expect(
        validateNewPassword(password: null, mobile: testMobile),
        equals(AppStrings.fieldRequired),
      );
      expect(
        validateNewPassword(password: '', mobile: testMobile),
        equals(AppStrings.fieldRequired),
      );
    });

    test('Rejects initial password (last 6 digits of mobile)', () {
      expect(
        validateNewPassword(password: initialPass, mobile: testMobile),
        equals(AppStrings.passwordCannotBeInitial),
      );

      // With formatted mobile +8801955957173 (initial password is '957173')
      expect(
        validateNewPassword(password: '957173', mobile: '+8801955957173'),
        equals(AppStrings.passwordCannotBeInitial),
      );

      // With spaced/hyphenated mobile
      expect(
        validateNewPassword(password: '345678', mobile: '01712-345678'),
        equals(AppStrings.passwordCannotBeInitial),
      );
    });

    test('Rejects passwords shorter than 8 characters', () {
      final shortPasswords = ['1234567', 'pass', 'abcdef', '12345'];

      for (final pass in shortPasswords) {
        expect(
          validateNewPassword(password: pass, mobile: testMobile),
          equals(AppStrings.passwordMinLength8),
          reason: '$pass has length ${pass.length} which is < 8',
        );
      }
    });

    test('Accepts valid password (>= 8 characters and not initial password)', () {
      final validPasswords = [
        'SecurePassword123',
        'Strong#2026',
        'my_new_pass_88',
        'pass1234',
        'custom_345678_pass', // contains initial password but not equal and >= 8 chars
      ];

      for (final pass in validPasswords) {
        expect(
          validateNewPassword(password: pass, mobile: testMobile),
          isNull,
          reason: '$pass should be valid',
        );
      }
    });

    test('Validates properly when mobile is null (e.g. contractor with email)', () {
      expect(
        validateNewPassword(password: 'short', mobile: null),
        equals(AppStrings.passwordMinLength8),
      );
      expect(
        validateNewPassword(password: 'ValidContractorPass123', mobile: null),
        isNull,
      );
    });
  });
}
