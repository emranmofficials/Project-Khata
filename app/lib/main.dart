import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/constants/app_colors.dart';
import 'core/constants/app_strings.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/controllers/auth_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables (.env)
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // Fallback if dotenv cannot find .env
  }

  // Initialize Supabase
  final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? 'https://uplxkvrztqmjiqiijfbk.supabase.co';
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVwbHhrdnJ6dHFtamlxaWlqZmJrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTI0MjQwNDksImV4cCI6MjEwODAwMDA0OX0.sF-CJcsbX99xtndvIrtfQ9JxV3jBLlhBtqTtJw0Qsi4';

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  runApp(
    const ProviderScope(
      child: ProjectKhataApp(),
    ),
  );
}

class ProjectKhataApp extends ConsumerWidget {
  const ProjectKhataApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final user = ref.watch(authControllerProvider).value;

    // Dynamically adapt theme to active role's brand color
    final primaryColor = user?.role.brandColor ?? AppColors.contractorNavy;

    return MaterialApp.router(
      title: AppStrings.appNameBangla,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: AppTheme.getTheme(primaryColor: primaryColor, isDark: false),
      darkTheme: AppTheme.getTheme(primaryColor: primaryColor, isDark: true),
      themeMode: ThemeMode.system,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('bn', 'BD'), // Bengali (Primary)
        Locale('en', 'US'),
      ],
    );
  }
}
