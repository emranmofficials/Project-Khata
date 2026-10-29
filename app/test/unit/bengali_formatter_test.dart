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
    });
  });
}
