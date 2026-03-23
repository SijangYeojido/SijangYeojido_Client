import 'dart:math' show sqrt;
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/sijang_design_system.dart';
import '../../widgets/shrinkable_button.dart';
import '../../widgets/sds_widgets.dart';
import '../../data/mock_data.dart';
import '../../models/models.dart';
import '../map/store_detail_screen.dart';

class MarketMapSimpleScreen extends StatefulWidget {
  final String marketName;
  const MarketMapSimpleScreen({super.key, required this.marketName});

  @override
  State<MarketMapSimpleScreen> createState() => _MarketMapSimpleScreenState();
}

class _MarketMapSimpleScreenState extends State<MarketMapSimpleScreen> {
  String? _selectedZone;
  Store? _selectedStore;
  final TransformationController _transformController = TransformationController();

  static const _zones = [
    _ZoneInfo('A', '건어물·먹거리', Color(0xFFE8F5E9), Color(0xFF4CAF50)),
    _ZoneInfo('B', '정육·수산물', Color(0xFFE3F2FD), Color(0xFF2196F3)),
    _ZoneInfo('C', '과일·야채', Color(0xFFFFF8E1), Color(0xFFFFC107)),
    _ZoneInfo('D', '잡화·기타', Color(0xFFFCE4EC), Color(0xFFE91E63)),
  ];

  List<Store> get _zoneStores => _selectedZone == null
      ? []
      : MockData.stores.where((s) => s.zoneId == _selectedZone).toList();

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final safeTop = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      body: Stack(
        children: [
          // ── Interactive Map Canvas ───────────────────────────────
          Positioned.fill(
            child: InteractiveViewer(
              transformationController: _transformController,
              minScale: 0.7,
              maxScale: 3.5,
              boundaryMargin: const EdgeInsets.all(100),
              child: GestureDetector(
                onTapUp: (details) => _handleTap(details.localPosition),
                child: CustomPaint(
                  painter: _MarketFloorplanPainter(
                    selectedZone: _selectedZone,
                    selectedStore: _selectedStore,
                    stores: MockData.stores,
                  ),
                  child: const SizedBox(
                    width: 800,
                    height: 700,
                  ),
                ),
              ),
            ),
          ),

          // ── Glassmorphic Top Bar ──────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(
                  padding: EdgeInsets.fromLTRB(16, safeTop + 8, 16, 14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.88),
                    border: const Border(
                      bottom: BorderSide(color: Colors.black12, width: 0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      ShrinkableButton(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2F4F6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.arrow_back_ios_new_rounded,
                              size: 16, color: AppColors.textPrimary),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${widget.marketName} 지도',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: SDS.fwBlack,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.4,
                              ),
                            ),
                            const Text(
                              '구역을 탭해서 점포를 확인하세요',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: SDS.fwBold,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Reset button
                      ShrinkableButton(
                        onTap: () {
                          setState(() {
                            _selectedZone = null;
                            _selectedStore = null;
                          });
                          _transformController.value = Matrix4.identity();
                        },
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2F4F6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.center_focus_strong_rounded,
                              size: 18, color: AppColors.textPrimary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Zone Legend ───────────────────────────────────────────
          Positioned(
            top: safeTop + 72,
            right: 16,
            child: Column(
              children: _zones.map((z) {
                final isSelected = _selectedZone == z.id;
                return GestureDetector(
                  onTap: () => setState(() {
                    _selectedZone = isSelected ? null : z.id;
                    _selectedStore = null;
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? z.color : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? z.color : Colors.black12,
                        width: isSelected ? 1.5 : 0.8,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: z.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${z.id}구역',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: SDS.fwBold,
                            color: isSelected ? Colors.white : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // ── Bottom Panel: Zone stores or store detail ──────────────
          AnimatedPositioned(
            duration: const Duration(milliseconds: 380),
            curve: Curves.easeOutCubic,
            left: 0,
            right: 0,
            bottom: _selectedZone != null ? 0 : -400,
            child: _selectedStore != null
                ? _StoreQuickCard(
                    store: _selectedStore!,
                    onClose: () => setState(() => _selectedStore = null),
                    onDetail: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => StoreDetailScreen(store: _selectedStore!),
                        ),
                      );
                    },
                  )
                : _ZoneStorePanel(
                    zoneInfo: _zones.firstWhere(
                      (z) => z.id == _selectedZone,
                      orElse: () => _zones.first,
                    ),
                    stores: _zoneStores,
                    onStoreTap: (s) => setState(() => _selectedStore = s),
                    onClose: () => setState(() {
                      _selectedZone = null;
                      _selectedStore = null;
                    }),
                  ),
          ),
        ],
      ),
    );
  }

  void _handleTap(Offset localPosition) {
    // Transform tap position accounting for InteractiveViewer
    final matrix = _transformController.value.clone()..invert();
    final transformed = MatrixUtils.transformPoint(matrix, localPosition);
    final tx = transformed.dx;
    final ty = transformed.dy;

    // Check store taps first (20px radius)
    for (final store in MockData.stores) {
      final sx = store.mapX * 800;
      final sy = store.mapY * 700;
      final dist = (tx - sx) * (tx - sx) + (ty - sy) * (ty - sy);
      if (dist < 400) {
        setState(() {
          _selectedStore = store;
          _selectedZone = store.zoneId;
        });
        return;
      }
    }

    // Check zone area taps
    const zoneRects = {
      'A': Rect.fromLTWH(60, 40, 300, 280),
      'B': Rect.fromLTWH(420, 40, 300, 280),
      'C': Rect.fromLTWH(60, 370, 300, 280),
      'D': Rect.fromLTWH(420, 370, 300, 280),
    };

    for (final entry in zoneRects.entries) {
      if (entry.value.contains(Offset(tx, ty))) {
        setState(() {
          _selectedZone = _selectedZone == entry.key ? null : entry.key;
          _selectedStore = null;
        });
        return;
      }
    }

    // Tap on empty area - deselect
    setState(() {
      _selectedZone = null;
      _selectedStore = null;
    });
  }
}

// ── CustomPainter: Market Floorplan ──────────────────────────────────────────

class _MarketFloorplanPainter extends CustomPainter {
  final String? selectedZone;
  final Store? selectedStore;
  final List<Store> stores;

  const _MarketFloorplanPainter({
    required this.selectedZone,
    required this.selectedStore,
    required this.stores,
  });

  static const _zoneDefs = [
    _ZoneInfo('A', '건어물·먹거리', Color(0xFFE8F5E9), Color(0xFF4CAF50)),
    _ZoneInfo('B', '정육·수산물', Color(0xFFE3F2FD), Color(0xFF2196F3)),
    _ZoneInfo('C', '과일·야채', Color(0xFFFFF8E1), Color(0xFFFFC107)),
    _ZoneInfo('D', '잡화·기타', Color(0xFFFCE4EC), Color(0xFFE91E63)),
  ];

  static const _zoneRects = {
    'A': Rect.fromLTWH(60, 40, 300, 280),
    'B': Rect.fromLTWH(420, 40, 300, 280),
    'C': Rect.fromLTWH(60, 370, 300, 280),
    'D': Rect.fromLTWH(420, 370, 300, 280),
  };

  @override
  void paint(Canvas canvas, Size size) {
    _drawBackground(canvas);
    _drawMainPaths(canvas);
    _drawZones(canvas);
    _drawStalls(canvas);
    _drawStores(canvas);
    _drawEntrances(canvas);
    _drawLabels(canvas);
  }

  void _drawBackground(Canvas canvas) {
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, 800, 700),
      Paint()..color = const Color(0xFFF0F2F5),
    );
    // Outer wall
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(30, 20, 740, 660),
        const Radius.circular(20),
      ),
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(30, 20, 740, 660),
        const Radius.circular(20),
      ),
      Paint()
        ..color = const Color(0xFFCFD8DC)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
  }

