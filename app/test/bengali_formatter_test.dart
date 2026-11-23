import 'package:flutter_test/flutter_test.dart';
import 'package:project_khata/core/utils/bengali_formatter.dart';

void main() {
  group('BengaliFormatter Tests', () {
    test('toBengaliNumber converts English digits to Bengali digits', () {
      expect(BengaliFormatter.toBengaliNumber('0123456789'), '০১২৩৪৫৬৭৮৯');
      expect(BengaliFormatter.toBengaliNumber(12345), '১২৩৪৫');
      expect(BengaliFormatter.toBengaliNumber(0), '০');
      expect(BengaliFormatter.toBengaliNumber(null), '০');
      expect(BengaliFormatter.toBengaliNumber('Phone: 01711000000'), 'Phone: ০১৭১১০০০০০০');
    });

    test('toCurrency formats numbers into Bengali currency style with ৳ symbol', () {
      expect(BengaliFormatter.toCurrency(0), '৳ ০');
      expect(BengaliFormatter.toCurrency(null), '৳ ০');
      expect(BengaliFormatter.toCurrency(500), '৳ ৫০০');
      expect(BengaliFormatter.toCurrency(1500), '৳ ১,৫০০');
      expect(BengaliFormatter.toCurrency(1250000), '৳ ১২,৫০,০০০');
      expect(BengaliFormatter.toCurrency(750.50, showDecimals: true), '৳ ৭৫০.৫০');
      expect(BengaliFormatter.toCurrency('3200'), '৳ ৩,২০০');
    });

    test('toFullDate formats DateTime into Bengali full date format', () {
      final date = DateTime(2026, 11, 23);
      expect(BengaliFormatter.toFullDate(date), '২৩ নভেম্বর ২০২৬');
      expect(BengaliFormatter.toFullDate(null), '');

      final newYear = DateTime(2027, 1, 1);
      expect(BengaliFormatter.toFullDate(newYear), '১ জানুয়ারি ২০২৭');
    });

    test('toShortDate formats DateTime into DD/MM/YYYY format with Bengali digits', () {
      final date = DateTime(2026, 11, 23);
      expect(BengaliFormatter.toShortDate(date), '২৩/১১/২০২৬');

      final dateSingleDigit = DateTime(2026, 5, 8);
      expect(BengaliFormatter.toShortDate(dateSingleDigit), '০৮/০৫/২০২৬');
      expect(BengaliFormatter.toShortDate(null), '');
    });

    test('getGreeting returns appropriate greeting based on hour', () {
      final greeting = BengaliFormatter.getGreeting();
      expect(greeting.isNotEmpty, true);
      expect(
        ['শুভ সকাল', 'শুভ দুপুর', 'শুভ সন্ধ্যা', 'শুভ রাত্রি'].contains(greeting),
        true,
      );
    });
  });
}
