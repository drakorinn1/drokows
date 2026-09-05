import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase projeni oluşturduktan sonra bu iki değeri
/// Supabase Dashboard > Project Settings > API sayfasından alıp buraya yaz.
class SupabaseConfig {
  SupabaseConfig._();

  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://lxlwglenwmasvdoevgkx.supabase.co',
  );

  static const String anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'sb_publishable_Wnf6ZMFi4eUSZJtpQeBnQg_2Sp3tPqo',
  );

  static Future<void> init() async {
    await Supabase.initialize(url: url, anonKey: anonKey);
  }
}

SupabaseClient get supabase => Supabase.instance.client;