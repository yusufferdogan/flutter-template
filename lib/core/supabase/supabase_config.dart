import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase configuration and initialization
class SupabaseConfig {
  /// Get Supabase URL from environment
  static String get supabaseUrl {
    final url = dotenv.env['SUPABASE_URL'];
    if (url == null || url.isEmpty) {
      throw Exception('SUPABASE_URL not found in .env file');
    }
    return url;
  }

  /// Get Supabase Anon Key from environment
  static String get supabaseAnonKey {
    final key = dotenv.env['SUPABASE_ANON_KEY'];
    if (key == null || key.isEmpty) {
      throw Exception('SUPABASE_ANON_KEY not found in .env file');
    }
    return key;
  }

  /// Initialize Supabase
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
        autoRefreshToken: true,
      ),
      realtimeClientOptions: const RealtimeClientOptions(
        logLevel: RealtimeLogLevel.info,
        timeout: Duration(seconds: 30),
      ),
      storageOptions: const StorageClientOptions(
        retryAttempts: 3,
      ),
    );
  }

  /// Get Supabase client instance
  static SupabaseClient get client => Supabase.instance.client;

  /// Get auth instance
  static GoTrueClient get auth => client.auth;

  /// Get database instance
  static SupabaseQueryBuilder from(String table) => client.from(table);

  /// Get storage instance
  static SupabaseStorageClient get storage => client.storage;

  /// Get functions instance
  static FunctionsClient get functions => client.functions;

  /// Get realtime instance
  static RealtimeClient get realtime => client.realtime;
}

/// Extension to provide easy access to Supabase client
extension SupabaseContext on Object {
  SupabaseClient get supabase => SupabaseConfig.client;
}
