import 'package:flutter_test/flutter_test.dart';
import 'package:project_khata/core/auth/phone_email.dart';

void main() {
  group('PhoneEmailHelper & Bangladeshi Mobile Validation Tests', () {
    test('Validates correct 11-digit Bangladeshi mobile numbers starting with 01[3-9]', () {
      final validNumbers = [
        '01300000000',
        '01400000000',
        '01500000000',
        '01600000000',
        '01712345678',
        '01812345678',
        '01955957173',
      ];

      for (final num in validNumbers) {
        expect(isValidBangladeshiMobile(num), isTrue, reason: '$num should be valid');
      }
    });

    test('Validates numbers with +88, 88, spaces, or hyphens', () {
      expect(isValidBangladeshiMobile('+8801712345678'), isTrue);
      expect(isValidBangladeshiMobile('8801955957173'), isTrue);
      expect(isValidBangladeshiMobile('01712-345678'), isTrue);
      expect(isValidBangladeshiMobile('01955 957 173'), isTrue);
      expect(isValidBangladeshiMobile('(018) 12345678'), isTrue);
    });

    test('Rejects invalid phone numbers', () {
      final invalidNumbers = [
        '01012345678', // 0 is invalid operator digit
        '01112345678', // 1 is invalid
        '01212345678', // 2 is invalid
        '0171234567', // 10 digits
        '017123456789', // 12 digits
        '02987654321', // Landline prefix
        '0171234abcd', // Non-digit
        '', // Empty
        null, // Null
        '   ', // Whitespace
      ];

      for (final num in invalidNumbers) {
        expect(isValidBangladeshiMobile(num), isFalse, reason: '$num should be invalid');
      }
    });

    test('mobileToSyntheticEmail formats phone into {mobile}@members.projectkhata.app', () {
      expect(
        mobileToSyntheticEmail('01712345678'),
        '01712345678@members.projectkhata.app',
      );
      expect(
        mobileToSyntheticEmail('+8801955957173'),
        '01955957173@members.projectkhata.app',
      );
      expect(
        mobileToSyntheticEmail('01812-345678'),
        '01812345678@members.projectkhata.app',
      );
    });

    test('getInitialPassword extracts last 6 digits of mobile', () {
      expect(getInitialPassword('01712345678'), '345678');
      expect(getInitialPassword('+8801955957173'), '957173');
      expect(getInitialPassword('01800123456'), '123456');
    });
  });
}
