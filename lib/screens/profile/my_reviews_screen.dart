import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../providers/app_data_provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/sijang_design_system.dart';
import '../../widgets/app_ui.dart';
import '../../widgets/shrinkable_button.dart';

class MyReviewsScreen extends StatefulWidget {
  const MyReviewsScreen({super.key});

  @override
  State<MyReviewsScreen> createState() => _MyReviewsScreenState();
}

class _MyReviewsScreenState extends State<MyReviewsScreen> {
  bool _isLoading = true;
  List<({StoreReview review, String storeName})> _reviews = const [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadReviews());
  }

  Future<void> _loadReviews() async {
    setState(() => _isLoading = true);
    final data = context.read<AppDataProvider>();
    final auth = context.read<AuthProvider>();
    final userName = auth.userName?.trim() ?? '';
    final stores = data.stores.take(8);
    final collected = <({StoreReview review, String storeName})>[];

    for (final store in stores) {
      try {
        final reviews = await data.getReviews(store.id);
        for (final review in reviews) {
          if (userName.isEmpty || review.userName == userName) {
            collected.add((review: review, storeName: store.name));
          }
        }
      } catch (_) {}
    }

    if (mounted) {
      setState(() {
        _reviews = collected;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: ShrinkableButton(
          onTap: () => Navigator.pop(context),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary,
            size: 20,
          ),
        ),
        title: const Text(
          '내가 쓴 리뷰',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: SDS.fwBlack,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _loadReviews,
            icon: const Icon(Icons.refresh_rounded, color: AppColors.textPrimary),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _reviews.isEmpty
          ? const AppEmptyState(
              icon: Icons.rate_review_outlined,
              title: '작성한 리뷰가 없어요',
              description: '점포 상세 화면에서 리뷰를 남기면 여기에 표시돼요.',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(24),
              itemCount: _reviews.length,
              separatorBuilder: (_, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = _reviews[index];
                return _ReviewCard(
                  storeName: item.storeName,
                  review: item.review,
                );
              },
            ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.storeName, required this.review});

  final String storeName;
  final StoreReview review;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            storeName,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: SDS.fwBlack,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              ...List.generate(
                5,
                (index) => Icon(
                  index < review.rating.round()
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  size: 16,
                  color: AppColors.warning,
                ),
              ),
              const Spacer(),
              Text(
                review.userName,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: SDS.fwBold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            review.content,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
              fontWeight: SDS.fwMedium,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
