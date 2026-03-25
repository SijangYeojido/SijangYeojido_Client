import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../data/mock_data.dart';
import '../../theme/app_colors.dart';
import '../../theme/sijang_design_system.dart';
import '../../widgets/shrinkable_button.dart';
import 'store_detail_screen.dart';
import '../market/market_info_screen.dart';
import '../market/market_map_simple_screen.dart';
import '../market/market_parking_screen.dart';
import '../../widgets/sds_widgets.dart';

class MarketHubScreen extends StatefulWidget {
  final String marketName;
  const MarketHubScreen({super.key, this.marketName = '신원시장'});

  @override
  State<MarketHubScreen> createState() => _MarketHubScreenState();
}

class _MarketHubScreenState extends State<MarketHubScreen> {
  String _selectedCategory = '전체';
  static const _categories = ['전체', '먹거리', '정육', '수산물', '과일/채소', '건어물', '기타'];

  List<Store> get _filteredStores {
    return MockData.stores.where((s) {
      if (_selectedCategory != '전체' && !s.category.contains(_selectedCategory)) return false;
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final market = MockData.getMarket(widget.marketName);

    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── 1. Immersive Cinematic Hero Header ─────────────────────
          SliverAppBar(
            expandedHeight: 380,
            pinned: true,
            stretch: true,
            elevation: 0,
            backgroundColor: market.accentColor,
            leading: ShrinkableButton(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.white),
              ),
            ),
            actions: [
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: _HeroActionChip(
                    label: '영업 중',
                    color: AppColors.success,
                  ),
                ),
              ),
              const SizedBox(width: 16),
            ],
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground, StretchMode.blurBackground],
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Primary Cinematic Gradient Area
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            market.accentColor,
                            market.accentColor.withValues(alpha: 0.85),
                            market.accentColor.withValues(alpha: 0.4),
                            AppColors.background,
                          ],
                          stops: const [0.0, 0.35, 0.65, 1.0],
                        ),
                      ),
                    ),
                  ),
                  // Traditional Pattern (Subtle & Elegant)
                  Positioned.fill(
                    bottom: 100,
                    child: Opacity(
                      opacity: 0.08,
                      child: CustomPaint(painter: _TraditionalPatternPainter()),
                    ),
                  ),
                  // Content Overlay
                  Positioned(
                    top: 130,
                    left: 24,
                    right: 24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SDSFadeIn(
                          delay: const Duration(milliseconds: 200),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(SDS.radiusCapsule),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.stars_rounded, size: 14, color: Colors.white.withValues(alpha: 0.9)),
                                const SizedBox(width: 8),
                                const Text(
                                  '대한민국 대표 전통시장',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: SDS.fwBold,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SDSFadeIn(
                          delay: const Duration(milliseconds: 400),
                          child: Text(
                            widget.marketName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 56,
                              fontWeight: SDS.fwBlack,
                              letterSpacing: SDS.lsTight,
                              height: 1.0,
                              shadows: [
                                Shadow(color: Colors.black12, blurRadius: 30, offset: Offset(0, 15)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // ── Integrated Action Palette (Glassmorphic Floating Bar) ──
                  Positioned(
                    bottom: 24,
                    left: 20,
                    right: 20,
                    child: SDSFadeIn(
                      delay: const Duration(milliseconds: 600),
                      child: SDSGlass(
                        blur: 32,
                        opacity: 0.9,
                        radius: 32,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _CircularActionButton(
                              icon: Icons.map_rounded,
                              label: '시장 지도',
                              color: const Color(0xFF00C896), // Shinwon/Toss Green
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => MarketMapSimpleScreen(marketName: widget.marketName),
                                  ),
                                );
                              },
                            ),
                            _CircularActionButton(
                              icon: Icons.local_parking_rounded,
                              label: '주차 안내',
                              color: const Color(0xFF3182F6), // Toss Blue
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => MarketParkingScreen(marketName: widget.marketName),
                                  ),
                                );
                              },
                            ),
                            _CircularActionButton(
                              icon: Icons.info_outline_rounded,
                              label: '시장 정보',
                              color: const Color(0xFF191F28), // Deep Graphite
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => MarketInfoScreen(marketName: widget.marketName),
                                  ),
                                );
                              },
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

          // ── 2. Premium Insight Card Section ──────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: SDSFadeIn(
                delay: const Duration(milliseconds: 800),
                child: Container(
                  padding: const EdgeInsets.all(SDS.space24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(SDS.radiusL),
                    boxShadow: SDS.shadowSoft,
                    border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
                  ),
                  child: Column(
                    children: [
                      // Address Bar
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: market.accentColor.withValues(alpha: 0.08),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.near_me_rounded, size: 16, color: market.accentColor),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  market.address,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: SDS.fwBold,
                                    color: AppColors.textPrimary,
                                    letterSpacing: SDS.lsTight,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '현재 위치에서 1.2km', // Mock distance
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: SDS.fwMedium,
                                    color: AppColors.textTertiary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right_rounded, size: 24, color: AppColors.textTertiary.withValues(alpha: 0.5)),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: SDS.space24),
                        child: Divider(color: AppColors.divider, height: 1, thickness: 1),
                      ),
                      // Stats Grid
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: _StatItem(label: '총 점포 수', value: '${MockData.stores.length}', icon: Icons.storefront_rounded)),
                          Container(width: 1, height: 32, color: AppColors.divider),
                          Expanded(
                            child: _StatItem(
                              label: '방문객 점수', 
                              value: '4.8', 
                              icon: Icons.star_rounded, 
                              color: AppColors.warning
                            ),
                          ),
                          Container(width: 1, height: 32, color: AppColors.divider),
                          Expanded(child: _StatItem(label: '인기 품목', value: '육회, 빈대떡', icon: Icons.auto_awesome_rounded, color: AppColors.accent)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── 3. Sticky Category Selector ─────────────────────────
          SliverPersistentHeader(
            pinned: true,
            delegate: _StickyCategoryDelegate(
              categories: _categories,
              selectedCategory: _selectedCategory,
              onSelected: (cat) => setState(() => _selectedCategory = cat),
            ),
          ),

          // ── 4. Premium Store Feed ────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final store = _filteredStores[index];
                  return SDSFadeIn(
                    delay: Duration(milliseconds: 100 * (index % 5)),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _StoreFeedCard(store: store),
                    ),
                  );
                },
                childCount: _filteredStores.length,
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

