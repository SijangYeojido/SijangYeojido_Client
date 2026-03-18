import 'package:flutter/material.dart';
import 'dart:async';
import '../data/mock_data.dart';

class FlashDealTickerWidget extends StatefulWidget {
  const FlashDealTickerWidget({super.key});

  @override
  State<FlashDealTickerWidget> createState() => _FlashDealTickerWidgetState();
}

class _FlashDealTickerWidgetState extends State<FlashDealTickerWidget> {
  late final ScrollController _scrollController;
  late final Timer _timer;
  double _scrollPosition = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _startTicker();
  }

  void _startTicker() {
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!mounted) return;
      _scrollPosition += 1.0;
      if (_scrollPosition > _scrollController.position.maxScrollExtent) {
        _scrollPosition = 0;
        _scrollController.jumpTo(0);
      } else {
        _scrollController.animateTo(
          _scrollPosition,
          duration: const Duration(milliseconds: 50),
          curve: Curves.linear,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deals = MockData.flashDeals;

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFF04452).withValues(alpha: 0.05),
        border: Border.symmetric(
          horizontal: BorderSide(
            color: const Color(0xFFF04452).withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final deal = deals[index % deals.length];
          final store = MockData.stores.firstWhere((s) => s.id == deal.storeId);
          
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            alignment: Alignment.center,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF04452),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'FLASH DEAL',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${store.name}: ${deal.title}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  deal.discount,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFF04452),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
