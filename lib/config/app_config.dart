class AppConfig {
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://sijang-api.hyphen.it.com',
  );
  static const resetLocalDataOnLaunch = bool.fromEnvironment(
    'RESET_LOCAL_DATA_ON_LAUNCH',
    defaultValue: false,
  );
  static const useLocalAuthFallback = bool.fromEnvironment(
    'USE_LOCAL_AUTH_FALLBACK',
    defaultValue: false,
  );
}
