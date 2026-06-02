import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../providers/app_data_provider.dart';
import '../theme/sijang_design_system.dart';
import '../theme/app_colors.dart';
import 'shrinkable_button.dart';

class MarketStoriesWidget extends StatelessWidget {
  const MarketStoriesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final stores = context
        .watch<AppDataProvider>()
        .stores
        .where((store) => store.imageUrls.isNotEmpty)
        .take(8)
        .toList();

    if (stores.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: SDS.gutter),
          child: Text(
            '시장의 실시간 일상',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
        ),
        const SizedBox(height: SDS.spaceM),
        SizedBox(
          height: 90,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: SDS.gutter),
            scrollDirection: Axis.horizontal,
            itemCount: stores.length,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              return _StoryAvatar(store: stores[index], isLive: index == 0);
            },
          ),
        ),
      ],
    );
  }
}

class _StoryAvatar extends StatelessWidget {
  final Store store;
  final bool isLive;

  const _StoryAvatar({required this.store, required this.isLive});

  @override
  Widget build(BuildContext context) {
    return ShrinkableButton(
      onTap: () {
        // Handle story tap
      },
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: isLive
                        ? [const Color(0xFFF04452), const Color(0xFFFF8E3C)]
                        : [const Color(0xFFCBD5E1), const Color(0xFF94A3B8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    radius: 28,
                    backgroundImage: NetworkImage(store.imageUrls.first),
                  ),
                ),
              ),
              if (isLive)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF04452),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Text(
                      'LIVE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 64,
            child: Text(
              store.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isLive ? FontWeight.w800 : FontWeight.w600,
                color: isLive ? AppColors.textPrimary : AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
