import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_khata/core/constants/app_colors.dart';
import 'package:project_khata/core/constants/contractor_strings.dart';
import '../../contractor_providers.dart';

class BillTemplateScreen extends ConsumerStatefulWidget {
  const BillTemplateScreen({super.key});

  @override
  ConsumerState<BillTemplateScreen> createState() => _BillTemplateScreenState();
}

class _BillTemplateScreenState extends ConsumerState<BillTemplateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _prefixController = TextEditingController(text: 'PK-INV-');
  final _termsController = TextEditingController(
    text: '১. বিল ইস্যু হওয়ার ৭ কার্যদিবসের মধ্যে বকেয়া পরিশোধযোগ্য।\n২. সমস্ত লেনদেনের অফিশিয়াল রশিদ প্রদান করা হবে।',
  );
  final _footerController = TextEditingController(text: 'ব্যবসা সফল হোক — ধন্যবাদ!');
  bool _includeSignature = true;
  bool _isSaving = false;

  @override
  void dispose() {
    _prefixController.dispose();
    _termsController.dispose();
    _footerController.dispose();
    super.dispose();
  }

  void _saveTemplate() async {
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('বিল টেমপ্লেট সফলভাবে সংরক্ষিত হয়েছে')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final companyAsync = ref.watch(companyProfileProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          ContractorStrings.billTemplateTitle,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // হেডার প্রিভিউ কার্ড
              const Text(
                'বিলের লাইভ প্রিভিউ',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                companyAsync.valueOrNull?.companyName ?? ContractorStrings.defaultCompanyName,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : AppColors.contractorNavy,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                companyAsync.valueOrNull?.address ?? 'ঢাকা, বাংলাদেশ',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                ),
                              ),
                              Text(
                                'মোবাইল: ০১৭১২-৩৪৫৬৭৮',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: (isDark ? const Color(0xFF93A8F4) : AppColors.contractorNavy)
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'ইনভয়েস',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isDark ? const Color(0xFF93A8F4) : AppColors.contractorNavy,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'ইনভয়েস নং: ${_prefixController.text}২০২৬-০০১',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                        const Text(
                          'তারিখ: ৩০ অক্টোবর, ২০২৬',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('কাজের বিবরণ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          Text('মোট টাকা', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('১ম তলার ঢালাই কাজ ও রড বাইন্ডিং', style: TextStyle(fontSize: 12)),
                        Text('৳ ১,৫০,০০০', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const Divider(height: 20),
                    if (_includeSignature) ...[
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 110,
                              height: 1,
                              color: isDark ? Colors.white38 : Colors.black45,
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'অনুমোদিত স্বাক্ষর',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // সেটিংস ফর্ম
              const Text(
                'টেমপ্লেট কাস্টমাইজেশন',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 14),

              // ইনভয়েস প্রিফিক্স
              const Text('ইনভয়েস নম্বর প্রিফিক্স', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _prefixController,
                decoration: const InputDecoration(
                  hintText: 'PK-INV-',
                  prefixIcon: Icon(Icons.tag_rounded),
                ),
                onChanged: (_) => setState(() {}),
              ),

              const SizedBox(height: 18),

              // বিলের শর্তাবলী
              const Text('বিলের শর্তাবলী ও নিয়মাবলী', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _termsController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'বিলের নিচে প্রদর্শিত নিয়মাবলী লিখুন',
                  prefixIcon: Icon(Icons.gavel_rounded),
                ),
              ),

              const SizedBox(height: 18),

              // ফুটার বার্তা
              const Text('ফুটার শুভেচ্ছা বার্তা', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _footerController,
                decoration: const InputDecoration(
                  hintText: 'ধন্যবাদ!',
                  prefixIcon: Icon(Icons.favorite_outline_rounded),
                ),
              ),

              const SizedBox(height: 18),

              // স্বাক্ষর লাইন টগল
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('অনুমোদিত স্বাক্ষর লাইন অন্তর্ভুক্ত করুন', style: TextStyle(fontWeight: FontWeight.bold)),
                value: _includeSignature,
                onChanged: (v) => setState(() => _includeSignature = v),
              ),

              const SizedBox(height: 28),

              // সংরক্ষণ বাটন
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveTemplate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? const Color(0xFF93A8F4) : AppColors.contractorNavy,
                    foregroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.save_rounded),
                  label: Text(
                    _isSaving ? 'সংরক্ষণ হচ্ছে...' : 'টেমপ্লেট সংরক্ষণ করুন',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
