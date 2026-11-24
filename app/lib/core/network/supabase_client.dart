import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase ক্লায়েন্ট প্রোভাইডার
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Supabase কনফিগারেশন হেল্পার
class SupabaseConfig {
  static const String defaultUrl = 'https://jintblmxigdclmcshrgz.supabase.co';
  static const String defaultAnonKey = 'sb_publishable_Z0_xmA04aP9ZLbErj52k9Q_COgUFS9r';

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
