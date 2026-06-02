import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../providers/app_data_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/sijang_design_system.dart';

class ProductManagementScreen extends StatefulWidget {
  const ProductManagementScreen({super.key});

  @override
  State<ProductManagementScreen> createState() =>
      _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  final _fmt = NumberFormat('#,###', 'ko_KR');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppDataProvider>().loadMerchantStores();
    });
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<AppDataProvider>();
    final products = _products(data.merchantStores);
    final firstStoreId = _firstStoreId(data.merchantStores);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: data.loadMerchantStores,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: SDS.topBar(
                context: context,
                title: '상품 관리',
                subtitle: '총 ${products.length}개의 상품이 등록되어 있습니다',
                showBackButton: false,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded),
                    onPressed: data.loadMerchantStores,
                  ),
                ],
              ),
            ),
            if (products.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: Text('등록된 상품이 없습니다.')),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final product = products[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _ProductTile(
                        product: product,
                        priceText:
                            '${_fmt.format(_int(product['currentPrice']))}원',
                        onEdit: () => _showProductSheet(
                          context,
                          _int(product['store']?['id']) == 0
                              ? firstStoreId ?? 0
                              : _int(product['store']?['id']),
                          product: product,
                        ),
                        onPriceTap: () => _showPriceSheet(context, product),
                        onDelete: () => context
                            .read<AppDataProvider>()
                            .deleteProduct(_int(product['id'])),
                      ),
                    );
                  }, childCount: products.length),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: firstStoreId == null
            ? null
            : () => _showProductSheet(context, firstStoreId),
        backgroundColor: AppColors.textPrimary,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }

  List<Map<String, dynamic>> _products(List<Map<String, dynamic>> stores) {
    return stores
        .expand((store) => (store['products'] as List<dynamic>? ?? []))
        .cast<Map<String, dynamic>>()
        .toList();
  }

  int? _firstStoreId(List<Map<String, dynamic>> stores) {
    if (stores.isEmpty) return null;
    return _int(stores.first['id']);
  }

  int _int(dynamic value) => int.tryParse(value?.toString() ?? '') ?? 0;

  void _showProductSheet(
    BuildContext context,
    int storeId, {
    Map<String, dynamic>? product,
  }) {
    if (storeId == 0) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _ProductSheet(storeId: storeId, product: product),
    );
  }

  void _showPriceSheet(BuildContext context, Map<String, dynamic> product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _PriceSheet(product: product),
    );
  }
}

class _ProductTile extends StatelessWidget {
  const _ProductTile({
    required this.product,
    required this.priceText,
    required this.onEdit,
    required this.onPriceTap,
    required this.onDelete,
  });

