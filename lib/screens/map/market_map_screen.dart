import 'dart:ui';
import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../data/mock_data.dart';
import '../../theme/app_colors.dart';
import '../../widgets/shrinkable_button.dart';
import '../../widgets/app_ui.dart';
import 'market_painter.dart';
import 'store_detail_screen.dart';
import 'store_bottom_sheet.dart';

class MarketMapScreen extends StatefulWidget {
  final String marketName;
  const MarketMapScreen({super.key, this.marketName = '광장시장'});

  @override
  State<MarketMapScreen> createState() => _MarketMapScreenState();
}

class _MarketMapScreenState extends State<MarketMapScreen> with SingleTickerProviderStateMixin {
  String? _selectedStoreId;
  String _searchQuery = '';
  bool _filterOpen = false;
  bool _filterCard = false;

  String _selectedCategory = '전체';
  String? _routeTargetStoreId;

  final _searchController = TextEditingController();
  final _sheetController = DraggableScrollableController();
  late TransformationController _transformationController;
  late AnimationController _animationController;
  Animation<Matrix4>? _mapAnimation;
  Size _mapSize = Size.zero;

  static const _categories = ['전체', '먹거리', '생선·해산물', '청과·야채', '포목·직물'];

  List<Store> get _filteredStores {
    return MockData.stores.where((s) {
      if (_filterOpen && s.status != StoreStatus.open) return false;
      if (_filterCard && !s.paymentMethods.contains(PaymentMethod.card)) {
        return false;
      }

      if (_selectedCategory != '전체' && s.category != _selectedCategory) return false;
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
      routeTargetStoreId: _routeTargetStoreId,
    );
    
    // Account for current transformation
    // final RenderBox box = context.findRenderObject() as RenderBox;
    // final localPos = box.globalToLocal(details.globalPosition);
    // Actually, InteractiveViewer child receives local coordinates if we use the right point.
    // But since GestureDetector is inside, it should be fine.
    
    final tappedStore = painter.storeAtPosition(details.localPosition, _mapSize);
    if (tappedStore != null) {
      setState(() {
        _selectedStoreId = tappedStore.id;
        _routeTargetStoreId = tappedStore.id;
      });
      _animateToStore(tappedStore);
      
      Future.delayed(const Duration(milliseconds: 400), () {
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => StoreDetailScreen(store: tappedStore)),
        ).then((_) => setState(() => _selectedStoreId = null));
      });
    } else {
      setState(() => _selectedStoreId = null);
      if (_sheetController.isAttached) {
        _sheetController.animateTo(
          0.1,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    }
  }

  void _animateToStore(Store store) {
    if (_mapSize == Size.zero) return;

    final double targetX = store.mapX * _mapSize.width;
    final double targetY = store.mapY * _mapSize.height;
    const double targetScale = 2.5;

    // Using the recommended non-deprecated methods for Matrix4
    // ignore: deprecated_member_use
    final Matrix4 endMatrix = Matrix4.identity()
      // ignore: deprecated_member_use
      ..translate(targetX * -targetScale + _mapSize.width / 2,
          targetY * -targetScale + _mapSize.height / 2)
      // ignore: deprecated_member_use
      ..scale(targetScale, targetScale, 1.0);

    _mapAnimation = Matrix4Tween(
      begin: _transformationController.value,
      end: endMatrix,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward(from: 0);
  }

  void _resetAll() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _selectedStoreId = null;
      _selectedCategory = '전체';
      _filterOpen = false;
      _filterCard = false;
      _routeTargetStoreId = null;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _sheetController.dispose();
    _animationController.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..addListener(() {
        if (_mapAnimation != null) {
          _transformationController.value = _mapAnimation!.value;
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final hasActiveFilters =
        _filterOpen || _filterCard || _searchQuery.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.mapBackground,
      body: Stack(
        children: [
          // ── Full-screen map ──────────────────────────────────────
          Positioned.fill(
            child: InteractiveViewer(
              transformationController: _transformationController,
              minScale: 1.0,
              maxScale: 4.0,
              boundaryMargin: const EdgeInsets.all(20),
              child: GestureDetector(
                onTapUp: _onMapTap,
                child: RepaintBoundary(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      _mapSize = Size(constraints.maxWidth, constraints.maxHeight);
                      return CustomPaint(
                        painter: MarketPainter(
                          stores: _filteredStores,
                          pois: MockData.pois,
                          selectedStoreId: _selectedStoreId,
                          routeTargetStoreId: _routeTargetStoreId,
                        ),
                        size: _mapSize,
                      );
                    },
                  ),
                ),
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
                  // Rebrand overlay backdrop (subtle hero tint)
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.primary.withValues(alpha: 0.10),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: const SizedBox(height: 1),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Row(
                      children: [
                        ShrinkableButton(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            height: 52,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x0A000000),
                                  blurRadius: 12,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface.withValues(alpha: 0.9),
                                    border: Border.all(color: AppColors.border),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.arrow_back_ios_new_rounded,
                                        size: 18,
                                        color: AppColors.textPrimary,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        widget.marketName,
                                        style: textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.textPrimary,
                                          letterSpacing: -0.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Search field
                        Expanded(
                          child: Container(
                            height: 52,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x14000000),
                                  blurRadius: 16,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.surface.withValues(alpha: 0.92),
                                    border: Border.all(color: AppColors.border),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: TextField(
                                    controller: _searchController,
                                    onChanged: (v) => setState(() => _searchQuery = v),
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: AppColors.textPrimary,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: '${widget.marketName} 점포 검색',
                                      hintStyle: textTheme.bodyMedium?.copyWith(
                                        color: AppColors.textTertiary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      prefixIcon: const Icon(
                                        Icons.search_rounded,
                                        size: 22,
                                        color: AppColors.textTertiary,
                                      ),
                                      suffixIcon: _searchQuery.isNotEmpty
                                          ? ShrinkableButton(
                                              onTap: () {
                                                _searchController.clear();
                                                setState(() => _searchQuery = '');
                                              },
                                              child: const Icon(
                                                Icons.close_rounded,
                                                size: 20,
                                                color: AppColors.textTertiary,
                                              ),
                                            )
                                          : null,
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      filled: false,
                                      contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 0),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _FilterIconButton(
                          onTap: _showFilterSheet,
                          isActive: _filterOpen || _filterCard,
                        ),
                      ],
                    ),
                  ),

                  // Category chips & Utility filters
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 36,
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      children: [
                        ..._categories.map((cat) {
                          final isSelected = _selectedCategory == cat;
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: _CategoryChip(
                              label: cat,
                              isSelected: isSelected,
                              onTap: () => setState(() => _selectedCategory = cat),
                            ),
                          );
                        }),
                        // Utility filters separator
                        Container(
                          width: 1,
                          height: 24,
                          color: AppColors.border,
                          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: '영업 중인 곳',
                          isSelected: _filterOpen,
                          icon: Icons.circle,
                          iconColor: AppColors.success,
                          onTap: () => setState(() => _filterOpen = !_filterOpen),
                        ),
                        const SizedBox(width: 6),
                        _FilterChip(
                          label: '카드 되는 곳',
                          isSelected: _filterCard,
                          icon: Icons.credit_card_outlined,
                          onTap: () => setState(() => _filterCard = !_filterCard),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Bottom draggable sheet ────────────────────────────────
          DraggableScrollableSheet(
            controller: _sheetController,
            initialChildSize: 0.3,
            minChildSize: 0.1,
            maxChildSize: 0.85,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 24,
                      offset: Offset(0, -6),
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
                            '어떤 점포를 찾으시나요?',
                            style: textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text(
                              '${_filteredStores.length}',
                              style: textTheme.labelLarge?.copyWith(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    // Store list
                    Expanded(
                      child: _filteredStores.isEmpty
                          ? _EmptyResult(
                              onReset: _resetAll,
                            )
                          : ListView.separated(
                              controller: scrollController,
                              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                              itemCount: _filteredStores.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final store = _filteredStores[index];
                                return _StoreResultCard(
                                  store: store,
                                  isSelected: store.id == _selectedStoreId,
                                  onTap: () {
                                    setState(() {
                                      _selectedStoreId = store.id;
                                      _routeTargetStoreId = store.id;
                                    });
                                    _animateToStore(store);
                                    if (_sheetController.isAttached) {
                                      _sheetController.animateTo(0.1, duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
                                    }
                                    Future.delayed(const Duration(milliseconds: 500), () {
                                      if (!mounted) return;
                                      // ignore: use_build_context_synchronously
                                      StoreBottomSheet.show(context, store);
                                    });
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

          // ── FAB ─────────────────────────────────────────────────
          Positioned(
            right: 16,
            bottom: 24, // Lifted slightly
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _MapFloatingButton(
                  icon: hasActiveFilters ? Icons.filter_alt_off_rounded : Icons.my_location_rounded,
                  isActive: hasActiveFilters,
                  onTap: _resetAll,
                ),
              ],
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
      builder: (_) {
        final textTheme = Theme.of(context).textTheme;
        return Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '필터',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            _FilterToggleTile(
              label: '지금 영업 중인 곳만 보기',
              subtitle: '현재 문을 연 점포만 모아볼게요',
              value: _filterOpen,
              onChanged: (v) => setState(() => _filterOpen = v),
            ),
            _FilterToggleTile(
              label: '카드 결제 가능한 곳만 보기',
              subtitle: '카드 결제가 되는 점포만 모아볼게요',
              value: _filterCard,
              onChanged: (v) => setState(() => _filterCard = v),
            ),

            const SizedBox(height: 16),
            AppPrimaryButton(
              label: '적용하기',
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
      },
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
    return ShrinkableButton(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              color: isActive
                  ? AppColors.primary
                  : AppColors.surface.withValues(alpha: 0.8),
              child: Icon(
                Icons.tune_rounded,
                size: 24,
                color: isActive ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ShrinkableButton(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(100),
          border: isSelected ? Border.all(
            color: AppColors.primary,
            width: 1.2,
          ) : null,
          boxShadow: [
            if (!isSelected)
              const BoxShadow(
                color: AppColors.cardShadowLight,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
          ],
        ),
        child: Text(
          label,
          style: textTheme.labelLarge?.copyWith(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
            color: isSelected ? Colors.white : AppColors.textSecondary,
            letterSpacing: -0.2,
          ),
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
    final textTheme = Theme.of(context).textTheme;
    return ShrinkableButton(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.12)
              : AppColors.surface.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(100),
          border: isSelected ? Border.all(
            color: AppColors.primary,
          ) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: isSelected ? 12 : 13,
                color: isSelected
                    ? AppColors.primary
                    : (iconColor ?? AppColors.textSecondary),
              ),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: textTheme.labelLarge?.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                letterSpacing: -0.2,
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
    final textTheme = Theme.of(context).textTheme;
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
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.primary,
            activeTrackColor: AppColors.primaryLight,
          ),
        ],
      ),
    );
  }
}

class _StoreResultCard extends StatelessWidget {
  final Store store;
  final bool isSelected;
  final VoidCallback onTap;

  const _StoreResultCard({
    required this.store,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final subtitle = '${store.zoneId}구역${store.unitNumber != null ? " · ${store.unitNumber}호" : ""} · ${store.category}';

    return ShrinkableButton(
      onTap: onTap,
      shrinkScale: 0.98,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.14),
                    AppColors.accent.withValues(alpha: 0.10),
                  ],
                )
              : null,
          color: isSelected ? null : AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            if (!isSelected)
              const BoxShadow(
                color: AppColors.cardShadow,
                blurRadius: 12,
                offset: Offset(0, 3),
              ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
              ),
              child: Center(
                child: Text(
                  store.name.isNotEmpty ? store.name.characters.first : '가',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                  ),
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
                      Expanded(
                        child: Text(
                          store.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.3,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _MiniStatusChip(status: store.status),

                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: store.paymentMethods.take(3).map((pm) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          pm.label,
                          style: textTheme.labelLarge?.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            const Icon(Icons.chevron_right,
                size: 20, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}

class _MiniStatusChip extends StatelessWidget {
  final StoreStatus status;
  const _MiniStatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: status.bgColor,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: status.color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            status.label,
            style: textTheme.labelLarge?.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: status.color,
            ),
          ),
        ],
      ),
    );
  }
}



class _EmptyResult extends StatelessWidget {
  final VoidCallback onReset;
  const _EmptyResult({required this.onReset});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: AppEmptyState(
          icon: Icons.search_off_rounded,
          title: '필터 검색 결과가 없어요',
          description: '다른 필터를 선택해보세요',
          actionLabel: '필터 초기화하기',
          onAction: onReset,
        ),
      ),
    );
  }
}

class _MapFloatingButton extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _MapFloatingButton({
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ShrinkableButton(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : AppColors.surface,
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 24,
          color: isActive ? Colors.white : AppColors.textPrimary,
        ),
      ),
    );
  }
}
