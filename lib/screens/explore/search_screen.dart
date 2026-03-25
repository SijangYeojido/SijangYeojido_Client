import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../data/mock_data.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_ui.dart';
import '../../widgets/shrinkable_button.dart';
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
  List<Store> _results = [];
  bool _hasStartedTyped = false;
  
  // Real history would use shared_preferences
  final List<String> _recentSearches = ['수산시장', '떡볶이', '축산'];

  void _onSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _results = [];
        _hasStartedTyped = false;
      });
      return;
    }

    final queryLower = query.toLowerCase();
    final allStores = MockData.stores;
    setState(() {
      _results = allStores.where((s) => 
        s.name.toLowerCase().contains(queryLower) ||
        s.category.toLowerCase().contains(queryLower) ||
        s.items.any((i) => i.name.toLowerCase().contains(queryLower))
      ).toList();
      _hasStartedTyped = true;
    });
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
                        border: Border.all(color: Colors.white.withValues(alpha: 0.8), width: 1.5),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: TextField(
                        controller: _searchController,
                        autofocus: true,
                        onChanged: _onSearch,
                        decoration: InputDecoration(
                          hintText: '가게 이름 또는 시장 테마 검색',
                          hintStyle: TextStyle(
                            color: AppColors.textTertiary,
                            fontWeight: SDS.fwBold,
                            fontSize: 16,
                          ),
                          prefixIcon: ShaderMask(
                            shaderCallback: (bounds) => AppColors.primaryGradient.createShader(bounds),
                            child: const Icon(Icons.search_rounded, color: Colors.white, size: 28),
                          ),
                          suffixIcon: _searchController.text.isNotEmpty 
                            ? IconButton(
                                icon: const Icon(Icons.cancel_rounded, color: AppColors.textTertiary),
                                onPressed: () {
                                  _searchController.clear();
                                  _onSearch('');
                                },
                              )
                            : null,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,  // Explicitly remove default borders
                          focusedBorder: InputBorder.none,  // Explicitly remove focus border
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 22),
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
                const Icon(Icons.storefront_rounded, color: AppColors.primary, size: 20),
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
    if (_results.isEmpty) {
      return AppEmptyState(
        icon: Icons.search_off_rounded,
        title: '검색 결과가 없어요',
        description: '오타를 확인하시거나\n다른 검색어로 다시 검색해 보세요',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _results.length,
      separatorBuilder: (context, index) => const SizedBox(height: 2),
      itemBuilder: (context, index) {
        final store = _results[index];
        return SDS.listRow(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          leading: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(SDS.radiusS),
            ),
            child: Icon(_iconForCategory(store.category), color: AppColors.primary, size: 24),
          ),
          title: Text(store.name),
          subtitle: Text('${store.category} · ${store.zoneId}구역'),
          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textTertiary),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => StoreDetailScreen(store: store)),
            );
          },
        );
      },
    );
  }

  IconData _iconForCategory(String category) {
    if (category.contains('먹거리')) return Icons.restaurant_rounded;
    if (category.contains('수산')) return Icons.set_meal_rounded;
    if (category.contains('정육')) return Icons.kebab_dining_rounded;
    if (category.contains('과일') || category.contains('채소')) return Icons.eco_rounded;
    return Icons.storefront_rounded;
  }
}
