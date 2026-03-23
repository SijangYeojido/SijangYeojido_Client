import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/models.dart';
import '../../data/mock_data.dart';
import '../../theme/app_colors.dart';
import '../../theme/sijang_design_system.dart';
import '../../widgets/sds_widgets.dart';
import '../../widgets/shrinkable_button.dart';
import '../../widgets/app_ui.dart';
import '../../services/favorite_service.dart';

class StoreDetailScreen extends StatelessWidget {
  final Store store;
  const StoreDetailScreen({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final zone = MockData.getZoneById(store.zoneId);
    // final daysSinceUpdate = store.lastUpdated != null
    //     ? DateTime.now().difference(store.lastUpdated!).inDays
    //     : null;

    // final isStale = (daysSinceUpdate ?? 0) > 7;

    final fmt = NumberFormat('#,###', 'ko_KR');
    final market = MockData.getMarket(store.marketName);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── Premium Cinematic Top Bar (V16) ──────────────────────────
          SDS.topBar(
            context: context,
            title: store.name,
            subtitle: '${market.name}에서 사랑받는 점포예요',
            actions: [
              ListenableBuilder(
                listenable: FavoriteService(),
                builder: (context, _) {
                  final isFav = FavoriteService().isFavorite(store.id);
                  return _ActionIconButton(
                    icon: isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: isFav ? Colors.redAccent : AppColors.textPrimary,
                    onTap: () => FavoriteService().toggleFavorite(store.id),
                  );
                },
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
                                const Icon(Icons.location_on_rounded, size: 16, color: AppColors.textTertiary),
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
                              '방금 따끈따끈한 소식이 도착했어요',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: SDS.fwBold,
                                color: market.accentColor,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                        child: Column(
                          children: [
                            _SectionCard(
                              title: '결제 수단',
                              delayMs: 400,
                              child: store.paymentMethods.isEmpty
                                  ? AppEmptyState(
                                      icon: Icons.payments_outlined,
                                      title: '어떤 결제 수단을 받으시나요?',
                                      description: '직접 결제해본 경험을 알려주시면\n다른 분들에게 큰 도움이 돼요',
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
                            _SectionCard(
                              title: '대표 상품',
                              delayMs: 500,
                              child: store.items.isEmpty
                                  ? AppEmptyState(
                                      icon: Icons.inventory_2_outlined,
                                      title: '이 가게의 대표 상품을 알고 싶어요',
                                      description: '가장 자신 있는 상품을 알려주시면\n이곳에 정성껏 소개해 드릴게요',
                                    )
                                  : Column(
                                      children: store.items.asMap().entries.map((entry) {
                                        final item = entry.value;
                                        return Padding(
                                          padding: const EdgeInsets.only(bottom: 16),
                                          child: Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: AppColors.background,
                                              borderRadius: BorderRadius.circular(20),
                                              border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
                                            ),
                                            child: Row(
                                              children: [
                                                ClipRRect(
                                                  borderRadius: BorderRadius.circular(12),
                                                  child: item.imageUrl != null
                                                      ? Image.network(
                                                          item.imageUrl!,
                                                          width: 80,
                                                          height: 80,
                                                          fit: BoxFit.cover,
                                                          errorBuilder: (context, error, stackTrace) => Container(
                                                            width: 80,
                                                            height: 80,
                                                            color: AppColors.border.withValues(alpha: 0.3),
                                                            child: const Icon(Icons.image_not_supported_rounded, color: AppColors.textTertiary),
                                                          ),
                                                        )
                                                      : Container(
                                                          width: 80,
                                                          height: 80,
                                                          color: AppColors.border.withValues(alpha: 0.3),
                                                          child: const Icon(Icons.image_outlined, color: AppColors.textTertiary),
                                                        ),
                                                ),
                                                const SizedBox(width: 16),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        item.name,
                                                        maxLines: 2,
                                                        overflow: TextOverflow.ellipsis,
                                                        style: textTheme.titleMedium?.copyWith(
                                                          fontWeight: SDS.fwBold,
                                                          color: AppColors.textPrimary,
                                                          letterSpacing: -0.5,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      if (item.price != null)
                                                        Text(
                                                          '${fmt.format(item.price)}원',
                                                          style: textTheme.titleLarge?.copyWith(
                                                            fontWeight: SDS.fwBlack,
                                                            color: AppColors.primary,
                                                            letterSpacing: -0.5,
                                                          ),
                                                        ),
                                                    ],
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
        padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).padding.bottom + 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: SDS.shadowPremium,
          border: const Border(top: BorderSide(color: Color(0xFFF2F4F6))),
        ),
        child: Row(
          children: [
            ShrinkableButton(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${store.name}으로 전화를 연결해요!')),
                );
              },
              child: Container(
                width: 52,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F4F6),
                  borderRadius: BorderRadius.circular(SDS.radiusM),
                ),
                child: const Icon(Icons.phone_rounded, color: AppColors.textPrimary, size: 22),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ShrinkableButton(
                onTap: () => Navigator.pop(context, true),
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(SDS.radiusM),
                    boxShadow: SDS.shadowAccent(AppColors.primary),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.directions_rounded, color: Colors.white, size: 22),
                      SizedBox(width: 10),
                      Text(
                        '길 안내 시작',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: SDS.fwBlack,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialReviews(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final storeReviews = MockData.reviews.where((r) => r.storeId == store.id).toList();

    return _SectionCard(
      title: '방문자 리뷰',
      child: storeReviews.isEmpty
          ? Column(
              children: [
                AppEmptyState(
                  icon: Icons.rate_review_outlined,
                  title: '다녀오신 후 리뷰를 남겨주세요',
                  description: '직접 방문한 경험을 들려주시면\n다른 분들에게 큰 도움이 돼요!',
                ),
                const SizedBox(height: 12),
                ShrinkableButton(
                  onTap: () => _showReviewSubmitSheet(context),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        '리뷰 쓰기',
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          : Column(
              children: [
                ...storeReviews.map((review) => Padding(
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
                                    Icon(Icons.star_rounded, size: 12, color: Colors.amber[600]),
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
                            style: textTheme.bodySmall?.copyWith(color: AppColors.textTertiary),
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
                            separatorBuilder: (context, index) => const SizedBox(width: 8),
                            itemBuilder: (context, idx) => ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                review.images[idx],
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  width: 100,
                                  height: 100,
                                  color: AppColors.border.withValues(alpha: 0.3),
                                  child: const Icon(Icons.image_not_supported_rounded, color: AppColors.textTertiary),
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
                )),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ShrinkableButton(
                        onTap: () {},
                        child: Container(
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
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ShrinkableButton(
                        onTap: () => _showReviewSubmitSheet(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Text(
                              '리뷰 쓰기',
                              style: textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildRealTimeInsight(BuildContext context) {
    if (store.freshness == null && store.inventoryStatus == null) return const SizedBox.shrink();
    
    final textTheme = Theme.of(context).textTheme;
    return _SectionCard(
      title: '지금 가게 상황은 어때요?',
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
                          const Icon(Icons.verified_rounded, color: Color(0xFF10B981), size: 16),
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
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
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
                    const Icon(Icons.inventory_2_rounded, color: AppColors.primary, size: 16),
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
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: store.inventoryStatus == '품절' ? Colors.red.withValues(alpha: 0.1) : AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    store.inventoryStatus!,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: store.inventoryStatus == '품절' ? Colors.red : AppColors.primary,
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 24),
            Text('방문은 어떠셨나요?', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: SDS.fwBlack, letterSpacing: SDS.lsTight)),
            const SizedBox(height: 8),
            Text('이 가게에 대한 솔직한 후기를 들려주세요.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) => Icon(Icons.star_rounded, size: 40, color: index < 4 ? AppColors.warning : AppColors.divider)),
            ),
            const SizedBox(height: 24),
            TextField(
              maxLines: 4,
              decoration: InputDecoration(
                hintText: '음식의 맛, 서비스, 분위기 등에 대해 알려주세요.',
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 24),
            AppPrimaryButton(
              label: '리뷰를 등록할게요',
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('리뷰가 성공적으로 등록되었어요!')));
              },
            ),
          ],
        ),
      ),
    );
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
            child: Icon(
              _iconFor(method),
              size: 16,
              color: color,
            ),
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
