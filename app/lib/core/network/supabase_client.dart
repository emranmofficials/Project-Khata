import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase ক্লায়েন্ট প্রোভাইডার
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Supabase কনফিগারেশন হেল্পার
class SupabaseConfig {
  static const String defaultUrl = 'https://uplxkvrztqmjiqiijfbk.supabase.co';
  static const String defaultAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVwbHhrdnJ6dHFtamlxaWlqZmJrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTI0MjQwNDksImV4cCI6MjEwODAwMDA0OX0.sF-CJcsbX99xtndvIrtfQ9JxV3jBLlhBtqTtJw0Qsi4';

  static String get supabaseUrl => const String.fromEnvironment(
        'SUPABASE_URL',
        defaultValue: defaultUrl,
      );

  static String get supabaseAnonKey => const String.fromEnvironment(
        'SUPABASE_ANON_KEY',
        defaultValue: defaultAnonKey,
      );

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
