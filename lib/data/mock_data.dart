import '../models/models.dart';
import '../theme/app_colors.dart';

class MockData {
  static final DateTime _now = DateTime.now();

  static final List<Deal> deals = [
    Deal(
      id: 'd1',
      storeId: 's3',
      title: '빈대떡 마감특가',
      description: '할머니 손맛 그대로! 녹두빈대떡 마감 할인. 바삭한 겉면과 촉촉한 속이 일품입니다. 1인 2개까지 구매 가능.',
      originalPrice: 8000,
      dealPrice: 5000,
      totalQty: 20,
      remainingQty: 8,
      expiresAt: _now.add(const Duration(minutes: 45)),
      status: DealStatus.live,
    ),
    Deal(
      id: 'd2',
      storeId: 's7',
      title: '광어회 반값 떨이',
      description: '오늘 새벽 직접 공수한 신선한 광어를 마감가에 드립니다. 회 뜨는 즉시 포장 가능. 초장, 깻잎, 마늘 기본 제공.',
      originalPrice: 25000,
      dealPrice: 12000,
      totalQty: 5,
      remainingQty: 3,
      expiresAt: _now.add(const Duration(minutes: 80)),
      status: DealStatus.live,
    ),
    Deal(
      id: 'd3',
      storeId: 's9',
      title: '제주 한라봉 박스특가',
      description: '제주도 직송 당도 보장 한라봉 5kg 한 박스. 달콤한 향과 풍부한 과즙이 특징. 선물용 포장 가능.',
      originalPrice: 18000,
      dealPrice: 9000,
      totalQty: 15,
      remainingQty: 11,
      expiresAt: _now.add(const Duration(minutes: 120)),
      status: DealStatus.live,
    ),
  ];

  static final List<Store> stores = [
    // A구역 - 포목
    Store(
      id: 's1',
      name: '삼성직물',
      zoneId: 'A',
      category: '포목/직물',
      status: StoreStatus.open,
      paymentMethods: [PaymentMethod.cash, PaymentMethod.card],
      items: const [
        StoreItem(name: '명주 한복감', price: 35000),
        StoreItem(name: '광목천 (1m)', price: 3500),
        StoreItem(name: '실크 원단', price: 45000),
      ],
      lastUpdated: DateTime(2026, 3, 14),
      infoSource: '상인 직접 등록',
      mapX: 0.2,
      mapY: 0.18,
    ),
    Store(
      id: 's2',
      name: '오리엔탈직물',
      zoneId: 'A',
      category: '포목/직물',
      status: StoreStatus.open,
      paymentMethods: [PaymentMethod.cash],
      items: const [
        StoreItem(name: '오방색 한복감 세트', price: 120000),
        StoreItem(name: '자수 원단 (50cm)', price: 15000),
      ],
      lastUpdated: DateTime(2026, 3, 10),
      infoSource: '방문자 제보',
      mapX: 0.62,
      mapY: 0.18,
    ),
    // B구역 - 먹거리
    Store(
      id: 's3',
      name: '할머니빈대떡',
      zoneId: 'B',
      category: '먹거리',
      status: StoreStatus.open,
      paymentMethods: [PaymentMethod.cash, PaymentMethod.zeroPay],
      items: const [
        StoreItem(name: '녹두빈대떡 (1개)', price: 4000),
        StoreItem(name: '막걸리 (1병)', price: 3000),
        StoreItem(name: '김치전 (1개)', price: 3500),
      ],
      lastUpdated: DateTime(2026, 3, 15),
      infoSource: '상인 직접 등록',
      mapX: 0.2,
      mapY: 0.42,
      activeDealId: 'd1',
    ),
    Store(
      id: 's4',
      name: '광장마포집육회',
      zoneId: 'B',
      category: '먹거리',
      status: StoreStatus.open,
      paymentMethods: [PaymentMethod.cash, PaymentMethod.card, PaymentMethod.kakao],
      items: const [
        StoreItem(name: '육회 (소)', price: 15000),
        StoreItem(name: '육회 (대)', price: 25000),
        StoreItem(name: '육사시미', price: 18000),
      ],
      lastUpdated: DateTime(2026, 3, 16),
      infoSource: '상인 직접 등록',
      mapX: 0.4,
      mapY: 0.42,
    ),
    Store(
      id: 's5',
      name: '황금손만두',
      zoneId: 'B',
      category: '먹거리',
      status: StoreStatus.open,
      paymentMethods: [PaymentMethod.cash, PaymentMethod.card, PaymentMethod.zeroPay, PaymentMethod.kakao],
      items: const [
        StoreItem(name: '고기만두 (10개)', price: 5000),
        StoreItem(name: '김치만두 (10개)', price: 5000),
        StoreItem(name: '왕만두 (5개)', price: 6000),
      ],
      lastUpdated: DateTime(2026, 3, 15),
      infoSource: '방문자 제보',
      mapX: 0.6,
      mapY: 0.42,
    ),
    Store(
      id: 's6',
      name: '전주비빔밥',
      zoneId: 'B',
      category: '먹거리',
      status: StoreStatus.closed,
      paymentMethods: [PaymentMethod.cash],
      items: const [
        StoreItem(name: '전주비빔밥', price: 9000),
        StoreItem(name: '돌솥비빔밥', price: 11000),
      ],
      lastUpdated: DateTime(2026, 3, 12),
      infoSource: '방문자 제보',
      mapX: 0.75,
      mapY: 0.42,
    ),
    // C구역 - 생선
    Store(
      id: 's7',
      name: '신선수산',
      zoneId: 'C',
      category: '생선/해산물',
      status: StoreStatus.open,
      paymentMethods: [PaymentMethod.cash, PaymentMethod.card],
      items: const [
        StoreItem(name: '광어회 (소)', price: 25000),
        StoreItem(name: '연어회 세트', price: 30000),
        StoreItem(name: '꽃게 (1kg)', price: 20000),
      ],
      lastUpdated: DateTime(2026, 3, 16),
      infoSource: '상인 직접 등록',
      mapX: 0.18,
      mapY: 0.68,
      activeDealId: 'd2',
    ),
    Store(
      id: 's8',
      name: '통영해물',
      zoneId: 'C',
      category: '생선/해산물',
      status: StoreStatus.open,
      paymentMethods: [PaymentMethod.cash, PaymentMethod.zeroPay],
      items: const [
        StoreItem(name: '굴 (500g)', price: 8000),
        StoreItem(name: '홍합 (1kg)', price: 5000),
        StoreItem(name: '바지락 (500g)', price: 6000),
      ],
      lastUpdated: DateTime(2026, 3, 15),
      infoSource: '방문자 제보',
      mapX: 0.38,
      mapY: 0.68,
    ),
    // D구역 - 청과
    Store(
      id: 's9',
      name: '제주청과',
      zoneId: 'D',
      category: '청과/야채',
      status: StoreStatus.open,
      paymentMethods: [PaymentMethod.cash, PaymentMethod.card, PaymentMethod.kakao],
      items: const [
        StoreItem(name: '제주 한라봉 (5kg)', price: 18000),
        StoreItem(name: '제주 감귤 (3kg)', price: 12000),
        StoreItem(name: '제주 천혜향', price: 25000),
      ],
      lastUpdated: DateTime(2026, 3, 16),
      infoSource: '상인 직접 등록',
      mapX: 0.62,
      mapY: 0.68,
      activeDealId: 'd3',
    ),
    Store(
      id: 's10',
      name: '한우한돈',
      zoneId: 'D',
      category: '청과/야채',
      status: StoreStatus.open,
      paymentMethods: [PaymentMethod.cash, PaymentMethod.card],
      items: const [
        StoreItem(name: '한우 등심 (200g)', price: 35000),
        StoreItem(name: '삼겹살 (500g)', price: 15000),
        StoreItem(name: '목살 (500g)', price: 12000),
      ],
      lastUpdated: DateTime(2026, 3, 14),
      infoSource: '방문자 제보',
      mapX: 0.8,
      mapY: 0.68,
    ),
  ];

