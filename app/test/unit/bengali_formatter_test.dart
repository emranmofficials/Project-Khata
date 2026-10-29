import 'package:flutter_test/flutter_test.dart';
import 'package:project_khata/core/utils/bengali_formatter.dart';

void main() {
  group('BengaliFormatter Tests', () {
    test('converts English digits to Bengali digits correctly', () {
      expect(BengaliFormatter.toBnNumber('0123456789'), '০১২৩৪৫৬৭৮৯');
      expect(BengaliFormatter.toBnNumber(150), '১৫০');
      expect(BengaliFormatter.toBnNumber(null), '০');
    });

    test('formats currency with Taka sign in Bengali digits', () {
      final formatted = BengaliFormatter.formatCurrency(50000);
      expect(formatted.contains('৳'), isTrue);
      expect(formatted.contains('৫০,০০০'), isTrue);
    });

    test('formats date correctly in Bengali', () {
      final date = DateTime(2026, 10, 29);
      final formattedDate = BengaliFormatter.formatDate(date);
      expect(formattedDate, '২৯ অক্টোবর ২০২৬');
      expect(BengaliFormatter.toDate(date), '২৯ অক্টোবর ২০২৬');
    });

    test('formats square feet and aliases', () {
      expect(BengaliFormatter.toCurrency(1200), '৳ ১,২০০');
      expect(BengaliFormatter.toSqft(2500), '২৫০০ বর্গফুট');
    });
  });
}
