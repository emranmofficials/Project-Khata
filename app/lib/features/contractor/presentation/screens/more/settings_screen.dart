import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:project_khata/core/constants/contractor_routes.dart';
import 'package:project_khata/core/constants/contractor_strings.dart';
import 'package:project_khata/widgets/contractor_widgets.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _useBanglaDigits = true;
  String _themeMode = 'system';
  bool _largeFont = false;
  double _defaultGeofence = 150;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(ContractorStrings.appSettings),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ভাষা সেটিংস সাব-পেজ লিঙ্ক
          Card(
            child: ListTile(
              leading: const Icon(Icons.language_rounded),
              title: const Text(ContractorStrings.languageSettingsTitle),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => context.push(ContractorRoutes.languageSettings),
            ),
          ),
          const SizedBox(height: 10),
          // থিম সেটিংস সাব-পেজ লিঙ্ক
          Card(
            child: ListTile(
              leading: const Icon(Icons.palette_outlined),
              title: const Text(ContractorStrings.themeSettingsTitle),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => context.push(ContractorRoutes.themeSettings),
            ),
          ),
          const SizedBox(height: 16),
          // ভাষা ও সংখ্যা ফরম্যাট
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    ContractorStrings.languageSetting,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
                RadioListTile<bool>(
                  title: const Text(ContractorStrings.banglaDigits),
                  value: true,
                  groupValue: _useBanglaDigits,
                  onChanged: (val) => setState(() => _useBanglaDigits = val!),
                ),
                RadioListTile<bool>(
                  title: const Text(ContractorStrings.englishDigits),
                  value: false,
                  groupValue: _useBanglaDigits,
                  onChanged: (val) => setState(() => _useBanglaDigits = val!),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // থিম নির্বাচন
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    ContractorStrings.themeSetting,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
                RadioListTile<String>(
                  title: const Text(ContractorStrings.themeSystem),
                  value: 'system',
                  groupValue: _themeMode,
                  onChanged: (val) => setState(() => _themeMode = val!),
                ),
                RadioListTile<String>(
                  title: const Text(ContractorStrings.themeLight),
                  value: 'light',
                  groupValue: _themeMode,
                  onChanged: (val) => setState(() => _themeMode = val!),
                ),
                RadioListTile<String>(
                  title: const Text(ContractorStrings.themeDark),
                  value: 'dark',
                  groupValue: _themeMode,
                  onChanged: (val) => setState(() => _themeMode = val!),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // বড় ফন্ট
          Card(
            child: SwitchListTile(
              title: const Text(
                ContractorStrings.largeFontToggle,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text('পঠনযোগ্যতার সুবিধার জন্য বড় ফন্ট চালু করুন'),
              value: _largeFont,
              onChanged: (val) => setState(() => _largeFont = val),
            ),
          ),

          const SizedBox(height: 16),

          // ডিফল্ট জিও-ফেন্স রেডিয়াস
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        ContractorStrings.defaultGeofenceSetting,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${toBn(_defaultGeofence.round())} মিটার',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Slider(
                    value: _defaultGeofence,
                    min: 100,
                    max: 200,
                    divisions: 10,
                    onChanged: (val) => setState(() => _defaultGeofence = val),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
