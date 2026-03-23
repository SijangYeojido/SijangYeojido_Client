import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../theme/app_colors.dart';
import '../../theme/sijang_design_system.dart';
import '../../widgets/shrinkable_button.dart';
import '../map/market_hub_screen.dart';

class NearbyMapScreen extends StatefulWidget {
  const NearbyMapScreen({super.key});

  @override
  State<NearbyMapScreen> createState() => _NearbyMapScreenState();
}

class _NearbyMapScreenState extends State<NearbyMapScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  _MarketPin? _selectedMarket;
  final TransformationController _transformController =
      TransformationController();

  // Mock market data with map positions (normalized 0-1)
  static final _markets = [
    _MarketPin(
      name: MockData.markets[0].name,
      description: MockData.markets[0].description,
      address: MockData.markets[0].address,
      distance: '350m',
      openStores: 42,
      totalStores: 68,
      x: 0.55,
      y: 0.42,
      isAvailable: MockData.markets[0].isAvailable,
      highlights: MockData.markets[0].highlights,
      accentColor: MockData.markets[0].accentColor,
      hasFlashDeal: true,
      isLiveStory: true,
    ),
    _MarketPin(
      name: MockData.markets[1].name,
      description: MockData.markets[1].description,
      address: MockData.markets[1].address,
      distance: '1.2km',
      openStores: 0,
      totalStores: 120,
      x: 0.78,
      y: 0.28,
      isAvailable: MockData.markets[1].isAvailable,
      highlights: MockData.markets[1].highlights,
      accentColor: MockData.markets[1].accentColor,
    ),
    _MarketPin(
      name: MockData.markets[2].name,
      description: MockData.markets[2].description,
      address: MockData.markets[2].address,
      distance: '3.5km',
      openStores: 0,
      totalStores: 85,
      x: 0.18,
      y: 0.55,
      isAvailable: MockData.markets[2].isAvailable,
      highlights: MockData.markets[2].highlights,
      accentColor: MockData.markets[2].accentColor,
      hasFlashDeal: true,
    ),
  ];

  // User location (normalized 0-1)
  static const _userX = 0.50;
  static const _userY = 0.48;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _transformController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFEEF1F6),
      body: Stack(
        children: [
          // ── Map Canvas ─────────────────────────────────────────
          InteractiveViewer(
            transformationController: _transformController,
            minScale: 0.8,
            maxScale: 3.0,
            constrained: false,
            child: GestureDetector(
              onTapUp: (details) => _handleMapTap(details),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 2,
                height: MediaQuery.of(context).size.height * 2,
                child: CustomPaint(
                  painter: _NearbyMapPainter(
                    markets: _markets,
                    selectedMarket: _selectedMarket,
                    userX: _userX,
                    userY: _userY,
                    pulseValue: _pulseAnimation,
                  ),
                ),
              ),
            ),
          ),

          // ── SDS Signature Search Bar (V7) ────────────────────────
          Positioned(
            top: SDS.gutter + MediaQuery.of(context).padding.top,
            left: SDS.gutter,
            right: SDS.gutter,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(SDS.radiusM),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  height: 68,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: SDS.glassDecoration(opacity: 0.75, blur: 20),
                  child: Row(
                    children: [
                      const Icon(Icons.search_rounded,
                          size: 24, color: AppColors.primary),
                      const SizedBox(width: 16),
                      Flexible(
                        child: Text(
                          '어느 시장으로 안내해 드릴까요?',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: SDS.fwBlack,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(SDS.radiusCapsule),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.location_on_rounded,
                                size: 14, color: AppColors.primary),
                            const SizedBox(width: 6),
                            const Text(
                              '종로구',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── My Location FAB ────────────────────────────────────
          Positioned(
            right: 16,
            bottom: (_selectedMarket != null ? 260 : 40) + bottomPadding,
            child: ShrinkableButton(
              onTap: () {
                _transformController.value = Matrix4.identity();
              },
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.10),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.my_location_rounded,
                    size: 22, color: AppColors.primary),
              ),
            ),
          ),

          // ── Fluid Market Card (V6) ──────────────────────────────
          AnimatedPositioned(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutBack,
            left: 16,
            right: 16,
            bottom: _selectedMarket != null ? (100 + bottomPadding) : -400,
            child: _selectedMarket == null
                ? const SizedBox.shrink()
                : _MarketDetailCard(
                    market: _selectedMarket!,
                    bottomPadding: 0,
                    onClose: () => setState(() => _selectedMarket = null),
                    onNavigate: () {
                      if (_selectedMarket!.isAvailable) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MarketHubScreen(
                                marketName: _selectedMarket!.name),
                          ),
                        );
                      }
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _handleMapTap(TapUpDetails details) {
    final renderBox = context.findRenderObject() as RenderBox;
    final canvasSize = Size(
      renderBox.size.width * 2,
      renderBox.size.height * 2,
    );

    // Transform tap position by inverse of current transform
    final matrix = _transformController.value.clone()..invert();
    final tapLocal = MatrixUtils.transformPoint(matrix, details.localPosition);

    for (final market in _markets) {
      final markerX = market.x * canvasSize.width;
      final markerY = market.y * canvasSize.height;
      final dx = tapLocal.dx - markerX;
      final dy = tapLocal.dy - markerY;
      final distance = sqrt(dx * dx + dy * dy);

      if (distance < 40) {
        setState(() => _selectedMarket = market);
        return;
      }
    }

    // Tapped empty area – dismiss
    if (_selectedMarket != null) {
      setState(() => _selectedMarket = null);
    }
  }
}

// ── Map Painter ──────────────────────────────────────────────────────────────

class _NearbyMapPainter extends CustomPainter {
  final List<_MarketPin> markets;
  final _MarketPin? selectedMarket;
  final double userX;
  final double userY;
  final Animation<double> pulseValue;

  _NearbyMapPainter({
    required this.markets,
    required this.selectedMarket,
    required this.userX,
    required this.userY,
    required this.pulseValue,
  }) : super(repaint: pulseValue);

  @override
  void paint(Canvas canvas, Size size) {
    _drawBackground(canvas, size);
    _drawRoads(canvas, size);
    _drawBlocks(canvas, size);
    _drawLabels(canvas, size);
    _drawUserLocation(canvas, size);
    _drawMarketPins(canvas, size);
  }

  void _drawBackground(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFFEEF1F6),
    );
  }

  void _drawRoads(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;

    final majorRoadPaint = Paint()
      ..color = const Color(0xFFF5E6C8)
      ..strokeWidth = 28
      ..strokeCap = StrokeCap.round;

    // Major horizontal roads
    canvas.drawLine(
      Offset(0, size.height * 0.3),
      Offset(size.width, size.height * 0.3),
      majorRoadPaint,
    );
    canvas.drawLine(
      Offset(0, size.height * 0.6),
      Offset(size.width, size.height * 0.6),
      majorRoadPaint,
    );

    // Major vertical roads
    canvas.drawLine(
      Offset(size.width * 0.35, 0),
      Offset(size.width * 0.35, size.height),
      majorRoadPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.65, 0),
      Offset(size.width * 0.65, size.height),
      majorRoadPaint,
    );

    // Minor roads
    for (var i = 0.15; i < 1; i += 0.2) {
      canvas.drawLine(
        Offset(0, size.height * i),
        Offset(size.width, size.height * i),
        roadPaint,
      );
    }
    for (var i = 0.1; i < 1; i += 0.15) {
      canvas.drawLine(
        Offset(size.width * i, 0),
        Offset(size.width * i, size.height),
        roadPaint,
      );
    }
  }

  void _drawBlocks(Canvas canvas, Size size) {
    final blockPaint = Paint()..color = const Color(0xFFE0E4EB);
    final greenPaint = Paint()..color = const Color(0xFFD4E8D0);

    // Building blocks
    final blocks = [
      Rect.fromLTWH(size.width * 0.02, size.height * 0.02,
          size.width * 0.12, size.height * 0.12),
      Rect.fromLTWH(size.width * 0.38, size.height * 0.02,
          size.width * 0.25, size.height * 0.12),
      Rect.fromLTWH(size.width * 0.02, size.height * 0.32,
          size.width * 0.15, size.height * 0.10),
      Rect.fromLTWH(size.width * 0.70, size.height * 0.62,
          size.width * 0.12, size.height * 0.15),
      Rect.fromLTWH(size.width * 0.02, size.height * 0.65,
          size.width * 0.10, size.height * 0.18),
      Rect.fromLTWH(size.width * 0.85, size.height * 0.35,
          size.width * 0.12, size.height * 0.08),
    ];

    for (final block in blocks) {
      final rrect = RRect.fromRectAndRadius(block, const Radius.circular(6));
      canvas.drawRRect(rrect, blockPaint);
    }

    // Green park areas
    final parks = [
      Rect.fromLTWH(size.width * 0.20, size.height * 0.70,
          size.width * 0.12, size.height * 0.10),
      Rect.fromLTWH(size.width * 0.80, size.height * 0.08,
          size.width * 0.10, size.height * 0.08),
    ];
    for (final park in parks) {
      final rrect = RRect.fromRectAndRadius(park, const Radius.circular(8));
      canvas.drawRRect(rrect, greenPaint);
    }
  }

  void _drawLabels(Canvas canvas, Size size) {
    // Road labels
    _drawTextLabel(canvas, '종로', Offset(size.width * 0.50, size.height * 0.295),
        10, const Color(0xFF999999));
    _drawTextLabel(canvas, '을지로',
        Offset(size.width * 0.50, size.height * 0.595), 10,
        const Color(0xFF999999));
    _drawTextLabel(canvas, '창경궁로',
        Offset(size.width * 0.345, size.height * 0.50), 9,
        const Color(0xFF999999),
        rotate: true);
  }

  void _drawTextLabel(Canvas canvas, String text, Offset pos, double fontSize,
      Color color,
      {bool rotate = false}) {
    final textSpan = TextSpan(
      text: text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w600,
        color: color,
        letterSpacing: 2,
      ),
    );
    final tp = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    )..layout();

    if (rotate) {
      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(-pi / 2);
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      canvas.restore();
    } else {
      tp.paint(canvas, Offset(pos.dx - tp.width / 2, pos.dy - tp.height / 2));
    }
  }

  void _drawUserLocation(Canvas canvas, Size size) {
    final cx = userX * size.width;
    final cy = userY * size.height;

    // Pulse ring
    final pulseRadius = 12 + pulseValue.value * 28;
    final pulseOpacity = (1.0 - pulseValue.value) * 0.3;
    canvas.drawCircle(
      Offset(cx, cy),
      pulseRadius,
      Paint()
        ..color = const Color(0xFF4285F4).withValues(alpha: pulseOpacity)
        ..style = PaintingStyle.fill,
    );

    // White outer ring
    canvas.drawCircle(
      Offset(cx, cy),
      10,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );

    // Blue dot
    canvas.drawCircle(
      Offset(cx, cy),
      7,
      Paint()
        ..color = const Color(0xFF4285F4)
        ..style = PaintingStyle.fill,
    );
  }

  void _drawMarketPins(Canvas canvas, Size size) {
    for (final market in markets) {
      final cx = market.x * size.width;
      final cy = market.y * size.height;
      final isSelected = selectedMarket == market;

      // Pin shadow
      canvas.drawCircle(
        Offset(cx, cy + 3),
        isSelected ? 22 : 18,
        Paint()..color = Colors.black.withValues(alpha: 0.12),
      );

      // Pin body
      final pinColor = market.isAvailable
          ? market.accentColor
          : const Color(0xFFB0B8C4);
      canvas.drawCircle(
        Offset(cx, cy),
        isSelected ? 22 : 18,
        Paint()..color = pinColor,
      );

      // --- V8 Dynamic Indicators ---
      if (market.hasFlashDeal || market.isLiveStory) {
        final indicatorX = cx + (isSelected ? 18 : 14);
        final indicatorY = cy - (isSelected ? 18 : 14);

        // Glow effect
        canvas.drawCircle(
          Offset(indicatorX, indicatorY),
          12,
          Paint()
            ..color = const Color(0xFFF04452).withValues(alpha: 0.2 + 0.1 * sin(pulseValue.value * pi))
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
        );

        canvas.drawCircle(
          Offset(indicatorX, indicatorY),
          9,
          Paint()..color = const Color(0xFFF04452),
        );
      }

      // Pin icon (storefront dot)
      canvas.drawCircle(
        Offset(cx, cy),
        isSelected ? 6 : 4,
        Paint()..color = Colors.white,
      );

      // Market name label
      final nameSpan = TextSpan(
        text: market.name,
        style: TextStyle(
          fontSize: isSelected ? 13 : 11,
          fontWeight: FontWeight.w800,
          color: market.isAvailable
              ? AppColors.textPrimary
              : AppColors.textTertiary,
          backgroundColor:
              Colors.white.withValues(alpha: 0.9),
        ),
      );
      final nameTp = TextPainter(
        text: nameSpan,
        textDirection: TextDirection.ltr,
      )..layout();
      nameTp.paint(canvas,
          Offset(cx - nameTp.width / 2, cy + (isSelected ? 28 : 22)));
    }
  }

  @override
  bool shouldRepaint(covariant _NearbyMapPainter oldDelegate) => true;
}

