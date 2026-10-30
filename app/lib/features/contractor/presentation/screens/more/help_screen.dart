import 'package:flutter/material.dart';
import '../../../../core/constants/contractor_strings.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(ContractorStrings.helpAndInfo),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF1E3A8A).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.handyman_rounded,
                size: 40,
                color: Color(0xFF1E3A8A),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Project Khata (প্রজেক্ট খাতা)',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'ভার্সন ২.১ (বিল্ড ৪৭)',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 24),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.support_agent_rounded),
                      title: Text('সহায়তা ও যোগাযোগ'),
                      subtitle: Text('support@projectkhata.app\n+880 1700-000000'),
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.verified_user_outlined),
                      title: Text('গোপনীয়তা নীতি ও শর্তাবলী'),
                      subtitle: Text('https://projectkhata.app/privacy'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
