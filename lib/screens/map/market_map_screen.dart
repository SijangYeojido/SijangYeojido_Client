import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../data/mock_data.dart';
import '../../theme/app_colors.dart';
import 'market_painter.dart';
import 'store_detail_screen.dart';

class MarketMapScreen extends StatefulWidget {
  final String marketName;
  const MarketMapScreen({super.key, this.marketName = '광장시장'});

  @override
  State<MarketMapScreen> createState() => _MarketMapScreenState();
}

class _MarketMapScreenState extends State<MarketMapScreen> {
  String? _selectedStoreId;
  String _searchQuery = '';
  bool _filterOpen = false;
  bool _filterCard = false;
  bool _filterDeal = false;
  String _selectedCategory = '전체';

  final _searchController = TextEditingController();
  Size _mapSize = Size.zero;

  static const _categories = ['전체', '먹거리', '생선·해산물', '청과·야채', '포목·직물'];

  List<Store> get _filteredStores {
    return MockData.stores.where((s) {
      if (_filterOpen && s.status != StoreStatus.open) return false;
      if (_filterCard && !s.paymentMethods.contains(PaymentMethod.card)) {
        return false;
      }
      if (_filterDeal && s.activeDealId == null) return false;
      if (_searchQuery.isNotEmpty &&
          !s.name.contains(_searchQuery) &&
          !s.category.contains(_searchQuery)) {
        return false;
      }
      if (!_matchesCategory(s)) return false;
      return true;
    }).toList();
  }

  bool _matchesCategory(Store store) {
    switch (_selectedCategory) {
      case '전체':
        return true;
      case '먹거리':
        return store.category.contains('먹거리');
      case '생선·해산물':
        return store.category.contains('생선') || store.category.contains('해산물');
      case '청과·야채':
        return store.category.contains('청과') || store.category.contains('야채');
      case '포목·직물':
        return store.category.contains('포목') || store.category.contains('직물');
      default:
        return true;
    }
  }

