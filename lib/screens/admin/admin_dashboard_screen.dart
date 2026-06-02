import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/mock_data.dart';
import '../../models/models.dart';
import '../../providers/app_data_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/sijang_design_system.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppDataProvider>().loadAdminData();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<AppDataProvider>();
    final pendingStores = data.adminStores
        .where((store) => store['approvalStatus']?.toString() == 'PENDING')
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('운영 관리'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => data.loadAdminData(),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: _AdminSectionShortcuts(
                onMarket: () => _scrollToOffset(210),
                onApproval: () => _scrollToOffset(850),
                onAnalytics: () => _scrollToOffset(1080),
                onReports: () => _scrollToOffset(1450),
                onTrust: () => _scrollToOffset(1690),
                onLogs: () => _scrollToOffset(2010),
                onStores: () => _scrollToOffset(2250),
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: data.loadAdminData,
              child: ListView(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _MetricTile(
                          label: '전체 시장',
                          value: '${data.markets.length}',
                          icon: Icons.map_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MetricTile(
                          label: '승인 대기',
                          value: '${pendingStores.length}',
                          icon: Icons.pending_actions_rounded,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _MetricTile(
                          label: '전체 점포',
                          value: '${data.adminStores.length}',
                          icon: Icons.storefront_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MetricTile(
                          label: '로그',
                          value: '${data.adminLogs.length}',
                          icon: Icons.receipt_long_rounded,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _SectionHeader(
                    title: '시장 관리',
                    subtitle: '${data.markets.length}개',
                    action: IconButton.filledTonal(
                      onPressed: () => _showMarketSheet(context),
                      icon: const Icon(Icons.add_rounded),
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (data.markets.isEmpty)
                    const _EmptyState(label: '등록된 시장이 없습니다.')
                  else
                    ...data.markets.map(
                      (market) => _MarketAdminTile(
                        market: market,
                        marketId: data.marketIdForName(market.name),
                      ),
                    ),
                  const SizedBox(height: 24),
                  _SectionHeader(
                    title: '지도 구역 관리',
                    subtitle: '${data.zones.length}개',
                    action: IconButton.filledTonal(
                      onPressed: data.markets.isEmpty
                          ? null
                          : () => _showZoneSheet(context),
                      icon: const Icon(Icons.add_location_alt_rounded),
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (data.zones.isEmpty)
                    const _EmptyState(label: '등록된 지도 구역이 없습니다.')
                  else
                    ...data.zones.map(
                      (zone) => _ZoneAdminTile(
                        zone: zone,
                        marketId: data.markets.isEmpty
                            ? null
                            : data.marketIdForName(data.markets.first.name),
                      ),
                    ),
                  const SizedBox(height: 24),
                  _SectionHeader(
                    title: '점포 승인',
                    subtitle: '${pendingStores.length}건 대기',
                  ),
                  const SizedBox(height: 10),
                  if (pendingStores.isEmpty)
                    const _EmptyState(label: '승인 대기 중인 점포가 없습니다.')
                  else
                    ...pendingStores.map(
                      (store) => _StoreApprovalTile(store: store),
                    ),
                  const SizedBox(height: 24),
                  _SectionHeader(
                    title: '성과 대시보드',
                    subtitle: '최근 7일',
                  ),
                  const SizedBox(height: 10),
                  _AdminAnalyticsPanel(analytics: data.adminAnalytics),
                  const SizedBox(height: 24),
                  _SectionHeader(
                    title: '신고 관리',
                    subtitle: '${data.adminReports.length}건',
                  ),
                  const SizedBox(height: 10),
                  if (data.adminReports.isEmpty)
                    const _EmptyState(label: '접수된 신고가 없습니다.')
                  else
                    ...data.adminReports.map(
                      (report) => _ReportTile(report: report),
                    ),
                  const SizedBox(height: 24),
                  _SectionHeader(
                    title: '운영 신뢰센터',
                    subtitle: '${data.moderationCases.length}건',
                  ),
                  const SizedBox(height: 10),
                  if (data.moderationCases.isEmpty)
                    const _EmptyState(label: '검토 중인 운영 케이스가 없습니다.')
                  else
                    ...data.moderationCases.map(
                      (moderationCase) =>
                          _ModerationCaseTile(moderationCase: moderationCase),
                    ),
                  const SizedBox(height: 24),
                  _SectionHeader(
                    title: '시스템 로그',
                    subtitle: '최근 ${data.adminLogs.length}건',
                  ),
                  const SizedBox(height: 10),
                  if (data.adminLogs.isEmpty)
                    const _EmptyState(label: '기록된 로그가 없습니다.')
                  else
                    ...data.adminLogs.map((log) => _LogTile(log: log)),
                  const SizedBox(height: 24),
                  _SectionHeader(
                    title: '전체 점포',
                    subtitle: '${data.adminStores.length}개',
                  ),
                  const SizedBox(height: 10),
                  if (data.adminStores.isEmpty)
                    const _EmptyState(label: '관리할 점포가 없습니다.')
                  else
                    ...data.adminStores.map(
                      (store) => _StoreAdminTile(store: store),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMarketSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _MarketSheet(),
    );
  }

  void _scrollToOffset(double offset) {
    if (!_scrollController.hasClients) return;
    final max = _scrollController.position.maxScrollExtent;
    _scrollController.animateTo(
      offset.clamp(0, max),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
    );
  }

  void _showZoneSheet(BuildContext context) {
    final data = context.read<AppDataProvider>();
    final marketId = data.markets.isEmpty
        ? null
        : data.marketIdForName(data.markets.first.name);
    if (marketId == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _ZoneSheet(marketId: marketId),
    );
  }
}

class _AdminSectionShortcuts extends StatelessWidget {
  const _AdminSectionShortcuts({
    required this.onMarket,
    required this.onApproval,
    required this.onStores,
    required this.onReports,
    required this.onAnalytics,
    required this.onTrust,
    required this.onLogs,
  });

  final VoidCallback onMarket;
  final VoidCallback onApproval;
  final VoidCallback onStores;
  final VoidCallback onReports;
  final VoidCallback onAnalytics;
  final VoidCallback onTrust;
  final VoidCallback onLogs;

  @override
  Widget build(BuildContext context) {
    final actions = [
      (Icons.map_rounded, '시장 관리', onMarket),
      (Icons.verified_rounded, '점포 승인', onApproval),
      (Icons.storefront_rounded, '전체 점포', onStores),
      (Icons.query_stats_rounded, '성과', onAnalytics),
      (Icons.report_rounded, '신고 관리', onReports),
      (Icons.verified_user_rounded, '신뢰센터', onTrust),
      (Icons.receipt_long_rounded, '시스템 로그', onLogs),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final action in actions)
          OutlinedButton.icon(
            onPressed: action.$3,
            icon: Icon(action.$1, size: 18),
            label: Text(action.$2),
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.textPrimary,
              side: const BorderSide(color: Color(0xFFE2E8F0)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: SDS.fwBlack,
                    color: AppColors.textPrimary,
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

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.subtitle,
    this.action,
  });

  final String title;
  final String subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: SDS.fwBlack,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Text(subtitle, style: const TextStyle(color: AppColors.textSecondary)),
        if (action != null) ...[const SizedBox(width: 8), action!],
      ],
    );
  }
}

class _MarketAdminTile extends StatelessWidget {
  const _MarketAdminTile({required this.market, required this.marketId});

  final MarketInfo market;
  final int? marketId;

  @override
  Widget build(BuildContext context) {
    return _AdminCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  market.name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: SDS.fwBold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              IconButton(
                tooltip: '시장 수정',
                onPressed: marketId == null
                    ? null
                    : () => _showEditSheet(context),
                icon: const Icon(Icons.edit_rounded),
              ),
              IconButton(
                tooltip: '시장 삭제',
                onPressed: marketId == null
                    ? null
                    : () => context.read<AppDataProvider>().deleteMarket(
                        marketId!,
                      ),
                icon: const Icon(Icons.delete_outline_rounded),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            market.address,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            market.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  void _showEditSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _MarketSheet(market: market, marketId: marketId),
    );
  }
}

class _StoreApprovalTile extends StatelessWidget {
  const _StoreApprovalTile({required this.store});

  final Map<String, dynamic> store;

  @override
  Widget build(BuildContext context) {
    final id = _asInt(store['id']);
    return _AdminCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            store['name']?.toString() ?? '점포',
            style: const TextStyle(
              fontSize: 17,
              fontWeight: SDS.fwBold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${store['category'] ?? '기타'} · ${store['market']?['name'] ?? '시장'}',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: id == 0
                      ? null
                      : () => context.read<AppDataProvider>().approveStore(
                          id,
                          'REJECTED',
                        ),
                  child: const Text('반려'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  onPressed: id == 0
                      ? null
                      : () => context.read<AppDataProvider>().approveStore(
                          id,
                          'APPROVED',
                        ),
                  child: const Text('승인'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ZoneAdminTile extends StatelessWidget {
  const _ZoneAdminTile({required this.zone, required this.marketId});

  final Zone zone;
  final int? marketId;

  @override
  Widget build(BuildContext context) {
    final zoneId = _asInt(zone.id);
    return _AdminCard(
      child: Row(
        children: [
          Container(
            width: 14,
            height: 48,
            decoration: BoxDecoration(
              color: zone.color,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  zone.name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: SDS.fwBold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  zone.description.isEmpty ? '설명 없음' : zone.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: '구역 수정',
            onPressed: marketId == null || zoneId == 0
                ? null
                : () => _showEditSheet(context),
            icon: const Icon(Icons.edit_location_alt_rounded),
          ),
          IconButton(
            tooltip: '구역 삭제',
            onPressed: marketId == null || zoneId == 0
                ? null
                : () => context.read<AppDataProvider>().deleteMarketZone(
                    marketId!,
                    zoneId,
                  ),
            icon: const Icon(Icons.delete_outline_rounded),
          ),
        ],
      ),
    );
  }

  void _showEditSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _ZoneSheet(marketId: marketId!, zone: zone),
    );
  }
}

class _StoreAdminTile extends StatelessWidget {
  const _StoreAdminTile({required this.store});

  final Map<String, dynamic> store;

  @override
  Widget build(BuildContext context) {
    final id = _asInt(store['id']);
    final status = store['approvalStatus']?.toString() ?? 'PENDING';
    return _AdminCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  store['name']?.toString() ?? '점포',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: SDS.fwBold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Chip(label: Text(_approvalLabel(status))),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${store['category'] ?? '기타'} · ${store['market']?['name'] ?? '시장'}',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: id == 0 ? null : () => _showEditSheet(context),
                  icon: const Icon(Icons.edit_rounded, size: 18),
                  label: const Text('수정'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: id == 0
                      ? null
                      : () => context.read<AppDataProvider>().deleteAdminStore(
                          id,
                        ),
                  icon: const Icon(Icons.delete_outline_rounded, size: 18),
                  label: const Text('삭제'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showEditSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _AdminStoreSheet(store: store),
    );
  }
}

class _ReportTile extends StatelessWidget {
  const _ReportTile({required this.report});

  final Map<String, dynamic> report;

  @override
  Widget build(BuildContext context) {
    final id = _asInt(report['id']);
    final status = report['status']?.toString() ?? 'PENDING';
    return _AdminCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${report['reportType'] ?? '신고'} · ${_reportStatusLabel(status)}',
            style: const TextStyle(
              fontWeight: SDS.fwBold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            report['reason']?.toString() ?? '',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: id == 0
                      ? null
                      : () => context
                            .read<AppDataProvider>()
                            .updateReportStatus(id, 'REJECTED'),
                  child: const Text('반려'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton(
                  onPressed: id == 0
                      ? null
                      : () => context
                            .read<AppDataProvider>()
                            .updateReportStatus(id, 'RESOLVED'),
                  child: const Text('해결'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AdminAnalyticsPanel extends StatelessWidget {
  const _AdminAnalyticsPanel({required this.analytics});

  final Map<String, dynamic>? analytics;

  @override
  Widget build(BuildContext context) {
    if (analytics == null) {
      return const _EmptyState(label: '성과 데이터를 불러오는 중입니다.');
    }
    final summary =
        (analytics?['summary'] as Map<String, dynamic>?) ?? const {};
    final daily = (analytics?['daily'] as List?) ?? const [];
    return _AdminCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _KpiMiniTile(
                  label: '주간 픽업 완료',
                  value: _metric(summary, 'pickupCompletions'),
                  icon: Icons.shopping_bag_rounded,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _KpiMiniTile(
                  label: '결제 성공',
                  value: _metric(summary, 'paymentSuccesses'),
                  icon: Icons.payments_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _KpiMiniTile(
                  label: '점포 열림',
                  value: _metric(summary, 'storeOpens'),
                  icon: Icons.storefront_rounded,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _KpiMiniTile(
                  label: '신고/조치',
                  value:
                      '${_metric(summary, 'reportsCreated')} / ${_metric(summary, 'moderationActions')}',
                  icon: Icons.verified_user_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _FunnelLine(
            label: '예약 시작률',
            value: _rate(summary, 'reservationStartRate'),
          ),
          _FunnelLine(
            label: '결제 성공률',
            value: _rate(summary, 'paymentSuccessRate'),
          ),
          _FunnelLine(
            label: '픽업 완료율',
            value: _rate(summary, 'pickupCompletionRate'),
          ),
          const SizedBox(height: 12),
          if (daily.isEmpty)
            const Text(
              '아직 일별 스냅샷이 없습니다.',
              style: TextStyle(color: AppColors.textSecondary),
            )
          else
            ...daily.take(7).map((row) {
              final item = row as Map<String, dynamic>;
              return _DailyKpiRow(
                date: item['date']?.toString() ?? '',
                primary: _metric(item, 'pickupCompletions'),
                secondary: _metric(item, 'reservationsCreated'),
              );
            }),
        ],
      ),
    );
  }
}

class _KpiMiniTile extends StatelessWidget {
  const _KpiMiniTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: SDS.fwBlack,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _FunnelLine extends StatelessWidget {
  const _FunnelLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: SDS.fwBold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyKpiRow extends StatelessWidget {
  const _DailyKpiRow({
    required this.date,
    required this.primary,
    required this.secondary,
  });

  final String date;
  final String primary;
  final String secondary;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(child: Text(date)),
          Text('픽업 $primary · 예약 $secondary'),
        ],
      ),
    );
  }
}

class _ModerationCaseTile extends StatelessWidget {
  const _ModerationCaseTile({required this.moderationCase});

  final Map<String, dynamic> moderationCase;

  @override
  Widget build(BuildContext context) {
    final id = _asInt(moderationCase['id']);
    final status = moderationCase['status']?.toString() ?? 'OPEN';
    final severity = moderationCase['severity']?.toString() ?? 'MEDIUM';
    final targetType = moderationCase['targetType']?.toString() ?? 'TARGET';
    final targetId = moderationCase['targetId']?.toString() ?? '-';
    final dueAt = DateTime.tryParse(moderationCase['dueAt']?.toString() ?? '');
    final actions = (moderationCase['actions'] as List?) ?? const [];
    return _AdminCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.verified_user_rounded,
                color: _severityColor(severity),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  moderationCase['title']?.toString() ?? '운영 케이스',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: SDS.fwBold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Chip(label: Text(_moderationStatusLabel(status))),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoChip(label: _severityLabel(severity)),
              _InfoChip(label: '$targetType #$targetId'),
              if (dueAt != null) _InfoChip(label: _slaLabel(dueAt)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            moderationCase['summary']?.toString() ?? '상세 메모 없음',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          if (actions.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              '최근 조치 ${actions.first['type'] ?? ''}',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
          const SizedBox(height: 12),
          _ModerationActions(caseId: id, targetType: targetType),
        ],
      ),
    );
  }
}

class _ModerationActions extends StatelessWidget {
  const _ModerationActions({required this.caseId, required this.targetType});

  final int caseId;
  final String targetType;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (targetType == 'STORE') ...[
          OutlinedButton.icon(
            onPressed: caseId == 0
                ? null
                : () => _run(context, 'TEMP_HIDE_TARGET'),
            icon: const Icon(Icons.visibility_off_rounded, size: 18),
            label: const Text('임시 숨김'),
          ),
          OutlinedButton.icon(
            onPressed: caseId == 0
                ? null
                : () => _run(context, 'RESTORE_TARGET'),
            icon: const Icon(Icons.visibility_rounded, size: 18),
            label: const Text('복구'),
          ),
        ],
        if (targetType == 'DEAL')
          OutlinedButton.icon(
            onPressed: caseId == 0 ? null : () => _run(context, 'FORCE_END_DEAL'),
            icon: const Icon(Icons.stop_circle_outlined, size: 18),
            label: const Text('딜 종료'),
          ),
        if (targetType == 'RESERVATION')
          OutlinedButton.icon(
            onPressed: caseId == 0
                ? null
                : () => _run(context, 'REFUND_RESERVATION'),
            icon: const Icon(Icons.payments_outlined, size: 18),
            label: const Text('환불'),
          ),
        OutlinedButton.icon(
          onPressed: caseId == 0
              ? null
              : () => _run(context, 'BLOCK_MERCHANT_DEALS', durationHours: 24),
          icon: const Icon(Icons.block_rounded, size: 18),
          label: const Text('딜 차단'),
        ),
        FilledButton.icon(
          onPressed: caseId == 0 ? null : () => _run(context, 'RESOLVE_CASE'),
          icon: const Icon(Icons.check_rounded, size: 18),
          label: const Text('해결'),
        ),
        OutlinedButton.icon(
          onPressed: caseId == 0 ? null : () => _run(context, 'REJECT_CASE'),
          icon: const Icon(Icons.close_rounded, size: 18),
          label: const Text('반려'),
        ),
      ],
    );
  }

  Future<void> _run(
    BuildContext context,
    String type, {
    int? durationHours,
  }) async {
    final note = await _askModerationNote(context, type);
    if (note == null) return;
    if (!context.mounted) return;
    await context.read<AppDataProvider>().runModerationAction(
      caseId,
      type,
      note: note,
      durationHours: durationHours,
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
      ),
    );
  }
}

class _LogTile extends StatelessWidget {
  const _LogTile({required this.log});

  final Map<String, dynamic> log;

  @override
  Widget build(BuildContext context) {
    final type = log['type']?.toString() ?? 'LOG';
    final action = log['action']?.toString();
    final method = log['method']?.toString();
    final path = log['path']?.toString();
    final status = log['statusCode']?.toString();
    return _AdminCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.receipt_long_rounded, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type,
                  style: const TextStyle(
                    fontWeight: SDS.fwBold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  action ?? '${method ?? ''} ${path ?? ''}'.trim(),
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                if (status != null)
                  Text(
                    'status $status',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MarketSheet extends StatefulWidget {
  const _MarketSheet({this.market, this.marketId});

  final MarketInfo? market;
  final int? marketId;

  @override
  State<_MarketSheet> createState() => _MarketSheetState();
}

class _MarketSheetState extends State<_MarketSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  late final TextEditingController _regionController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _hoursController;
  late final TextEditingController _latitudeController;
  late final TextEditingController _longitudeController;
  late final TextEditingController _mapWidthController;
  late final TextEditingController _mapHeightController;
  bool _submitting = false;

  bool get _isEditing => widget.marketId != null;

  @override
  void initState() {
    super.initState();
    final market = widget.market;
    _nameController = TextEditingController(text: market?.name ?? '');
    _addressController = TextEditingController(text: market?.address ?? '');
    _regionController = TextEditingController(
      text: market == null || market.highlights.isEmpty
          ? '서울'
          : market.highlights.first,
    );
    _descriptionController = TextEditingController(
      text: market?.description ?? '',
    );
    _hoursController = TextEditingController(
      text: market == null || market.highlights.length < 2
          ? '09:00-20:00'
          : market.highlights[1],
    );
    _latitudeController = TextEditingController(text: '37.4836');
    _longitudeController = TextEditingController(text: '126.9294');
    _mapWidthController = TextEditingController(text: '1000');
    _mapHeightController = TextEditingController(text: '700');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _regionController.dispose();
    _descriptionController.dispose();
    _hoursController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _mapWidthController.dispose();
    _mapHeightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _SheetFrame(
      title: _isEditing ? '시장 수정' : '시장 등록',
      submitting: _submitting,
      submitLabel: _isEditing ? '수정' : '등록',
      onSubmit: _submit,
      children: [
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(labelText: '시장명'),
        ),
        TextField(
          controller: _addressController,
          decoration: const InputDecoration(labelText: '주소'),
        ),
        TextField(
          controller: _regionController,
          decoration: const InputDecoration(labelText: '지역'),
        ),
        TextField(
          controller: _descriptionController,
          decoration: const InputDecoration(labelText: '설명'),
        ),
        TextField(
          controller: _hoursController,
          decoration: const InputDecoration(labelText: '운영시간'),
        ),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _latitudeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: '위도'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _longitudeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: '경도'),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _mapWidthController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: '지도 너비'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _mapHeightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: '지도 높이'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (_nameController.text.trim().isEmpty ||
        _addressController.text.trim().isEmpty) {
      return;
    }

    final body = {
      'name': _nameController.text.trim(),
      'address': _addressController.text.trim(),
      'region': _regionController.text.trim(),
      'description': _descriptionController.text.trim(),
      'operatingHours': _hoursController.text.trim(),
      'latitude': _double(_latitudeController.text, 37.4836),
      'longitude': _double(_longitudeController.text, 126.9294),
      'mapWidth': _double(_mapWidthController.text, 1000),
      'mapHeight': _double(_mapHeightController.text, 700),
    };

    setState(() => _submitting = true);
    final data = context.read<AppDataProvider>();
    if (_isEditing) {
      await data.updateMarket(widget.marketId!, body);
    } else {
      await data.createMarket(body);
    }
    await data.loadAdminData();
    if (mounted) Navigator.pop(context);
  }
}

class _AdminStoreSheet extends StatefulWidget {
  const _AdminStoreSheet({required this.store});

  final Map<String, dynamic> store;

  @override
  State<_AdminStoreSheet> createState() => _AdminStoreSheetState();
}

class _AdminStoreSheetState extends State<_AdminStoreSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _categoryController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _openingController;
  late final TextEditingController _closingController;
  late final TextEditingController _paymentController;
  late final TextEditingController _addressController;
  late final TextEditingController _mapXController;
  late final TextEditingController _mapYController;
  String _businessStatus = 'OPEN';
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.store['name']?.toString() ?? '',
    );
    _categoryController = TextEditingController(
      text: widget.store['category']?.toString() ?? '기타',
    );
    _descriptionController = TextEditingController(
      text: widget.store['description']?.toString() ?? '',
    );
    _openingController = TextEditingController(
      text: widget.store['openingTime']?.toString() ?? '09:00',
    );
    _closingController = TextEditingController(
      text: widget.store['closingTime']?.toString() ?? '20:00',
    );
    _paymentController = TextEditingController(
      text: _joinList(widget.store['paymentMethods']),
    );
    _addressController = TextEditingController(
      text: widget.store['addressDetail']?.toString() ?? '',
    );
    _mapXController = TextEditingController(
      text: widget.store['mapX']?.toString() ?? '',
    );
    _mapYController = TextEditingController(
      text: widget.store['mapY']?.toString() ?? '',
    );
    final status = widget.store['businessStatus']?.toString();
    if (status == 'OPEN' || status == 'CLOSED' || status == 'BREAK') {
      _businessStatus = status!;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    _openingController.dispose();
    _closingController.dispose();
    _paymentController.dispose();
    _addressController.dispose();
    _mapXController.dispose();
    _mapYController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _SheetFrame(
      title: '점포 수정',
      submitting: _submitting,
      submitLabel: '저장',
      onSubmit: _submit,
      children: [
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(labelText: '점포명'),
        ),
        TextField(
          controller: _categoryController,
          decoration: const InputDecoration(labelText: '카테고리'),
        ),
        TextField(
          controller: _descriptionController,
          decoration: const InputDecoration(labelText: '설명'),
        ),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _openingController,
                decoration: const InputDecoration(labelText: '오픈 시간'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _closingController,
                decoration: const InputDecoration(labelText: '마감 시간'),
              ),
            ),
          ],
        ),
        DropdownButtonFormField<String>(
          initialValue: _businessStatus,
          decoration: const InputDecoration(labelText: '영업 상태'),
          items: const [
            DropdownMenuItem(value: 'OPEN', child: Text('영업중')),
            DropdownMenuItem(value: 'BREAK', child: Text('준비중')),
            DropdownMenuItem(value: 'CLOSED', child: Text('휴무')),
          ],
          onChanged: (value) {
            if (value != null) setState(() => _businessStatus = value);
          },
        ),
        TextField(
          controller: _paymentController,
          decoration: const InputDecoration(labelText: '결제 수단, 쉼표로 구분'),
        ),
        TextField(
          controller: _addressController,
          decoration: const InputDecoration(labelText: '상세 위치'),
        ),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _mapXController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: '지도 X'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _mapYController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: '지도 Y'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _submit() async {
    final storeId = _asInt(widget.store['id']);
    if (storeId == 0 || _nameController.text.trim().isEmpty) return;
    setState(() => _submitting = true);
    final body = {
      'name': _nameController.text.trim(),
      'category': _categoryController.text.trim().isEmpty
          ? '기타'
          : _categoryController.text.trim(),
      'description': _descriptionController.text.trim(),
      'openingTime': _openingController.text.trim(),
      'closingTime': _closingController.text.trim(),
      'businessStatus': _businessStatus,
      'paymentMethods': _splitList(_paymentController.text),
      'addressDetail': _addressController.text.trim(),
      if (_mapXController.text.trim().isNotEmpty)
        'mapX': _double(_mapXController.text, 0),
      if (_mapYController.text.trim().isNotEmpty)
        'mapY': _double(_mapYController.text, 0),
    };
    await context.read<AppDataProvider>().updateAdminStore(storeId, body);
    if (mounted) Navigator.pop(context);
  }
}

class _ZoneSheet extends StatefulWidget {
  const _ZoneSheet({required this.marketId, this.zone});

  final int marketId;
  final Zone? zone;

  @override
  State<_ZoneSheet> createState() => _ZoneSheetState();
}

class _ZoneSheetState extends State<_ZoneSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _categoryController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _colorController;
  late final TextEditingController _boundaryController;
  bool _submitting = false;

  bool get _isEditing => widget.zone != null;

  @override
  void initState() {
    super.initState();
    final zone = widget.zone;
    _nameController = TextEditingController(text: zone?.name ?? '');
    _categoryController = TextEditingController(
      text: zone?.description.split(' 중심 구역').first ?? '',
    );
    _descriptionController = TextEditingController(
      text: zone?.description ?? '',
    );
    _colorController = TextEditingController(
      text: zone == null ? '#16A34A' : _hexColor(zone.color),
    );
    _boundaryController = TextEditingController(
      text: '80,120\n350,120\n350,430\n80,430',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    _colorController.dispose();
    _boundaryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _SheetFrame(
      title: _isEditing ? '구역 수정' : '구역 등록',
      submitting: _submitting,
      submitLabel: _isEditing ? '수정' : '등록',
      onSubmit: _submit,
      children: [
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(labelText: '구역명'),
        ),
        TextField(
          controller: _categoryController,
          decoration: const InputDecoration(labelText: '취급 품목'),
        ),
        TextField(
          controller: _descriptionController,
          decoration: const InputDecoration(labelText: '설명'),
        ),
        TextField(
          controller: _colorController,
          decoration: const InputDecoration(labelText: '색상 HEX'),
        ),
        TextField(
          controller: _boundaryController,
          minLines: 4,
          maxLines: 6,
          decoration: const InputDecoration(
            labelText: '경계 좌표',
            helperText: '한 줄에 x,y 형식으로 입력',
          ),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    setState(() => _submitting = true);
    final body = {
      'name': name,
      'category': _categoryController.text.trim(),
      'description': _descriptionController.text.trim(),
      'color': _normalizeHex(_colorController.text),
      'boundary': _parseBoundary(_boundaryController.text),
    };
    final data = context.read<AppDataProvider>();
    if (_isEditing) {
      await data.updateMarketZone(
        widget.marketId,
        _asInt(widget.zone!.id),
        body,
      );
    } else {
      await data.createMarketZone(widget.marketId, body);
    }
    await data.loadAdminData();
    if (mounted) Navigator.pop(context);
  }
}

class _SheetFrame extends StatelessWidget {
  const _SheetFrame({
    required this.title,
    required this.children,
    required this.submitting,
    required this.submitLabel,
    required this.onSubmit,
  });

  final String title;
  final List<Widget> children;
  final bool submitting;
  final String submitLabel;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: SDS.fwBlack,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
            const SizedBox(height: 16),
            FilledButton(
              onPressed: submitting ? null : onSubmit,
              child: Text(submitting ? '처리 중...' : submitLabel),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminCard extends StatelessWidget {
  const _AdminCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: child,
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Text(
        label,
        style: const TextStyle(color: AppColors.textSecondary),
      ),
    );
  }
}

int _asInt(dynamic value) => int.tryParse(value?.toString() ?? '') ?? 0;

double _double(String value, double fallback) {
  return double.tryParse(value.trim()) ?? fallback;
}

String _joinList(dynamic value) {
  if (value is List) return value.map((item) => item.toString()).join(', ');
  return value?.toString() ?? '';
}

List<String> _splitList(String value) {
  return value
      .split(',')
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .toList();
}

String _hexColor(Color color) {
  final value = color.toARGB32() & 0xFFFFFF;
  return '#${value.toRadixString(16).padLeft(6, '0').toUpperCase()}';
}

String _normalizeHex(String value) {
  final trimmed = value.trim();
  final hex = trimmed.startsWith('#') ? trimmed : '#$trimmed';
  final valid = RegExp(r'^#[0-9A-Fa-f]{6}$').hasMatch(hex);
  return valid ? hex.toUpperCase() : '#16A34A';
}

List<Map<String, double>> _parseBoundary(String value) {
  final points = <Map<String, double>>[];
  for (final line in value.split('\n')) {
    final parts = line.split(',');
    if (parts.length != 2) continue;
    final x = double.tryParse(parts[0].trim());
    final y = double.tryParse(parts[1].trim());
    if (x == null || y == null) continue;
    points.add({'x': x, 'y': y});
  }
  return points;
}

String _approvalLabel(String status) {
  switch (status) {
    case 'APPROVED':
      return '승인';
    case 'REJECTED':
      return '반려';
    default:
      return '대기';
  }
}

String _reportStatusLabel(String status) {
  switch (status) {
    case 'RESOLVED':
      return '해결';
    case 'REJECTED':
      return '반려';
    default:
      return '접수';
  }
}

String _metric(Map<String, dynamic> source, String key) {
  return int.tryParse(source[key]?.toString() ?? '')?.toString() ?? '0';
}

String _rate(Map<String, dynamic> source, String key) {
  final value = double.tryParse(source[key]?.toString() ?? '') ?? 0;
  return '${(value * 100).toStringAsFixed(1)}%';
}

String _moderationStatusLabel(String status) {
  switch (status) {
    case 'IN_REVIEW':
      return '검토';
    case 'ACTIONED':
      return '조치';
    case 'RESOLVED':
      return '해결';
    case 'REJECTED':
      return '반려';
    default:
      return '접수';
  }
}

String _severityLabel(String severity) {
  switch (severity) {
    case 'CRITICAL':
      return '긴급';
    case 'HIGH':
      return '높음';
    case 'LOW':
      return '낮음';
    default:
      return '보통';
  }
}

Color _severityColor(String severity) {
  switch (severity) {
    case 'CRITICAL':
      return const Color(0xFFB91C1C);
    case 'HIGH':
      return const Color(0xFFDC2626);
    case 'LOW':
      return const Color(0xFF64748B);
    default:
      return AppColors.primary;
  }
}

String _slaLabel(DateTime dueAt) {
  final remaining = dueAt.difference(DateTime.now());
  if (remaining.isNegative) return 'SLA 초과';
  final hours = remaining.inHours;
  if (hours > 0) return 'SLA $hours시간 남음';
  return 'SLA ${remaining.inMinutes}분 남음';
}

Future<String?> _askModerationNote(BuildContext context, String type) async {
  final controller = TextEditingController();
  final result = await showDialog<String>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(_moderationActionLabel(type)),
      content: TextField(
        controller: controller,
        minLines: 2,
        maxLines: 4,
        decoration: const InputDecoration(
          labelText: '운영 메모',
          hintText: '조치 사유를 남겨 주세요',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('취소'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, controller.text.trim()),
          child: const Text('실행'),
        ),
      ],
    ),
  );
  controller.dispose();
  return result;
}

String _moderationActionLabel(String type) {
  switch (type) {
    case 'TEMP_HIDE_TARGET':
      return '임시 숨김 실행';
    case 'RESTORE_TARGET':
      return '대상 복구';
    case 'FORCE_END_DEAL':
      return '딜 강제 종료';
    case 'REFUND_RESERVATION':
      return '예약 환불';
    case 'BLOCK_MERCHANT_DEALS':
      return '상인 딜 생성 차단';
    case 'RESOLVE_CASE':
      return '케이스 해결';
    case 'REJECT_CASE':
      return '케이스 반려';
    default:
      return '운영 조치';
  }
}