  void _drawMainPaths(Canvas canvas) {
    final pathPaint = Paint()
      ..color = const Color(0xFFECEFF1)
      ..style = PaintingStyle.fill;

    // Main horizontal corridor
    canvas.drawRect(const Rect.fromLTWH(30, 320, 740, 40), pathPaint);
    // Main vertical corridor
    canvas.drawRect(const Rect.fromLTWH(370, 20, 60, 660), pathPaint);

    // Path lines
    final linePaint = Paint()
      ..color = const Color(0xFFB0BEC5)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Dashed center lines
    _drawDashedLine(canvas, const Offset(30, 340), const Offset(770, 340), linePaint);
    _drawDashedLine(canvas, const Offset(400, 20), const Offset(400, 680), linePaint);
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const dashLength = 8.0;
    const gapLength = 6.0;
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final len = sqrt(dx * dx + dy * dy);
    final unitX = dx / len;
    final unitY = dy / len;
    double dist = 0;
    while (dist < len) {
      final p1 = Offset(start.dx + unitX * dist, start.dy + unitY * dist);
      final end1 = dist + dashLength;
      final p2 = Offset(
        start.dx + unitX * end1.clamp(0, len),
        start.dy + unitY * end1.clamp(0, len),
      );
      canvas.drawLine(p1, p2, paint);
      dist += dashLength + gapLength;
    }
  }

