import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/mock_data.dart';
import '../../models/models.dart';
import '../../providers/app_data_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_ui.dart';
import '../../widgets/shrinkable_button.dart';
import '../map/market_hub_screen.dart';
import '../map/store_detail_screen.dart';
import '../../theme/sijang_design_system.dart';
import '../../widgets/sds_widgets.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<MarketInfo> _marketResults = [];
  List<Store> _storeResults = [];
  bool _hasStartedTyped = false;

  // Real history would use shared_preferences
  final List<String> _recentSearches = ['승인시연상회', '신원시장', '관악구', '떡볶이'];

  void _onSearch(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      setState(() {
        _marketResults = [];
        _storeResults = [];
        _hasStartedTyped = false;
      });
      return;
    }

    final data = context.read<AppDataProvider>();
    setState(() {
      _marketResults = data.searchMarkets(trimmed);
      _storeResults = data.searchStores(trimmed);
      _hasStartedTyped = true;
    });
    data.recordAction('search.query', metadata: {'keyword': trimmed});
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          SDS.topBar(
            context: context,
            title: '시장 검색',
            subtitle: '찾으시는 시장 또는 가게를 입력해 주세요',
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Hero(
              tag: 'search_bar',
              child: Material(
                color: Colors.transparent,
                child: Container(
                  height: 72,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: SDSGlass(
                    blur: 20,
                    opacity: 0.9,
                    radius: 32,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(32),
                        color: Colors.white.withValues(alpha: 0.6),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.8),
                          width: 1.5,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Semantics(
                        label: 'global-search-field',
                        textField: true,
                        child: TextField(
                          controller: _searchController,
                          autofocus: true,
                          onChanged: _onSearch,
                          decoration: InputDecoration(
                            hintText: '시장명, 지역, 점포명, 품목 검색',
                            hintStyle: TextStyle(
                              color: AppColors.textTertiary,
                              fontWeight: SDS.fwBold,
                              fontSize: 16,
                            ),
                            prefixIcon: ShaderMask(
                              shaderCallback: (bounds) => AppColors
                                  .primaryGradient
                                  .createShader(bounds),
                              child: const Icon(
                                Icons.search_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(
                                      Icons.cancel_rounded,
                                      color: AppColors.textTertiary,
                                    ),
                                    onPressed: () {
                                      _searchController.clear();
                                      _onSearch('');
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 22,
                            ),
                          ),
                          style: TextStyle(
                            fontWeight: SDS.fwBlack,
                            color: AppColors.textPrimary,
                            fontSize: 17,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: _hasStartedTyped
                ? _buildSearchResults()
                : _buildSearchHome(textTheme),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchHome(TextTheme textTheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24), // Reduced top padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12), // Small initial gap
          Text(
            '최근 검색어',
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12), // Reduced from 16
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _recentSearches.map((s) => _buildRecentChip(s)).toList(),
          ),
          const SizedBox(height: 32), // Reduced from 48
          Text(
            '인기 카테고리',
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12), // Reduced from 16
          _buildCategoryList(textTheme),
        ],
      ),
    );
  }

  Widget _buildRecentChip(String text) {
    return ShrinkableButton(
      onTap: () {
        _searchController.text = text;
        _onSearch(text);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryList(TextTheme textTheme) {
    final categories = ['먹거리', '정육/수산', '과일/채소', '건어물/양념'];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 2.5,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        return ShrinkableButton(
          onTap: () => _onSearch(categories[index]),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(
                  Icons.storefront_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Text(
                  categories[index],
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchResults() {
    if (_marketResults.isEmpty && _storeResults.isEmpty) {
      return AppEmptyState(
        icon: Icons.search_off_rounded,
        title: '검색 결과가 없어요',
        description: '오타를 확인하시거나\n다른 검색어로 다시 검색해 보세요',
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        if (_marketResults.isNotEmpty) ...[
          _ResultSectionTitle(title: '시장 검색 결과', count: _marketResults.length),
          const SizedBox(height: 8),
          ..._marketResults.asMap().entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _MarketResultRow(
                market: entry.value,
                index: entry.key,
                onTap: () {
                  context.read<AppDataProvider>().recordAction(
                    'search.market.select',
                    metadata: {'marketName': entry.value.name},
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          MarketHubScreen(marketName: entry.value.name),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
        if (_storeResults.isNotEmpty) ...[
          _ResultSectionTitle(title: '점포 검색 결과', count: _storeResults.length),
          const SizedBox(height: 8),
          ..._storeResults.asMap().entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: _StoreResultRow(
                store: entry.value,
                index: entry.key,
                icon: _iconForCategory(entry.value.category),
                onTap: () {
                  context.read<AppDataProvider>().recordAction(
                    'search.store.select',
                    metadata: {'storeId': entry.value.id},
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => StoreDetailScreen(store: entry.value),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ],
    );
  }

  IconData _iconForCategory(String category) {
    if (category.contains('먹거리')) return Icons.restaurant_rounded;
    if (category.contains('수산')) return Icons.set_meal_rounded;
    if (category.contains('정육')) return Icons.kebab_dining_rounded;
    if (category.contains('과일') || category.contains('채소')) {
      return Icons.eco_rounded;
    }
    return Icons.storefront_rounded;
  }
}

class _ResultSectionTitle extends StatelessWidget {
  const _ResultSectionTitle({required this.title, required this.count});

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: SDS.fwBlack,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$count건',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: SDS.fwBold,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _MarketResultRow extends StatelessWidget {
  const _MarketResultRow({
    required this.market,
    required this.index,
    required this.onTap,
  });

  final MarketInfo market;
  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'market-result-$index',
      button: true,
      excludeSemantics: true,
      child: SDS.listRow(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        leading: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: market.accentColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(SDS.radiusS),
          ),
          child: Icon(
            Icons.store_mall_directory_rounded,
            color: market.accentColor,
            size: 24,
          ),
        ),
        title: Text(market.name),
        subtitle: Text('${market.address} · ${market.storeCount}개 점포'),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          size: 14,
          color: AppColors.textTertiary,
        ),
        onTap: onTap,
      ),
    );
  }
}

class _StoreResultRow extends StatelessWidget {
  const _StoreResultRow({
    required this.store,
    required this.index,
    required this.icon,
    required this.onTap,
  });

  final Store store;
  final int index;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'store-result-$index',
      button: true,
      excludeSemantics: true,
      child: SDS.listRow(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(SDS.radiusS),
          ),
          child: Icon(icon, color: AppColors.primary, size: 24),
        ),
        title: Text(store.name),
        subtitle: Text(
          '${store.marketName} · ${store.category} · ${store.zoneId}구역',
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          size: 14,
          color: AppColors.textTertiary,
        ),
        onTap: onTap,
      ),
    );
  }
}
