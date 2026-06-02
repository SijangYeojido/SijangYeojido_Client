import 'package:flutter/material.dart';
import '../models/models.dart';
import 'favorite_service.dart';

class RecommendationService extends ChangeNotifier {
  static final RecommendationService _instance =
      RecommendationService._internal();
  factory RecommendationService() => _instance;
  RecommendationService._internal();

  List<Store> getRecommendedStores([List<Store> stores = const []]) {
    final favIds = FavoriteService().favoriteIds;
    if (favIds.isEmpty) {
      return stores.take(5).toList();
    }

    final favoriteStores = stores.where((s) => favIds.contains(s.id)).toList();
    final favoriteCategories = favoriteStores.map((s) => s.category).toSet();

    final recommended = stores
        .where(
          (s) =>
              !favIds.contains(s.id) && favoriteCategories.contains(s.category),
        )
        .toList();

    if (recommended.length < 5) {
      final others = stores
          .where(
            (s) =>
                !favIds.contains(s.id) &&
                !favoriteCategories.contains(s.category),
          )
          .take(5 - recommended.length)
          .toList();
      recommended.addAll(others);
    }

    return recommended.take(5).toList();
  }
}
