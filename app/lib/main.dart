import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_strings.dart';
import 'core/network/supabase_client.dart';
import 'core/theme/app_theme.dart';
import 'features/navigation/presentation/screens/root_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Supabase ক্লায়েন্ট ইনিশিয়ালাইজেশন
  try {
    await SupabaseConfig.initialize();
  } catch (e) {
    debugPrint('Supabase Initialization Note: $e');
  }

  runApp(
    const ProviderScope(
      child: ProjectKhataApp(),
    ),
  );
}

class ProjectKhataApp extends StatelessWidget {
  const ProjectKhataApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const RootNavigationScreen(),
    );
  }
}