// ── Supporting Components ──────────────────────────────────────────

class _TraditionalPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    const spacing = 48.0;
    for (double x = 0; x < size.width + spacing; x += spacing) {
      for (double y = 0; y < size.height + spacing; y += spacing) {
        final offset = Offset(x + (y / spacing % 2 == 0 ? 0 : spacing / 2), y);
        canvas.drawCircle(offset, 12, paint);
        canvas.drawCircle(offset, 3, paint..strokeWidth = 0.5);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _HeroActionChip extends StatelessWidget {
  final String label;
  final Color color;

  const _HeroActionChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(100),
        boxShadow: SDS.shadowSoft,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(fontSize: 12, fontWeight: SDS.fwBlack, color: color),
          ),
        ],
      ),
    );
  }
}

class _CircularActionButton extends StatelessWidget {
  final IconData? icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _CircularActionButton({
    this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final btnSize = (screenWidth - 88) / 4;
    final clampedSize = btnSize.clamp(48.0, 64.0);

    return ShrinkableButton(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: clampedSize,
            height: clampedSize,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(clampedSize * 0.34),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Icon(icon, size: clampedSize * 0.44, color: color),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: SDS.fwBold,
              color: AppColors.textPrimary,
              letterSpacing: -0.4,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 22, color: color ?? AppColors.textTertiary),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: SDS.fwBlack,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: SDS.fwMedium,
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }
}


class _StickyCategoryDelegate extends SliverPersistentHeaderDelegate {
  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String> onSelected;

  _StickyCategoryDelegate({
    required this.categories,
    required this.selectedCategory,
    required this.onSelected,
  });

