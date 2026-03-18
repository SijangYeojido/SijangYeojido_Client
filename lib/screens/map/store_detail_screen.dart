import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/models.dart';
import '../../data/mock_data.dart';
import '../../theme/app_colors.dart';
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
    final daysSinceUpdate = store.lastUpdated != null
        ? DateTime.now().difference(store.lastUpdated!).inDays
        : null;
    final isStale = (daysSinceUpdate ?? 0) > 7;
    final fmt = NumberFormat('#,###', 'ko_KR');
    final market = MockData.getMarket(store.marketName);

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Center(
          child: ShrinkableButton(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.8),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.textPrimary),
            ),
          ),
        ),
        actions: [
          Center(
            child: ListenableBuilder(
              listenable: FavoriteService(),
              builder: (context, _) {
                final isFav = FavoriteService().isFavorite(store.id);
                return ShrinkableButton(
                  onTap: () => FavoriteService().toggleFavorite(store.id),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.8),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        size: 20,
                        color: isFav ? Colors.redAccent : AppColors.textPrimary,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Header: Immersive Hero Area ---
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          market.accentColor.withValues(alpha: 0.15),
                          market.accentColor.withValues(alpha: 0.05),
                          AppColors.background,
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                    padding: EdgeInsets.fromLTRB(24, MediaQuery.of(context).padding.top + 40, 24, 40),
                    child: Column(
                      children: [
                        Hero(
                          tag: 'store_image_${store.id}',
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(40),
                              border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.15),
                                  blurRadius: 40,
                                  offset: const Offset(0, 15),
                                ),
                                BoxShadow(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  blurRadius: 20,
                                  offset: const Offset(0, -10),
                                  spreadRadius: -5,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Icon(
                                _iconForCategory(store.category),
                                size: 56,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                                          // --- Store Title and Quick Stats (V6 Staggered Entry) ---
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 30 * (1 - value)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: market.accentColor.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        store.category,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w900,
                                          color: market.accentColor,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    if (store.unitNumber != null)
                                      Text(
                                        '호수: ${store.unitNumber}',
                                        style: textTheme.bodySmall?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textTertiary,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  store.name,
                                  style: textTheme.headlineMedium?.copyWith(
                                    fontSize: 28, // Scaled down for better fit
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.textPrimary,
                                    letterSpacing: -1.0,
                                    height: 1.25,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _StatusBadge(status: store.status),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                        const SizedBox(height: 24),
                        if (zone != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(100),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.location_on_rounded, size: 16, color: market.accentColor.withValues(alpha: 0.5)),
                                const SizedBox(width: 8),
                                Text(
                                  '${zone.name} • ${store.unitNumber ?? "위치 정보 없음"}',
                                  style: textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (daysSinceUpdate != null) ...[
                          const SizedBox(height: 16),
                          Text(
                            '마지막 업데이트: ${daysSinceUpdate == 0 ? "오늘" : daysSinceUpdate == 1 ? "어제" : "$daysSinceUpdate일 전"} (${store.infoSource ?? "시스템 제보"})',
                            style: textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: isStale ? AppColors.warning : AppColors.textTertiary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // --- Details Sections ---
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                    child: Column(
                      children: [
                        // Payment methods
                        _SectionCard(
                          title: '결제 수단',
                          child: store.paymentMethods.isEmpty
                              ? AppEmptyState(
                                  icon: Icons.payments_outlined,
                                  title: '결제 수단 정보가 없어요',
                                  description: '방문 후 결제 방식을 알려주시면\n더 정확하게 안내할게요',
                                )
                              : Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: store.paymentMethods
                                      .map((m) => _PaymentChip(method: m))
                                      .toList(),
                                ),
                        ),

                        const SizedBox(height: 16),

                        // Items
                        _SectionCard(
                          title: '대표 상품',
                          child: store.items.isEmpty
                              ? AppEmptyState(
                                  icon: Icons.inventory_2_outlined,
                                  title: '대표 상품이 아직 등록되지 않았어요',
                                  description: '이 가게에서 많이 파는 상품을\n알려주시면 빠르게 반영할게요',
                                )
                              : Column(
                                  children: store.items.asMap().entries.map((entry) {
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 12),
                                      child: Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: AppColors.background,
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 32,
                                              height: 32,
                                              decoration: BoxDecoration(
                                                gradient: AppUI.primaryGradient,
                                                shape: BoxShape.circle,
                                              ),
                                              alignment: Alignment.center,
                                              child: Text(
                                                '${entry.key + 1}',
                                                style: textTheme.labelSmall?.copyWith(
                                                  fontWeight: FontWeight.w900,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 14),
                                            Expanded(
                                              child: Text(
                                                entry.value.name,
                                                style: textTheme.bodyLarge?.copyWith(
                                                  fontWeight: FontWeight.w700,
                                                  color: AppColors.textPrimary,
                                                ),
                                              ),
                                            ),
                                            if (entry.value.price != null)
                                              Text(
                                                '${fmt.format(entry.value.price)}원',
                                                style: textTheme.titleMedium?.copyWith(
                                                  fontWeight: FontWeight.w900,
                                                  color: AppColors.textPrimary,
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
          ),
        ],
      ),
      // --- Floating Control Center (V6 Capsule Design) ---
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Container(
            height: 84,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(100), // Perfect Capsule
              boxShadow: [
                BoxShadow(
                  color: market.accentColor.withValues(alpha: 0.15),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                  spreadRadius: -5,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
              border: Border.all(
                color: market.accentColor.withValues(alpha: 0.1),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                const SizedBox(width: 12),
                _ActionIconBtn(
                  icon: Icons.phone_rounded,
                  label: '전화',
                  onTap: () {},
                ),
                const SizedBox(width: 8),
                _ActionIconBtn(
                  icon: Icons.share_rounded,
                  label: '공유',
                  onTap: () {},
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: ShrinkableButton(
                    onTap: () {
                      // Logic for reservation would go here
                    },
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            market.accentColor,
                            market.accentColor.withValues(alpha: 0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(100),
                        boxShadow: [
                          BoxShadow(
                            color: market.accentColor.withValues(alpha: 0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          '지금 예약하기',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialReviews(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final storeReviews = MockData.reviews.where((r) => r.storeId == store.id).toList();

    return _SectionCard(
      title: '방문자 리뷰 💬',
      child: storeReviews.isEmpty
          ? AppEmptyState(
              icon: Icons.rate_review_outlined,
              title: '첫 번째 리뷰를 남겨주세요',
              description: '직접 방문한 경험을 공유하면\n다른 분들에게 큰 도움이 성돼요!',
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
                ShrinkableButton(
                  onTap: () {},
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
            ),
    );
  }

  Widget _buildRealTimeInsight(BuildContext context) {
    if (store.freshness == null && store.inventoryStatus == null) return const SizedBox.shrink();
    
    final textTheme = Theme.of(context).textTheme;
    return _SectionCard(
      title: '실시간 현황 ⚡',
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
                            '품질 신선도',
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
                      '재고 상태',
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

  IconData _iconForCategory(String category) {
    if (category.contains('먹거리')) return Icons.restaurant_rounded;
    if (category.contains('수산')) return Icons.set_meal_rounded;
    if (category.contains('정육')) return Icons.kebab_dining_rounded;
    if (category.contains('과일') || category.contains('채소')) return Icons.eco_rounded;
    if (category.contains('건어물')) return Icons.water_drop_rounded;
    return Icons.storefront_rounded;
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
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
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _iconFor(method),
            size: 18,
            color: color,
          ),
          const SizedBox(width: 8),
          Text(
            method.label,
            style: textTheme.labelLarge?.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: color,
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
        return const Color(0xFF16A34A);
      case PaymentMethod.card:
        return const Color(0xFF2563EB);
      case PaymentMethod.zeroPay:
        return const Color(0xFF00C7AE);
      case PaymentMethod.kakao:
        return const Color(0xFFFFE812);
    }
  }
}

class _ActionIconBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionIconBtn({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ShrinkableButton(
        onTap: onTap,
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: AppColors.textSecondary),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textSecondary,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
