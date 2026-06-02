import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/mock_data.dart';
import '../../models/models.dart';
import '../../providers/app_data_provider.dart';
import '../../services/notification_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/sijang_design_system.dart';
import '../../widgets/shrinkable_button.dart';
import 'package:sijangyeojido_client/screens/map/market_hub_screen.dart';
import '../../widgets/skeleton.dart';
import '../../widgets/offline_cache_banner.dart';
import '../../widgets/data_load_error_banner.dart';
import '../explore/search_screen.dart';
import '../../widgets/sds_widgets.dart';
import '../../widgets/app_ui.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Timer _timer;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });

    // Simulate initial loading
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final data = context.watch<AppDataProvider>();
    final markets = data.markets;
    final openCount = data.stores
        .where((s) => s.status == StoreStatus.open)
        .length;
    final showSkeleton = _isLoading || (data.isLoading && markets.isEmpty);

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // ── Cinematic V16 Header (Asymmetric Overhaul) ──────
          SliverToBoxAdapter(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 320, // Reduced height for a tighter layout
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(SDS.radiusEpic),
                      bottomRight: Radius.circular(SDS.radiusEpic),
                    ),
                  ),
                ),

                // 3. Branded Content Column
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        // 3a. Branded Top Bar
                        Row(
                          children: [
                            const Text(
                              '시장여지도',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: SDS.fwBlack,
                                color: AppColors.textPrimary,
                                letterSpacing: -1.0,
                              ),
                            ),
                            const Spacer(),
                            _ActionIconBtn(
                              icon: Icons.notifications_none_rounded,
                              onTap: () => _showNotificationSheet(context),
                            ),
                          ],
                        ),
                        // 3b. Headline
                        const SizedBox(height: 40),
                        SDSFadeIn(
                          delay: const Duration(milliseconds: 300),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                text: const TextSpan(
                                  style: TextStyle(
                                    fontSize: 34,
                                    fontWeight: SDS.fwBlack,
                                    color: AppColors.textPrimary,
                                    height: 1.2,
                                    letterSpacing: -1.5,
                                  ),
                                  children: [
                                    TextSpan(text: '시장에 가고\n'),
                                    TextSpan(
                                      text: '싶을 때',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '가장 가까운 소식과 정겨운 풍경',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: SDS.fwBold,
                                  color: AppColors.textSecondary.withValues(
                                    alpha: 0.6,
                                  ),
                                  letterSpacing: -0.4,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // 3c. High-Fidelity Search Bar (Moved Below Headline)
                        SDSFadeIn(
                          delay: const Duration(milliseconds: 500),
                          offset: const Offset(0, 10),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: SDSGlass(
                              blur: 40,
                              opacity: 0.98,
                              radius: 24,
                              padding: const EdgeInsets.all(1),
                              child: Hero(
                                tag: 'search_bar',
                                child: Material(
                                  color: Colors.transparent,
                                  child: Semantics(
                                    label: 'home-search',
                                    button: true,
                                    excludeSemantics: true,
                                    child: ShrinkableButton(
                                      onTap: () {
                                        Navigator.of(context).push(
                                          PageRouteBuilder(
                                            transitionDuration: const Duration(
                                              milliseconds: 500,
                                            ),
                                            pageBuilder:
                                                (
                                                  context,
                                                  animation,
                                                  secondaryAnimation,
                                                ) => const SearchScreen(),
                                            transitionsBuilder:
                                                (
                                                  context,
                                                  animation,
                                                  secondaryAnimation,
                                                  child,
                                                ) {
                                                  return FadeTransition(
                                                    opacity: animation,
                                                    child: child,
                                                  );
                                                },
                                          ),
                                        );
                                      },
                                      child: Container(
                                        height: 60,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            24,
                                          ),
                                          color: Colors.white,
                                          border: Border.all(
                                            color: const Color(0xFFF2F4F6),
                                            width: 1.5,
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.search_rounded,
                                              color: AppColors.primary,
                                              size: 28,
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              '어느 시장이 궁금하세요?',
                                              style: TextStyle(
                                                color: AppColors.textSecondary,
                                                fontWeight: SDS.fwBold,
                                                fontSize: 16,
                                                letterSpacing: -0.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
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
          SliverToBoxAdapter(child: OfflineCacheBanner(data: data)),
          SliverToBoxAdapter(child: DataLoadErrorBanner(data: data)),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // ── Adorable 3D Categories ──────────────────────────
          const SliverToBoxAdapter(child: SizedBox(height: 8)),

          // ── Recommended Markets Section ───────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        '지금 추천하는 시장',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: SDS.fwBlack,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.8,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          '$openCount곳 영업중',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '실시간으로 활기찬 시장들을 모아봤어요',
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.textSecondary,
                      fontWeight: SDS.fwMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, bottomPadding + 100),
            sliver: showSkeleton
                ? SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => const Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: Skeleton(height: 180, borderRadius: 28),
                      ),
                      childCount: 3,
                    ),
                  )
                : markets.isEmpty
                ? SliverToBoxAdapter(
                    child: AppEmptyState(
                      icon: Icons.storefront_outlined,
                      title: '표시할 시장이 없어요',
                      description: data.errorMessage ??
                          '서버에서 시장 정보를 불러오지 못했습니다.',
                      actionLabel: '다시 불러오기',
                      onAction: data.isLoading ? null : () => data.refresh(),
                    ),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final market = markets[index];
                      return _PremiumMarketCard(market: market);
                    }, childCount: markets.length),
                  ),
          ),
        ],
      ),
    );
  }

  void _showNotificationSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _NotificationSettingsSheet(),
    );
  }
}

