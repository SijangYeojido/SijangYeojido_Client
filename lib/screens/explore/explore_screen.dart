import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/sijang_design_system.dart';
import '../../models/models.dart';
import '../../data/mock_data.dart';

import '../map/store_detail_screen.dart';
import '../../widgets/sds_widgets.dart';


class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  String _selectedCategory = '전체';
  final List<String> _categories = ['전체', '먹거리', '생선/해산물', '청과/야채', '포목/직물'];

  List<Store> get _filteredStores {
    var stores = MockData.stores;
    if (_selectedCategory != '전체') {
      stores = stores.where((s) => s.category == _selectedCategory).toList();
    }
    return stores;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildHeroHeader(),
          _buildFloatingSearchBar(),
          _buildCategoryFilters(),
          _buildStoresGrid(),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildHeroHeader() {
    return SliverAppBar(
      expandedHeight: 280,
      backgroundColor: AppColors.cinematicDeep,
      collapsedHeight: 0,
      toolbarHeight: 0,
      pinned: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.file(
              File('/Users/bagjun-won/.gemini/antigravity/brain/673c5789-358e-4d47-abc7-c24556e62ea4/traditional_market_hero_1773854073585.png'),
              fit: BoxFit.cover,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.1),
                    Colors.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 24,
              bottom: 48,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '전통시장 지도 탐험',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: SDS.fwBlack,
                      color: Colors.white,
                      letterSpacing: SDS.lsTight,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.auto_awesome, size: 16, color: AppColors.cinematicGold),
                      const SizedBox(width: 6),
                      Text(
                        '오늘의 가장 신선한 이야기가 기다려요',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: SDS.fwBold,
                          color: Colors.white.withValues(alpha: 0.8),
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

  Widget _buildFloatingSearchBar() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _GlassSearchDelegate(),
    );
  }

  Widget _buildCategoryFilters() {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: _categories.map((cat) {
              final isSelected = _selectedCategory == cat;
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat),
                  child: AnimatedContainer(
                    duration: SDS.durationFast,
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.cinematicDeep : AppColors.surface,
                      borderRadius: BorderRadius.circular(SDS.radiusCapsule),
                      boxShadow: isSelected ? SDS.shadowSoft : null,
                      border: Border.all(
                        color: isSelected ? AppColors.cinematicDeep : AppColors.divider,
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      cat,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: SDS.fwBold,
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                        letterSpacing: SDS.lsNormal,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildStoresGrid() {
    final stores = _filteredStores;
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: _StoreEpicCard(
              store: stores[index],
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => StoreDetailScreen(store: stores[index]),
                ),
              ),
            ),
          ),
          childCount: stores.length,
        ),
      ),
    );
  }
}

class _GlassSearchDelegate extends SliverPersistentHeaderDelegate {
  @override
  double get minExtent => 88;
  @override
  double get maxExtent => 88;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.85),
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            height: 56,
            decoration: SDS.glassDecoration(
              radius: SDS.radiusM,
              opacity: 0.5,
              color: Colors.white,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              children: [
                const Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 24),
                const SizedBox(width: 14),
                Text(
                  '어떤 가게를 찾아볼까요?',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: SDS.fwSemiBold,
                    color: AppColors.textTertiary,
                    letterSpacing: SDS.lsNormal,
                  ),
                ),
                const Spacer(),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.cinematicDeep.withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.tune_rounded, size: 18, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => false;
}

class _StoreEpicCard extends StatelessWidget {
  final Store store;
  final VoidCallback onTap;

  const _StoreEpicCard({required this.store, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SDS.epicCard(
      child: InkWell(
        onTap: onTap,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Hero(
                tag: 'store_image_${store.id}',
                child: PremiumPlaceholder(
                  category: store.category,
                  width: 120,
                  height: 140,
                  borderRadius: 0,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(SDS.radiusS),
                            ),
                            child: Text(
                              store.category,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: SDS.fwBold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const Spacer(),
                          const Icon(Icons.star_rounded, size: 16, color: AppColors.cinematicGold),
                          const SizedBox(width: 4),
                          Text(
                            '4.8',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: SDS.fwBold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        store.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: SDS.fwBlack,
                          color: AppColors.textPrimary,
                          letterSpacing: SDS.lsTight,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${store.zoneId}구역 · 장터의 명물',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: SDS.fwMedium,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Icon(Icons.location_on_rounded, size: 14, color: AppColors.textTertiary),
                          const SizedBox(width: 4),
                          Text(
                            '여기서 120m',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: SDS.fwBold,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
