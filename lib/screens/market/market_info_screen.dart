import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_colors.dart';
import '../../theme/sijang_design_system.dart';
import '../../widgets/shrinkable_button.dart';
import '../../widgets/sds_widgets.dart';

class MarketInfoScreen extends StatelessWidget {
  final String marketName;
  const MarketInfoScreen({super.key, required this.marketName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Cinematic V16 Sliver Header ──────────────────────
          SliverAppBar(
            expandedHeight: 340,
            backgroundColor: Colors.white,
            elevation: 0,
            pinned: true,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ShrinkableButton(
                onTap: () => Navigator.pop(context),
                child: const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 18),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // 1. Premium 3D Hero Background
                  Container(
                    color: const Color(0xFFF7F8FA),
                    child: Center(
                      child: Opacity(
                        opacity: 0.9,
                        child: Image.asset(
                          'assets/images/market_hero.png',
                          width: 280,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  // 2. Gradient Overlay for pin text readability
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.05),
                          Colors.transparent,
                          Colors.white.withValues(alpha: 0.8),
                          Colors.white,
                        ],
                        stops: const [0.0, 0.4, 0.85, 1.0],
                      ),
                    ),
                  ),
                  // 3. Floating Glassmorphism Title Card
                  Positioned(
                    bottom: 24,
                    left: 20,
                    right: 20,
                    child: SDSFadeIn(
                      delay: const Duration(milliseconds: 300),
                      child: SDSGlass(
                        blur: 24,
                        opacity: 0.9,
                        padding: const EdgeInsets.all(24),
                        radius: 32,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.stars_rounded, color: AppColors.primary, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  '전통의 가치',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: SDS.fwBold,
                                    color: AppColors.primary,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              marketName,
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: SDS.fwBlack,
                                color: AppColors.textPrimary,
                                letterSpacing: -1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Market Content ──────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),
                  SDSFadeIn(
                    delay: const Duration(milliseconds: 500),
                    child: const Text(
                      '서울 관악구의 대표 전통시장인\n신원시장은 도림천 주변에 늘어서 있던\n노점들로부터 그 역사가 시작되었습니다.\n\n현재는 신림역과 인접한 편리한 교통과 도림천의 자연이 어우러진 현대적인 수변 시장으로 탈바꿈하였으며, 상인들의 넉넉한 인심과 정을 그대로 간직하고 있는 소중한 공간입니다.',
                      style: TextStyle(
                        fontSize: 17,
                        color: AppColors.textSecondary,
                        height: 1.6,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildDetailSection(
                    '위치 및 교통',
                    '서울 관악구 신림동 1587-39\n지하철 2호선 신림역 도보 5분 거리',
                  ),
                  const SizedBox(height: 48),
                  SDSFadeIn(
                    delay: const Duration(milliseconds: 600),
                    child: _buildUltimateUtilityGrid(context),
                  ),
                  const SizedBox(height: 56),

                  // ── Immersive Guide Sections ──────────────────
                  SDSFadeIn(
                    delay: const Duration(milliseconds: 700),
                    child: _buildPremiumInfoSection(
                      title: '방문 가이드',
                      items: [
                        _buildPremiumInfoItem(Icons.access_time_filled_rounded, '영업 시간', '매일 09:00 - 23:00'),
                        _buildPremiumInfoItem(Icons.shopping_bag_rounded, '주요 품목', '먹거리, 빈대떡, 육회, 한복'),
                        _buildPremiumInfoItem(Icons.credit_card_rounded, '결제 수단', '온누리상품권, 제로페이 가능'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static const _phoneNumber = '028545453';

  void _showCenterToast(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Text(
              message,
              style: const TextStyle(color: Colors.white, fontSize: 15),
            ),
          ),
        ),
      ),
    );
    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 2), entry.remove);
  }

  Future<void> _handleCall(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('전화 연결', textAlign: TextAlign.center),
        content: const Text('02-854-5453으로 전화를 걸까요?', textAlign: TextAlign.center),
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              backgroundColor: const Color(0xFFF0F0F0),
              minimumSize: const Size(100, 44),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('취소', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 12),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: AppColors.primary,
              minimumSize: const Size(100, 44),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('전화걸기', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final uri = Uri(scheme: 'tel', path: _phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      await Clipboard.setData(const ClipboardData(text: '02-854-5453'));
      if (context.mounted) {
        _showCenterToast(context, '전화번호를 복사했습니다.');
      }
    }
  }

  Widget _buildUltimateUtilityGrid(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildCircularAction(Icons.phone_rounded, '전화하기', onTap: () => _handleCall(context)),
        _buildCircularAction(Icons.location_on_rounded, '위치보기'),
        _buildCircularAction(Icons.share_rounded, '공유하기'),
        _buildCircularAction(Icons.bookmark_rounded, '저장하기'),
      ],
    );
  }

  Widget _buildCircularAction(IconData icon, String label, {VoidCallback? onTap}) {
    return Column(
      children: [
        ShrinkableButton(
          onTap: onTap ?? () {},
          child: Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: const Color(0xFFF7F8FA),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
            ),
            child: Icon(icon, color: AppColors.textPrimary, size: 28),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: SDS.fwBold,
            color: AppColors.textSecondary,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumInfoSection({required String title, required List<Widget> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: SDS.fwBlack,
            color: AppColors.textPrimary,
            letterSpacing: -0.6,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F8FA),
            borderRadius: BorderRadius.circular(SDS.radiusL),
          ),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildPremiumInfoItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: SDS.fwBold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: SDS.fwBlack,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: SDS.fwBlack,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: const TextStyle(
            fontSize: 15,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
