import 'package:flutter/material.dart';

import '../providers/app_data_provider.dart';
import '../theme/app_colors.dart';
import '../theme/sijang_design_system.dart';
import 'shrinkable_button.dart';

class DataLoadErrorBanner extends StatelessWidget {
  const DataLoadErrorBanner({super.key, required this.data});

  final AppDataProvider data;

  @override
  Widget build(BuildContext context) {
    if (data.isLoading || data.markets.isNotEmpty || data.errorMessage == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(SDS.radiusM),
        border: Border.all(
          color: AppColors.danger.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.cloud_off_rounded,
                color: AppColors.danger,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                '시장 정보를 불러오지 못했어요',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: SDS.fwBlack,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            data.errorMessage!,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: SDS.fwBold,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          ShrinkableButton(
            onTap: data.isLoading ? null : () => data.refresh(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '다시 불러오기',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: SDS.fwBlack,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