  void _onMapTap(TapUpDetails details) {
    if (_mapSize == Size.zero) return;
    final painter = MarketPainter(
      stores: _filteredStores,
      pois: MockData.pois,
      selectedStoreId: _selectedStoreId,
      activeDeals: MockData.deals,
    );
    final tappedStore = painter.storeAtPosition(details.localPosition, _mapSize);
    if (tappedStore != null) {
      setState(() => _selectedStoreId = tappedStore.id);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => StoreDetailScreen(store: tappedStore)),
      ).then((_) => setState(() => _selectedStoreId = null));
    } else {
      setState(() => _selectedStoreId = null);
    }
  }

  void _resetAll() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _selectedStoreId = null;
      _selectedCategory = '전체';
      _filterOpen = false;
      _filterCard = false;
      _filterDeal = false;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasActiveFilters =
        _filterOpen || _filterCard || _filterDeal || _searchQuery.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.mapBackground,
      body: Stack(
        children: [
          // ── Full-screen map ──────────────────────────────────────
          Positioned.fill(
            child: GestureDetector(
              onTapUp: _onMapTap,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  _mapSize = Size(constraints.maxWidth, constraints.maxHeight);
                  return CustomPaint(
                    painter: MarketPainter(
                      stores: _filteredStores,
                      pois: MockData.pois,
                      selectedStoreId: _selectedStoreId,
                      activeDeals: MockData.deals,
                    ),
                    size: _mapSize,
                  );
                },
              ),
            ),
          ),

          // ── Top overlay ──────────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Row(
                      children: [
                        // Market selector button
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            height: 44,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x18000000),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.storefront_rounded,
                                  size: 16,
                                  color: AppColors.primaryRed,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  widget.marketName,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  size: 18,
                                  color: AppColors.textTertiary,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Search field
                        Expanded(
                          child: Container(
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x18000000),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _searchController,
                              onChanged: (v) => setState(() => _searchQuery = v),
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textPrimary,
                              ),
                              decoration: InputDecoration(
                                hintText: '${widget.marketName} 점포 검색',
                                hintStyle: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textTertiary,
                                ),
                                prefixIcon: const Icon(
                                  Icons.search_rounded,
                                  size: 20,
                                  color: AppColors.textTertiary,
                                ),
                                suffixIcon: _searchQuery.isNotEmpty
                                    ? GestureDetector(
                                        onTap: () {
                                          _searchController.clear();
                                          setState(() => _searchQuery = '');
                                        },
                                        child: const Icon(
                                          Icons.close_rounded,
                                          size: 18,
                                          color: AppColors.textTertiary,
                                        ),
                                      )
                                    : null,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: AppColors.surface,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 0),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _FilterIconButton(
                          onTap: _showFilterSheet,
                          isActive: _filterOpen || _filterCard || _filterDeal,
                        ),
                      ],
                    ),
                  ),

                  // Filter chips
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 36,
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      children: [
                        _FilterChip(
                          label: '영업중',
                          isSelected: _filterOpen,
                          icon: Icons.circle,
                          iconColor: AppColors.success,
                          onTap: () => setState(() => _filterOpen = !_filterOpen),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: '카드결제',
                          isSelected: _filterCard,
                          icon: Icons.credit_card_outlined,
                          onTap: () => setState(() => _filterCard = !_filterCard),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: '현재특가',
                          isSelected: _filterDeal,
                          icon: Icons.local_offer_outlined,
                          iconColor: AppColors.primaryRed,
                          onTap: () => setState(() => _filterDeal = !_filterDeal),
                        ),
                      ],
                    ),
                  ),

                  // Category chips
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 34,
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      children: _categories.map((cat) {
                        final isSelected = _selectedCategory == cat;
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedCategory = cat),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 13, vertical: 5),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.textPrimary
                                    : AppColors.surface.withValues(alpha: 0.92),
                                borderRadius: BorderRadius.circular(100),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x0F000000),
                                    blurRadius: 4,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Text(
                                cat,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── FAB ─────────────────────────────────────────────────
          Positioned(
            right: 16,
            bottom: 20,
            child: FloatingActionButton.small(
              onPressed: _resetAll,
              backgroundColor:
                  hasActiveFilters ? AppColors.primaryRed : AppColors.surface,
              foregroundColor:
                  hasActiveFilters ? Colors.white : AppColors.textPrimary,
              elevation: 4,
              child: Icon(
                hasActiveFilters ? Icons.filter_alt_off : Icons.my_location,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '필터',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            _FilterToggleTile(
              label: '영업중만 보기',
              subtitle: '현재 영업 중인 점포만 표시',
              value: _filterOpen,
              onChanged: (v) => setState(() => _filterOpen = v),
            ),
            _FilterToggleTile(
              label: '카드결제 가능',
              subtitle: '카드 결제가 되는 점포만 표시',
              value: _filterCard,
              onChanged: (v) => setState(() => _filterCard = v),
            ),
            _FilterToggleTile(
              label: '현재 특가 진행 중',
              subtitle: '할인 특가가 있는 점포만 표시',
              value: _filterDeal,
              onChanged: (v) => setState(() => _filterDeal = v),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('적용하기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Widgets ──────────────────────────────────────────────────────────────────

class _FilterIconButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isActive;
  const _FilterIconButton({required this.onTap, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryRed : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color(0x18000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          Icons.tune_rounded,
          size: 20,
          color: isActive ? Colors.white : AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;
  final Color? iconColor;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryRed : AppColors.surface,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: isSelected ? AppColors.primaryRed : AppColors.border,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F000000),
              blurRadius: 4,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: isSelected ? 12 : 13,
                color: isSelected
                    ? Colors.white
                    : (iconColor ?? AppColors.textSecondary),
              ),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterToggleTile extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _FilterToggleTile({
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.primaryRed,
            activeTrackColor: AppColors.primaryRedLight,
          ),
        ],
      ),
    );
  }
}