// ── Market Bottom Sheet ──────────────────────────────────────────────────────

class _MarketDetailCard extends StatelessWidget {
  final _MarketPin market;
  final double bottomPadding;
  final VoidCallback onClose;
  final VoidCallback onNavigate;

  const _MarketDetailCard({
    required this.market,
    required this.bottomPadding,
    required this.onClose,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(SDS.radiusXL),
        boxShadow: SDS.shadowPremium,
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 16, 20, bottomPadding + 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E8EB),
                    borderRadius: BorderRadius.circular(SDS.radiusCapsule),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Market name + distance
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                market.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: SDS.fwBlack,
                                  letterSpacing: -0.5,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: market.isAvailable
                                    ? AppColors.primaryLight
                                    : AppColors.background,
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Text(
                                market.isAvailable ? '입장 가능' : '준비 중',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: market.isAvailable
                                      ? AppColors.primary
                                      : AppColors.textTertiary,
                                ),
                              ),
                            ),
                            if (market.hasFlashDeal) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF04452).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(100),
                                  border: Border.all(color: const Color(0xFFF04452).withValues(alpha: 0.3)),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.bolt_rounded, size: 11, color: Color(0xFFF04452)),
                                    SizedBox(width: 3),
                                    Text(
                                      'DEAL',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFFF04452),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          market.address,
                          style: textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.directions_walk_rounded,
                            size: 20, color: AppColors.primary),
                        const SizedBox(height: 2),
                        Text(
                          market.distance,
                          style: textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Stats row
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _StatItem(
                        icon: Icons.storefront_rounded,
                        label: '전체 점포',
                        value: '${market.totalStores}곳',
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 32,
                      color: AppColors.border,
                    ),
                    Expanded(
                      child: _StatItem(
                        icon: Icons.circle,
                        iconSize: 8,
                        label: '영업 중',
                        value: '${market.openStores}곳',
                        color: market.openStores > 0
                            ? AppColors.success
                            : AppColors.textTertiary,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 32,
                      color: AppColors.border,
                    ),
                    Expanded(
                      child: _StatItem(
                        icon: Icons.directions_walk_rounded,
                        label: '도보',
                        value: market.distance,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Highlights
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: market.highlights.map((h) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: market.isAvailable
                          ? AppColors.primaryLight
                          : AppColors.background,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      '#$h',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: market.isAvailable
                            ? AppColors.primary
                            : AppColors.textTertiary,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),

              // CTA button
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ShrinkableButton(
                  onTap: market.isAvailable ? onNavigate : null,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: market.isAvailable 
                        ? LinearGradient(
                            colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.85)],
                          )
                        : null,
                      color: market.isAvailable ? null : AppColors.divider,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: market.isAvailable ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.25),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ] : [],
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            market.isAvailable
                                ? Icons.near_me_rounded
                                : Icons.lock_outline_rounded,
                            size: 22,
                            color: market.isAvailable ? Colors.white : AppColors.textTertiary,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            market.isAvailable ? '이 시장 구경할까요?' : '아직 준비 중이에요',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: SDS.fwBlack,
                              letterSpacing: -0.5,
                              color: market.isAvailable ? Colors.white : AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final double iconSize;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    this.iconSize = 14,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: iconSize, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

// ── Data Model ───────────────────────────────────────────────────────────────

class _MarketPin {
  final String name;
  final String description;
  final String address;
  final String distance;
  final int openStores;
  final int totalStores;
  final double x;
  final double y;
  final bool isAvailable;
  final List<String> highlights;
  final Color accentColor;
  final bool hasFlashDeal;
  final bool isLiveStory;

  const _MarketPin({
    required this.name,
    required this.description,
    required this.address,
    required this.distance,
    required this.openStores,
    required this.totalStores,
    required this.x,
    required this.y,
    required this.isAvailable,
    required this.highlights,
    required this.accentColor,
    this.hasFlashDeal = false,
    this.isLiveStory = false,
  });
}
