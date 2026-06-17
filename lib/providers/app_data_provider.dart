import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../data/mock_data.dart';
import '../models/models.dart';
import '../services/api_client.dart';
import '../services/offline_cache_service.dart';

class AppDataProvider with ChangeNotifier {
  AppDataProvider({ApiClient? client})
    : _client = client ?? ApiClient.instance {
    if (kDebugMode) _useMockFallback();
    refresh();
  }

  final ApiClient _client;
  final OfflineCacheService _offlineCache = OfflineCacheService.instance;

  bool _isLoading = false;
  bool _isUsingCachedData = false;
  bool _isCacheStale = false;
  DateTime? _cacheUpdatedAt;
  String? _errorMessage;
  List<MarketInfo> _markets = const [];
  List<Store> _stores = const [];
  List<Zone> _zones = const [];
  List<POI> _pois = const [];
  List<Map<String, dynamic>> _merchantStores = const [];
  List<Map<String, dynamic>> _adminStores = const [];
  List<Map<String, dynamic>> _adminReports = const [];
  List<Map<String, dynamic>> _moderationCases = const [];
  List<Map<String, dynamic>> _adminLogs = const [];
  Map<String, dynamic>? _adminAnalytics;
  Map<String, dynamic>? _sellerAnalytics;
  List<Reservation> _reservations = const [];
  List<FlashDeal> _flashDeals = const [];
  List<Map<String, dynamic>> _merchantDeals = const [];
  List<Map<String, dynamic>> _coupons = const [];
  Map<String, int> _marketIdsByName = const {};
  Map<int, Offset> _marketLocationsById = const {};
  Map<String, Size> _marketMapSizesByName = const {};

  bool get isLoading => _isLoading;
  bool get isUsingCachedData => _isUsingCachedData;
  bool get isCacheStale => _isCacheStale;
  DateTime? get cacheUpdatedAt => _cacheUpdatedAt;
  String? get errorMessage => _errorMessage;
  List<MarketInfo> get markets => _markets;
  List<Store> get stores => _stores;
  List<Zone> get zones => _zones;
  List<POI> get pois => _pois;
  List<Map<String, dynamic>> get merchantStores => _merchantStores;
  List<Map<String, dynamic>> get adminStores => _adminStores;
  List<Map<String, dynamic>> get adminReports => _adminReports;
  List<Map<String, dynamic>> get moderationCases => _moderationCases;
  List<Map<String, dynamic>> get adminLogs => _adminLogs;
  Map<String, dynamic>? get adminAnalytics => _adminAnalytics;
  Map<String, dynamic>? get sellerAnalytics => _sellerAnalytics;
  List<Reservation> get reservations => _reservations;
  List<FlashDeal> get flashDeals => _flashDeals;
  List<Map<String, dynamic>> get merchantDeals => _merchantDeals;
  List<Map<String, dynamic>> get coupons => _coupons;

  int? marketIdForName(String marketName) => _marketIdsByName[marketName];

  MarketInfo getMarket(String name) {
    return _markets.firstWhere(
      (market) => market.name == name,
      orElse: () => kDebugMode
          ? MockData.getMarket(name)
          : MarketInfo(
              name: name,
              description: '',
              address: '',
              storeCount: 0,
              highlights: const [],
              accentColor: const Color(0xFF4F46E5),
              isAvailable: false,
            ),
    );
  }

  Zone? getZoneById(String id) {
    try {
      return _zones.firstWhere((zone) => zone.id == id);
    } catch (_) {
      return kDebugMode ? MockData.getZoneById(id) : null;
    }
  }

  Store? getStoreById(String id) {
    try {
      return _stores.firstWhere((store) => store.id == id);
    } catch (_) {
      return kDebugMode ? MockData.getStoreById(id) : null;
    }
  }

  List<Store> storesForMarket(String marketName) {
    return _stores.where((store) => store.marketName == marketName).toList();
  }

  List<MarketInfo> searchMarkets(String keyword) {
    final normalized = keyword.trim().toLowerCase();
    if (normalized.isEmpty) return const [];
    return _markets.where((market) {
      return market.name.toLowerCase().contains(normalized) ||
          market.address.toLowerCase().contains(normalized) ||
          market.description.toLowerCase().contains(normalized) ||
          market.highlights.any(
            (highlight) => highlight.toLowerCase().contains(normalized),
          );
    }).toList();
  }

  List<Store> searchStores(String keyword, {String? category}) {
    final normalized = keyword.trim().toLowerCase();
    return _stores.where((store) {
      final matchesKeyword =
          normalized.isEmpty ||
          store.name.toLowerCase().contains(normalized) ||
          store.category.toLowerCase().contains(normalized) ||
          store.items.any(
            (item) => item.name.toLowerCase().contains(normalized),
          );
      final matchesCategory =
          category == null ||
          category.isEmpty ||
          store.category == category ||
          category == '전체';
      return matchesKeyword && matchesCategory;
    }).toList();
  }

