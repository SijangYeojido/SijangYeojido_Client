import 'package:flutter/material.dart';
import 'api_client.dart';

class FavoriteService extends ChangeNotifier {
  static final FavoriteService _instance = FavoriteService._internal();
  factory FavoriteService() => _instance;
  FavoriteService._internal();

  final Set<String> _favoriteIds = {};

  Set<String> get favoriteIds => _favoriteIds;

  bool isFavorite(String storeId) => _favoriteIds.contains(storeId);

  Future<void> loadFavorites() async {
    try {
      final response =
          await ApiClient.instance.get('/favorites') as Map<String, dynamic>;
      final stores = response['stores'] as List<dynamic>? ?? [];
      _favoriteIds
        ..clear()
        ..addAll(
          stores
              .map((row) {
                final store =
                    (row as Map<String, dynamic>)['store']
                        as Map<String, dynamic>?;
                return store?['id']?.toString() ?? '';
              })
              .where((id) => id.isNotEmpty),
        );
      notifyListeners();
    } catch (_) {}
  }

  Future<void> toggleFavorite(String storeId) async {
    final parsedStoreId = int.tryParse(storeId);
    if (parsedStoreId == null) return;

    final wasFavorite = _favoriteIds.contains(storeId);
    if (wasFavorite) {
      _favoriteIds.remove(storeId);
    } else {
      _favoriteIds.add(storeId);
    }
    notifyListeners();

    try {
      if (wasFavorite) {
        await ApiClient.instance.delete('/favorites/stores/$storeId');
      } else {
        await ApiClient.instance.post(
          '/favorites/stores',
          body: {'storeId': parsedStoreId},
        );
      }
    } catch (_) {
      if (wasFavorite) {
        _favoriteIds.add(storeId);
      } else {
        _favoriteIds.remove(storeId);
      }
      notifyListeners();
    }
  }
}