  final Map<String, dynamic> product;
  final String priceText;
  final VoidCallback onEdit;
  final VoidCallback onPriceTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final available = product['stockStatus']?.toString() != 'SOLD_OUT';
    return SDS.epicCard(
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
            child: const Icon(
              Icons.inventory_2_outlined,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['name']?.toString() ?? '상품',
                  style: const TextStyle(
                    fontWeight: SDS.fwBold,
                    fontSize: 17,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  priceText,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: SDS.fwMedium,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: '상품 수정',
            onPressed: onEdit,
            icon: const Icon(Icons.tune_rounded),
          ),
          IconButton(
            tooltip: '가격 수정',
            onPressed: onPriceTap,
            icon: const Icon(Icons.edit_rounded),
          ),
          IconButton(
            tooltip: '삭제',
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline_rounded),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: available ? AppColors.primaryLight : AppColors.dangerLight,
              borderRadius: BorderRadius.circular(SDS.radiusS),
            ),
            child: Text(
              available ? '판매중' : '품절',
              style: TextStyle(
                fontSize: 12,
                fontWeight: SDS.fwBold,
                color: available ? AppColors.primary : AppColors.danger,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductSheet extends StatefulWidget {
  const _ProductSheet({required this.storeId, this.product});

  final int storeId;
  final Map<String, dynamic>? product;

  @override
  State<_ProductSheet> createState() => _ProductSheetState();
}

class _ProductSheetState extends State<_ProductSheet> {
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController(text: '기타');
  final _priceController = TextEditingController();
  final _unitController = TextEditingController();
  final _originController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _submitting = false;

  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    if (product != null) {
      _nameController.text = product['name']?.toString() ?? '';
      _categoryController.text = product['category']?.toString() ?? '기타';
      _priceController.text = product['currentPrice']?.toString() ?? '';
      _unitController.text = product['unit']?.toString() ?? '';
      _originController.text = product['origin']?.toString() ?? '';
      _descriptionController.text = product['description']?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _priceController.dispose();
    _unitController.dispose();
    _originController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _SheetFrame(
      title: _isEditing ? '상품 수정' : '상품 등록',
      submitting: _submitting,
      submitLabel: _isEditing ? '수정' : '등록',
      onSubmit: _submit,
      children: [
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(labelText: '상품명'),
        ),
        TextField(
          controller: _categoryController,
          decoration: const InputDecoration(labelText: '카테고리'),
        ),
        TextField(
          controller: _priceController,
          enabled: !_isEditing,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: _isEditing ? '가격은 가격 수정에서 변경' : '가격',
          ),
        ),
        TextField(
          controller: _unitController,
          decoration: const InputDecoration(labelText: '단위'),
        ),
        TextField(
          controller: _originController,
          decoration: const InputDecoration(labelText: '원산지'),
        ),
        TextField(
          controller: _descriptionController,
          decoration: const InputDecoration(labelText: '설명'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    final price = int.tryParse(_priceController.text.trim()) ?? 0;
    if (_nameController.text.trim().isEmpty || (!_isEditing && price <= 0)) {
      return;
    }
    setState(() => _submitting = true);
    if (_isEditing) {
      await context.read<AppDataProvider>().updateProduct(
        productId: int.tryParse(widget.product?['id']?.toString() ?? '') ?? 0,
        name: _nameController.text.trim(),
        category: _categoryController.text.trim().isEmpty
            ? '기타'
            : _categoryController.text.trim(),
        unit: _unitController.text.trim(),
        origin: _originController.text.trim(),
        description: _descriptionController.text.trim(),
      );
    } else {
      await context.read<AppDataProvider>().createProduct(
        storeId: widget.storeId,
        name: _nameController.text.trim(),
        category: _categoryController.text.trim().isEmpty
            ? '기타'
            : _categoryController.text.trim(),
        currentPrice: price,
        unit: _unitController.text.trim(),
        origin: _originController.text.trim(),
        description: _descriptionController.text.trim(),
      );
    }
    if (mounted) Navigator.pop(context);
  }
}

class _PriceSheet extends StatefulWidget {
  const _PriceSheet({required this.product});

  final Map<String, dynamic> product;

  @override
  State<_PriceSheet> createState() => _PriceSheetState();
}

class _PriceSheetState extends State<_PriceSheet> {
  late final TextEditingController _priceController;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController(
      text: widget.product['currentPrice']?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _SheetFrame(
      title: '가격 수정',
      submitting: _submitting,
      submitLabel: '수정',
      onSubmit: _submit,
      children: [
        TextField(
          controller: _priceController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: '새 가격'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    final price = int.tryParse(_priceController.text.trim()) ?? 0;
    final productId = int.tryParse(widget.product['id']?.toString() ?? '') ?? 0;
    if (price <= 0 || productId == 0) return;
    setState(() => _submitting = true);
    await context.read<AppDataProvider>().updateProductPrice(
      productId: productId,
      price: price,
      note: '앱에서 가격 수정',
    );
    if (mounted) Navigator.pop(context);
  }
}

class _SheetFrame extends StatelessWidget {
  const _SheetFrame({
    required this.title,
    required this.children,
    required this.submitting,
    required this.submitLabel,
    required this.onSubmit,
  });

  final String title;
  final List<Widget> children;
  final bool submitting;
  final String submitLabel;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: SDS.fwBlack,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
          const SizedBox(height: 16),
          FilledButton(
            onPressed: submitting ? null : onSubmit,
            child: Text(submitting ? '처리 중...' : submitLabel),
          ),
        ],
      ),
    );
  }
}
