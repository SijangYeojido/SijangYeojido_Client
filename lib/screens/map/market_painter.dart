import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../theme/app_colors.dart';

class MarketPainter extends CustomPainter {
  final List<Store> stores;
  final List<POI> pois;
  final String? selectedStoreId;
  final List<Deal> activeDeals;

  MarketPainter({
    required this.stores,
    required this.pois,
    this.selectedStoreId,
    required this.activeDeals,
  });

  static const _zones = [
    _ZoneDef('A', 'A구역\n포목/직물', Rect.fromLTRB(0.05, 0.08, 0.9, 0.28), AppColors.zoneA),
    _ZoneDef('B', 'B구역\n먹거리', Rect.fromLTRB(0.05, 0.32, 0.9, 0.55), AppColors.zoneB),
    _ZoneDef('C', 'C구역\n생선/해산물', Rect.fromLTRB(0.05, 0.59, 0.48, 0.82), AppColors.zoneC),
    _ZoneDef('D', 'D구역\n청과/야채', Rect.fromLTRB(0.52, 0.59, 0.9, 0.82), AppColors.zoneD),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    _drawBackground(canvas, size);
    _drawZones(canvas, size);
    _drawAisles(canvas, size);
    _drawPOIs(canvas, size);
    _drawStores(canvas, size);
  }

