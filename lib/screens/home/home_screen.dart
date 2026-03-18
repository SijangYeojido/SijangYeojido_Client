import 'dart:async';
import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../models/models.dart';
import '../../theme/app_colors.dart';
import '../../theme/sijang_design_system.dart';
import '../../widgets/shrinkable_button.dart';
import 'package:sijangyeojido_client/screens/map/market_hub_screen.dart';
import '../../widgets/skeleton.dart';
import '../explore/search_screen.dart';
import '../../services/favorite_service.dart';
import '../map/store_detail_screen.dart';
import '../../widgets/market_stories.dart';
import '../../widgets/flash_deal_ticker.dart';

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
    final textTheme = Theme.of(context).textTheme;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final openCount =
        MockData.stores.where((s) => s.status == StoreStatus.open).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── Search Bar (Top) ──────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              color: AppColors.surface,
              padding: const EdgeInsets.fromLTRB(20, 64, 20, 12),
              child: ShrinkableButton(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SearchScreen()),
                  );
                },
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      const Icon(Icons.search_rounded,
                          color: AppColors.primary, size: 24),
                      const SizedBox(width: 12),
                      Text(
                        '가게, 품목, 구역 검색',
                        style: textTheme.bodyLarge?.copyWith(
                          color: AppColors.textTertiary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Cinematic Storytelling Header (V7) ───────────────────
          SliverToBoxAdapter(
            child: Container(
              height: 420,
              color: AppColors.surface,
              child: Stack(
                children: [
                    // Dynamic Narrative Image (V7.1 Platform Branding)
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 1.1, end: 1.0),
                      duration: SDS.durationSlow,
                      curve: SDS.curveEntrance,
                      builder: (context, scale, child) {
                        return Transform.scale(
                          scale: scale,
                          child: Container(
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage('https://images.unsplash.com/photo-1543007630-9710e4a00a20?auto=format&fit=crop&q=80&w=1500'), // Premium Market Map Aesthetic
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    // Sophisticated Gradient Overlay (Optimized for Legibility)
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.6), // Dark top for status bar
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.7), // Stronger dark background for text
                              AppColors.surface,                   // Transition to content surface
                            ],
                            stops: const [0.0, 0.35, 0.85, 1.0],
                        ),
                      ),
                    ),
                    // Narrative Content
                    Positioned(
                      left: SDS.gutter,
                      right: SDS.gutter,
                      bottom: SDS.spaceXL,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: SDS.glassDecoration(opacity: 0.5, blur: 16), // Thicker glass for contrast
                            child: Text(
                              '전통과 디지털의 만남 🗺️',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textPrimary, // High-contrast dark text on light glass
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            '전통시장의 새로운 지도,\n시장여지도로 시작하세요',
                            style: TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -1.8,
                              height: 1.15,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.6), // Stronger shadow for title
                                  blurRadius: 15,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: SDS.spaceL),
                          Text(
                            '어느 시장을 찾고 계신가요? 👋',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),

          // ── V8 Dynamic Commerce (Flash Deal Ticker) ─────────────
          const SliverToBoxAdapter(child: FlashDealTickerWidget()),

          // ── V8 Social Layer (Market Stories) ────────────────────
          const SliverPadding(
            padding: EdgeInsets.only(top: SDS.spaceL, bottom: SDS.spaceL),
            sliver: SliverToBoxAdapter(child: MarketStoriesWidget()),
          ),



          // ── Favorites Section ──────────────────────────────────
          SliverToBoxAdapter(
            child: ListenableBuilder(
              listenable: FavoriteService(),
              builder: (context, _) {
                final favIds = FavoriteService().favoriteIds;
                if (favIds.isEmpty) return const SizedBox.shrink();

                final favStores = MockData.stores
                    .where((s) => favIds.contains(s.id))
                    .toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
                      child: Row(
                        children: [
                          const Icon(Icons.favorite_rounded,
                              color: Colors.redAccent, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            '나의 단골집',
                            style: textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 140,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        scrollDirection: Axis.horizontal,
                        itemCount: favStores.length,
                        itemBuilder: (context, index) {
                          final store = favStores[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: ShrinkableButton(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => StoreDetailScreen(store: store),
                                  ),
                                );
                              },
                              child: Container(
                                width: 140,
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.03),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: AppColors.background,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.storefront_rounded,
                                        color: AppColors.primary,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      store.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),


          // ── Market Section ─────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '지금,\n전통시장을 활짝 열어보세요 🎞️',
                          style: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                            height: 1.25,
                            letterSpacing: -1.0,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '터치해서 실내 지도를 펼쳐보세요',
                          style: textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '$openCount곳 영업 중',
                          style: textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: EdgeInsets.fromLTRB(20, 12, 20, bottomPadding + 100),
            sliver: _isLoading 
                ? SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => const Padding(
                        padding: EdgeInsets.only(bottom: 14),
                        child: Skeleton(height: 160, borderRadius: 28),
                      ),
                      childCount: 3,
                    ),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final market = MockData.markets[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _MarketCard(
                            market: market,
                            openStoreCount: market.isAvailable ? openCount : 0,
                          ),
                        );
                      },
                      childCount: MockData.markets.length,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _MarketCard extends StatelessWidget {
  final MarketInfo market;
  final int openStoreCount;

  const _MarketCard({
    required this.market,
    required this.openStoreCount,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ShrinkableButton(
      onTap: () {
        if (!market.isAvailable) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MarketHubScreen(marketName: market.name),
          ),
        );
      },
      shrinkScale: 0.96,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(26),
        decoration: BoxDecoration(
          color: market.isAvailable ? AppColors.surface : AppColors.surface.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(SDS.radiusL),
          border: Border.all(
            color: market.isAvailable 
                ? market.accentColor.withValues(alpha: 0.18) 
                : AppColors.border.withValues(alpha: 0.5),
            width: 1.8,
          ),
          boxShadow: market.isAvailable 
              ? SDS.shadowAccent(market.accentColor)
              : SDS.shadowSoft,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          market.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: market.isAvailable
                                ? AppColors.textPrimary
                                : AppColors.textTertiary,
                            letterSpacing: -1.0,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (market.isAvailable)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                market.accentColor,
                                market.accentColor.withValues(alpha: 0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: market.accentColor.withValues(alpha: 0.25),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Text(
                            'MAP',
                            style: textTheme.labelSmall?.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    market.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: market.isAvailable
                          ? AppColors.textSecondary
                          : AppColors.textTertiary,
                      height: 1.5,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (market.isAvailable) ...[
                    Row(
                      children: [
                        _MiniStat(
                          icon: Icons.storefront_rounded,
                          label: '$openStoreCount개 매장 운영 중',
                          color: AppColors.success,
                        ),
                        const SizedBox(width: 12),
                        _MiniStat(
                          icon: Icons.location_on_rounded,
                          label: '실시간 지도 지원',
                          color: market.accentColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: market.highlights.map((h) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: market.isAvailable
                              ? AppColors.background
                              : AppColors.background.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            color: AppColors.border.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          '#$h',
                          style: textTheme.labelLarge?.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: market.isAvailable
                                ? AppColors.textSecondary
                                : AppColors.textTertiary,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            if (market.isAvailable)
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.chevron_right_rounded,
                    color: AppColors.textPrimary, size: 28),
              )
            else
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
                ),
                child: Text(
                  '준비 중',
                  style: textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _MiniStat({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}