  @override
  double get minExtent => 140.0; // Increased to 140 to prevent internal overflows
  @override
  double get maxExtent => 140.0;

  String _assetForCategory(String category) {
    if (category == '전체') return 'assets/images/market_building.png';
    if (category == '먹거리') return 'assets/images/category_meal_3d.png';
    if (category == '정육') return 'assets/images/category_meat_3d_cute.png';
    if (category == '수산물') return 'assets/images/category_fish_3d_cute.png';
    if (category == '과일/채소') return 'assets/images/category_veggie_3d_cute.png';
    if (category == '건어물') return 'assets/images/category_dried_fish_3d.png';
    return 'assets/images/category_etc_3d.png';
  }

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.background.withValues(alpha: 0.98),
      alignment: Alignment.centerLeft,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 0), // SDSCategoryItem handles padding
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = cat == selectedCategory;
          return SDSCategoryItem(
            label: cat,
            assetPath: _assetForCategory(cat),
            isSelected: isSelected,
            onTap: () => onSelected(cat),
          );
        },
      ),
    );
  }

  @override
  bool shouldRebuild(_StickyCategoryDelegate oldDelegate) {
    return selectedCategory != oldDelegate.selectedCategory ||
           categories != oldDelegate.categories;
  }
}

class _StoreFeedCard extends StatelessWidget {
  final Store store;
  const _StoreFeedCard({required this.store});

  @override
  Widget build(BuildContext context) {
    return ShrinkableButton(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => StoreDetailScreen(store: store)),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(SDS.space18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(SDS.radiusL),
          boxShadow: SDS.shadowPremium,
          border: Border.all(color: AppColors.divider.withValues(alpha: 0.3)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'store_image_${store.id}',
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(SDS.radiusM),
                  boxShadow: SDS.shadowSoft,
                ),
                child: PremiumPlaceholder(
                  category: store.category,
                  width: 84,
                  height: 84,
                  borderRadius: SDS.radiusM,
                ),
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          store.name,
                          style: const TextStyle(
                            fontWeight: SDS.fwBlack, 
                            fontSize: 19, 
                            letterSpacing: SDS.lsTight,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      _SmallStatusChip(status: store.status),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.divider.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${store.zoneId}구역',
                          style: const TextStyle(fontSize: 11, fontWeight: SDS.fwBold, color: AppColors.textSecondary),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        store.category,
                        style: const TextStyle(fontSize: 12, fontWeight: SDS.fwMedium, color: AppColors.textTertiary),
                      ),
                      const Spacer(),
                      if (store.freshness != null) ...[
                        Icon(Icons.auto_awesome_rounded, size: 12, color: AppColors.accent),
                        const SizedBox(width: 4),
                        Text(
                          '신선도 ${store.freshness}%',
                          style: TextStyle(fontSize: 11, fontWeight: SDS.fwBold, color: AppColors.accent),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 14),
                  if (store.items.isNotEmpty || store.inventoryStatus != null)
                    Row(
                      children: [
                        if (store.items.isNotEmpty)
                          Expanded(
                            child: Row(
                              children: [
                                Icon(Icons.shopping_bag_outlined, size: 14, color: AppColors.textTertiary),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    store.items.first.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 13, fontWeight: SDS.fwMedium, color: AppColors.textSecondary),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (store.inventoryStatus != null)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: store.inventoryStatus == '여유' ? AppColors.success.withValues(alpha: 0.1) : AppColors.danger.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(SDS.radiusCapsule),
                            ),
                            child: Text(
                              store.inventoryStatus!,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: SDS.fwBlack,
                                color: store.inventoryStatus == '여유' ? AppColors.success : AppColors.danger,
                              ),
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SmallStatusChip extends StatelessWidget {
  final StoreStatus status;
  const _SmallStatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: status.bgColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: status.color.withValues(alpha: 0.2)),
      ),
      child: Text(
        status == StoreStatus.open ? 'OPEN' : 'CLOSED',
        style: TextStyle(
          fontSize: 9,
          fontWeight: SDS.fwBlack,
          color: status.color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
