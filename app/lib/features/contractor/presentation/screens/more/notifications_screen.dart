import 'package:flutter/material.dart';
import 'package:project_khata/core/constants/contractor_strings.dart';
import 'package:project_khata/widgets/contractor_widgets.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<Map<String, dynamic>> _notifications = [
    {
      'id': '1',
      'title': 'নতুন প্রজেক্ট এন্ট্রি জমা',
      'body': 'তারেক মাহমুদ মেঘনা ভিউ রেসিডেন্স প্রজেক্টের এন্ট্রি জমা দিয়েছেন।',
      'time': '১০ মিনিট আগে',
      'isRead': false,
    },
    {
      'id': '2',
      'title': 'সাইটের বাইরে হাজিরা',
      'body': '১ জন শ্রমিকের সাইট সীমার বাইরে হাজিরা অনুমোদনের অপেক্ষায় রয়েছে।',
      'time': '১ ঘণ্টা আগে',
      'isRead': false,
    },
    {
      'id': '3',
      'title': 'বিল খতিয়ান প্রস্তুত',
      'body': 'গত মাসের বিল খতিয়ান সফলভাবে তৈরি ও লক করা হয়েছে।',
      'time': 'গতকাল',
      'isRead': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(ContractorStrings.notifications),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                for (var n in _notifications) {
                  n['isRead'] = true;
                }
              });
            },
            child: const Text('সব পঠিত'),
          ),
        ],
      ),
      body: _notifications.isEmpty
          ? const EmptyState(
              icon: Icons.notifications_none_rounded,
              title: 'কোনো নোটিফিকেশন নেই',
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _notifications.length,
              itemBuilder: (context, idx) {
                final n = _notifications[idx];
                final isRead = n['isRead'] as bool;

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    onTap: () {
                      setState(() => n['isRead'] = true);
                    },
                    leading: CircleAvatar(
                      backgroundColor: isRead ? Colors.grey.shade200 : const Color(0xFFEFF6FF),
                      child: Icon(
                        isRead ? Icons.notifications_none : Icons.notifications_active,
                        color: isRead ? Colors.grey : const Color(0xFF1E3A8A),
                      ),
                    ),
                    title: Text(
                      n['title'] as String,
                      style: TextStyle(
                        fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 3),
                        Text(n['body'] as String),
                        const SizedBox(height: 4),
                        Text(
                          n['time'] as String,
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
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
