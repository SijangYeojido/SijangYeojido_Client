import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/sijang_design_system.dart';
import '../../widgets/shrinkable_button.dart';
import '../../widgets/sds_widgets.dart';

class MarketMapSimpleScreen extends StatelessWidget {
  final String marketName;
  const MarketMapSimpleScreen({super.key, required this.marketName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ── Immersive Map Background ──────────────────────────────
          Positioned.fill(
            child: Container(
              color: const Color(0xFFEEF1F6),
              child: Stack(
                children: [
                   // Generic Traditional Market Floorplan Mock
                   Center(
                     child: Opacity(
                       opacity: 0.1,
                       child: Icon(Icons.map_rounded, size: 400, color: AppColors.textPrimary),
                     ),
                   ),
                   // Sample Zone Markers
                   _buildZoneMarker(context, 0.3, 0.4, 'A구역', AppColors.primary),
                   _buildZoneMarker(context, 0.7, 0.3, 'B구역', AppColors.accent),
                   _buildZoneMarker(context, 0.4, 0.7, 'C구역', AppColors.orange),
                   _buildZoneMarker(context, 0.6, 0.6, 'D구역', AppColors.success),
                ],
              ),
            ),
          ),

          // ── Glassmorphic Top Bar ──────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 8, 20, 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.7),
                    border: const Border(bottom: BorderSide(color: Colors.black12, width: 0.5)),
                  ),
                  child: Row(
                    children: [
                      ShrinkableButton(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$marketName 지도',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: SDS.fwBlack,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const Text(
                            '실내 구성 및 점포 위치 안내',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: SDS.fwBold,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Bottom Insight Card ───────────────────────────────────
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: SDSFadeIn(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(SDS.radiusXL),
                  boxShadow: SDS.shadowPremium,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.info_outline_rounded, color: AppColors.primary),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '지도가 준비 중입니다',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: SDS.fwBlack,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                '더 정확한 실내 안내를 위해 리모델링 중이에요!',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: SDS.fwBold,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SDS.button(
                      label: '리스트로 보기',
                      onTap: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZoneMarker(BuildContext context, double x, double y, String label, Color color) {
    return Positioned(
      left: MediaQuery.of(context).size.width * x,
      top: MediaQuery.of(context).size.height * y,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(100),
              boxShadow: SDS.shadowSoft,
            ),
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 4),
          const Icon(Icons.location_on_rounded, color: Colors.white, size: 24),
        ],
      ),
    );
  }
}
