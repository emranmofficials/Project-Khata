import 'package:intl/intl.dart';

/// বাংলা সংখ্যা, তারিখ ও টাকা ফরম্যাটিং ইউটিলিটি
class BengaliFormatter {
  static const Map<String, String> _englishToBengaliDigits = {
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

  static const List<String> _bengaliMonths = [
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
    'ডিসেম্বর',
  ];

  /// যেকোনো ইংরেজি সংখ্যা বা স্ট্রিংকে বাংলা সংখ্যায় রূপান্তর
  static String toBengaliNumber(dynamic number) {
    if (number == null) return '০';
    String str = number.toString();
    _englishToBengaliDigits.forEach((en, bn) {
      str = str.replaceAll(en, bn);
    });
    return str;
  }

  /// টাকার ফরম্যাট (যেমন: ৳ ১,২৫০.০০)
  static String toCurrency(dynamic amount, {bool showDecimals = false}) {
    if (amount == null) return '৳ ০';
    double val = (amount is num) ? amount.toDouble() : double.tryParse(amount.toString()) ?? 0.0;
    final formatter = NumberFormat(showDecimals ? '#,##0.00' : '#,##0');
    String formatted = formatter.format(val);
    return '৳ ${toBengaliNumber(formatted)}';
  }

  /// পূর্ণাঙ্গ বাংলা তারিখ (যেমন: ২৩ নভেম্বর ২০২৬)
  static String toFullDate(DateTime? date) {
    if (date == null) return '';
    String day = toBengaliNumber(date.day);
    String month = _bengaliMonths[date.month - 1];
    String year = toBengaliNumber(date.year);
    return '$day $month $year';
  }

  /// সংক্ষিপ্ত বাংলা তারিখ (যেমন: ২৩/১১/২০২৬)
  static String toShortDate(DateTime? date) {
    if (date == null) return '';
    String day = toBengaliNumber(date.day.toString().padLeft(2, '0'));
    String month = toBengaliNumber(date.month.toString().padLeft(2, '0'));
    String year = toBengaliNumber(date.year);
    return '$day/$month/$year';
  }

  /// সময়ভিত্তিক শুভেচ্ছা বার্তা (শুভ সকাল / দুপুর / সন্ধ্যা)
  static String getGreeting() {
    int hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'শুভ সকাল';
    } else if (hour >= 12 && hour < 17) {
      return 'শুভ দুপুর';
    } else if (hour >= 17 && hour < 21) {
      return 'শুভ সন্ধ্যা';
    } else {
      return 'শুভ রাত্রি';
    }
  }
}
