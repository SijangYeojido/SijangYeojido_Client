import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class OfflineCacheService {
  OfflineCacheService._();

  static final OfflineCacheService instance = OfflineCacheService._();
  static const Duration staleAfter = Duration(hours: 24);

  static const String _publicBundleKey = 'offline_public_explore_bundle_v1';
  static const int _version = 1;

  Future<void> savePublicBundle(Map<String, dynamic> bundle) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = <String, dynamic>{
      'version': _version,
      'cachedAt': DateTime.now().toIso8601String(),
      'data': bundle,
    };
    await prefs.setString(_publicBundleKey, jsonEncode(payload));
  }

  Future<Map<String, dynamic>?> loadPublicBundle() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_publicBundleKey);
      if (raw == null || raw.isEmpty) return null;

      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;
      if (decoded['version'] != _version) return null;
      if (decoded['data'] is! Map<String, dynamic>) return null;

      return decoded;
    } catch (_) {
      return null;
    }
  }

  DateTime? cachedAt(Map<String, dynamic>? cachedBundle) {
    if (cachedBundle == null) return null;
    return DateTime.tryParse(cachedBundle['cachedAt']?.toString() ?? '');
  }

  bool isStale(DateTime? cachedAt) {
    if (cachedAt == null) return true;
    return DateTime.now().difference(cachedAt) > staleAfter;
  }

  Future<void> clearPublicBundle() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_publicBundleKey);
  }
}
