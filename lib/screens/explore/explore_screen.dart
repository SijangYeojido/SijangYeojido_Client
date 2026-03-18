import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../models/models.dart';
import '../../data/mock_data.dart';

import '../map/store_detail_screen.dart';
import '../../widgets/premium_placeholder.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final _searchController = TextEditingController();
  String _selectedCategory = '전체';
  String _searchQuery = '';

  final List<String> _categories = ['전체', '먹거리', '생선/해산물', '청과/야채', '포목/직물'];

  List<Store> get _filteredStores {
    var stores = MockData.stores;
    if (_selectedCategory != '전체') {
      stores = stores.where((s) => s.category == _selectedCategory).toList();
    }
    if (_searchQuery.isNotEmpty) {
      stores = stores
          .where((s) =>
              s.name.contains(_searchQuery) ||
              s.category.contains(_searchQuery) ||
              s.items.any((i) => i.name.contains(_searchQuery)))
          .toList();
    }
    return stores;
  }



  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          _buildSearchBar(),
          _buildCategoryChips(),

          _buildStoresSection(),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      floating: true,
      backgroundColor: AppColors.background,
      elevation: 0,
      centerTitle: false,
      title: const Text(
        '탐색',
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (v) => setState(() => _searchQuery = v),
            style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: '점포명, 품목으로 검색',
              hintStyle: const TextStyle(
                fontSize: 15,
                color: AppColors.textTertiary,
              ),
              prefixIcon: const Icon(
                Icons.search,
                color: AppColors.textTertiary,
                size: 20,
              ),
              suffixIcon: _searchQuery.isNotEmpty
                  ? GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                      child: const Icon(
                        Icons.close,
                        color: AppColors.textTertiary,
                        size: 18,
                      ),
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 40,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _categories.length,
          itemBuilder: (context, i) {
            final cat = _categories[i];
            final selected = _selectedCategory == cat;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => setState(() => _selectedCategory = cat),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primary : AppColors.surface,
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(
                      color: selected ? AppColors.primary : AppColors.border,
                    ),
                  ),
                  child: Text(
                    cat,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }



  Widget _buildStoresSection() {
    final stores = _filteredStores;

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: Row(
                children: [
                  Text(
                    _searchQuery.isNotEmpty ? '검색 결과' : '시장 점포',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${stores.length}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            );
          }
          if (stores.isEmpty) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.search_off, size: 48, color: AppColors.textTertiary),
                    SizedBox(height: 12),
                    Text(
                      '검색 결과가 없어요',
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          final store = stores[index - 1];
          return _StoreListItem(
            store: store,
            onTap: () => _openStore(store),
          );
        },
        childCount: stores.isEmpty ? 2 : stores.length + 1,
      ),
    );
  }



  void _openStore(Store store) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StoreDetailScreen(store: store),
      ),
    );
  }
}



class _StoreListItem extends StatelessWidget {
  final Store store;
  final VoidCallback onTap;

  const _StoreListItem({required this.store, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.border,
            width: 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x06000000),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Hero(
                  tag: 'store_image_${store.id}',
                  child: PremiumPlaceholder(
                    category: store.category,
                    width: 48,
                    height: 48,
                    borderRadius: 10,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            store.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _StatusBadge(status: store.status),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${store.zoneId}구역',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            store.category,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (store.items.isNotEmpty) ...[
              const SizedBox(height: 10),
              const Divider(height: 1, color: AppColors.divider),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: store.items.take(3).map((item) {
                  return Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  );
                }).toList(),
              ),
            ],

          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final StoreStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: status.bgColor,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: status.color,
        ),
      ),
    );
  }
}
