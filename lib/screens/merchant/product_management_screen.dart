import 'package:flutter/material.dart';
import '../../theme/sijang_design_system.dart';
import '../../theme/app_colors.dart';

class ProductManagementScreen extends StatefulWidget {
  const ProductManagementScreen({super.key});

  @override
  State<ProductManagementScreen> createState() => _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  final List<Map<String, String>> _products = [
    {'name': '샤인머스캣', 'price': '25,000원', 'status': '판매중'},
    {'name': '꿀사과 (5입)', 'price': '12,000원', 'status': '판매중'},
    {'name': '제주 감귤', 'price': '8,000원', 'status': '품절'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SDS.topBar(
              context: context,
              title: '상품 관리',
              subtitle: '총 ${_products.length}개의 상품이 등록되어 있습니다',
              showBackButton: false,
              actions: [
                GestureDetector(
                  onTap: () => _showBulkUploadModal(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(SDS.radiusS),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.bolt_rounded, color: AppColors.primary, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          '빠른 등록',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: SDS.fwBold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final product = _products[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SDS.epicCard(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: AppColors.divider,
                              borderRadius: BorderRadius.circular(SDS.radiusM),
                            ),
                            child: const Icon(Icons.image_outlined, color: AppColors.textTertiary),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product['name']!,
                                  style: TextStyle(
                                    fontWeight: SDS.fwBold,
                                    fontSize: 17,
                                    color: AppColors.textPrimary,
                                    letterSpacing: SDS.lsNormal,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  product['price']!,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontWeight: SDS.fwMedium,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: product['status'] == '판매중' 
                                  ? AppColors.primaryLight 
                                  : AppColors.dangerLight,
                              borderRadius: BorderRadius.circular(SDS.radiusS),
                            ),
                            child: Text(
                              product['status']!,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: SDS.fwBold,
                                color: product['status'] == '판매중' 
                                    ? AppColors.primary 
                                    : AppColors.danger,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                childCount: _products.length,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.textPrimary,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }

  void _showBulkUploadModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _BulkUploadModal(),
    );
  }
}

class _BulkUploadModal extends StatefulWidget {
  @override
  State<_BulkUploadModal> createState() => _BulkUploadModalState();
}

class _BulkUploadModalState extends State<_BulkUploadModal> {
  final List<Map<String, TextEditingController>> _rows = [
    {
      'name': TextEditingController(),
      'price': TextEditingController(),
    }
  ];

  void _addRow() {
    setState(() {
      _rows.add({
        'name': TextEditingController(),
        'price': TextEditingController(),
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(SDS.radiusL)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '상품 빠른 등록',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: SDS.fwBlack,
                    color: AppColors.textPrimary,
                    letterSpacing: SDS.lsTight,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              '상품명과 가격을 연속해서 입력하세요.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: SDS.fwMedium,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: _rows.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: AppColors.primaryLight,
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.primary,
                            fontWeight: SDS.fwBlack,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 3,
                        child: _buildModalInput(_rows[index]['name']!, '상품명 (예: 딸기)'),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: _buildModalInput(_rows[index]['price']!, '가격', suffix: '원'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SDS.button(
                  label: '항목 추가',
                  isPrimary: false,
                  onTap: _addRow,
                  icon: Icons.add_rounded,
                ),
                const SizedBox(height: 12),
                SDS.button(
                  label: '총 ${_rows.length}개 상품 등록하기',
                  onTap: () => Navigator.pop(context),
                  color: AppColors.textPrimary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModalInput(TextEditingController controller, String hint, {String? suffix}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(SDS.radiusM),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(fontSize: 14, fontWeight: SDS.fwMedium),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.textTertiary),
          border: InputBorder.none,
          suffixText: suffix,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}
