import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../providers/app_data_provider.dart';
import '../theme/app_colors.dart';
import '../theme/sijang_design_system.dart';

class OfflineCacheBanner extends StatelessWidget {
  const OfflineCacheBanner({super.key, required this.data});

  final AppDataProvider data;

  @override
  Widget build(BuildContext context) {
    if (!data.isUsingCachedData) return const SizedBox.shrink();

    final cachedAt = data.cacheUpdatedAt;
    final timeLabel = cachedAt == null
        ? '저장 시각 확인 불가'
        : '${DateFormat('M월 d일 HH:mm').format(cachedAt)} 저장';
    final title = data.isCacheStale
        ? '오래된 저장 데이터로 보고 있어요'
        : '오프라인 저장 데이터로 보고 있어요';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(SDS.radiusM),
        border: Border.all(
          color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            data.isCacheStale
                ? Icons.history_toggle_off_rounded
                : Icons.offline_bolt_rounded,
            color: const Color(0xFFD97706),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: SDS.fwBlack,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$timeLabel · 예약/신고는 온라인 연결 후 가능',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: SDS.fwBold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