  void _drawBackground(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.mapBackground;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  void _drawZones(Canvas canvas, Size size) {
    for (final zone in _zones) {
      final rect = _scaleRect(zone.rect, size);
      final rRect = RRect.fromRectAndRadius(rect, const Radius.circular(12));

      // Fill
      final fillPaint = Paint()..color = zone.color;
      canvas.drawRRect(rRect, fillPaint);

      // Border
      final borderPaint = Paint()
        ..color = zone.color.withValues(alpha:0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawRRect(rRect, borderPaint);

      // Zone label
      final labelPainter = TextPainter(
        text: TextSpan(
          text: zone.label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFF6B6560),
            height: 1.4,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      labelPainter.layout(maxWidth: rect.width - 16);
      labelPainter.paint(
        canvas,
        Offset(rect.left + 10, rect.top + 8),
      );
    }
  }

  void _drawAisles(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.aisle;

    // Horizontal aisle between A and B
    final aisleH1 = _scaleRect(const Rect.fromLTRB(0.0, 0.28, 1.0, 0.32), size);
    canvas.drawRect(aisleH1, paint);

    // Horizontal aisle between B and C/D
    final aisleH2 = _scaleRect(const Rect.fromLTRB(0.0, 0.55, 1.0, 0.59), size);
    canvas.drawRect(aisleH2, paint);

    // Vertical aisle between C and D
    final aisleV = _scaleRect(const Rect.fromLTRB(0.48, 0.59, 0.52, 0.82), size);
    canvas.drawRect(aisleV, paint);

    // Outer margins (also aisle color)
    final topAisle = _scaleRect(const Rect.fromLTRB(0.0, 0.0, 1.0, 0.08), size);
    canvas.drawRect(topAisle, paint);

    final bottomAisle = _scaleRect(const Rect.fromLTRB(0.0, 0.82, 1.0, 1.0), size);
    canvas.drawRect(bottomAisle, paint);

    final leftAisle = _scaleRect(const Rect.fromLTRB(0.0, 0.0, 0.05, 1.0), size);
    canvas.drawRect(leftAisle, paint);

    final rightAisle = _scaleRect(const Rect.fromLTRB(0.9, 0.0, 1.0, 1.0), size);
    canvas.drawRect(rightAisle, paint);
  }

  void _drawPOIs(Canvas canvas, Size size) {
    for (final poi in pois) {
      final pos = Offset(poi.mapX * size.width, poi.mapY * size.height);
      final color = poi.type.color;

      // Background circle
      final bgPaint = Paint()..color = color.withValues(alpha:0.15);
      canvas.drawCircle(pos, 14, bgPaint);

      // Border circle
      final borderPaint = Paint()
        ..color = color.withValues(alpha:0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawCircle(pos, 14, borderPaint);

      // POI label
      final labelPainter = TextPainter(
        text: TextSpan(
          text: _poiEmoji(poi.type),
          style: const TextStyle(fontSize: 12),
        ),
        textDirection: TextDirection.ltr,
      );
      labelPainter.layout();
      labelPainter.paint(
        canvas,
        Offset(pos.dx - labelPainter.width / 2, pos.dy - labelPainter.height / 2),
      );
    }
  }

  String _poiEmoji(POIType type) {
    switch (type) {
      case POIType.toilet:
        return '🚻';
      case POIType.parking:
        return '🅿';
      case POIType.atm:
        return '💳';
      case POIType.entrance:
        return '🚪';
    }
  }

  void _drawStores(Canvas canvas, Size size) {
    final activeDealIds = activeDeals.map((d) => d.storeId).toSet();

    for (final store in stores) {
      final pos = Offset(store.mapX * size.width, store.mapY * size.height);
      final isSelected = store.id == selectedStoreId;
      final hasDeal = activeDealIds.contains(store.id);

      if (isSelected) {
        // Selection ring
        final selectionPaint = Paint()
          ..color = AppColors.primaryRed.withValues(alpha:0.25)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(pos, 18, selectionPaint);
      }

      if (hasDeal) {
        _drawDealPin(canvas, pos, isSelected);
      } else if (store.status == StoreStatus.open) {
        _drawOpenPin(canvas, pos, isSelected);
      } else {
        _drawClosedPin(canvas, pos, isSelected);
      }

      // Store name label
      final namePainter = TextPainter(
        text: TextSpan(
          text: store.name,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: hasDeal ? AppColors.primaryRed : AppColors.textPrimary,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      namePainter.layout(maxWidth: 60);
      namePainter.paint(
        canvas,
        Offset(pos.dx - namePainter.width / 2, pos.dy + 13),
      );
    }
  }

  void _drawDealPin(Canvas canvas, Offset pos, bool isSelected) {
    // Outer red circle
    final outerPaint = Paint()..color = AppColors.primaryRed;
    canvas.drawCircle(pos, isSelected ? 13 : 11, outerPaint);

    // White ring
    final ringPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(pos, isSelected ? 13 : 11, ringPaint);

    // Inner white dot
    final innerPaint = Paint()..color = Colors.white;
    canvas.drawCircle(pos, 4, innerPaint);

    // Percent sign or deal indicator
    final textPainter = TextPainter(
      text: const TextSpan(
        text: '%',
        style: TextStyle(
          fontSize: 7,
          fontWeight: FontWeight.w900,
          color: AppColors.primaryRed,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(pos.dx - textPainter.width / 2, pos.dy - textPainter.height / 2),
    );
  }

  void _drawOpenPin(Canvas canvas, Offset pos, bool isSelected) {
    final outerPaint = Paint()..color = AppColors.textPrimary;
    canvas.drawCircle(pos, isSelected ? 11 : 9, outerPaint);

    final innerPaint = Paint()..color = Colors.white;
    canvas.drawCircle(pos, 4, innerPaint);
  }

  void _drawClosedPin(Canvas canvas, Offset pos, bool isSelected) {
    final outerPaint = Paint()..color = AppColors.textTertiary;
    canvas.drawCircle(pos, isSelected ? 11 : 9, outerPaint);

    final innerPaint = Paint()..color = Colors.white;
    canvas.drawCircle(pos, 4, innerPaint);
  }

  Rect _scaleRect(Rect normalized, Size size) {
    return Rect.fromLTRB(
      normalized.left * size.width,
      normalized.top * size.height,
      normalized.right * size.width,
      normalized.bottom * size.height,
    );
  }

  Store? storeAtPosition(Offset pos, Size size) {
    const hitRadius = 20.0;
    for (final store in stores) {
      final storePos = Offset(store.mapX * size.width, store.mapY * size.height);
      if ((pos - storePos).distance <= hitRadius) {
        return store;
      }
    }
    return null;
  }

  @override
  bool shouldRepaint(MarketPainter oldDelegate) {
    return oldDelegate.selectedStoreId != selectedStoreId ||
        oldDelegate.stores.length != stores.length ||
        oldDelegate.activeDeals.length != activeDeals.length;
  }
}

class _ZoneDef {
  final String id;
  final String label;
  final Rect rect;
  final Color color;

  const _ZoneDef(this.id, this.label, this.rect, this.color);
}
