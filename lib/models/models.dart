import 'package:flutter/material.dart';

enum StoreStatus { open, closed, unknown }

enum PaymentMethod { cash, card, zeroPay, kakao }

enum DealStatus { live, expired, soldOut }

enum POIType { toilet, parking, atm, entrance }

class Zone {
  final String id;
  final String name;
  final String description;
  final Color color;

  const Zone({
    required this.id,
    required this.name,
    required this.description,
    required this.color,
  });
}

class StoreItem {
  final String name;
  final int? price;

  const StoreItem({required this.name, this.price});
}

class Store {
  final String id;
  final String name;
  final String zoneId;
  final String category;
  final StoreStatus status;
  final List<PaymentMethod> paymentMethods;
  final List<StoreItem> items;
  final DateTime? lastUpdated;
  final String? infoSource;
  final double mapX;
  final double mapY;
  final String? activeDealId;

  const Store({
    required this.id,
    required this.name,
    required this.zoneId,
    required this.category,
    required this.status,
    required this.paymentMethods,
    required this.items,
    this.lastUpdated,
    this.infoSource,
    required this.mapX,
    required this.mapY,
    this.activeDealId,
  });

  bool get hasDeal => activeDealId != null;
}

class Deal {
  final String id;
  final String storeId;
  final String title;
  final String description;
  final int originalPrice;
  final int dealPrice;
  final int totalQty;
  final int remainingQty;
  final DateTime expiresAt;
  final DealStatus status;

  const Deal({
    required this.id,
    required this.storeId,
    required this.title,
    required this.description,
    required this.originalPrice,
    required this.dealPrice,
    required this.totalQty,
    required this.remainingQty,
    required this.expiresAt,
    required this.status,
  });

  double get discountRate => (originalPrice - dealPrice) / originalPrice;

  int get discountPercent => (discountRate * 100).round();
}

class POI {
  final String name;
  final POIType type;
  final double mapX;
  final double mapY;

  const POI({
    required this.name,
    required this.type,
    required this.mapX,
    required this.mapY,
  });
}

class Market {
  final String id;
  final String name;
  final String address;
  final List<Zone> zones;
  final List<Store> stores;
  final List<POI> pois;

  const Market({
    required this.id,
    required this.name,
    required this.address,
    required this.zones,
    required this.stores,
    required this.pois,
  });
}

class Reservation {
  final String id;
  final String dealId;
  final String dealTitle;
  final String storeName;
  final int quantity;
  final int totalAmount;
  final DateTime reservedAt;
  final DateTime expiresAt;
  final String pickupCode;
  final bool isCompleted;

  const Reservation({
    required this.id,
    required this.dealId,
    required this.dealTitle,
    required this.storeName,
    required this.quantity,
    required this.totalAmount,
    required this.reservedAt,
    required this.expiresAt,
    required this.pickupCode,
    this.isCompleted = false,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isActive => !isCompleted && !isExpired;

  Duration get remainingTime {
    final diff = expiresAt.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }
}

extension StoreStatusLabel on StoreStatus {
  String get label {
    switch (this) {
      case StoreStatus.open:
        return '영업중';
      case StoreStatus.closed:
        return '휴무';
      case StoreStatus.unknown:
        return '확인필요';
    }
  }

  Color get color {
    switch (this) {
      case StoreStatus.open:
        return const Color(0xFF16A34A);
      case StoreStatus.closed:
        return const Color(0xFF78716C);
      case StoreStatus.unknown:
        return const Color(0xFFEA580C);
    }
  }

  Color get bgColor {
    switch (this) {
      case StoreStatus.open:
        return const Color(0xFFDCFCE7);
      case StoreStatus.closed:
        return const Color(0xFFF5F4F0);
      case StoreStatus.unknown:
        return const Color(0xFFFFF7ED);
    }
  }
}

extension PaymentMethodLabel on PaymentMethod {
  String get label {
    switch (this) {
      case PaymentMethod.cash:
        return '현금';
      case PaymentMethod.card:
        return '카드';
      case PaymentMethod.zeroPay:
        return '제로페이';
      case PaymentMethod.kakao:
        return '카카오페이';
    }
  }
}

extension POITypeInfo on POIType {
  String get label {
    switch (this) {
      case POIType.toilet:
        return '화장실';
      case POIType.parking:
        return '주차장';
      case POIType.atm:
        return 'ATM';
      case POIType.entrance:
        return '입구';
    }
  }

  Color get color {
    switch (this) {
      case POIType.toilet:
        return const Color(0xFF2563EB);
      case POIType.parking:
        return const Color(0xFF16A34A);
      case POIType.atm:
        return const Color(0xFFEA580C);
      case POIType.entrance:
        return const Color(0xFF7C3AED);
    }
  }
}
