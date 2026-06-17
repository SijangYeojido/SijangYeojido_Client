import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_data_provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/sijang_design_system.dart';
import '../../widgets/shrinkable_button.dart';
import '../auth/login_screen.dart';

class MarketCouponScreen extends StatelessWidget {
  final String marketName;
  const MarketCouponScreen({super.key, required this.marketName});

  // Shinwon Brand Red
  static const Color shinwonRed = Color(0xFFF04452);

  @override
  Widget build(BuildContext context) {
    final coupons = context.watch<AppDataProvider>().coupons;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ShrinkableButton(
            onTap: () => Navigator.pop(context),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary,
              size: 20,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: EdgeInsets.only(left: 12.0),
              child: Text(
                '\u00A0사용 가능한 쿠폰이\n\u00A0${coupons.length}개 있어요',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: SDS.fwBlack,
                  color: AppColors.textPrimary,
                  height: 1.3,
                  letterSpacing: 0.8,
                ),
                overflow: TextOverflow.visible,
              ),
            ),
            const SizedBox(height: 32),

            // ─── Nuclear Fixed Savings Card ───
            _buildNuclearSavingsCard(),
            const SizedBox(height: 32),

            const Padding(
              padding: EdgeInsets.only(left: 12.0),
              child: Text(
                '\u00A0진행 중인 혜택',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: SDS.fwBlack,
                  color: AppColors.textPrimary,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (coupons.isEmpty)
              const Padding(
                padding: EdgeInsets.all(12),
                child: Text('현재 받을 수 있는 쿠폰이 없습니다.'),
              )
            else
              ...coupons.map(
                (coupon) => _buildNuclearCouponItem(
                  context: context,
                  id: int.tryParse(coupon['id']?.toString() ?? '') ?? 0,
                  title: coupon['title']?.toString() ?? '쿠폰',
                  subtitle: coupon['description']?.toString() ?? '',
                  value: coupon['benefit']?.toString() ?? '혜택',
                  isDownloaded: coupon['claimed'] == true,
                ),
              ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildNuclearSavingsCard() {
    // NUCLEAR FIX: Bypass SDS.epicCard to avoid forced ClipRRect
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 34),
      decoration: BoxDecoration(
        color: shinwonRed,
        borderRadius: BorderRadius.circular(SDS.radiusL),
        boxShadow: SDS.shadowAccent(shinwonRed),
      ),
      child: Row(
        children: [
          const SizedBox(width: 14), // Safety physical spacer
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '\u00A0이번 달 절약 가능한 금액',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: SDS.fwBold,
                    letterSpacing: 1.0,
                  ),
                  overflow: TextOverflow.visible,
                ),
                const SizedBox(height: 10),
                Text(
                  '\u00A0약 24,000원',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: SDS.fwBlack,
                    letterSpacing: 1.0,
                  ),
                  overflow: TextOverflow.visible,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.savings_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNuclearCouponItem({
    required BuildContext context,
    required int id,
    required String title,
    required String subtitle,
    required String value,
    required bool isDownloaded,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(SDS.radiusM),
          boxShadow: SDS.shadowPremium,
        ),
        child: Row(
          children: [
            Container(
              width: 74,
              height: 74,
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  value,
                  style: const TextStyle(
                    color: shinwonRed,
                    fontSize: 16,
                    fontWeight: SDS.fwBlack,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '\u00A0$title',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: SDS.fwBlack,
                      color: AppColors.textPrimary,
                      letterSpacing: 0.5,
                    ),
                    overflow: TextOverflow.visible,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\u00A0$subtitle',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: SDS.fwBold,
                      letterSpacing: 0.5,
                    ),
                    overflow: TextOverflow.visible,
                  ),
                ],
              ),
            ),
            ShrinkableButton(
              onTap: isDownloaded || id == 0
                  ? () {}
                  : () async {
                      if (!_ensureLoggedIn(context)) return;
                      try {
                        await context.read<AppDataProvider>().claimCoupon(id);
                      } catch (_) {
                        if (!context.mounted) return;
                        final message =
                            context.read<AppDataProvider>().errorMessage ??
                            '쿠폰을 받을 수 없습니다. 잠시 후 다시 시도해 주세요.';
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(message)));
                      }
                    },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDownloaded
                      ? const Color(0xFFF2F4F6)
                      : shinwonRed.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isDownloaded
                      ? Icons.check_circle_rounded
                      : Icons.download_rounded,
                  color: isDownloaded ? AppColors.textTertiary : shinwonRed,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _ensureLoggedIn(BuildContext context) {
    if (context.read<AuthProvider>().isLoggedIn) return true;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('쿠폰 받기는 로그인 후 이용할 수 있습니다.')));
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
    return false;
  }
}
