import 'package:flutter/material.dart';
import 'package:project_khata/core/constants/app_colors.dart';
import 'package:project_khata/core/constants/contractor_strings.dart';

class SupportContactScreen extends StatefulWidget {
  const SupportContactScreen({super.key});

  @override
  State<SupportContactScreen> createState() => _SupportContactScreenState();
}

class _SupportContactScreenState extends State<SupportContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  String _selectedTopic = 'প্রযুক্তিগত সমস্যা';
  bool _isSending = false;

  final List<String> _topics = [
    'প্রযুক্তিগত সমস্যা',
    'হিসাব ও পেমেন্ট সংক্রান্ত',
    'হাজিরা ও লোকেশন সমস্যা',
    'নতুন ফিচারের পরামর্শ',
    'অন্যান্য জিজ্ঞাসা',
  ];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSending = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (mounted) {
      setState(() => _isSending = false);
      _messageController.clear();
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('বার্তা গৃহীত হয়েছে'),
          content: const Text('আপনার বার্তাটি আমাদের সাপোর্ট টিমের কাছে পৌঁছেছে। অতি দ্রুত আপনার সাথে যোগাযোগ করা হবে।'),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('ঠিক আছে'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          ContractorStrings.supportContactTitle,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ইন্ট্রো ব্যানার
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.headset_mic_rounded, color: Color(0xFF2563EB), size: 32),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'আমরা আপনার সহায়তায় সর্বদা প্রস্তুত',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'যেকোনো প্রযুক্তিগত বা হিসাবজনিত সহায়তায় আমাদের সাপোর্ট টিমে সরাসরি যোগাযোগ করুন।',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // যোগাযোগ চ্যানেল কার্ডস
            _buildContactChannel(
              title: 'সরাসরি হেল্পলাইন',
              subtitle: '০১৮০০-০০০০০০ (টোল-ফ্রি)',
              actionText: 'কল করুন',
              icon: Icons.phone_in_talk_rounded,
              color: const Color(0xFF0F766E),
              isDark: isDark,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('ডায়ালারে নম্বর ওপেন হচ্ছে...')),
                );
              },
            ),

            const SizedBox(height: 12),

            _buildContactChannel(
              title: 'হোয়াটসঅ্যাপ সাপোর্ট',
              subtitle: '০১৭০০-০০০০০০ (২৪/৭ চ্যাট সাপোর্ট)',
              actionText: 'চ্যাট করুন',
              icon: Icons.chat_rounded,
              color: const Color(0xFF2563EB),
              isDark: isDark,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('হোয়াটসঅ্যাপ ওপেন হচ্ছে...')),
                );
              },
            ),

            const SizedBox(height: 12),

            _buildContactChannel(
              title: 'ইমেইল হেল্পডেস্ক',
              subtitle: 'support@projectkhata.com',
              actionText: 'মেইল করুন',
              icon: Icons.email_outlined,
              color: const Color(0xFFD97706),
              isDark: isDark,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('ইমেইল অ্যাপ ওপেন হচ্ছে...')),
                );
              },
            ),

            const SizedBox(height: 32),

            // সরাসরি বার্তা পাঠানোর ফর্ম
            const Text(
              'সরাসরি বার্তা পাঠান',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),

            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('বার্তার বিষয়', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedTopic,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.help_outline_rounded),
                    ),
                    items: _topics.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedTopic = val);
                    },
                  ),

                  const SizedBox(height: 18),

                  const Text('আপনার বার্তা বা বিবরণ', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _messageController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'সমস্যা বা বিস্তারিত এখানে লিখুন...',
                      alignLabelWithHint: true,
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'বার্তা লিখুন' : null,
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _isSending ? null : _sendMessage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? const Color(0xFF93A8F4) : AppColors.contractorNavy,
                        foregroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: _isSending
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.send_rounded),
                      label: Text(
                        _isSending ? 'পাঠানো হচ্ছে...' : 'বার্তা পাঠান',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildContactChannel({
    required String title,
    required String subtitle,
    required String actionText,
    required IconData icon,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
        trailing: OutlinedButton(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          onPressed: onTap,
          child: Text(actionText, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
