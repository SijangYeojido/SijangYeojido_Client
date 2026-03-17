import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import 'main_scaffold.dart';

class _MarketInfo {
  final String id;
  final String name;
  final String address;
  final String description;
  final Color accentColor;
  final int storeCount;
  final bool isAvailable;
  final List<String> highlights;

  const _MarketInfo({
    required this.id,
    required this.name,
    required this.address,
    required this.description,
    required this.accentColor,
    required this.storeCount,
    required this.isAvailable,
    required this.highlights,
  });
}

class MarketSelectionScreen extends StatelessWidget {
  const MarketSelectionScreen({super.key});

  static const _markets = [
    _MarketInfo(
      id: 'm1',
      name: '광장시장',
      address: '서울 종로구 창경궁로 88',
      description: '1905년 개설된 100년 역사의 서울 대표 전통시장',
      accentColor: Color(0xFFE5362B),
      storeCount: 5000,
      isAvailable: true,
      highlights: ['빈대떡', '육회', '마약김밥'],
    ),
    _MarketInfo(
      id: 'm2',
      name: '통인시장',
      address: '서울 종로구 자하문로15길 18',
      description: '엽전으로 음식을 구매하는 도시락카페 시장',
      accentColor: Color(0xFF16A34A),
      storeCount: 80,
      isAvailable: false,
      highlights: ['도시락카페', '기름떡볶이', '계란말이'],
    ),
    _MarketInfo(
      id: 'm3',
      name: '남대문시장',
      address: '서울 중구 남대문시장4길 21',
      description: '대한민국 최대 규모의 종합 도매시장',
      accentColor: Color(0xFF2563EB),
      storeCount: 10000,
      isAvailable: false,
      highlights: ['갈치조림', '어묵', '수입잡화'],
    ),
    _MarketInfo(
      id: 'm4',
      name: '경동시장',
      address: '서울 동대문구 제기동 1032',
      description: '한약재와 신선 식재료의 메카',
      accentColor: Color(0xFFEA580C),
      storeCount: 800,
      isAvailable: false,
      highlights: ['한약재', '산나물', '견과류'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(context)),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 48),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _MarketCard(market: _markets[index]),
                ),
                childCount: _markets.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          24, MediaQuery.of(context).padding.top + 28, 24, 32),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo row
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primaryRed,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.storefront_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '시장여지도',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  Text(
                    '전통시장을 더 쉽게',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),
          const Text(
            '어떤 시장을\n방문하시나요?',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              height: 1.25,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            '시장을 선택하면 점포 정보와 특가 할인을\n한눈에 확인할 수 있어요.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _MarketCard extends StatelessWidget {
  final _MarketInfo market;
  const _MarketCard({required this.market});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: market.isAvailable
          ? () {
              HapticFeedback.lightImpact();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MainScaffold(marketName: market.name),
                ),
              );
            }
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: market.isAvailable
                ? market.accentColor.withValues(alpha: 0.25)
                : AppColors.border,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: market.isAvailable ? 0.06 : 0.03),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Color bar at top
            Container(
              height: 5,
              decoration: BoxDecoration(
                color: market.isAvailable ? market.accentColor : AppColors.border,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(14)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title row
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  market.name,
                                  style: TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w800,
                                    color: market.isAvailable
                                        ? AppColors.textPrimary
                                        : AppColors.textTertiary,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                _StatusBadge(isAvailable: market.isAvailable),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  size: 12,
                                  color: market.isAvailable
                                      ? AppColors.textTertiary
                                      : AppColors.border,
                                ),
                                const SizedBox(width: 3),
                                Expanded(
                                  child: Text(
                                    market.address,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: market.isAvailable
                                          ? AppColors.textTertiary
                                          : AppColors.border,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (market.isAvailable)
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: market.accentColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    market.description,
                    style: TextStyle(
                      fontSize: 13,
                      color: market.isAvailable
                          ? AppColors.textSecondary
                          : AppColors.textTertiary,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Highlights
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: market.highlights
                        .map(
                          (h) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: market.isAvailable
                                  ? market.accentColor.withValues(alpha: 0.08)
                                  : AppColors.divider,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text(
                              '#$h',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: market.isAvailable
                                    ? market.accentColor
                                    : AppColors.textTertiary,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 14),
                  // Footer info
                  Row(
                    children: [
                      Icon(
                        Icons.store_outlined,
                        size: 13,
                        color: market.isAvailable
                            ? AppColors.textSecondary
                            : AppColors.textTertiary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '약 ${_formatCount(market.storeCount)}개 점포',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: market.isAvailable
                              ? AppColors.textSecondary
                              : AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 10000) {
      return '${(count / 10000).toStringAsFixed(0)}만';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(0)}천';
    }
    return count.toString();
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isAvailable;
  const _StatusBadge({required this.isAvailable});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isAvailable ? const Color(0xFFDCFCE7) : AppColors.divider,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        isAvailable ? '이용 가능' : '준비중',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isAvailable
              ? const Color(0xFF16A34A)
              : AppColors.textTertiary,
        ),
      ),
    );
  }
}