class _PremiumMarketCard extends StatelessWidget {
  final MarketInfo market;

  const _PremiumMarketCard({required this.market});

  @override
  Widget build(BuildContext context) {
    final isAvailable = market.isAvailable;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Semantics(
        label: 'home-market-card ${market.name}',
        button: isAvailable,
        child: ShrinkableButton(
          onTap: () {
            if (!isAvailable) return;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MarketHubScreen(marketName: market.name),
              ),
            );
          },
          child: Container(
            height: 180,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(SDS.radiusL),
              boxShadow: [
                BoxShadow(
                  color: (isAvailable ? market.accentColor : Colors.black)
                      .withValues(alpha: 0.08),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
              border: isAvailable
                  ? Border.all(
                      color: market.accentColor.withValues(alpha: 0.1),
                      width: 1.5,
                    )
                  : null,
            ),
            child: Stack(
              children: [
                // Background Gradient Accent
                if (isAvailable)
                  Positioned(
                    right: -40,
                    top: -40,
                    child: Container(
                      width: 160, // Increased from 100
                      height: 160,
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            market.accentColor.withValues(alpha: 0.1),
                            market.accentColor.withValues(alpha: 0.0),
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),

                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isAvailable
                                        ? AppColors.primary.withValues(
                                            alpha: 0.1,
                                          )
                                        : const Color(0xFFF2F4F6),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    isAvailable ? '운영중' : '준비중',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: SDS.fwBlack,
                                      color: isAvailable
                                          ? AppColors.primary
                                          : AppColors.textTertiary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    market.address,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                      fontWeight: SDS.fwBold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              market.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: SDS.fwBlack,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.8,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isAvailable
                                  ? market.description
                                  : '곧 서비스를 시작할 예정이에요',
                              style: const TextStyle(
                                fontSize: 15,
                                color: AppColors.textSecondary,
                                fontWeight: SDS.fwMedium,
                                height: 1.4,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F8FA),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.storefront_rounded,
                            color: isAvailable
                                ? market.accentColor
                                : AppColors.textTertiary,
                            size: 40,
                          ),
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
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: AppColors.textPrimary, size: 24),
      ),
    );
  }
}

class _NotificationSettingsSheet extends StatelessWidget {
  const _NotificationSettingsSheet();

  @override
  Widget build(BuildContext context) {
    final service = context.watch<NotificationService>();
    final preferences = service.preferences ?? const <String, dynamic>{};
    final firebaseStatus = service.firebaseAvailable
        ? service.permissionGranted
              ? '푸시 알림 수신 중'
              : '알림 권한이 필요해요'
        : 'Firebase 설정 대기 중';

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '알림 설정',
            style: TextStyle(
              fontSize: 22,
              fontWeight: SDS.fwBlack,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            firebaseStatus,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontWeight: SDS.fwBold,
            ),
          ),
          const SizedBox(height: 18),
          _NotificationSwitch(
            title: '즐겨찾기 특가 알림',
            value: preferences['dealAlerts'] != false,
            onChanged: (value) =>
                service.updatePreferences({'dealAlerts': value}),
          ),
          _NotificationSwitch(
            title: '예약/픽업 알림',
            value: preferences['reservationAlerts'] != false,
            onChanged: (value) =>
                service.updatePreferences({'reservationAlerts': value}),
          ),
          _NotificationSwitch(
            title: '상인 예약 알림',
            value: preferences['merchantAlerts'] != false,
            onChanged: (value) =>
                service.updatePreferences({'merchantAlerts': value}),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: service.syncAfterLogin,
              icon: const Icon(Icons.notifications_active_rounded),
              label: const Text('알림 권한 다시 확인'),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationSwitch extends StatelessWidget {
  const _NotificationSwitch({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile.adaptive(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: SDS.fwBold,
          color: AppColors.textPrimary,
        ),
      ),
      value: value,
      onChanged: onChanged,
    );
  }
}
