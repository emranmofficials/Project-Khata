import 'package:flutter/material.dart';
import 'package:project_khata/core/constants/contractor_strings.dart';

class AuditLogScreen extends StatelessWidget {
  const AuditLogScreen({super.key});

  final List<Map<String, String>> _logs = const [
    {
      'actor': 'ঠিকাদার (এডমিন)',
      'action': 'সুপারভাইজার অ্যাসাইনমেন্ট পরিবর্তন',
      'detail': 'মেঘনা ভিউ রেসিডেন্স প্রজেক্টে তারেক মাহমুদকে অ্যাসাইন করা হয়েছে',
      'time': 'আজ সকাল ১০:৩০',
    },
    {
      'actor': 'তারেক মাহমুদ (সুপারভাইজার)',
      'action': 'দৈনিক হাজিরা দাখিল',
      'detail': '১২ জন শ্রমিকের উপস্থিতি ও ওভারটাইম রেকর্ড দাখিল করা হয়েছে',
      'time': 'আজ সকাল ০৯:১৫',
    },
    {
      'actor': 'ঠিকাদার (এডমিন)',
      'action': 'মজুরি পেমেন্ট বরাদ্দ',
      'detail': 'মোবারক হোসেনকে ৫,০০০ টাকা FIFO ভিত্তিতে বরাদ্দ করা হয়েছে',
      'time': 'গতকাল বিকাল ০৫:২০',
    },
    {
      'actor': 'ফারহানা আহমেদ (ক্লায়েন্ট)',
      'action': 'মালামাল রেকর্ড যোগ',
      'detail': 'BSRM রড ক্রয় রেকর্ড যোগ করা হয়েছে (ক্লায়েন্ট যোগকৃত)',
      'time': '২৮ অক্টোবর',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(ContractorStrings.auditLog),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _logs.length,
        itemBuilder: (context, idx) {
          final log = _logs[idx];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        log['actor']!,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Text(
                        log['time']!,
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    log['action']!,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.blueGrey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    log['detail']!,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