  Future<void> refresh() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _loadFromServer();
    } catch (error) {
      final restored = await _restoreFromCache();
      if (!restored) {
        _useMockFallback();
      }
      _errorMessage = _friendlyError(error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMerchantStores() async {
    try {
      final response = await _client.get('/seller/stores') as List<dynamic>;
      _merchantStores = response.cast<Map<String, dynamic>>();
      notifyListeners();
    } catch (error) {
      _errorMessage = _friendlyError(error);
      notifyListeners();
    }
  }

  Future<void> loadMerchantDeals() async {
    try {
      final response = await _client.get('/deals/seller') as List<dynamic>;
      _merchantDeals = response.cast<Map<String, dynamic>>();
      notifyListeners();
    } catch (error) {
      _errorMessage = _friendlyError(error);
      notifyListeners();
    }
  }

  Future<void> loadAdminData() async {
    try {
      final storesResponse =
          await _client.get('/admin/stores') as List<dynamic>;
      final reportsResponse =
          await _client.get('/reports/admin') as List<dynamic>;
      final moderationResponse =
          await _client.get('/admin/moderation/cases') as List<dynamic>;
      final logsResponse =
          await _client.get('/admin/system/logs', query: {'limit': 30})
              as List<dynamic>;
      final analyticsResponse =
          await _client.get('/admin/analytics/overview', query: {'range': '7d'})
              as Map<String, dynamic>;
      _adminStores = storesResponse.cast<Map<String, dynamic>>();
      _adminReports = reportsResponse.cast<Map<String, dynamic>>();
      _moderationCases = moderationResponse.cast<Map<String, dynamic>>();
      _adminLogs = logsResponse.cast<Map<String, dynamic>>();
      _adminAnalytics = analyticsResponse;
      notifyListeners();
    } catch (error) {
      _errorMessage = _friendlyError(error);
      notifyListeners();
    }
  }

  Future<void> approveStore(int storeId, String approvalStatus) async {
    await _client.patch(
      '/admin/stores/$storeId/approve',
      body: {'approvalStatus': approvalStatus},
    );
    await recordAction(
      'admin.store.approve',
      metadata: {'storeId': storeId, 'approvalStatus': approvalStatus},
    );
    await loadAdminData();
    await refresh();
  }

  Future<void> createMarket(Map<String, dynamic> body) async {
    await _client.post('/markets', body: body);
    await recordAction('admin.market.create', metadata: {'name': body['name']});
    await refresh();
  }

  Future<void> updateMarket(int marketId, Map<String, dynamic> body) async {
    await _client.patch('/markets/$marketId', body: body);
    await recordAction('admin.market.update', metadata: {'marketId': marketId});
    await refresh();
  }

  Future<void> deleteMarket(int marketId) async {
    await _client.delete('/markets/$marketId');
    await recordAction('admin.market.delete', metadata: {'marketId': marketId});
    await refresh();
    await loadAdminData();
  }

  Future<void> createMarketZone(int marketId, Map<String, dynamic> body) async {
    await _client.post('/markets/$marketId/zones', body: body);
    await recordAction(
      'admin.market_zone.create',
      metadata: {'marketId': marketId, 'name': body['name']},
    );
    await refresh();
  }

  Future<void> updateMarketZone(
    int marketId,
    int zoneId,
    Map<String, dynamic> body,
  ) async {
    await _client.patch('/markets/$marketId/zones/$zoneId', body: body);
    await recordAction(
      'admin.market_zone.update',
      metadata: {'marketId': marketId, 'zoneId': zoneId},
    );
    await refresh();
  }

  Future<void> deleteMarketZone(int marketId, int zoneId) async {
    await _client.delete('/markets/$marketId/zones/$zoneId');
    await recordAction(
      'admin.market_zone.delete',
      metadata: {'marketId': marketId, 'zoneId': zoneId},
    );
    await refresh();
  }

  Future<void> updateAdminStore(int storeId, Map<String, dynamic> body) async {
    await _client.patch('/admin/stores/$storeId', body: body);
    await recordAction('admin.store.update', metadata: {'storeId': storeId});
    await loadAdminData();
    await refresh();
  }

  Future<void> deleteAdminStore(int storeId) async {
    await _client.delete('/admin/stores/$storeId');
    await recordAction('admin.store.delete', metadata: {'storeId': storeId});
    await loadAdminData();
    await refresh();
  }

  Future<void> updateReportStatus(
    int reportId,
    String status, {
    String? adminMemo,
  }) async {
    await _client.patch(
      '/reports/admin/$reportId/status',
      body: {
        'status': status,
        if (adminMemo != null && adminMemo.isNotEmpty) 'adminMemo': adminMemo,
      },
    );
    await recordAction(
      'admin.report.status',
      metadata: {'reportId': reportId, 'status': status},
    );
    await loadAdminData();
  }

  Future<void> runModerationAction(
    int caseId,
    String type, {
    String? note,
    int? durationHours,
  }) async {
    final body = <String, dynamic>{
      'type': type,
      if (note != null && note.isNotEmpty) 'note': note,
    };
    if (durationHours != null) {
      body['durationHours'] = durationHours;
    }
    await _client.post('/admin/moderation/cases/$caseId/actions', body: body);
    await recordAction(
      'admin.moderation.action',
      metadata: {'caseId': caseId, 'type': type},
    );
    await loadAdminData();
    await refresh();
  }

  Future<void> loadReservations() async {
    try {
      final response = await _client.get('/reservations') as List<dynamic>;
      _reservations = response
          .cast<Map<String, dynamic>>()
          .map(_reservationFromJson)
          .toList();
      notifyListeners();
    } catch (error) {
      _errorMessage = _friendlyError(error);
      notifyListeners();
    }
  }

  Future<void> loadSellerAnalytics() async {
    try {
      _sellerAnalytics =
          await _client.get(
                '/seller/analytics/overview',
                query: {'range': '7d'},
              )
              as Map<String, dynamic>;
      notifyListeners();
    } catch (error) {
      _errorMessage = _friendlyError(error);
      notifyListeners();
    }
  }

  Future<Reservation> createReservation({
    required String storeId,
    String? productId,
    String? dealId,
    int quantity = 1,
  }) async {
    if (_isUsingCachedData) {
      throw const ApiException(
        0,
        '오프라인 저장 데이터에서는 예약을 사용할 수 없습니다. 온라인 연결 후 다시 시도해 주세요.',
      );
    }
    try {
      await recordAction(
        'reservation.start',
        metadata: {
          'storeId': _requiredInt(storeId, '점포'),
          if (productId != null) 'productId': _requiredInt(productId, '상품'),
          if (dealId != null) 'dealId': _requiredInt(dealId, '특가'),
          'quantity': quantity,
        },
      );
      final response =
          await _client.post(
                '/reservations',
                body: {
                  'storeId': _requiredInt(storeId, '점포'),
                  if (productId != null)
                    'productId': _requiredInt(productId, '상품'),
                  if (dealId != null) 'dealId': _requiredInt(dealId, '특가'),
                  'quantity': quantity,
                },
              )
              as Map<String, dynamic>;
      final reservationId = response['id']?.toString() ?? '';
      final paidResponse = reservationId.isEmpty
          ? response
          : await _client.post(
                  '/reservations/$reservationId/payments/mock-confirm',
                )
                as Map<String, dynamic>;
      final reservation = _reservationFromJson(paidResponse);
      await loadReservations();
      await _loadFlashDeals();
      return reservation;
    } catch (error) {
      _errorMessage = _friendlyError(error);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> completeReservation(
    String reservationId, {
    required String pickupCode,
  }) async {
    await _client.patch(
      '/reservations/$reservationId/complete',
      body: {'pickupCode': pickupCode},
    );
    await loadReservations();
  }

  Future<void> cancelReservation(String reservationId) async {
    await _client.patch('/reservations/$reservationId/cancel');
    await loadReservations();
    await _loadFlashDeals();
  }

  Future<void> createDeal({
    required int storeId,
    int? productId,
    required String title,
    String? description,
    required int dealPrice,
    int? originalPrice,
    required int availableQuantity,
    required DateTime expiresAt,
  }) async {
    await _client.post(
      '/deals',
      body: {
        'storeId': storeId,
        if (productId != null && productId > 0) 'productId': productId,
        'title': title,
        if (description != null && description.isNotEmpty)
          'description': description,
        'dealPrice': dealPrice,
        if (originalPrice != null && originalPrice > 0)
          'originalPrice': originalPrice,
        'availableQuantity': availableQuantity,
        'expiresAt': expiresAt.toIso8601String(),
      },
    );
    await recordAction(
      'merchant.deal.create',
      metadata: {'storeId': storeId, 'title': title},
    );
    await loadMerchantDeals();
    await _loadFlashDeals();
  }

  Future<void> endDeal(int dealId) async {
    await _client.patch('/deals/$dealId/end');
    await recordAction('merchant.deal.end', metadata: {'dealId': dealId});
    await loadMerchantDeals();
    await _loadFlashDeals();
  }

  Future<void> loadCoupons() async {
    try {
      final response = await _client.get('/coupons') as List<dynamic>;
      _coupons = response.cast<Map<String, dynamic>>();
      notifyListeners();
    } catch (error) {
      _errorMessage = _friendlyError(error);
      notifyListeners();
    }
  }

  Future<void> claimCoupon(int couponId) async {
    try {
      await _client.post('/coupons/$couponId/claim');
      await loadCoupons();
    } catch (error) {
      _errorMessage = _friendlyError(error);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> submitReport({
    required String reportType,
    required String targetType,
    required int targetId,
    required String reason,
    Map<String, dynamic>? metadata,
  }) async {
    if (_isUsingCachedData) {
      throw const ApiException(
        0,
        '오프라인 저장 데이터에서는 신고를 사용할 수 없습니다. 온라인 연결 후 다시 시도해 주세요.',
      );
    }
    await _client.post(
      '/reports',
      body: {
        'reportType': reportType,
        'targetType': targetType,
        'targetId': targetId,
        'reason': reason,
        ...metadata == null ? const {} : {'metadata': metadata},
      },
    );
    await recordAction(
      'report.submit',
      metadata: {
        'reportType': reportType,
        'targetType': targetType,
        'targetId': targetId,
      },
    );
  }

  Future<List<StoreReview>> getReviews(String storeId) async {
    final response =
        await _client.get('/reviews/stores/$storeId') as List<dynamic>;
    return response
        .cast<Map<String, dynamic>>()
        .map(
          (json) => StoreReview(
            id: json['id']?.toString() ?? '',
            storeId: storeId,
            userName:
                (json['user'] as Map<String, dynamic>?)?['name']?.toString() ??
                '사용자',
            userAvatar:
                (json['user'] as Map<String, dynamic>?)?['profileImage']
                    ?.toString() ??
                '',
            content: json['content']?.toString() ?? '',
            rating: double.tryParse(json['rating']?.toString() ?? '') ?? 0,
            images: [
              if (json['imageUrl']?.toString().isNotEmpty == true)
                _client.resolveAssetUrl(json['imageUrl']?.toString()),
            ],
            createdAt:
                DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
                DateTime.now(),
          ),
        )
        .toList();
  }

  Future<void> createReview({
    required String storeId,
    required double rating,
    required String content,
  }) async {
    try {
      await _client.post(
        '/reviews',
        body: {
          'storeId': _requiredInt(storeId, '점포'),
          'rating': rating,
          'content': content,
        },
      );
    } catch (error) {
      _errorMessage = _friendlyError(error);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> createProduct({
    required int storeId,
    required String name,
    required String category,
    required int currentPrice,
    String? unit,
    String? origin,
    String? description,
  }) async {
    await _client.post(
      '/seller/stores/$storeId/products',
      body: {
        'name': name,
        'category': category,
        'currentPrice': currentPrice,
        if (unit != null && unit.isNotEmpty) 'unit': unit,
        if (origin != null && origin.isNotEmpty) 'origin': origin,
        if (description != null && description.isNotEmpty)
          'description': description,
      },
    );
    await recordAction(
      'merchant.product.create',
      metadata: {'storeId': storeId, 'name': name},
    );
    await loadMerchantStores();
    await refresh();
  }

  Future<void> updateProduct({
    required int productId,
    String? name,
    String? category,
    String? unit,
    String? origin,
    String? description,
    String? stockStatus,
  }) async {
    await _client.patch(
      '/seller/products/$productId',
      body: {
        if (name != null && name.isNotEmpty) 'name': name,
        if (category != null && category.isNotEmpty) 'category': category,
        if (unit != null && unit.isNotEmpty) 'unit': unit,
        if (origin != null && origin.isNotEmpty) 'origin': origin,
        if (description != null && description.isNotEmpty)
          'description': description,
        if (stockStatus != null && stockStatus.isNotEmpty)
          'stockStatus': stockStatus,
      },
    );
    await recordAction(
      'merchant.product.update',
      metadata: {'productId': productId},
    );
    await loadMerchantStores();
    await refresh();
  }

  Future<void> createStoreRequest({
    required String name,
    required String category,
    String? description,
  }) async {
    final marketId = _marketIdsByName.values.isEmpty
        ? 1
        : _marketIdsByName.values.first;
    final location =
        _marketLocationsById[marketId] ?? const Offset(37.4836, 126.9294);
    await _client.post(
      '/seller/stores',
      body: {
        'marketId': marketId,
        'name': name,
        'category': category,
        'description': description ?? '$name 점포 등록 요청',
        'latitude': location.dx,
        'longitude': location.dy,
        'openingTime': '09:00',
        'closingTime': '20:00',
        'paymentMethods': ['cash', 'card'],
      },
    );
    await recordAction('merchant.store.request', metadata: {'name': name});
    await loadMerchantStores();
  }

  Future<void> updateMerchantStore(
    int storeId,
    Map<String, dynamic> body,
  ) async {
    await _client.patch('/seller/stores/$storeId', body: body);
    await recordAction('merchant.store.update', metadata: {'storeId': storeId});
    await loadMerchantStores();
    await refresh();
  }

  Future<void> addStorePhoto({
    required int storeId,
    required String imageUrl,
    String? caption,
  }) async {
    await _client.post(
      '/seller/stores/$storeId/photos',
      body: {
        'imageUrl': imageUrl,
        if (caption != null && caption.isNotEmpty) 'caption': caption,
      },
    );
    await recordAction(
      'merchant.store.photo.add',
      metadata: {'storeId': storeId},
    );
    await loadMerchantStores();
    await refresh();
  }

  Future<String> uploadStoreImage(String filePath) {
    return _client.uploadImage(filePath);
  }

  Future<void> updateProductPrice({
    required int productId,
    required int price,
    String? note,
  }) async {
    await _client.patch(
      '/seller/products/$productId/price',
      body: {
        'price': price,
        ...note == null ? const {} : {'note': note},
      },
    );
    await recordAction(
      'merchant.product.price.update',
      metadata: {'productId': productId, 'price': price},
    );
    await loadMerchantStores();
    await refresh();
  }

  Future<void> deleteProduct(int productId) async {
    await _client.delete('/seller/products/$productId');
    await recordAction(
      'merchant.product.delete',
      metadata: {'productId': productId},
    );
    await loadMerchantStores();
    await refresh();
  }

  Future<List<Map<String, dynamic>>> compareProducts({
    required String name,
    String? category,
    int? marketId,
  }) async {
    final response =
        await _client.get(
              '/products/compare',
              query: {'name': name, 'category': category, 'marketId': marketId},
            )
            as List<dynamic>;
    await recordAction(
      'product.compare',
      metadata: {'name': name, 'category': category, 'marketId': marketId},
    );
    return response.cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> getPriceHistory(int productId) async {
    final response =
        await _client.get('/products/$productId/price-history')
            as List<dynamic>;
    await recordAction(
      'product.price_history.view',
      metadata: {'productId': productId},
    );
    return response.cast<Map<String, dynamic>>();
  }

  Future<List<Store>> getViewportStores({
    required String marketName,
    required Rect normalizedBounds,
  }) async {
    final marketId = _marketIdsByName[marketName];
    if (marketId == null) {
      return storesForMarket(marketName).where((store) {
        return normalizedBounds.contains(Offset(store.mapX, store.mapY));
      }).toList();
    }

    final size = _marketMapSizesByName[marketName] ?? const Size(1, 1);
    final response =
        await _client.get(
              '/map/markets/$marketId/viewport',
              query: {
                'minX': normalizedBounds.left * size.width,
                'minY': normalizedBounds.top * size.height,
                'maxX': normalizedBounds.right * size.width,
                'maxY': normalizedBounds.bottom * size.height,
              },
            )
            as Map<String, dynamic>;

    final rows = (response['stores'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();
    return rows
        .map(
          (store) => _storeFromJson(
            store,
            const [],
            marketName,
            size.width,
            size.height,
          ),
        )
        .toList();
  }

  Future<void> recordAction(String action, {Map<String, dynamic>? metadata}) {
    final body = <String, dynamic>{'action': action};
    if (metadata != null) {
      body['metadata'] = metadata;
    }
    return _client.post('/system/logs', body: body).catchError((_) {
      // Action logs should never block the user-facing workflow.
    });
  }

  Future<void> _loadFromServer() async {
    final bundle = await _fetchPublicBundle();
    _applyPublicBundle(bundle);
    await _offlineCache.savePublicBundle(bundle);
    _isUsingCachedData = false;
    _isCacheStale = false;
    _cacheUpdatedAt = null;
    await loadCoupons();
  }

  Future<Map<String, dynamic>> _fetchPublicBundle() async {
    final marketRows = await _client.get('/markets') as List<dynamic>;
    if (marketRows.isEmpty) {
      throw const ApiException(404, '등록된 시장이 없습니다.');
    }

    final markets = <Map<String, dynamic>>[];
    for (final rawMarket in marketRows.cast<Map<String, dynamic>>()) {
      final marketId = int.tryParse(rawMarket['id'].toString()) ?? 0;
      final map =
          await _client.get('/markets/$marketId/map') as Map<String, dynamic>;
      final storeRows =
          await _client.get('/markets/$marketId/stores') as List<dynamic>;
      final stores = <Map<String, dynamic>>[];
      for (final rawStore in storeRows.cast<Map<String, dynamic>>()) {
        final storeId = int.tryParse(rawStore['id'].toString()) ?? 0;
        final productRows = rawStore['products'] is List<dynamic>
            ? rawStore['products'] as List<dynamic>
            : await _client.get('/stores/$storeId/products') as List<dynamic>;
        stores.add({...rawStore, 'products': productRows});
      }
      markets.add({'market': rawMarket, 'map': map, 'stores': stores});
    }

    final deals = await _client.get('/deals/live') as List<dynamic>;
    return {'markets': markets, 'deals': deals};
  }

  bool _applyPublicBundle(Map<String, dynamic> bundle) {
    final marketBundles = (bundle['markets'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();
    if (marketBundles.isEmpty) return false;

    final parsedMarkets = <MarketInfo>[];
    final parsedStores = <Store>[];
    final parsedZones = <Zone>[];
    final parsedPois = <POI>[];
    final marketIds = <String, int>{};
    final marketLocations = <int, Offset>{};
    final marketMapSizes = <String, Size>{};

    for (final marketBundle in marketBundles) {
      final rawMarket =
          (marketBundle['market'] as Map<String, dynamic>?) ??
          const <String, dynamic>{};
      final marketId = int.tryParse(rawMarket['id'].toString()) ?? 0;
      final map =
          (marketBundle['map'] as Map<String, dynamic>?) ??
          const <String, dynamic>{};
      final storeRows = (marketBundle['stores'] as List<dynamic>? ?? [])
          .cast<Map<String, dynamic>>();
      final width = _number(map['mapWidth'], fallback: 1);
      final height = _number(map['mapHeight'], fallback: 1);
      final marketName = rawMarket['name']?.toString() ?? '시장';
      marketIds[marketName] = marketId;
      marketLocations[marketId] = Offset(
        _number(rawMarket['latitude'], fallback: 37.4836),
        _number(rawMarket['longitude'], fallback: 126.9294),
      );
      marketMapSizes[marketName] = Size(width, height);

      final marketZones = (map['zones'] as List<dynamic>? ?? [])
          .cast<Map<String, dynamic>>()
          .map(_zoneFromJson)
          .toList();
      parsedZones.addAll(marketZones);

      parsedPois.addAll(
        (map['pois'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>().map(
          (poi) => _poiFromJson(poi, width, height),
        ),
      );

      for (final rawStore in storeRows) {
        final productRows = rawStore['products'] is List<dynamic>
            ? rawStore['products'] as List<dynamic>
            : const <dynamic>[];
        parsedStores.add(
          _storeFromJson(
            rawStore,
            productRows.cast<Map<String, dynamic>>(),
            marketName,
            width,
            height,
          ),
        );
      }

      parsedMarkets.add(
        MarketInfo(
          name: marketName,
          description: rawMarket['description']?.toString() ?? '',
          address: rawMarket['address']?.toString() ?? '',
          storeCount: storeRows.length,
          highlights: [
            rawMarket['region']?.toString() ?? '전통시장',
            rawMarket['operatingHours']?.toString() ?? '운영정보',
            '${storeRows.length}개 점포',
          ],
          accentColor: _accentColor(parsedMarkets.length),
          isAvailable: true,
        ),
      );
    }

    _markets = parsedMarkets;
    _stores = parsedStores;
    _zones = parsedZones.isEmpty && kDebugMode ? MockData.zones : parsedZones;
    _pois = parsedPois.isEmpty && kDebugMode ? MockData.pois : parsedPois;
    _marketIdsByName = marketIds;
    _marketLocationsById = marketLocations;
    _marketMapSizesByName = marketMapSizes;
    _flashDeals = _flashDealsFromRows(bundle['deals'] as List<dynamic>? ?? []);
    return true;
  }

  Future<bool> _restoreFromCache() async {
    final cached = await _offlineCache.loadPublicBundle();
    if (cached == null) return false;
    final data = cached['data'];
    if (data is! Map<String, dynamic> || !_applyPublicBundle(data)) {
      return false;
    }
    _cacheUpdatedAt = _offlineCache.cachedAt(cached);
    _isCacheStale = _offlineCache.isStale(_cacheUpdatedAt);
    _isUsingCachedData = true;
    await recordAction(
      'market.cache.fallback',
      metadata: {
        'cacheUpdatedAt': _cacheUpdatedAt?.toIso8601String(),
        'isStale': _isCacheStale,
      },
    );
    return true;
  }

  Future<void> _loadFlashDeals() async {
    final response = await _client.get('/deals/live') as List<dynamic>;
    _flashDeals = _flashDealsFromRows(response);
  }

  List<FlashDeal> _flashDealsFromRows(List<dynamic> response) {
    return response
        .cast<Map<String, dynamic>>()
        .map(_flashDealFromJson)
        .where((deal) => !deal.isExpired)
        .toList();
  }

  FlashDeal _flashDealFromJson(Map<String, dynamic> json) {
    return FlashDeal(
      id: json['id']?.toString() ?? '',
      storeId:
          (json['store'] as Map<String, dynamic>?)?['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '오늘 특가',
      discount: '${json['dealPrice'] ?? 0}원',
      dealPrice: int.tryParse(json['dealPrice']?.toString() ?? '') ?? 0,
      originalPrice: int.tryParse(json['originalPrice']?.toString() ?? ''),
      availableQuantity:
          int.tryParse(json['availableQuantity']?.toString() ?? '') ?? 0,
      expiresAt:
          DateTime.tryParse(json['expiresAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  Store _storeFromJson(
    Map<String, dynamic> json,
    List<Map<String, dynamic>> products,
    String marketName,
    double mapWidth,
    double mapHeight,
  ) {
    final photoRows = json['photos'] as List<dynamic>? ?? [];
    final imageUrls = [
      if (json['imageUrl']?.toString().isNotEmpty == true)
        _client.resolveAssetUrl(json['imageUrl']?.toString()),
      ...photoRows.cast<Map<String, dynamic>>().map(
        (photo) => _client.resolveAssetUrl(photo['imageUrl']?.toString()),
      ),
    ].where((url) => url.isNotEmpty).toList();
    final imageUrl = json['imageUrl']?.toString().isNotEmpty == true
        ? _client.resolveAssetUrl(json['imageUrl']?.toString())
        : photoRows.isNotEmpty
        ? _client.resolveAssetUrl(
            (photoRows.first as Map<String, dynamic>)['imageUrl']?.toString(),
          )
        : null;

    return Store(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '점포',
      unitNumber: json['unitNo']?.toString(),
      zoneId:
          (json['zone'] as Map<String, dynamic>?)?['id']?.toString() ??
          json['zoneId']?.toString() ??
          'A',
      category: json['category']?.toString() ?? '기타',
      status: _statusFromJson(json['businessStatus']?.toString()),
      paymentMethods: _paymentMethods(json['paymentMethods']),
      items: products
          .map((product) => _itemFromJson(product, imageUrl))
          .toList(),
      lastUpdated: DateTime.tryParse(json['updatedAt']?.toString() ?? ''),
      infoSource: json['approvalStatus']?.toString() ?? '서버',
      mapX: _normalized(json['mapX'], mapWidth),
      mapY: _normalized(json['mapY'], mapHeight),
      marketName: marketName,
      inventoryStatus: _inventoryFromProducts(products),
      freshness: products.isEmpty ? null : 90,
      description: json['description']?.toString(),
      openingTime: json['openingTime']?.toString(),
      closingTime: json['closingTime']?.toString(),
      regularHolidays: _stringList(json['regularHolidays']),
      temporaryHolidays: _stringList(json['temporaryHolidays']),
      imageUrls: imageUrls,
      addressDetail: json['addressDetail']?.toString(),
    );
  }

  StoreItem _itemFromJson(Map<String, dynamic> json, String? imageUrl) {
    return StoreItem(
      id: json['id']?.toString(),
      name: json['name']?.toString() ?? '상품',
      category: json['category']?.toString(),
      origin: json['origin']?.toString(),
      unitNumber: json['unit']?.toString(),
      price: int.tryParse(json['currentPrice']?.toString() ?? ''),
      imageUrl: imageUrl,
      stockStatus: json['stockStatus']?.toString(),
    );
  }

  Zone _zoneFromJson(Map<String, dynamic> json) {
    return Zone(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '구역',
      description:
          json['description']?.toString() ?? json['category']?.toString() ?? '',
      color: _parseColor(json['color']?.toString()),
    );
  }

  POI _poiFromJson(
    Map<String, dynamic> json,
    double mapWidth,
    double mapHeight,
  ) {
    return POI(
      name: json['name']?.toString() ?? '편의시설',
      type: _poiType(json['type']?.toString()),
      mapX: _normalized(json['mapX'], mapWidth),
      mapY: _normalized(json['mapY'], mapHeight),
    );
  }

  void _useMockFallback() {
    _isUsingCachedData = false;
    _isCacheStale = false;
    _cacheUpdatedAt = null;
    if (!kDebugMode) {
      _markets = const [];
      _stores = const [];
      _zones = const [];
      _pois = const [];
      _reservations = const [];
      _flashDeals = const [];
      _merchantDeals = const [];
      _coupons = const [];
      return;
    }
    _markets = MockData.markets;
    _stores = MockData.stores;
    _zones = MockData.zones;
    _pois = MockData.pois;
    _reservations = MockData.reservations;
    _flashDeals = MockData.flashDeals;
    _merchantDeals = const [];
    _coupons = const [];
  }

  int _requiredInt(String value, String label) {
    final parsed = int.tryParse(value);
    if (parsed == null) {
      throw ApiException(400, '$label 정보가 서버 데이터와 맞지 않습니다. 새로고침 후 다시 시도해 주세요.');
    }
    return parsed;
  }

  Reservation _reservationFromJson(Map<String, dynamic> json) {
    final store = json['store'] as Map<String, dynamic>?;
    final product = json['product'] as Map<String, dynamic>?;
    final deal = json['deal'] as Map<String, dynamic>?;
    final status = json['status']?.toString() ?? 'ACTIVE';
    final payments = json['payments'] as List<dynamic>? ?? [];
    final paid = payments.cast<Map<String, dynamic>>().firstWhere(
      (payment) => payment['status']?.toString() == 'PAID',
      orElse: () => const {},
    );
    return Reservation(
      id: json['id']?.toString() ?? '',
      storeName: store?['name']?.toString() ?? '점포',
      itemName:
          product?['name']?.toString() ?? deal?['title']?.toString() ?? '예약 상품',
      quantity: int.tryParse(json['quantity']?.toString() ?? '') ?? 1,
      totalAmount: int.tryParse(json['totalAmount']?.toString() ?? '') ?? 0,
      reservedAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      expiresAt:
          DateTime.tryParse(json['expiresAt']?.toString() ?? '') ??
          DateTime.now(),
      pickupCode: json['pickupCode']?.toString() ?? '0000',
      status: status,
      paymentStatus:
          paid['status']?.toString() ??
          (status == 'PENDING_PAYMENT' ? 'PENDING' : 'PAID'),
    );
  }

  Color _accentColor(int index) {
    const colors = [
      Color(0xFFF04452),
      Color(0xFF16A34A),
      Color(0xFF2563EB),
      Color(0xFFEA580C),
    ];
    return colors[index % colors.length];
  }

  Color _parseColor(String? value) {
    if (value == null || value.isEmpty) return _accentColor(0);
    final hex = value.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  StoreStatus _statusFromJson(String? status) {
    switch ((status ?? '').toUpperCase()) {
      case 'OPEN':
        return StoreStatus.open;
      case 'CLOSED':
        return StoreStatus.closed;
      default:
        return StoreStatus.unknown;
    }
  }

  List<PaymentMethod> _paymentMethods(dynamic value) {
    final rows = value is List<dynamic> ? value : const [];
    final mapped = rows.map((raw) {
      final text = raw.toString().toLowerCase();
      if (text.contains('card')) return PaymentMethod.card;
      if (text.contains('zero')) return PaymentMethod.zeroPay;
      if (text.contains('kakao')) return PaymentMethod.kakao;
      return PaymentMethod.cash;
    }).toSet();
    return mapped.isEmpty ? const [PaymentMethod.cash] : mapped.toList();
  }

  List<String> _stringList(dynamic value) {
    if (value is! List<dynamic>) return const [];
    return value.map((item) => item.toString()).toList();
  }

  POIType _poiType(String? type) {
    switch ((type ?? '').toUpperCase()) {
      case 'PARKING':
        return POIType.parking;
      case 'ATM':
        return POIType.atm;
      case 'ENTRANCE':
        return POIType.entrance;
      case 'TOILET':
      default:
        return POIType.toilet;
    }
  }

  String? _inventoryFromProducts(List<Map<String, dynamic>> products) {
    if (products.isEmpty) return null;
    final soldOut = products.every(
      (product) => product['stockStatus']?.toString() == 'SOLD_OUT',
    );
    return soldOut ? '품절' : '판매중';
  }

  double _normalized(dynamic value, double max) {
    final number = _number(value, fallback: 0);
    if (number <= 1) return number.clamp(0, 1);
    if (max <= 1) return 0;
    return (number / max).clamp(0, 1);
  }

  double _number(dynamic value, {required double fallback}) {
    return double.tryParse(value?.toString() ?? '') ?? fallback;
  }

  String _friendlyError(Object error) {
    if (error is ApiException) {
      if (error.statusCode == 0) return error.message;
      return error.message;
    }
    return '서버 데이터를 불러오지 못했습니다. 네트워크 연결을 확인해 주세요.';
  }
}
