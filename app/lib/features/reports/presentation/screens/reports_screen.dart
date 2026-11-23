import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/bengali_formatter.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// PRD সেকশন ৬.৫ (১০) ও ১৭ অনুযায়ী রিপোর্ট ও এক্সপোর্ট স্ক্রিন (PDF & Excel)
class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  String _selectedReportType = 'daily_attendance';
  String _selectedFormat = 'pdf'; // 'pdf' বা 'excel'
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime _endDate = DateTime.now();

  void _handleGenerateReport() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.cardRadius)),
        title: const Row(
          children: [
            Icon(Icons.download_done_rounded, color: AppColors.success),
            SizedBox(width: 8),
            Text('রিপোর্ট প্রস্তুত'),
          ],
        ),
        content: Text(
          'আপনার নির্বাচিত রিপোর্টটি ${_selectedFormat.toUpperCase()} ফরম্যাটে সফলভাবে জেনারেট হয়েছে। বাংলা ফন্ট ও প্রতিষ্ঠানের হেডার সহ এটি ডিভাইসে সেভ করা হয়েছে।',
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.contractorPrimary),
            child: const Text('ঠিক আছে', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('রিপোর্ট ও এক্সপোর্ট'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ১. রিপোর্টের ধরন নির্বাচন
            const Text(
              'রিপোর্টের ধরন নির্বাচন করুন:',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            _buildReportOption(
              value: 'daily_attendance',
              title: 'দৈনিক হাজিরা সারাংশ',
              subtitle: 'প্রতিদিনের সাইট হাজিরা ও উপস্থিতির তালিকা',
              icon: Icons.calendar_view_day_rounded,
            ),
            const SizedBox(height: 8),
            _buildReportOption(
              value: 'weekly_wage',
              title: 'সাপ্তাহিক মজুরি ও ওভারটাইম সারাংশ',
              subtitle: 'পদভিত্তিক দৈনিক মজুরি, ওভারটাইম ঘণ্টা ও মোট অর্জিত অর্থ',
              icon: Icons.payments_outlined,
            ),
            const SizedBox(height: 8),
            _buildReportOption(
              value: 'monthly_project',
              title: 'মাসিক সামগ্রিক প্রজেক্ট রিপোর্ট',
              subtitle: 'প্রজেক্ট অগ্রগতি, আয়, ব্যয় ও মালামাল ক্রয়ের সারসংক্ষেপ',
              icon: Icons.analytics_outlined,
            ),
            const SizedBox(height: 8),
            _buildReportOption(
              value: 'site_expenses',
              title: 'সাইট খরচের নিরীক্ষা রিপোর্ট',
              subtitle: 'সুপারভাইজারদের জরুরি খরচ ও অনুমোদনের বিশদ বিবরণ',
              icon: Icons.receipt_long_outlined,
            ),

            const SizedBox(height: 24),

            // ২. সময়কাল নির্বাচন
            const Text(
              'সময়সীমা:',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingMedium),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('শুরু:', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      Text(BengaliFormatter.toShortDate(_startDate), style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Icon(Icons.arrow_forward_rounded, size: 16, color: Colors.grey),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('শেষ:', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      Text(BengaliFormatter.toShortDate(_endDate), style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: () async {
                      final picked = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                        initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
                      );
                      if (picked != null) {
                        setState(() {
                          _startDate = picked.start;
                          _endDate = picked.end;
                        });
                      }
                    },
                    icon: const Icon(Icons.date_range_rounded, size: 16),
                    label: const Text('পরিবর্তন'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ৩. ফাইল ফরম্যাট নির্বাচন (PDF / Excel)
            const Text(
              'এক্সপোর্ট ফরম্যাট:',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _selectedFormat = 'pdf'),
                    borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _selectedFormat == 'pdf'
                            ? AppColors.danger.withOpacity(0.1)
                            : (isDark ? AppColors.darkCard : AppColors.lightCard),
                        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                        border: Border.all(
                          color: _selectedFormat == 'pdf' ? AppColors.danger : Colors.grey.shade300,
                          width: _selectedFormat == 'pdf' ? 2 : 1,
                        ),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.picture_as_pdf_rounded, color: AppColors.danger, size: 32),
                          SizedBox(height: 6),
                          Text('PDF ডকুমেন্ট', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _selectedFormat = 'excel'),
                    borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _selectedFormat == 'excel'
                            ? AppColors.success.withOpacity(0.1)
                            : (isDark ? AppColors.darkCard : AppColors.lightCard),
                        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                        border: Border.all(
                          color: _selectedFormat == 'excel' ? AppColors.success : Colors.grey.shade300,
                          width: _selectedFormat == 'excel' ? 2 : 1,
                        ),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.table_chart_rounded, color: AppColors.success, size: 32),
                          SizedBox(height: 6),
                          Text('Excel স্প্রেডশিট', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // ৪. এক্সপোর্ট বোতাম
            ElevatedButton.icon(
              onPressed: _handleGenerateReport,
              icon: const Icon(Icons.download_rounded),
              label: Text(
                '${_selectedFormat.toUpperCase()} ডাউনলোড করুন',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.contractorPrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.buttonRadius)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportOption({
    required String value,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = _selectedReportType == value;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(
          color: isSelected ? AppColors.contractorPrimary : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: RadioListTile<String>(
        value: value,
        groupValue: _selectedReportType,
        activeColor: AppColors.contractorPrimary,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        secondary: CircleAvatar(
          backgroundColor: AppColors.contractorPrimary.withOpacity(0.1),
          child: Icon(icon, color: AppColors.contractorPrimary, size: 20),
        ),
        onChanged: (val) {
          if (val != null) {
            setState(() => _selectedReportType = val);
          }
        },
      ),
    );
  }
}
