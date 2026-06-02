import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../providers/app_data_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/sijang_design_system.dart';
import '../../widgets/offline_cache_banner.dart';
import '../map/store_detail_screen.dart';

class MarketMapSimpleScreen extends StatefulWidget {
  final String marketName;
  const MarketMapSimpleScreen({super.key, required this.marketName});

  @override
  State<MarketMapSimpleScreen> createState() => _MarketMapSimpleScreenState();
}

class _MarketMapSimpleScreenState extends State<MarketMapSimpleScreen> {
  String _selectedZoneId = 'all';
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppDataProvider>().recordAction(
        'market.map.view',
        metadata: {
          'marketName': widget.marketName,
          if (context.read<AppDataProvider>().marketIdForName(
                widget.marketName,
              ) !=
              null)
            'marketId': context.read<AppDataProvider>().marketIdForName(
              widget.marketName,
            ),
          'mode': 'directory',
        },
      );
      context.read<AppDataProvider>().recordAction(
        'market.map.rendered',
        metadata: {
          'marketName': widget.marketName,
          if (context.read<AppDataProvider>().marketIdForName(
                widget.marketName,
              ) !=
              null)
            'marketId': context.read<AppDataProvider>().marketIdForName(
              widget.marketName,
            ),
          'mode': 'directory',
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<AppDataProvider>();
    final zones = data.zones;
    final stores = data.storesForMarket(widget.marketName);
    final filteredStores = _filterStores(stores);
    final groupedStores = _groupByZone(filteredStores, zones);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.marketName} 안내',
              style: const TextStyle(fontSize: 18, fontWeight: SDS.fwBlack),
            ),
            Text(
              '${stores.length}개 점포를 구역별로 확인',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: SDS.fwBold,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          OfflineCacheBanner(data: data),
          _HeaderPanel(
            marketName: widget.marketName,
            storeCount: stores.length,
            visibleCount: filteredStores.length,
            openCount: stores
                .where((store) => store.status == StoreStatus.open)
                .length,
            onQueryChanged: (value) {
              setState(() => _query = value.trim());
              if (value.trim().isNotEmpty) {
                context.read<AppDataProvider>().recordAction(
                  'market.map.search',
                  metadata: {
                    'marketName': widget.marketName,
                    if (data.marketIdForName(widget.marketName) != null)
                      'marketId': data.marketIdForName(widget.marketName),
                    'query': value.trim(),
                  },
                );
              }
            },
          ),
          _ZoneSelector(
            zones: zones,
            selectedZoneId: _selectedZoneId,
            onSelected: (zoneId) {
              setState(() => _selectedZoneId = zoneId);
              context.read<AppDataProvider>().recordAction(
                'market.map.filter',
                metadata: {
                  'marketName': widget.marketName,
                  if (data.marketIdForName(widget.marketName) != null)
                    'marketId': data.marketIdForName(widget.marketName),
                  'zoneId': zoneId,
                },
              );
            },
          ),
          Expanded(
            child: filteredStores.isEmpty
                ? const _EmptyDirectory()
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                    children: [
                      for (final entry in groupedStores.entries) ...[
                        _ZoneSectionHeader(
                          zoneName: entry.key,
                          count: entry.value.length,
                        ),
                        const SizedBox(height: 8),
                        for (final store in entry.value)
                          _StoreDirectoryTile(
                            store: store,
                            zoneName: entry.key,
                            onTap: () => _openStore(context, store),
                          ),
                        const SizedBox(height: 14),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  List<Store> _filterStores(List<Store> stores) {
    final normalizedQuery = _query.replaceAll(' ', '').toLowerCase();
    return stores.where((store) {
      final zoneMatched =
          _selectedZoneId == 'all' || store.zoneId == _selectedZoneId;
      if (!zoneMatched) return false;
      if (normalizedQuery.isEmpty) return true;
      final haystack = [
        store.name,
        store.category,
        store.unitNumber ?? '',
        store.items.map((item) => item.name).join(' '),
      ].join(' ').replaceAll(' ', '').toLowerCase();
      return haystack.contains(normalizedQuery);
    }).toList()..sort((a, b) => _storeSortKey(a).compareTo(_storeSortKey(b)));
  }

  Map<String, List<Store>> _groupByZone(List<Store> stores, List<Zone> zones) {
    final zoneNames = {for (final zone in zones) zone.id: zone.name};
    final grouped = <String, List<Store>>{};
    for (final store in stores) {
      final zoneName = zoneNames[store.zoneId] ?? '기타 구역';
      grouped.putIfAbsent(zoneName, () => []).add(store);
    }
    return grouped;
  }

  String _storeSortKey(Store store) {
    final unit = store.unitNumber ?? '';
    return '${store.zoneId.padLeft(8, '0')}-$unit-${store.name}';
  }

  void _openStore(BuildContext context, Store store) {
    context.read<AppDataProvider>().recordAction(
      'market.map.pin_select',
      metadata: {
        'storeId': store.id,
        'marketName': widget.marketName,
        if (context.read<AppDataProvider>().marketIdForName(
              widget.marketName,
            ) !=
            null)
          'marketId': context.read<AppDataProvider>().marketIdForName(
            widget.marketName,
          ),
        'source': 'directory',
      },
    );
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => StoreDetailScreen(store: store)),
    );
  }
}

class _HeaderPanel extends StatelessWidget {
  const _HeaderPanel({
    required this.marketName,
    required this.storeCount,
    required this.visibleCount,
    required this.openCount,
    required this.onQueryChanged,
  });

  final String marketName;
  final int storeCount;
  final int visibleCount;
  final int openCount;
  final ValueChanged<String> onQueryChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _MetricPill(
                  label: '전체 점포',
                  value: '$storeCount',
                  icon: Icons.storefront_rounded,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MetricPill(
                  label: '영업중',
                  value: '$openCount',
                  icon: Icons.schedule_rounded,
                  color: const Color(0xFF16A34A),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MetricPill(
                  label: '현재 표시',
                  value: '$visibleCount',
                  icon: Icons.filter_alt_rounded,
                  color: const Color(0xFF475569),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextField(
            onChanged: onQueryChanged,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: '점포명, 품목, 구역번호 검색',
              prefixIcon: const Icon(Icons.search_rounded),
              filled: true,
              fillColor: const Color(0xFFF1F5F9),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 7),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: SDS.fwBlack,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: SDS.fwBold,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ZoneSelector extends StatelessWidget {
  const _ZoneSelector({
    required this.zones,
    required this.selectedZoneId,
    required this.onSelected,
  });

  final List<Zone> zones;
  final String selectedZoneId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final options = [
      const Zone(
        id: 'all',
        name: '전체',
        description: '전체 구역',
        color: AppColors.primary,
      ),
      ...zones,
    ];
    return Container(
      height: 58,
      color: Colors.white,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
        scrollDirection: Axis.horizontal,
        itemCount: options.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final zone = options[index];
          final selected = zone.id == selectedZoneId;
          return ChoiceChip(
            selected: selected,
            label: Text(zone.name),
            avatar: CircleAvatar(
              radius: 5,
              backgroundColor: selected ? Colors.white : zone.color,
            ),
            selectedColor: AppColors.primary,
            backgroundColor: const Color(0xFFF1F5F9),
            labelStyle: TextStyle(
              color: selected ? Colors.white : AppColors.textPrimary,
              fontWeight: SDS.fwBold,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(
                color: selected ? AppColors.primary : const Color(0xFFE2E8F0),
              ),
            ),
            onSelected: (_) => onSelected(zone.id),
          );
        },
      ),
    );
  }
}

class _ZoneSectionHeader extends StatelessWidget {
  const _ZoneSectionHeader({required this.zoneName, required this.count});

  final String zoneName;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          zoneName,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: SDS.fwBlack,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFFE2E8F0),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$count개',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: SDS.fwBold,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _StoreDirectoryTile extends StatelessWidget {
  const _StoreDirectoryTile({
    required this.store,
    required this.zoneName,
    required this.onTap,
  });

  final Store store;
  final String zoneName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final mainItem = store.items.isEmpty ? null : store.items.first;
    return Semantics(
      label: store.name,
      button: true,
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: store.status.bgColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    store.unitNumber ?? store.category.characters.first,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: SDS.fwBlack,
                      color: store.status.color,
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
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: SDS.fwBlack,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _StatusBadge(status: store.status),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        [
                          zoneName,
                          store.category,
                          if (store.addressDetail != null) store.addressDetail!,
                        ].join(' · '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: SDS.fwBold,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (mainItem != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          '${mainItem.name}${mainItem.price == null ? '' : ' · ${mainItem.price}원'}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF475569),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF94A3B8),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final StoreStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: status.bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: SDS.fwBold,
          color: status.color,
        ),
      ),
    );
  }
}

class _EmptyDirectory extends StatelessWidget {
  const _EmptyDirectory();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off_rounded, size: 42, color: Color(0xFF94A3B8)),
          SizedBox(height: 10),
          Text(
            '조건에 맞는 점포가 없습니다.',
            style: TextStyle(
              fontWeight: SDS.fwBold,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
