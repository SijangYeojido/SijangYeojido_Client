import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/sijang_design_system.dart';
import '../../widgets/sds_widgets.dart';

class MarketMapSimpleScreen extends StatelessWidget {
  final String marketName;

  const MarketMapSimpleScreen({super.key, required this.marketName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          SDS.topBar(
            context: context,
            title: '$marketName 지도',
            subtitle: '현재 구역의 매장 위치를 확인하세요',
          ),
          Expanded(
            child: Stack(
              children: [
                // Placeholder for actual map image or vector
                Container(
                  color: AppColors.border.withValues(alpha: 0.3),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.map_outlined,
                          size: 80,
                          color: AppColors.textTertiary.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '상세 지도는 준비 중입니다',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: SDS.fwBold,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Mock Zone Markers
                _buildZoneMarker(context, 'A구역', 0.25, 0.35, AppColors.primary),
                _buildZoneMarker(context, 'B구역', 0.65, 0.45, AppColors.secondary),
                _buildZoneMarker(context, 'C구역', 0.45, 0.75, AppColors.accent),
              ],
            ),
          ),
          _buildZoneLegend(context),
        ],
      ),
    );
  }

  Widget _buildZoneMarker(
    BuildContext context,
    String label,
    double x,
    double y,
    Color color,
  ) {
    return Positioned(
      left: MediaQuery.of(context).size.width * x,
      top: MediaQuery.of(context).size.height * 0.6 * y,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: SDS.shadowSoft,
              border: Border.all(color: color, width: 2),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: SDS.fwBlack,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Container(
            width: 2,
            height: 20,
            color: color,
          ),
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZoneLegend(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '시장 구역 안내',
            style: TextStyle(
              fontSize: 18,
              fontWeight: SDS.fwBlack,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildLegendItem('A구역 (먹거리 골목)', AppColors.primary),
          const SizedBox(height: 12),
          _buildLegendItem('B구역 (포목/직물 주단)', AppColors.secondary),
          const SizedBox(height: 12),
          _buildLegendItem('C구역 (숨은 로컬 명소)', AppColors.accent),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: SDS.fwSemiBold,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
