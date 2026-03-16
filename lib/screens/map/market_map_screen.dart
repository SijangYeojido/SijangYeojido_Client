import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../data/mock_data.dart';
import '../../theme/app_colors.dart';
import 'market_painter.dart';
import 'store_bottom_sheet.dart';

class MarketMapScreen extends StatefulWidget {
  const MarketMapScreen({super.key});

  @override
  State<MarketMapScreen> createState() => _MarketMapScreenState();
}

class _MarketMapScreenState extends State<MarketMapScreen> {
  String? _selectedStoreId;
  String _searchQuery = '';
  bool _filterOpen = false;
  bool _filterCard = false;
  bool _filterDeal = false;

  final _searchController = TextEditingController();
  Size _mapSize = Size.zero;

  List<Store> get _filteredStores {
    return MockData.stores.where((s) {
      if (_filterOpen && s.status != StoreStatus.open) return false;
      if (_filterCard && !s.paymentMethods.contains(PaymentMethod.card)) return false;
      if (_filterDeal && s.activeDealId == null) return false;
      if (_searchQuery.isNotEmpty &&
          !s.name.contains(_searchQuery) &&
          !s.category.contains(_searchQuery)) return false;
      return true;
    }).toList();
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
      StoreBottomSheet.show(context, tappedStore);
    } else {
      setState(() => _selectedStoreId = null);
    }
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
      body: Stack(
        children: [
          // Full-screen map
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

          // Top overlay
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Column(
                children: [
                  // Search bar row
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x1A000000),
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
                                hintText: '광장시장 점포 검색',
                                hintStyle: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textTertiary,
                                ),
                                prefixIcon: const Icon(
                                  Icons.search,
                                  size: 20,
                                  color: AppColors.textTertiary,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: AppColors.surface,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 0,
                                ),
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
                          onTap: () => setState(() => _filterOpen = !_filterOpen),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: '카드결제',
                          isSelected: _filterCard,
                          onTap: () => setState(() => _filterCard = !_filterCard),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: '현재특가',
                          isSelected: _filterDeal,
                          icon: Icons.local_offer_outlined,
                          onTap: () => setState(() => _filterDeal = !_filterDeal),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom draggable sheet
          DraggableScrollableSheet(
            initialChildSize: 0.3,
            minChildSize: 0.15,
            maxChildSize: 0.85,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x1A000000),
                      blurRadius: 16,
                      offset: Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Handle
                    Center(
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                    ),
                    // Sheet header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: Row(
                        children: [
                          Text(
                            '점포 목록',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primaryRedLight,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text(
                              '${_filteredStores.length}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryRed,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    // Store list
                    Expanded(
                      child: ListView.separated(
                        controller: scrollController,
                        padding: const EdgeInsets.only(bottom: 16),
                        itemCount: _filteredStores.length,
                        separatorBuilder: (_, __) =>
                            const Divider(height: 1, indent: 16, endIndent: 16),
                        itemBuilder: (context, index) {
                          final store = _filteredStores[index];
                          return _StoreListTile(
                            store: store,
                            isSelected: store.id == _selectedStoreId,
                            onTap: () {
                              setState(() => _selectedStoreId = store.id);
                              StoreBottomSheet.show(context, store);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // FAB - 현위치
          Positioned(
            right: 16,
            bottom: 220,
            child: FloatingActionButton.small(
              onPressed: () {
                setState(() => _selectedStoreId = null);
              },
              backgroundColor: AppColors.surface,
              foregroundColor: AppColors.textPrimary,
              elevation: 4,
              child: const Icon(Icons.my_location, size: 20),
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
        padding: const EdgeInsets.all(24),
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
              value: _filterOpen,
              onChanged: (v) => setState(() => _filterOpen = v),
            ),
            _FilterToggleTile(
              label: '카드결제 가능',
              value: _filterCard,
              onChanged: (v) => setState(() => _filterCard = v),
            ),
            _FilterToggleTile(
              label: '현재 특가 진행 중',
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

class _FilterIconButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isActive;

  const _FilterIconButton({required this.onTap, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryRed : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          Icons.tune,
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

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
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
                size: 14,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
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

class _StoreListTile extends StatelessWidget {
  final Store store;
  final bool isSelected;
  final VoidCallback onTap;

  const _StoreListTile({
    required this.store,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: isSelected ? AppColors.primaryRedLight : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Zone badge
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _zoneColor(store.zoneId),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                store.zoneId,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
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
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (store.hasDeal) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppColors.primaryRed,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'DEAL',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    store.category,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            _StatusDot(status: store.status),
          ],
        ),
      ),
    );
  }

  Color _zoneColor(String zoneId) {
    switch (zoneId) {
      case 'A':
        return AppColors.zoneA;
      case 'B':
        return AppColors.zoneB;
      case 'C':
        return AppColors.zoneC;
      case 'D':
        return AppColors.zoneD;
      default:
        return AppColors.divider;
    }
  }
}

class _StatusDot extends StatelessWidget {
  final StoreStatus status;
  const _StatusDot({required this.status});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: status.color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          status.label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: status.color,
          ),
        ),
      ],
    );
  }
}

class _FilterToggleTile extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _FilterToggleTile({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.textPrimary,
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primaryRed,
          ),
        ],
      ),
    );
  }
}
