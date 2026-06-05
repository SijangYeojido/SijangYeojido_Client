import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/mock_data.dart';
import '../../models/models.dart';
import '../../providers/app_data_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/sijang_design_system.dart';
import '../../widgets/sds_widgets.dart';
import '../../widgets/shrinkable_button.dart';
import '../../widgets/app_ui.dart';
import '../../services/favorite_service.dart';
import '../market/market_map_simple_screen.dart';
import '../pickup/pickup_screen.dart';

class StoreDetailScreen extends StatelessWidget {
  final Store store;
  const StoreDetailScreen({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final data = context.watch<AppDataProvider>();
    final zone = data.getZoneById(store.zoneId);
    // final daysSinceUpdate = store.lastUpdated != null
    //     ? DateTime.now().difference(store.lastUpdated!).inDays
    //     : null;

    // final isStale = (daysSinceUpdate ?? 0) > 7;

    final fmt = NumberFormat('#,###', 'ko_KR');
    final market = data.getMarket(store.marketName);
    final liveDeals = data.flashDeals
        .where((deal) => deal.storeId == store.id && !deal.isExpired)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── Premium Cinematic Top Bar (V16) ──────────────────────────
          SDS.topBar(
            context: context,
            title: store.name,
            subtitle: '${market.name}에서 사랑받는 점포예요 ✨',
            actions: [
              if (store.items.isNotEmpty) ...[
                Semantics(
                  label: 'product-compare',
                  button: true,
                  onTap: () =>
                      _showProductInsightSheet(context, store.items.first),
                  excludeSemantics: true,
                  child: _ActionIconButton(
                    icon: Icons.compare_arrows_rounded,
                    onTap: () =>
                        _showProductInsightSheet(context, store.items.first),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              ListenableBuilder(
                listenable: FavoriteService(),
                builder: (context, _) {
                  final isFav = FavoriteService().isFavorite(store.id);
                  return _ActionIconButton(
                    icon: isFav
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: isFav ? Colors.redAccent : AppColors.textPrimary,
                    onTap: () => FavoriteService().toggleFavorite(store.id),
                  );
                },
              ),
              const SizedBox(width: 8),
              Semantics(
                label: 'report-store',
                button: true,
                onTap: () => _showReportSheet(context),
                excludeSemantics: true,
                child: _ActionIconButton(
                  icon: Icons.flag_outlined,
                  onTap: () => _showReportSheet(context),
                ),
              ),
              const SizedBox(width: 8),
              _ActionIconButton(
                icon: Icons.share_rounded,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${store.name} 정보를 친구와 나누어 보세요!')),
                  );
                },
              ),
            ],
          ),
          Expanded(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- Header: Immersive Hero Area ---
                      Container(
                        width: double.infinity,
                        height: 380,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppColors.primary.withValues(alpha: 0.1),
                              AppColors.background,
                            ],
                          ),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Positioned(
                              top: -100,
                              child: Container(
                                width: 500,
                                height: 500,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      AppColors.primary.withValues(alpha: 0.15),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SDSFadeIn(
                                  delay: Duration(milliseconds: 200),
                                  child: SDSLogo(size: 180),
                                ),
                                const SizedBox(height: 32),
                                const SDSFadeIn(
                                  delay: Duration(milliseconds: 400),
                                  child: Text(
                                    '지금 이 가게는요',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: SDS.fwBold,
                                      color: AppColors.textSecondary,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                SDSFadeIn(
                                  delay: const Duration(milliseconds: 600),
                                  child: _StatusBadge(status: store.status),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              store.name,
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: SDS.fwBlack,
                                letterSpacing: SDS.lsTight,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on_rounded,
                                  size: 16,
                                  color: AppColors.textTertiary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${zone?.name ?? ""} • ${store.unitNumber ?? ""}호',
                                  style: const TextStyle(
                                    fontWeight: SDS.fwBold,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '방금 따끈따끈한 소식이 도착했어요 ✨',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: SDS.fwBold,
                                color: market.accentColor,
                                letterSpacing: -0.3,
                              ),
                            ),
                            if (store.items.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              Semantics(
                                label: 'product-compare',
                                button: true,
                                onTap: () => _showProductInsightSheet(
                                  context,
                                  store.items.first,
                                ),
                                excludeSemantics: true,
                                child: OutlinedButton.icon(
                                  onPressed: () => _showProductInsightSheet(
                                    context,
                                    store.items.first,
                                  ),
                                  icon: const Icon(
                                    Icons.compare_arrows_rounded,
                                    size: 18,
                                  ),
                                  label: const Text('상품 가격 비교/이력 보기'),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                        child: Column(
                          children: [
                            _SectionCard(
                              title: '운영 정보',
                              delayMs: 300,
                              child: Column(
                                children: [
                                  _StoreInfoRow(
                                    icon: Icons.schedule_rounded,
                                    label: '영업시간',
                                    value:
                                        '${store.openingTime ?? '--:--'} - ${store.closingTime ?? '--:--'}',
                                  ),
                                  _StoreInfoRow(
                                    icon: Icons.event_busy_rounded,
                                    label: '휴무',
                                    value:
                                        [
                                          ...store.regularHolidays,
                                          ...store.temporaryHolidays.map(
                                            (day) => '임시 $day',
                                          ),
                                        ].isEmpty
                                        ? '휴무 정보 없음'
                                        : [
                                            ...store.regularHolidays,
                                            ...store.temporaryHolidays.map(
                                              (day) => '임시 $day',
                                            ),
                                          ].join(', '),
                                  ),
                                  _StoreInfoRow(
                                    icon: Icons.place_rounded,
                                    label: '상세 위치',
                                    value:
                                        store.addressDetail?.isNotEmpty == true
                                        ? store.addressDetail!
                                        : '${zone?.name ?? ""} ${store.unitNumber ?? ""}호',
                                  ),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton.icon(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                MarketMapSimpleScreen(
                                                  marketName: store.marketName,
                                                ),
                                          ),
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.map_outlined,
                                        size: 18,
                                      ),
                                      label: const Text('지도에서 위치 보기'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (store.imageUrls.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              _SectionCard(
                                title: '점포 사진',
                                delayMs: 350,
                                child: SizedBox(
                                  height: 112,
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: store.imageUrls.length,
                                    separatorBuilder: (context, index) =>
                                        const SizedBox(width: 10),
                                    itemBuilder: (context, index) => ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        store.imageUrls[index],
                                        width: 132,
                                        height: 112,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (
                                              context,
                                              error,
                                              stackTrace,
                                            ) => Container(
                                              width: 132,
                                              height: 112,
                                              color: AppColors.border
                                                  .withValues(alpha: 0.3),
                                              child: const Icon(
                                                Icons
                                                    .image_not_supported_rounded,
                                                color: AppColors.textTertiary,
                                              ),
                                            ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 16),
                            _SectionCard(
                              title: '결제 수단',
                              delayMs: 400,
                              child: store.paymentMethods.isEmpty
                                  ? AppEmptyState(
                                      icon: Icons.payments_outlined,
                                      title: '어떤 결제 수단을 받으시나요?',
                                      description:
                                          '직접 결제해본 경험을 알려주시면\n다른 분들에게 큰 도움이 돼요',
                                    )
                                  : Wrap(
                                      spacing: 12,
                                      runSpacing: 12,
                                      children: store.paymentMethods
                                          .map((m) => _PaymentChip(method: m))
                                          .toList(),
                                    ),
                            ),
                            const SizedBox(height: 16),
                            if (liveDeals.isNotEmpty) ...[
                              _SectionCard(
                                title: '지금 예약 가능한 특가 ⚡',
                                delayMs: 450,
                                child: Column(
                                  children: liveDeals
                                      .map(
                                        (deal) => _DealReservationTile(
                                          deal: deal,
                                          store: store,
                                          onReserve: () => _reserveDeal(
                                            context,
                                            store,
                                            deal,
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                            _SectionCard(
                              title: '대표 상품 🍱',
                              delayMs: 500,
                              child: store.items.isEmpty
                                  ? AppEmptyState(
                                      icon: Icons.inventory_2_outlined,
                                      title: '이 가게의 대표 상품을 알고 싶어요',
                                      description:
                                          '가장 자신 있는 상품을 알려주시면\n이곳에 정성껏 소개해 드릴게요',
                                    )
                                  : Column(
                                      children: store.items.asMap().entries.map((
                                        entry,
                                      ) {
                                        final item = entry.value;
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 16,
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: AppColors.background,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              border: Border.all(
                                                color: AppColors.border
                                                    .withValues(alpha: 0.5),
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  child: item.imageUrl != null
                                                      ? Image.network(
                                                          item.imageUrl!,
                                                          width: 80,
                                                          height: 80,
                                                          fit: BoxFit.cover,
                                                          errorBuilder:
                                                              (
                                                                context,
                                                                error,
                                                                stackTrace,
                                                              ) => Container(
                                                                width: 80,
                                                                height: 80,
                                                                color: AppColors
                                                                    .border
                                                                    .withValues(
                                                                      alpha:
                                                                          0.3,
                                                                    ),
                                                                child: const Icon(
                                                                  Icons
                                                                      .image_not_supported_rounded,
                                                                  color: AppColors
                                                                      .textTertiary,
                                                                ),
                                                              ),
                                                        )
                                                      : Container(
                                                          width: 80,
                                                          height: 80,
                                                          color: AppColors
                                                              .border
                                                              .withValues(
                                                                alpha: 0.3,
                                                              ),
                                                          child: const Icon(
                                                            Icons
                                                                .image_outlined,
                                                            color: AppColors
                                                                .textTertiary,
                                                          ),
                                                        ),
                                                ),
                                                const SizedBox(width: 16),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        item.name,
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: textTheme
                                                            .titleMedium
                                                            ?.copyWith(
                                                              fontWeight:
                                                                  SDS.fwBold,
                                                              color: AppColors
                                                                  .textPrimary,
                                                              letterSpacing:
                                                                  -0.5,
                                                            ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      if (item.price != null)
                                                        Text(
                                                          '${fmt.format(item.price)}원',
                                                          style: textTheme
                                                              .titleLarge
                                                              ?.copyWith(
                                                                fontWeight:
                                                                    SDS.fwBlack,
                                                                color: AppColors
                                                                    .primary,
                                                                letterSpacing:
                                                                    -0.5,
                                                              ),
                                                        ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        [
                                                          if (item.category !=
                                                                  null &&
                                                              item
                                                                  .category!
                                                                  .isNotEmpty)
                                                            item.category!,
                                                          if (item.unitNumber !=
                                                                  null &&
                                                              item
                                                                  .unitNumber!
                                                                  .isNotEmpty)
                                                            item.unitNumber!,
                                                          if (item.origin !=
                                                                  null &&
                                                              item
                                                                  .origin!
                                                                  .isNotEmpty)
                                                            item.origin!,
                                                          _stockLabel(
                                                            item.stockStatus,
                                                          ),
                                                        ].join(' · '),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: textTheme
                                                            .bodySmall
                                                            ?.copyWith(
                                                              color: AppColors
                                                                  .textSecondary,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Semantics(
                                                  label: 'product-compare',
                                                  button: true,
                                                  onTap: () =>
                                                      _showProductInsightSheet(
                                                        context,
                                                        item,
                                                      ),
                                                  excludeSemantics: true,
                                                  child: ShrinkableButton(
                                                    onTap: () =>
                                                        _showProductInsightSheet(
                                                          context,
                                                          item,
                                                        ),
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 16,
                                                            vertical: 8,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: AppColors.primary
                                                            .withValues(
                                                              alpha: 0.1,
                                                            ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                      ),
                                                      child: const Text(
                                                        '비교',
                                                        style: TextStyle(
                                                          color:
                                                              AppColors.primary,
                                                          fontWeight:
                                                              SDS.fwBold,
                                                          fontSize: 13,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                            ),
                            const SizedBox(height: 16),
                            _buildSocialReviews(context),
                            const SizedBox(height: 16),
                            _buildRealTimeInsight(context),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      // --- Premium Bottom Action Bar (V13) ---
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(
          20,
          12,
          20,
          MediaQuery.of(context).padding.bottom + 12,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: SDS.shadowPremium,
          border: const Border(top: BorderSide(color: Color(0xFFF2F4F6))),
        ),
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ActionIconButton(
                  icon: Icons.phone_rounded,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${store.name}으로 전화를 연결해요! 📞')),
                    );
                  },
                ),
                const SizedBox(height: 6),
                const Text(
                  '상담/전화',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: SDS.fwBold,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SDS.button(
                label: '길 안내 시작',
                isPrimary: false,
                icon: Icons.directions_rounded,
                onTap: () => _openDirections(context, market),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SDS.button(
                label: '점포 상품 예약',
                color: market.accentColor,
                onTap: () async {
                  try {
                    final appData = context.read<AppDataProvider>();
                    if (appData.isUsingCachedData) {
                      _showOfflineActionBlocked(context);
                      return;
                    }
                    final reservation = liveDeals.isNotEmpty
                        ? await appData.createReservation(
                            storeId: store.id,
                            dealId: liveDeals.first.id,
                          )
                        : await appData.createReservation(
                            storeId: store.id,
                            productId: store.items.isNotEmpty
                                ? store.items.first.id
                                : null,
                          );
                    if (!context.mounted) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PickupScreen(reservation: reservation),
                      ),
                    );
                  } catch (_) {
                    if (!context.mounted) return;
                    final message =
                        context.read<AppDataProvider>().errorMessage ??
                        '예약을 만들지 못했습니다. 잠시 후 다시 시도해 주세요.';
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(message)));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openDirections(BuildContext context, MarketInfo market) async {
    final query = [
      market.address,
      store.addressDetail,
      store.name,
    ].whereType<String>().where((value) => value.trim().isNotEmpty).join(' ');
    final destination = query.isEmpty ? store.name : query;
    final uri = Uri.https('maps.apple.com', '/', {
      'daddr': destination,
      'dirflg': 'w',
    });

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('지도 앱을 열 수 없습니다. 잠시 후 다시 시도해 주세요.')),
      );
    }
  }

  Widget _buildSocialReviews(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return _SectionCard(
      title: '방문자 리뷰 💬',
      child: FutureBuilder<List<StoreReview>>(
        future: context.read<AppDataProvider>().getReviews(store.id),
        builder: (context, snapshot) {
          final storeReviews = snapshot.data ?? const <StoreReview>[];
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (storeReviews.isEmpty) {
            return AppEmptyState(
              icon: Icons.rate_review_outlined,
              title: '다녀오신 후 리뷰를 남겨주세요',
              description: '직접 방문한 경험을 들려주시면\n다른 분들에게 큰 도움이 돼요!',
            );
          }
          return Column(
            children: [
              ...storeReviews.map(
                (review) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundImage: NetworkImage(review.userAvatar),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  review.userName,
                                  style: textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.star_rounded,
                                      size: 12,
                                      color: Colors.amber[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      review.rating.toString(),
                                      style: textTheme.labelSmall?.copyWith(
                                        color: Colors.amber[800],
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '2일 전', // Simplified for mock
                            style: textTheme.bodySmall?.copyWith(
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        review.content,
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                      if (review.images.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 100,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: review.images.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(width: 8),
                            itemBuilder: (context, idx) => ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                review.images[idx],
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                      width: 100,
                                      height: 100,
                                      color: AppColors.border.withValues(
                                        alpha: 0.3,
                                      ),
                                      child: const Icon(
                                        Icons.image_not_supported_rounded,
                                        color: AppColors.textTertiary,
                                      ),
                                    ),
                              ),
                            ),
                          ),
                        ),
                      ],
                      const Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: Divider(color: AppColors.divider, height: 1),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ShrinkableButton(
                onTap: () => _showReviewSubmitSheet(context),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      '리뷰 전체 보기',
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _reserveDeal(
    BuildContext context,
    Store store,
    FlashDeal deal,
  ) async {
    try {
      final appData = context.read<AppDataProvider>();
      if (appData.isUsingCachedData) {
        _showOfflineActionBlocked(context);
        return;
      }
      context.read<AppDataProvider>().recordAction(
        'deal.detail.view',
        metadata: {
          'storeId': store.id,
          'dealId': deal.id,
          'marketName': store.marketName,
        },
      );
      final reservation = await appData.createReservation(
        storeId: store.id,
        dealId: deal.id,
      );
      if (!context.mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PickupScreen(reservation: reservation),
        ),
      );
    } catch (_) {
      if (!context.mounted) return;
      final message =
          context.read<AppDataProvider>().errorMessage ??
          '특가 예약을 만들지 못했습니다. 잠시 후 다시 시도해 주세요.';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Widget _buildRealTimeInsight(BuildContext context) {
    if (store.freshness == null && store.inventoryStatus == null) {
      return const SizedBox.shrink();
    }

    final textTheme = Theme.of(context).textTheme;
    return _SectionCard(
      title: '지금 가게 상황은 어때요? ⚡',
      child: Column(
        children: [
          if (store.freshness != null) ...[
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.verified_rounded,
                            color: Color(0xFF10B981),
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '품질 신선도가 이만큼이에요',
                            style: textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: LinearProgressIndicator(
                          value: store.freshness! / 100,
                          minHeight: 8,
                          backgroundColor: AppColors.background,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF10B981),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Text(
                  '${store.freshness}%',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF10B981),
                  ),
                ),
              ],
            ),
          ],
          if (store.freshness != null && store.inventoryStatus != null)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(height: 1, color: AppColors.divider),
            ),
          if (store.inventoryStatus != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.inventory_2_rounded,
                      color: AppColors.primary,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '재고가 얼마나 남았을까요?',
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: store.inventoryStatus == '품절'
                        ? Colors.red.withValues(alpha: 0.1)
                        : AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    store.inventoryStatus!,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: store.inventoryStatus == '품절'
                          ? Colors.red
                          : AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  void _showReviewSubmitSheet(BuildContext context) {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          MediaQuery.of(context).viewInsets.bottom + 40,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '방문은 어떠셨나요?',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: SDS.fwBlack,
                letterSpacing: SDS.lsTight,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '이 가게에 대한 솔직한 후기를 들려주세요.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                5,
                (index) => Icon(
                  Icons.star_rounded,
                  size: 40,
                  color: index < 4 ? AppColors.warning : AppColors.divider,
                ),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: controller,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: '음식의 맛, 서비스, 분위기 등에 대해 알려주세요.',
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
            AppPrimaryButton(
              label: '리뷰를 등록할게요',
              onPressed: () async {
                final content = controller.text.trim();
                if (content.isEmpty) return;
                try {
                  await context.read<AppDataProvider>().createReview(
                    storeId: store.id,
                    rating: 4,
                    content: content,
                  );
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('리뷰가 성공적으로 등록되었어요! ✨')),
                  );
                } catch (_) {
                  if (!context.mounted) return;
                  final message =
                      context.read<AppDataProvider>().errorMessage ??
                      '리뷰를 등록하지 못했습니다. 잠시 후 다시 시도해 주세요.';
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(message)));
                }
              },
            ),
          ],
        ),
      ),
    ).whenComplete(controller.dispose);
  }

  void _showReportSheet(BuildContext context) {
    if (context.read<AppDataProvider>().isUsingCachedData) {
      _showOfflineActionBlocked(context);
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _ReportSheet(store: store),
    );
  }

  void _showOfflineActionBlocked(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('오프라인 저장 데이터에서는 예약/신고를 사용할 수 없습니다. 온라인 연결 후 다시 시도해 주세요.'),
      ),
    );
  }

  void _showProductInsightSheet(BuildContext context, StoreItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _ProductInsightSheet(store: store, item: item),
    );
  }
}

class _StoreInfoRow extends StatelessWidget {
  const _StoreInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: SDS.fwBold,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: SDS.fwMedium,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DealReservationTile extends StatelessWidget {
  const _DealReservationTile({
    required this.deal,
    required this.store,
    required this.onReserve,
  });

  final FlashDeal deal;
  final Store store;
  final VoidCallback onReserve;

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,###', 'ko_KR');
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFF04452).withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Color(0xFFF04452),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.flash_on_rounded, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  deal.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: SDS.fwBlack,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${fmt.format(deal.dealPrice)}원 · 남은 수량 ${deal.availableQuantity}',
                  style: const TextStyle(
                    fontWeight: SDS.fwBold,
                    color: Color(0xFFF04452),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          FilledButton(
            onPressed: onReserve,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFF04452),
              foregroundColor: Colors.white,
            ),
            child: const Text('예약'),
          ),
        ],
      ),
    );
  }
}

class _ProductInsightSheet extends StatefulWidget {
  const _ProductInsightSheet({required this.store, required this.item});

  final Store store;
  final StoreItem item;

  @override
  State<_ProductInsightSheet> createState() => _ProductInsightSheetState();
}

class _ProductInsightSheetState extends State<_ProductInsightSheet> {
  late final Future<_ProductInsightData> _future;
  final _fmt = NumberFormat('#,###', 'ko_KR');

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_ProductInsightData> _load() async {
    final data = context.read<AppDataProvider>();
    final marketId = data.marketIdForName(widget.store.marketName);
    final productId = int.tryParse(widget.item.id ?? '');
    final compare = await data.compareProducts(
      name: widget.item.name,
      category: widget.item.category,
      marketId: marketId,
    );
    final history = productId == null
        ? <Map<String, dynamic>>[]
        : await data.getPriceHistory(productId);
    return _ProductInsightData(compare: compare, history: history);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: FutureBuilder<_ProductInsightData>(
        future: _future,
        builder: (context, snapshot) {
          final insight = snapshot.data;
          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.item.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: SDS.fwBlack,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  [
                    if (widget.item.category != null) widget.item.category!,
                    if (widget.item.unitNumber != null) widget.item.unitNumber!,
                    if (widget.item.origin != null) widget.item.origin!,
                    _stockLabel(widget.item.stockStatus),
                  ].join(' · '),
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                if (widget.item.price != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    '${_fmt.format(widget.item.price)}원',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: SDS.fwBlack,
                      color: AppColors.primary,
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                const Text(
                  '동일 상품 가격 비교',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: SDS.fwBold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                if (snapshot.connectionState == ConnectionState.waiting)
                  const LinearProgressIndicator()
                else if (snapshot.hasError)
                  const Text(
                    '가격 비교 정보를 불러오지 못했습니다.',
                    style: TextStyle(color: AppColors.textSecondary),
                  )
                else if (insight == null || insight.compare.isEmpty)
                  const Text(
                    '비교 가능한 상품이 없습니다.',
                    style: TextStyle(color: AppColors.textSecondary),
                  )
                else
                  ...insight.compare
                      .take(5)
                      .map((product) => _ProductCompareRow(product: product)),
                const SizedBox(height: 20),
                const Text(
                  '가격 변동 이력',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: SDS.fwBold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                if (insight == null || insight.history.isEmpty)
                  const Text(
                    '아직 가격 이력이 없습니다.',
                    style: TextStyle(color: AppColors.textSecondary),
                  )
                else
                  ...insight.history
                      .take(6)
                      .map((history) => _PriceHistoryRow(history: history)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ProductCompareRow extends StatelessWidget {
  const _ProductCompareRow({required this.product});

  final Map<String, dynamic> product;

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,###', 'ko_KR');
    final price = int.tryParse(product['currentPrice']?.toString() ?? '');
    final store = product['store'] as Map<String, dynamic>?;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              store?['name']?.toString() ?? '점포',
              style: const TextStyle(color: AppColors.textPrimary),
            ),
          ),
          Text(
            price == null ? '-' : '${fmt.format(price)}원',
            style: const TextStyle(
              fontWeight: SDS.fwBold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceHistoryRow extends StatelessWidget {
  const _PriceHistoryRow({required this.history});

  final Map<String, dynamic> history;

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,###', 'ko_KR');
    final price = int.tryParse(history['price']?.toString() ?? '');
    final date = DateTime.tryParse(history['createdAt']?.toString() ?? '');
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              date == null
                  ? '변경일 미상'
                  : DateFormat('yyyy.MM.dd HH:mm', 'ko_KR').format(date),
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          Text(
            price == null ? '-' : '${fmt.format(price)}원',
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

class _ProductInsightData {
  const _ProductInsightData({required this.compare, required this.history});

  final List<Map<String, dynamic>> compare;
  final List<Map<String, dynamic>> history;
}

String _stockLabel(String? status) {
  switch ((status ?? '').toUpperCase()) {
    case 'SOLD_OUT':
      return '품절';
    case 'HIDDEN':
      return '숨김';
    case 'DISCONTINUED':
      return '판매 종료';
    default:
      return '판매중';
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final double delayMs;

  const _SectionCard({
    required this.title,
    required this.child,
    this.delayMs = 0,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SDSFadeIn(
      delay: Duration(milliseconds: delayMs.toInt()),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: SDS.space24),
        padding: const EdgeInsets.all(SDS.space24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(SDS.radiusL),
          boxShadow: SDS.shadowPremium,
          border: Border.all(color: AppColors.border.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 18,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(SDS.radiusS),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: SDS.space20),
            child,
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: status.bgColor,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: status.color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: status.color.withValues(alpha: 0.3),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            status.label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: status.color,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentChip extends StatelessWidget {
  final PaymentMethod method;
  const _PaymentChip({required this.method});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final color = _colorFor(method);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFF2F4F6), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(_iconFor(method), size: 16, color: color),
          ),
          const SizedBox(width: 8),
          Text(
            method.label,
            style: textTheme.labelLarge?.copyWith(
              fontSize: 13,
              fontWeight: SDS.fwBold,
              color: const Color(0xFF191F28), // Toss Deep Graphite
              letterSpacing: -0.4,
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconFor(PaymentMethod m) {
    switch (m) {
      case PaymentMethod.cash:
        return Icons.payments_rounded;
      case PaymentMethod.card:
        return Icons.credit_card_rounded;
      case PaymentMethod.zeroPay:
        return Icons.qr_code_2_rounded;
      case PaymentMethod.kakao:
        return Icons.chat_bubble_rounded;
    }
  }

  Color _colorFor(PaymentMethod m) {
    switch (m) {
      case PaymentMethod.cash:
        return const Color(0xFF00C896); // Toss Green
      case PaymentMethod.card:
        return const Color(0xFF3182F6); // Toss Blue
      case PaymentMethod.zeroPay:
        return const Color(0xFFFF5F2E); // Orange
      case PaymentMethod.kakao:
        return const Color(0xFFFFE812); // Kakao Yellow
    }
  }
}

// Removed unused _ActionIconBtn

class _ActionIconButton extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final VoidCallback onTap;

  const _ActionIconButton({
    required this.icon,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ShrinkableButton(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFFF2F4F6),
          borderRadius: BorderRadius.circular(SDS.radiusM),
        ),
        child: Icon(icon, color: color ?? const Color(0xFF4E5968), size: 22),
      ),
    );
  }
}

class _ReportSheet extends StatefulWidget {
  const _ReportSheet({required this.store});

  final Store store;

  @override
  State<_ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends State<_ReportSheet> {
  final _reasonController = TextEditingController();
  String _reportType = 'STORE_INFO';
  bool _submitting = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            '정보 신고',
            style: TextStyle(
              fontSize: 22,
              fontWeight: SDS.fwBlack,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _reportType,
            items: const [
              DropdownMenuItem(value: 'STORE_INFO', child: Text('점포 정보 오류')),
              DropdownMenuItem(value: 'PRICE_ERROR', child: Text('가격 오류')),
              DropdownMenuItem(value: 'LOCATION_ERROR', child: Text('위치 오류')),
              DropdownMenuItem(value: 'FAKE_STORE', child: Text('허위 점포')),
            ],
            onChanged: (value) {
              if (value != null) setState(() => _reportType = value);
            },
          ),
          TextField(
            controller: _reasonController,
            maxLines: 3,
            decoration: const InputDecoration(labelText: '내용'),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _submitting ? null : _submit,
            child: Text(_submitting ? '접수 중...' : '신고 접수'),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final targetId = int.tryParse(widget.store.id) ?? 0;
    if (targetId == 0 || _reasonController.text.trim().isEmpty) return;
    setState(() => _submitting = true);
    try {
      await context.read<AppDataProvider>().submitReport(
        reportType: _reportType,
        targetType: _reportType == 'PRICE_ERROR' ? 'PRICE' : 'STORE',
        targetId: targetId,
        reason: _reasonController.text.trim(),
        metadata: {'storeName': widget.store.name},
      );
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;
      final message =
          context.read<AppDataProvider>().errorMessage ??
          '신고를 접수하지 못했습니다. 잠시 후 다시 시도해 주세요.';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}
