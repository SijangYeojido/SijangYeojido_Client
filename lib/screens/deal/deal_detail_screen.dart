import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/models.dart';
import '../../theme/app_colors.dart';
import '../pickup/pickup_screen.dart';

class DealDetailScreen extends StatefulWidget {
  final Deal deal;
  final Store store;

  const DealDetailScreen({super.key, required this.deal, required this.store});

  @override
  State<DealDetailScreen> createState() => _DealDetailScreenState();
}

class _DealDetailScreenState extends State<DealDetailScreen> {
  late Timer _timer;
  late Duration _remaining;
  bool _payFullAmount = true;

  @override
  void initState() {
    super.initState();
    _remaining = widget.deal.expiresAt.difference(DateTime.now());
    if (_remaining.isNegative) _remaining = Duration.zero;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final diff = widget.deal.expiresAt.difference(DateTime.now());
      setState(() {
        _remaining = diff.isNegative ? Duration.zero : diff;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (h > 0) return '$h:$m:$s';
    return '$m:$s';
  }

  void _onReserve() {
    final reservation = Reservation(
      id: 'r_new_${DateTime.now().millisecondsSinceEpoch}',
      dealId: widget.deal.id,
      dealTitle: widget.deal.title,
      storeName: widget.store.name,
      quantity: 1,
      totalAmount: _payFullAmount ? widget.deal.dealPrice : 1000,
      reservedAt: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(minutes: 15)),
      pickupCode: (1000 + DateTime.now().millisecond % 9000).toString(),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PickupScreen(reservation: reservation),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,###', 'ko_KR');
    final progressValue = widget.deal.totalQty > 0
        ? widget.deal.remainingQty / widget.deal.totalQty
        : 0.0;
    final isExpired = _remaining == Duration.zero;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('특가 상세'),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Store info header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _zoneColor(widget.store.zoneId),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            widget.store.zoneId,
                            style: const TextStyle(
                              fontSize: 16,
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
                              Text(
                                widget.store.name,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                widget.store.category,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: widget.store.status.bgColor,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(
                            widget.store.status.label,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: widget.store.status.color,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Deal title & price
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tag
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primaryRed,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            '현재특가',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          widget.deal.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Price display
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${fmt.format(widget.deal.originalPrice)}원',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textTertiary,
                                    decoration: TextDecoration.lineThrough,
                                    decorationColor: AppColors.textTertiary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${fmt.format(widget.deal.dealPrice)}원',
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primaryRed,
                                  ),
                                ),
              ],
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.primaryRed,
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Text(
                                '${widget.deal.discountPercent}% 할인',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Countdown & stock
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isExpired
                          ? AppColors.divider
                          : AppColors.primaryRedLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isExpired
                            ? AppColors.border
                            : AppColors.primaryRed.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time_filled,
                                  size: 16,
                                  color: isExpired
                                      ? AppColors.textTertiary
                                      : AppColors.primaryRed,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  isExpired ? '마감됨' : '마감까지',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: isExpired
                                        ? AppColors.textTertiary
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              isExpired ? '--:--' : _formatDuration(_remaining),
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: isExpired
                                    ? AppColors.textTertiary
                                    : AppColors.primaryRed,
                                fontFeatures: const [
                                  FontFeature.tabularFigures()
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Stock progress bar
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '잔여 수량',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                Text(
                                  '${widget.deal.remainingQty} / ${widget.deal.totalQty}개',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: LinearProgressIndicator(
                                value: progressValue,
                                backgroundColor: AppColors.border,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                    AppColors.primaryRed),
                                minHeight: 8,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Description
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '상품 설명',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.deal.description,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Payment option
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '결제 방식',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _PaymentOptionTile(
                          title: '전액 결제',
                          subtitle: '${fmt.format(widget.deal.dealPrice)}원 (앱에서 결제)',
                          isSelected: _payFullAmount,
                          onTap: () => setState(() => _payFullAmount = true),
                        ),
                        const SizedBox(height: 8),
                        _PaymentOptionTile(
                          title: '예약금만 결제',
                          subtitle: '1,000원 (나머지 현장 결제)',
                          isSelected: !_payFullAmount,
                          onTap: () => setState(() => _payFullAmount = false),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),

          // Sticky bottom bar
          Container(
            padding: EdgeInsets.fromLTRB(
                16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '결제 금액',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        _payFullAmount
                            ? '${fmt.format(widget.deal.dealPrice)}원'
                            : '1,000원',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: isExpired ? null : _onReserve,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 52),
                      disabledBackgroundColor: AppColors.border,
                    ),
                    child: Text(isExpired ? '마감된 특가' : '예약하기'),
                  ),
                ),
              ],
            ),
          ),
        ],
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

class _PaymentOptionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentOptionTile({
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryRedLight : AppColors.divider,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primaryRed : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primaryRed : AppColors.textTertiary,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryRed,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppColors.primaryRed
                          : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