  void _drawZones(Canvas canvas) {
    for (final zone in _zoneDefs) {
      final rect = _zoneRects[zone.id]!;
      final isSelected = selectedZone == zone.id;
      final alpha = isSelected ? 0.25 : 0.12;

      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(12)),
        Paint()..color = zone.bgColor.withValues(alpha: alpha * 4),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(12)),
        Paint()
          ..color = zone.color.withValues(alpha: isSelected ? 0.6 : 0.2)
          ..style = PaintingStyle.stroke
          ..strokeWidth = isSelected ? 2.5 : 1.5,
      );
    }
  }

  void _drawStalls(Canvas canvas) {
    // Draw small stall rectangles within each zone
    final stallPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final stallBorderPaint = Paint()
      ..color = const Color(0xFFCFD8DC)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    // Zone A stalls grid (4 rows x 3 cols)
    _drawStallGrid(canvas, const Offset(75, 55), 4, 3, 60, 40, stallPaint, stallBorderPaint);
    // Zone B stalls
    _drawStallGrid(canvas, const Offset(435, 55), 4, 3, 60, 40, stallPaint, stallBorderPaint);
    // Zone C stalls
    _drawStallGrid(canvas, const Offset(75, 385), 4, 3, 60, 40, stallPaint, stallBorderPaint);
    // Zone D stalls
    _drawStallGrid(canvas, const Offset(435, 385), 4, 3, 60, 40, stallPaint, stallBorderPaint);
  }

  void _drawStallGrid(Canvas canvas, Offset origin, int rows, int cols,
      double cellW, double cellH, Paint fill, Paint stroke) {
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final rect = Rect.fromLTWH(
          origin.dx + c * (cellW + 6),
          origin.dy + r * (cellH + 6),
          cellW,
          cellH,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(6)),
          fill,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(6)),
          stroke,
        );
      }
    }
  }

  void _drawStores(Canvas canvas) {
    for (final store in stores) {
      final x = store.mapX * 800;
      final y = store.mapY * 700;
      final isSelected = selectedStore?.id == store.id;
      final isOpen = store.status == StoreStatus.open;

      final pinColor = isSelected
          ? AppColors.primary
          : (isOpen ? const Color(0xFF4CAF50) : const Color(0xFF9E9E9E));

      // Glow for selected
      if (isSelected) {
        canvas.drawCircle(
          Offset(x, y),
          16,
          Paint()
            ..color = AppColors.primary.withValues(alpha: 0.25)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
        );
      }

      // Pin body
      canvas.drawCircle(
        Offset(x, y),
        isSelected ? 11 : 8,
        Paint()..color = pinColor,
      );
      canvas.drawCircle(
        Offset(x, y),
        isSelected ? 11 : 8,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      // Inner dot
      canvas.drawCircle(
        Offset(x, y),
        isSelected ? 4 : 3,
        Paint()..color = Colors.white,
      );

      // Label for selected store
      if (isSelected) {
        _drawStoreLabel(canvas, store.name, Offset(x, y - 18));
      }
    }
  }

  void _drawStoreLabel(Canvas canvas, String name, Offset pos) {
    final tp = TextPainter(
      text: TextSpan(
        text: name,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          backgroundColor: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final bgRect = Rect.fromCenter(
      center: pos,
      width: tp.width + 10,
      height: tp.height + 6,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(bgRect, const Radius.circular(6)),
      Paint()..color = Colors.white,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bgRect, const Radius.circular(6)),
      Paint()
        ..color = AppColors.primary.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    tp.paint(
      canvas,
      Offset(bgRect.left + 5, bgRect.top + 3),
    );
  }

  void _drawEntrances(Canvas canvas) {
    final entPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    // Main entrance (bottom center)
    _drawEntranceMarker(canvas, const Offset(400, 680), '정문', entPaint);
    // Side entrance (right)
    _drawEntranceMarker(canvas, const Offset(770, 340), '측문', entPaint);
  }

  void _drawEntranceMarker(Canvas canvas, Offset pos, String label, Paint paint) {
    // Arrow indicator
    final path = Path();
    const s = 8.0;
    if (pos.dy > 600) {
      // bottom entrance - up arrow
      path.moveTo(pos.dx, pos.dy - s * 2);
      path.lineTo(pos.dx - s, pos.dy);
      path.lineTo(pos.dx + s, pos.dy);
      path.close();
    } else {
      // side entrance - left arrow
      path.moveTo(pos.dx - s * 2, pos.dy);
      path.lineTo(pos.dx, pos.dy - s);
      path.lineTo(pos.dx, pos.dy + s);
      path.close();
    }
    canvas.drawPath(path, paint);

    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final labelPos = pos.dy > 600
        ? Offset(pos.dx - tp.width / 2, pos.dy - s * 2 - tp.height - 4)
        : Offset(pos.dx - s * 2 - tp.width - 4, pos.dy - tp.height / 2);

    tp.paint(canvas, labelPos);
  }

  void _drawLabels(Canvas canvas) {
    for (final zone in _zoneDefs) {
      final rect = _zoneRects[zone.id]!;
      final isSelected = selectedZone == zone.id;
      final labelColor = isSelected ? zone.color : zone.color.withValues(alpha: 0.6);

      final tp = TextPainter(
        text: TextSpan(
          text: '${zone.id}구역\n${zone.name}',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            color: labelColor,
            height: 1.4,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      )..layout(maxWidth: rect.width - 20);

      // Position label at top-right of zone
      tp.paint(
        canvas,
        Offset(
          rect.right - tp.width - 12,
          rect.top + 10,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MarketFloorplanPainter oldDelegate) =>
      oldDelegate.selectedZone != selectedZone ||
      oldDelegate.selectedStore != selectedStore;
}

// ── Supporting Data ──────────────────────────────────────────────────────────

class _ZoneInfo {
  final String id;
  final String name;
  final Color bgColor;
  final Color color;

  const _ZoneInfo(this.id, this.name, this.bgColor, this.color);
}

// ── Zone Store Panel ─────────────────────────────────────────────────────────

class _ZoneStorePanel extends StatelessWidget {
  final _ZoneInfo zoneInfo;
  final List<Store> stores;
  final ValueChanged<Store> onStoreTap;
  final VoidCallback onClose;

  const _ZoneStorePanel({
    required this.zoneInfo,
    required this.stores,
    required this.onStoreTap,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 24,
            offset: Offset(0, -8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: zoneInfo.bgColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: zoneInfo.color.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    '${zoneInfo.id}구역',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: SDS.fwBlack,
                      color: zoneInfo.color,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    zoneInfo.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: SDS.fwBlack,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                Text(
                  '${stores.length}개 점포',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: SDS.fwBold,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 8),
                ShrinkableButton(
                  onTap: onClose,
                  child: const Icon(Icons.close_rounded,
                      size: 20, color: AppColors.textTertiary),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF2F4F6)),
          // Store list
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 220),
            child: stores.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      '이 구역에 등록된 점포가 없어요',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: stores.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, indent: 20, endIndent: 20),
                    itemBuilder: (context, index) {
                      final store = stores[index];
                      return ShrinkableButton(
                        onTap: () => onStoreTap(store),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.storefront_rounded,
                                    color: AppColors.primary, size: 18),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      store.name,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: SDS.fwBold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      store.category,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: store.status == StoreStatus.open
                                      ? const Color(0xFFE8F5E9)
                                      : const Color(0xFFF2F4F6),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  store.status == StoreStatus.open
                                      ? '영업중'
                                      : '준비중',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: SDS.fwBlack,
                                    color: store.status == StoreStatus.open
                                        ? const Color(0xFF4CAF50)
                                        : AppColors.textTertiary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.chevron_right_rounded,
                                  size: 16, color: AppColors.textTertiary),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 12),
        ],
      ),
    );
  }
}

// ── Store Quick Card ─────────────────────────────────────────────────────────

class _StoreQuickCard extends StatelessWidget {
  final Store store;
  final VoidCallback onClose;
  final VoidCallback onDetail;

  const _StoreQuickCard({
    required this.store,
    required this.onClose,
    required this.onDetail,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 24,
            offset: Offset(0, -8),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        20, 16, 20, MediaQuery.of(context).padding.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              PremiumPlaceholder(
                category: store.category,
                width: 52,
                height: 52,
                borderRadius: SDS.radiusM,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      store.name,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: SDS.fwBlack,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${store.zoneId}구역 • ${store.category}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: SDS.fwBold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: store.status == StoreStatus.open
                      ? const Color(0xFFE8F5E9)
                      : const Color(0xFFF2F4F6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  store.status == StoreStatus.open ? '영업중' : '준비중',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: SDS.fwBlack,
                    color: store.status == StoreStatus.open
                        ? const Color(0xFF4CAF50)
                        : AppColors.textTertiary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ShrinkableButton(
                onTap: onClose,
                child: const Icon(Icons.close_rounded,
                    size: 20, color: AppColors.textTertiary),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ShrinkableButton(
            onTap: onDetail,
            child: Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(SDS.radiusM),
                boxShadow: SDS.shadowAccent(AppColors.primary),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.store_rounded, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text(
                    '점포 상세 보기',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: SDS.fwBlack,
                      color: Colors.white,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
