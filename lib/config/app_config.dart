import 'dart:io';

class AppConfig {
  static String get apiBaseUrl {
    const configured = String.fromEnvironment('API_BASE_URL');
    if (configured.isNotEmpty) return configured;
    if (Platform.isAndroid) return 'http://10.0.2.2:4000';
    return 'http://127.0.0.1:4000';
  }

  static const resetLocalDataOnLaunch = bool.fromEnvironment(
    'RESET_LOCAL_DATA_ON_LAUNCH',
    defaultValue: false,
  );

  static const useLocalAuthFallback = bool.fromEnvironment(
    'USE_LOCAL_AUTH_FALLBACK',
    defaultValue: false,
  );
}
