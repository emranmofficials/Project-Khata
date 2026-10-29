import 'package:intl/intl.dart';

class BengaliFormatter {
  BengaliFormatter._();

  static const Map<String, String> _enToBnDigits = {
    '0': '০',
    '1': '১',
    '2': '২',
    '3': '৩',
    '4': '৪',
    '5': '৫',
    '6': '৬',
    '7': '৭',
    '8': '৮',
    '9': '৯',
  };

  /// Converts any English digits in a string or number to Bengali numerals
  static String toBnNumber(dynamic number) {
    if (number == null) return '০';
    final str = number.toString();
    return str.split('').map((char) => _enToBnDigits[char] ?? char).join('');
  }

  /// Formats currency with Taka symbol in Bengali numerals
  static String formatCurrency(num amount) {
    final formatter = NumberFormat('#,##,###.##', 'en_US');
    final formatted = formatter.format(amount);
    return '৳ ${toBnNumber(formatted)}';
  }

  /// Alias for formatCurrency
  static String toCurrency(num amount) => formatCurrency(amount);

  /// Formats a DateTime to readable Bengali format (e.g. ২৯ অক্টোবর ২০২৬)
  static String formatDate(DateTime date) {
    const months = [
      'জানুয়ারি',
      'ফেব্রুয়ারি',
      'মার্চ',
      'এপ্রিল',
      'মে',
      'জুন',
      'জুলাই',
      'আগস্ট',
      'সেপ্টেম্বর',
      'অক্টোবর',
      'নভেম্বর',
      'ডিসেম্বর'
    ];
    final day = toBnNumber(date.day);
    final month = months[date.month - 1];
    final year = toBnNumber(date.year);
    return '$day $month $year';
  }

  /// Alias for formatDate
  static String toDate(DateTime date) => formatDate(date);
  static String toBnDate(DateTime date) => formatDate(date);

  /// Formats square feet
  static String toSqft(num sqft) => '${toBnNumber(sqft)} বর্গফুট';
}
