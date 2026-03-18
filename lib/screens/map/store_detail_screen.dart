import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/models.dart';
import '../../data/mock_data.dart';
import '../../theme/app_colors.dart';
import '../../widgets/shrinkable_button.dart';
import '../../widgets/app_ui.dart';

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
            child: ShrinkableButton(
              onTap: () {},
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.8),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.favorite_border_rounded, size: 20, color: AppColors.textPrimary),
                ),
              ),
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
                          AppColors.primary.withValues(alpha: 0.15),
                          AppColors.background,
                        ],
                      ),
                    ),
                    padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 50, 20, 32),
                    child: Column(
                      children: [
                        Hero(
                          tag: 'store_image_${store.id}',
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(32),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.12),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Icon(
                                _iconForCategory(store.category),
                                size: 52,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          store.name,
                          textAlign: TextAlign.center,
                          style: textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                            letterSpacing: -1.0,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.surface.withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(100),
                                border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
                              ),
                              child: Text(
                                store.category,
                                style: textTheme.labelLarge?.copyWith(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _StatusBadge(status: store.status),
                          ],
                        ),
                        const SizedBox(height: 20),
                        if (zone != null) 
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: zone.color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.location_on_rounded, size: 16, color: zone.color),
                                const SizedBox(width: 6),
                                Text(
                                  '${zone.name}구역${store.unitNumber != null ? " · ${store.unitNumber}호" : ""}',
                                  style: textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: zone.color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (daysSinceUpdate != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isStale
                                  ? AppColors.warningLight
                                  : AppColors.surface.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isStale
                                      ? Icons.report_problem_rounded
                                      : Icons.update_rounded,
                                  size: 14,
                                  color: isStale
                                      ? AppColors.warning
                                      : AppColors.textTertiary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${daysSinceUpdate == 0 ? "오늘" : daysSinceUpdate == 1 ? "어제" : "$daysSinceUpdate일 전"} 업데이트 · ${store.infoSource ?? "시스템 제보"}',
                                  style: textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
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
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // --- Bottom Fixed Action Bar ---
          Container(
            padding: EdgeInsets.fromLTRB(
              20,
              16,
              20,
              MediaQuery.of(context).padding.bottom + 16,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.95),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 30,
                  offset: const Offset(0, -10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ShrinkableButton(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: AppUI.primaryGradient,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.25),
                                blurRadius: 15,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.map_rounded, color: Colors.white, size: 20),
                                const SizedBox(width: 10),
                                Text(
                                  '지도에서 위치 보기',
                                  style: textTheme.titleMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.directions_rounded,
                        label: '길찾기',
                        onTap: () {},
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.bookmark_border_rounded,
                        label: '즐겨찾기',
                        onTap: () {},
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.report_gmailerrorred_rounded,
                        label: '정보 신고',
                        onTap: () {},
                        isDestructive: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
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

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        isDestructive ? AppColors.textTertiary : AppColors.textSecondary;
    return ShrinkableButton(
      onTap: onTap,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: color,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