  static final List<POI> pois = [
    const POI(name: '화장실', type: POIType.toilet, mapX: 0.05, mapY: 0.88),
    const POI(name: 'ATM', type: POIType.atm, mapX: 0.5, mapY: 0.92),
    const POI(name: '주차장', type: POIType.parking, mapX: 0.9, mapY: 0.88),
    const POI(name: '정문 입구', type: POIType.entrance, mapX: 0.5, mapY: 0.05),
  ];

  static final List<Zone> zones = [
    Zone(
      id: 'A',
      name: 'A구역',
      description: '포목/직물',
      color: AppColors.zoneA,
    ),
    Zone(
      id: 'B',
      name: 'B구역',
      description: '먹거리',
      color: AppColors.zoneB,
    ),
    Zone(
      id: 'C',
      name: 'C구역',
      description: '생선/해산물',
      color: AppColors.zoneC,
    ),
    Zone(
      id: 'D',
      name: 'D구역',
      description: '청과/야채',
      color: AppColors.zoneD,
    ),
  ];

  static final List<Reservation> reservations = [
    Reservation(
      id: 'r1',
      dealId: 'd1',
      dealTitle: '빈대떡 마감특가',
      storeName: '할머니빈대떡',
      quantity: 2,
      totalAmount: 10000,
      reservedAt: _now.subtract(const Duration(minutes: 5)),
      expiresAt: _now.add(const Duration(minutes: 10)),
      pickupCode: '3847',
      isCompleted: false,
    ),
    Reservation(
      id: 'r2',
      dealId: 'd2',
      dealTitle: '광어회 반값 떨이',
      storeName: '신선수산',
      quantity: 1,
      totalAmount: 12000,
      reservedAt: _now.subtract(const Duration(hours: 2)),
      expiresAt: _now.subtract(const Duration(hours: 1, minutes: 45)),
      pickupCode: '5291',
      isCompleted: true,
    ),
  ];

  static Deal? getDealById(String id) {
    try {
      return deals.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }

  static Store? getStoreById(String id) {
    try {
      return stores.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  static List<Deal> getDealsForStore(String storeId) {
    return deals.where((d) => d.storeId == storeId).toList();
  }

  static Zone? getZoneById(String id) {
    try {
      return zones.firstWhere((z) => z.id == id);
    } catch (_) {
      return null;
    }
  }
}
