import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/sijang_design_system.dart';
import '../../widgets/shrinkable_button.dart';

class MarketMapSimpleScreen extends StatefulWidget {
  final String marketName;
  const MarketMapSimpleScreen({super.key, required this.marketName});

  @override
  State<MarketMapSimpleScreen> createState() => _MarketMapSimpleScreenState();
}

class _MarketMapSimpleScreenState extends State<MarketMapSimpleScreen> {
  final TransformationController _transformController = TransformationController();

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  void _resetZoom() {
    _transformController.value = Matrix4.identity();
  }

  @override
  Widget build(BuildContext context) {
    final safeTop = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      body: Stack(
        children: [
          // ── Interactive Map Image ──────────────────────────────────
          Positioned.fill(
            child: InteractiveViewer(
              transformationController: _transformController,
              minScale: 0.5,
              maxScale: 5.0,
              boundaryMargin: const EdgeInsets.all(80),
              child: Padding(
                padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 80),
                child: Image.asset(
                  'assets/images/sinwon_market_2x.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          // ── Glassmorphic Top Bar ───────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(
                  padding: EdgeInsets.fromLTRB(16, safeTop + 8, 16, 14),
                  decoration: const BoxDecoration(
                    color: Color(0xE0FFFFFF),
                    border: Border(
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
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 16,
                            color: AppColors.textPrimary,
                          ),
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
                              '두 손가락으로 확대·축소, 드래그로 이동하세요',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: SDS.fwBold,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ShrinkableButton(
                        onTap: _resetZoom,
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2F4F6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.center_focus_strong_rounded,
                            size: 18,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Zoom Controls ──────────────────────────────────────────
          Positioned(
            right: 16,
            bottom: MediaQuery.of(context).padding.bottom + 24,
            child: Column(
              children: [
                _ZoomButton(
                  icon: Icons.add_rounded,
                  onTap: () {
                    final current = _transformController.value.clone();
                    final scale = current.getMaxScaleOnAxis();
                    if (scale < 5.0) {
                      _transformController.value =
                          current * Matrix4.diagonal3Values(1.3, 1.3, 1.0);
                    }
                  },
                ),
                const SizedBox(height: 8),
                _ZoomButton(
                  icon: Icons.remove_rounded,
                  onTap: () {
                    final current = _transformController.value.clone();
                    final scale = current.getMaxScaleOnAxis();
                    if (scale > 0.5) {
                      _transformController.value =
                          current * Matrix4.diagonal3Values(1 / 1.3, 1 / 1.3, 1.0);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ZoomButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ZoomButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ShrinkableButton(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color(0x18000000),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, size: 22, color: AppColors.textPrimary),
      ),
    );
  }
}
