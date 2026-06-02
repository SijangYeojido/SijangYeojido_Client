import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sijangyeojido_client/services/offline_cache_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('public bundle is saved with cache metadata and restored', () async {
    final service = OfflineCacheService.instance;
    final bundle = {
      'markets': [
        {
          'market': {'id': 1, 'name': '신원시장'},
          'map': {'mapWidth': 100, 'mapHeight': 100},
          'stores': const [],
        },
      ],
      'deals': const [],
    };

    await service.savePublicBundle(bundle);
    final cached = await service.loadPublicBundle();

    expect(cached, isNotNull);
    expect(cached?['version'], 1);
    expect(service.cachedAt(cached), isNotNull);
    expect((cached?['data'] as Map<String, dynamic>)['markets'], isNotEmpty);
  });

  test('cache is stale after 24 hours', () async {
    final service = OfflineCacheService.instance;
    final stalePayload = {
      'version': 1,
      'cachedAt': DateTime.now()
          .subtract(const Duration(hours: 25))
          .toIso8601String(),
      'data': {'markets': const [], 'deals': const []},
    };
    SharedPreferences.setMockInitialValues({
      'offline_public_explore_bundle_v1': jsonEncode(stalePayload),
    });

    final cached = await service.loadPublicBundle();
    final cachedAt = service.cachedAt(cached);

    expect(cachedAt, isNotNull);
    expect(service.isStale(cachedAt), isTrue);
  });
}
