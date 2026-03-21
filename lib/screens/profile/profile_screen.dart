import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../data/mock_data.dart';
import '../../theme/sijang_design_system.dart';
import '../../widgets/sds_widgets.dart';
import '../../widgets/shrinkable_button.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final completedReservations = MockData.reservations.where((r) => r.isCompleted).length;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Cinematic V16 Header ────────────────────────────
          SliverToBoxAdapter(
            child: Stack(
              children: [
                // 1. Subtle Premium Gradient BG
                Container(
                  height: 260,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF7F8FA),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(SDS.radiusEpic),
                      bottomRight: Radius.circular(SDS.radiusEpic),
                    ),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            const Text(
                              '마이페이지',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: SDS.fwBlack,
                                color: AppColors.textPrimary,
                                letterSpacing: -1.0,
                              ),
                            ),
                            const Spacer(),
                            _ActionIconBtn(
                              icon: Icons.settings_rounded,
                              onTap: () {},
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        // 2. Glassmorphism Profile Card
                        SDSFadeIn(
                          delay: const Duration(milliseconds: 300),
                          child: SDSGlass(
                            blur: 32,
                            opacity: 0.85,
                            radius: 32,
                            padding: const EdgeInsets.all(24),
                            child: Row(
                              children: [
                                _ProfileAvatar(initial: '김'),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        '김시장님',
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: SDS.fwBlack,
                                          color: AppColors.textPrimary,
                                          letterSpacing: -0.8,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        '시장여지도와 함께한 지 3개월째 ✨',
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
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),

          // ── Premium Stats Row ──────────────────────────────
          SliverToBoxAdapter(
            child: SDSFadeIn(
              delay: const Duration(milliseconds: 500),
              child: _StatsRow(completedDeals: completedReservations),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 48)),

          // ── Settings Sections ──────────────────────────────
          SliverToBoxAdapter(
            child: SDSFadeIn(
              delay: const Duration(milliseconds: 600),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    _buildSectionHeader('단골 시장'),
                    _FavoriteMarketCard(
                      name: '신원시장',
                      address: '서울 종로구 창경궁로 88',
                      storeCount: MockData.stores.length,
                    ),
                    const SizedBox(height: 40),
                    _buildSectionHeader('나의 활동'),
                    _UltimateSettingItem(icon: Icons.receipt_long_rounded, label: '주문 내역', color: AppColors.primary),
                    _UltimateSettingItem(icon: Icons.confirmation_number_rounded, label: '나의 쿠폰', color: AppColors.orange),
                    _UltimateSettingItem(icon: Icons.star_rounded, label: '내가 쓴 리뷰', color: AppColors.warning),
                    const SizedBox(height: 40),
                    _buildSectionHeader('설정'),
                    _UltimateSettingItem(icon: Icons.notifications_rounded, label: '알림 설정'),
                    _UltimateSettingItem(icon: Icons.shield_rounded, label: '개인정보 관리'),
                    _UltimateSettingItem(
                      icon: Icons.swap_horiz_rounded, 
                      label: '역할 변경', 
                      onTap: () => context.read<AuthProvider>().toggleRole(),
                    ),
                    _UltimateSettingItem(
                      icon: Icons.logout_rounded, 
                      label: '로그아웃', 
                      onTap: () => context.read<AuthProvider>().logout(),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: SDS.fwBlack,
              color: AppColors.textPrimary,
              letterSpacing: -0.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  final String initial;
  const _ProfileAvatar({required this.initial});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 68,
      height: 68,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: SDS.fwBlack,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final int completedDeals;
  const _StatsRow({required this.completedDeals});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          _StatBento(label: '방문 시장', value: '1', icon: Icons.location_on_rounded, color: AppColors.primary),
          const SizedBox(width: 12),
          _StatBento(label: '즐겨찾기', value: '5', icon: Icons.favorite_rounded, color: AppColors.danger),
          const SizedBox(width: 12),
          _StatBento(label: '활동 점수', value: '98', icon: Icons.bolt_rounded, color: AppColors.orange),
        ],
      ),
    );
  }
}

class _StatBento extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatBento({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F8FA),
          borderRadius: BorderRadius.circular(SDS.radiusL),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(fontSize: 22, fontWeight: SDS.fwBlack, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: SDS.fwBold, color: AppColors.textTertiary),
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoriteMarketCard extends StatelessWidget {
  final String name;
  final String address;
  final int storeCount;

  const _FavoriteMarketCard({
    required this.name,
    required this.address,
    required this.storeCount,
  });

  @override
  Widget build(BuildContext context) {
    return ShrinkableButton(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(SDS.radiusL),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(color: const Color(0xFFF2F4F6)),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.storefront_rounded, color: AppColors.primary, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(fontSize: 18, fontWeight: SDS.fwBlack, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    address,
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: SDS.fwMedium),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}

class _UltimateSettingItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback? onTap;

  const _UltimateSettingItem({
    required this.icon,
    required this.label,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ShrinkableButton(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFF2F4F6), width: 1)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: color ?? AppColors.textSecondary),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: SDS.fwBold,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const Spacer(),
            const Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}

class _ActionIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _ActionIconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ShrinkableButton(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 22, color: AppColors.textPrimary),
      ),
    );
  }
}
