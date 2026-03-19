import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/sijang_design_system.dart';
import '../../widgets/shrinkable_button.dart';
import '../../data/mock_data.dart';
import '../../models/models.dart';
import '../map/store_detail_screen.dart';

class MarketMapSimpleScreen extends StatefulWidget {
  final String marketName;
  const MarketMapSimpleScreen({super.key, required this.marketName});

  @override
  State<MarketMapSimpleScreen> createState() => _MarketMapSimpleScreenState();
}

class _MarketMapSimpleScreenState extends State<MarketMapSimpleScreen> {
  String _selectedCategory = '전체';
  String _selectedZone = '전체';
  bool _isListView = false;
  final TextEditingController _searchController = TextEditingController();
  
  final List<String> _categories = ['전체', '먹거리', '수산물', '정육', '기타'];
  final List<String> _zones = ['전체', 'A', 'B', 'C'];

  List<Store> get _filteredStores {
    return MockData.stores.where((s) {
      final matchesCategory = _selectedCategory == '전체' || s.category == _selectedCategory;
      final matchesZone = _selectedZone == '전체' || s.zoneId == _selectedZone;
      final matchesSearch = _searchController.text.isEmpty || 
          s.name.toLowerCase().contains(_searchController.text.toLowerCase());
      return matchesCategory && matchesZone && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ── 1. Map Canvas OR List View ────────────────────────────
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: _isListView ? _buildListView() : _buildMapView(),
            ),
          ),

          // ── 2. Top Navigation & Filters (Glass) ───────────────────
          _buildTopInterface(),

          // ── 3. Bottom Utility Hub ─────────────────────────────────
          _buildBottomPanel(),
          
          // ── 4. View Mode Toggle ───────────────────────────────────
          _buildViewToggle(),
        ],
      ),
    );
  }

  Widget _buildTopInterface() {
    return Positioned(
      top: 0, left: 0, right: 0,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 8, 20, 20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.8),
              border: const Border(bottom: BorderSide(color: Color(0xFFF2F4F6), width: 1)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    ShrinkableButton(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: AppColors.textPrimary),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        '${widget.marketName} 가이드',
                        style: const TextStyle(fontSize: 18, fontWeight: SDS.fwBlack, color: AppColors.textPrimary),
                      ),
                    ),
                    const Icon(Icons.notifications_none_rounded, color: AppColors.textPrimary),
                  ],
                ),
                const SizedBox(height: 20),
                // Search Bar
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F4F6),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() {}),
                    decoration: const InputDecoration(
                      hintText: '가게 이름을 검색해 보세요',
                      hintStyle: TextStyle(color: AppColors.textTertiary, fontSize: 14, fontWeight: SDS.fwBold),
                      prefixIcon: Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 20),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Horizontal Category Filters
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: _categories.map((cat) => _buildFilterChip(cat, isCategory: true)).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, {required bool isCategory}) {
    final bool isSelected = isCategory ? _selectedCategory == label : _selectedZone == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isCategory) _selectedCategory = label;
          else _selectedZone = label;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF04452) : Colors.white,
          borderRadius: BorderRadius.circular(SDS.radiusCapsule),
          border: Border.all(color: isSelected ? const Color(0xFFF04452) : const Color(0xFFECEFF1), width: 1.5),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: SDS.fwBlack,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildMapView() {
    return Container(
      color: const Color(0xFFF8F9FA),
      child: Stack(
        children: [
          // Background Vector Map Mock
          Center(
            child: Opacity(
              opacity: 0.05,
              child: Icon(Icons.account_tree_rounded, size: 500, color: const Color(0xFFF04452)),
            ),
          ),
          // Store Markers
          ..._filteredStores.map((store) => _buildStoreMarker(store)),
          
          // Zone Highlights (Simulated)
          if (_selectedZone != '전체')
            Center(
              child: Container(
                width: 200, height: 200,
                decoration: BoxDecoration(
                  color: const Color(0xFFF04452).withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFF04452).withValues(alpha: 0.2), width: 2),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStoreMarker(Store store) {
    return Positioned(
      left: MediaQuery.of(context).size.width * store.mapX,
      top: MediaQuery.of(context).size.height * store.mapY,
      child: ShrinkableButton(
        onTap: () => _showStoreQuickView(store),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: SDS.shadowSoft,
              ),
              child: Text(
                '\u00A0' + store.name,
                style: const TextStyle(fontSize: 10, fontWeight: SDS.fwBlack, color: AppColors.textPrimary),
              ),
            ),
            const Icon(Icons.location_on_rounded, color: Color(0xFFF04452), size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildListView() {
    final stores = _filteredStores;
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 180, 20, 100),
      itemCount: stores.length,
      itemBuilder: (context, index) {
        final store = stores[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: SDS.listRow(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => StoreDetailScreen(store: store))),
            title: Text('\u00A0' + store.name, style: const TextStyle(fontWeight: SDS.fwBlack)),
            subtitle: Text('\u00A0${store.category} · ${store.zoneId}구역'),
            leading: Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: const Color(0xFFF04452).withValues(alpha: 0.1), shape: BoxShape.circle),
              child: const Icon(Icons.storefront_rounded, color: Color(0xFFF04452), size: 20),
            ),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textTertiary),
          ),
        );
      },
    );
  }

  Widget _buildBottomPanel() {
    return Positioned(
      bottom: 0, left: 0, right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -4))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('현재 구역 안내', style: TextStyle(fontSize: 16, fontWeight: SDS.fwBlack, color: AppColors.textPrimary)),
                Text('${_filteredStores.length}개의 가게', style: const TextStyle(fontSize: 13, color: Color(0xFFF04452), fontWeight: SDS.fwBold)),
              ],
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _zones.map((zone) => _buildFilterChip(zone, isCategory: false)).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewToggle() {
    return Positioned(
      bottom: 120, right: 20,
      child: ShrinkableButton(
        onTap: () => setState(() => _isListView = !_isListView),
        child: Container(
          width: 60, height: 60,
          decoration: BoxDecoration(color: Color(0xFF2C2E33), shape: BoxShape.circle, boxShadow: SDS.shadowPremium),
          child: Icon(_isListView ? Icons.map_rounded : Icons.list_rounded, color: Colors.white),
        ),
      ),
    );
  }

  void _showStoreQuickView(Store store) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: SDS.shadowPremium),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 60, height: 60,
                  decoration: BoxDecoration(color: const Color(0xFFF2F4F6), borderRadius: BorderRadius.circular(16)),
                  child: const Icon(Icons.restaurant_rounded, color: Color(0xFFF04452)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('\u00A0' + store.name, style: const TextStyle(fontSize: 18, fontWeight: SDS.fwBlack, color: AppColors.textPrimary)),
                      Text('\u00A0${store.category} · ${store.zoneId}구역', style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, fontWeight: SDS.fwBold)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: SDS.button(
                    label: '가게 상세정보',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => StoreDetailScreen(store: store)));
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: const Color(0xFFF2F4F6), borderRadius: BorderRadius.circular(16)),
                  child: const Icon(Icons.directions_rounded, color: AppColors.textPrimary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
