class AppConfig {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://isgomjrexrsdhnubcdbd.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXB'
        'hYmFzZSIsInJlZiI6ImlzZ29tanJleHJzZGhudWJjZGJkIiwicm9sZ'
        'SI6ImFub24iLCJpYXQiOjE3ODA1NDYwNDMsImV4cCI6MjA5NjEyMjA'
        '0M30.yKDizItH-AzDP0SN2s8pBDyWHVWUrFUguRk2xn9jBe0',
  );

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: supabaseUrl,
  );
}
