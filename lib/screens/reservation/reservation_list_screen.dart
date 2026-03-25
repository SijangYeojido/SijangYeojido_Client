import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import '../../models/models.dart';
import '../../data/mock_data.dart';
import '../pickup/pickup_screen.dart';
import '../../widgets/app_ui.dart';
import '../../theme/sijang_design_system.dart';

class ReservationListScreen extends StatefulWidget {
  const ReservationListScreen({super.key});

  @override
  State<ReservationListScreen> createState() => _ReservationListScreenState();
}

class _ReservationListScreenState extends State<ReservationListScreen> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final active = MockData.reservations.where((r) => r.isActive).toList();
    final past = MockData.reservations.where((r) => !r.isActive).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SDS.topBar(
              context: context,
              title: '주문 내역',
              subtitle: active.isNotEmpty
                  ? '맛있는 기다림이 ${active.length}건 있어요'
                  : '기분 좋은 소식을 기다리고 있어요',
            ),
          ),
          if (active.isEmpty && past.isEmpty)
            SliverFillRemaining(
              child: _EmptyState(),
            )
          else ...[
            if (active.isNotEmpty) ...[
              _sectionHeader(
                context: context,
                title: '지금 준비 중이에요',
                count: active.length,
                color: AppColors.primary,
                subtitle: '픽업까지 얼마나 남았을까요?',
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => _ActiveReservationCard(
                    reservation: active[i],
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PickupScreen(reservation: active[i]),
                      ),
                    ),
                  ),
                  childCount: active.length,
                ),
              ),
            ],
            if (past.isNotEmpty) ...[
              _sectionHeader(
                context: context,
                title: '지난 주문 내역',
                count: past.length,
                color: AppColors.textSecondary,
                subtitle: '완료되거나 취소된 내역들이에요',
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => _PastReservationCard(reservation: past[i]),
                  childCount: past.length,
                ),
              ),
            ],
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ],
      ),
    );
  }

  Widget _sectionHeader({
    required BuildContext context,
    required String title,
    required int count,
    required Color color,
    String? subtitle,
  }) {
    return SliverToBoxAdapter(
      child: AppSectionHeader(
        title: '$title · $count',
        subtitle: subtitle,
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Text(
            title,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
          ),
        ),
      ),
    );
  }
}

class _ActiveReservationCard extends StatelessWidget {
  final Reservation reservation;
  final VoidCallback onTap;

  const _ActiveReservationCard({required this.reservation, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      decoration: SDS.glassDecoration(
        radius: SDS.radiusL,
        opacity: 0.7,
        color: Colors.white,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(SDS.radiusM),
                  ),
                  child: const Icon(Icons.shopping_bag_rounded, color: AppColors.primary, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reservation.itemName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: SDS.fwBlack,
                          color: AppColors.textPrimary,
                          letterSpacing: SDS.lsTight,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${reservation.storeName} · ${reservation.quantity}개',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: SDS.fwMedium,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildTimer(reservation),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: SDS.button(
              label: '픽업 코드 보기',
              onTap: onTap,
              icon: Icons.qr_code_rounded,
              width: double.infinity,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimer(Reservation reservation) {
    final now = DateTime.now();
    final remaining = reservation.expiresAt.difference(now);
    final isExpired = remaining.isNegative;
    final totalSeconds = remaining.inSeconds.abs();
    final mins = totalSeconds ~/ 60;
    final secs = totalSeconds % 60;
    final isUrgent = !isExpired && remaining.inMinutes < 5;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isUrgent ? AppColors.danger.withValues(alpha: 0.1) : AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(SDS.radiusS),
      ),
      child: Column(
        children: [
          Text(
            '$mins:${secs.toString().padLeft(2, '0')}',
            style: TextStyle(
              fontSize: 15,
              fontWeight: SDS.fwBlack,
              color: isUrgent ? AppColors.danger : AppColors.primary,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          Text(
            isUrgent ? '마감 임박' : '남음',
            style: TextStyle(
              fontSize: 10,
              fontWeight: SDS.fwBold,
              color: isUrgent ? AppColors.danger : AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}


class _PastReservationCard extends StatelessWidget {
  final Reservation reservation;

  const _PastReservationCard({required this.reservation});

  @override
  Widget build(BuildContext context) {
    return SDS.listRow(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: reservation.isCompleted
              ? AppColors.success.withValues(alpha: 0.1)
              : AppColors.background,
          shape: BoxShape.circle,
        ),
        child: Icon(
          reservation.isCompleted ? Icons.check_rounded : Icons.close_rounded,
          color: reservation.isCompleted ? AppColors.success : AppColors.textTertiary,
          size: 20,
        ),
      ),
      title: Text(reservation.itemName),
      subtitle: Text('${reservation.storeName} • ${NumberFormat('#,###', 'ko_KR').format(reservation.totalAmount)}원'),
      trailing: Text(
        reservation.isCompleted ? '잘 전달해 드렸어요' : '시간이 지났어요',
        style: TextStyle(
          fontSize: 12,
          fontWeight: SDS.fwBold,
          color: reservation.isCompleted ? AppColors.success : AppColors.textTertiary,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: AppEmptyState(
        icon: Icons.receipt_long_outlined,
        title: '아직 주문한 내역이 없어요',
        description: '지도를 구경하다가 마음에 드는\n점포의 특가 딜을 예약해 보세요!',
      ),
    );
  }
}
