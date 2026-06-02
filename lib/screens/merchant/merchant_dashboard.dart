import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../providers/app_data_provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../models/models.dart';

class MerchantDashboard extends StatefulWidget {
  const MerchantDashboard({super.key});

  @override
  State<MerchantDashboard> createState() => _MerchantDashboardState();
}

class _MerchantDashboardState extends State<MerchantDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppDataProvider>().loadMerchantStores();
      context.read<AppDataProvider>().loadMerchantDeals();
      context.read<AppDataProvider>().loadReservations();
      context.read<AppDataProvider>().loadSellerAnalytics();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final data = context.watch<AppDataProvider>();
    final stores = data.merchantStores;
    final products = stores
        .expand((store) => (store['products'] as List<dynamic>? ?? []))
        .cast<Map<String, dynamic>>()
        .toList();
    final liveDeals = data.merchantDeals
        .where((deal) => deal['status']?.toString() == 'LIVE')
        .toList();
    final activeReservations = data.reservations
        .where((reservation) => reservation.isActive)
        .toList();
    final approved = stores
        .where((store) => store['approvalStatus']?.toString() == 'APPROVED')
        .length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                '${auth.userName ?? '상인'}의 매장',
                style: GoogleFonts.inter(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: false,
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded, color: Colors.black),
                onPressed: data.loadMerchantStores,
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StatusCard(stores: stores),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      _StatItem(
                        label: '등록 점포',
                        value: '${stores.length}',
                        icon: Icons.storefront_outlined,
                        color: AppColors.textPrimary,
                      ),
                      const SizedBox(width: 12),
                      _StatItem(
                        label: '판매 상품',
                        value: '${products.length}',
                        icon: Icons.inventory_2_outlined,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '승인 현황',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      FilledButton.icon(
                        onPressed: () => _showStoreRequestSheet(context),
                        icon: const Icon(Icons.add_business_rounded, size: 18),
                        label: const Text('점포 요청'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _ApprovalSummary(
                    approved: approved,
                    pending: stores.length - approved,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '성과',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _MerchantAnalyticsPanel(analytics: data.sellerAnalytics),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '오늘 특가',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      FilledButton.icon(
                        onPressed: stores.isEmpty
                            ? null
                            : () => _showDealSheet(context, stores),
                        icon: const Icon(Icons.flash_on_rounded, size: 18),
                        label: const Text('특가 시작'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (liveDeals.isEmpty)
                    const _EmptyStoreState(label: '진행 중인 특가가 없습니다.')
                  else
                    ...liveDeals.map((deal) => _DealTile(deal: deal)),
                  const SizedBox(height: 24),
                  Text(
                    '픽업 대기',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (activeReservations.isEmpty)
                    const _EmptyStoreState(label: '픽업 대기 예약이 없습니다.')
                  else
                    ...activeReservations.map(
                      (reservation) =>
                          _ReservationQueueTile(reservation: reservation),
                    ),
                  const SizedBox(height: 24),
                  Text(
                    '내 점포',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (stores.isEmpty)
                    const _EmptyStoreState()
                  else
                    ...stores.map((store) => _MerchantStoreTile(store: store)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showStoreRequestSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _StoreRequestSheet(),
    );
  }

  void _showDealSheet(BuildContext context, List<Map<String, dynamic>> stores) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _DealSheet(stores: stores),
    );
  }
}

class _MerchantStoreTile extends StatelessWidget {
  const _MerchantStoreTile({required this.store});

  final Map<String, dynamic> store;

  @override
  Widget build(BuildContext context) {
    final status = store['approvalStatus']?.toString() ?? 'PENDING';
    final id = int.tryParse(store['id']?.toString() ?? '') ?? 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  store['name']?.toString() ?? '점포',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Chip(label: Text(status == 'APPROVED' ? '승인됨' : '검토중')),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${store['category'] ?? '기타'} · ${store['openingTime'] ?? '--:--'}-${store['closingTime'] ?? '--:--'}',
            style: GoogleFonts.inter(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showEditSheet(context, store),
                  icon: const Icon(Icons.edit_rounded, size: 18),
                  label: const Text('정보 수정'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _pickAndUpload(context, id),
                  icon: const Icon(Icons.photo_camera_rounded, size: 18),
                  label: const Text('사진 등록'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showEditSheet(BuildContext context, Map<String, dynamic> store) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _StoreEditSheet(store: store),
    );
  }

  Future<void> _pickAndUpload(BuildContext context, int storeId) async {
    if (storeId == 0) return;
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null || !context.mounted) return;
    final data = context.read<AppDataProvider>();
    final url = await data.uploadStoreImage(image.path);
    await data.addStorePhoto(storeId: storeId, imageUrl: url);
  }
}

class _MerchantAnalyticsPanel extends StatelessWidget {
  const _MerchantAnalyticsPanel({required this.analytics});

  final Map<String, dynamic>? analytics;

  @override
  Widget build(BuildContext context) {
    final summary =
        (analytics?['summary'] as Map<String, dynamic>?) ?? const {};
    final daily = (analytics?['daily'] as List?) ?? const [];
    if (analytics == null) {
      return const _EmptyStoreState(label: '성과 데이터를 불러오는 중입니다.');
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _SellerKpiTile(
                  label: '예약',
                  value: _analyticsMetric(summary, 'reservationsCreated'),
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SellerKpiTile(
                  label: '픽업 완료',
                  value: _analyticsMetric(summary, 'pickupCompletions'),
                  color: const Color(0xFF16A34A),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SellerKpiTile(
                  label: '환불',
                  value: _analyticsMetric(summary, 'refunds'),
                  color: const Color(0xFFDC2626),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '픽업 완료율 ${_analyticsRate(summary, 'pickupCompletionRate')}',
            style: GoogleFonts.inter(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          if (daily.isEmpty)
            Text(
              '아직 집계된 성과가 없습니다.',
              style: GoogleFonts.inter(color: AppColors.textSecondary),
            )
          else
            ...daily.take(7).map((row) {
              final item = row as Map<String, dynamic>;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(child: Text(item['date']?.toString() ?? '')),
                    Text(
                      '예약 ${_analyticsMetric(item, 'reservationsCreated')} · 픽업 ${_analyticsMetric(item, 'pickupCompletions')}',
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _SellerKpiTile extends StatelessWidget {
  const _SellerKpiTile({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.inter(color: AppColors.textSecondary)),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyStoreState extends StatelessWidget {
  const _EmptyStoreState({this.label = '아직 등록된 점포가 없습니다.'});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Text(label),
    );
  }
}

class _DealTile extends StatelessWidget {
  const _DealTile({required this.deal});

  final Map<String, dynamic> deal;

  @override
  Widget build(BuildContext context) {
    final id = int.tryParse(deal['id']?.toString() ?? '') ?? 0;
    final quantity = deal['availableQuantity']?.toString() ?? '0';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          const Icon(Icons.flash_on_rounded, color: Color(0xFFF04452)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  deal['title']?.toString() ?? '오늘 특가',
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${deal['dealPrice'] ?? 0}원 · 남은 수량 $quantity',
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: id == 0
                ? null
                : () => context.read<AppDataProvider>().endDeal(id),
            child: const Text('종료'),
          ),
        ],
      ),
    );
  }
}

class _ReservationQueueTile extends StatelessWidget {
  const _ReservationQueueTile({required this.reservation});

  final Reservation reservation;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          const Icon(Icons.qr_code_rounded, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reservation.itemName,
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${reservation.storeName} · ${reservation.quantity}개 · ${reservation.pickupCode}',
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
          FilledButton(
            onPressed: () => _showCompleteDialog(context),
            child: const Text('픽업 완료'),
          ),
        ],
      ),
    );
  }

  void _showCompleteDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('픽업 코드 확인'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: '고객의 4자리 코드'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () async {
              await context.read<AppDataProvider>().completeReservation(
                reservation.id,
                pickupCode: controller.text.trim(),
              );
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('완료'),
          ),
        ],
      ),
    ).whenComplete(controller.dispose);
  }
}

class _StoreEditSheet extends StatefulWidget {
  const _StoreEditSheet({required this.store});

  final Map<String, dynamic> store;

  @override
  State<_StoreEditSheet> createState() => _StoreEditSheetState();
}

class _StoreEditSheetState extends State<_StoreEditSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _categoryController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _openingController;
  late final TextEditingController _closingController;
  late final TextEditingController _regularHolidayController;
  late final TextEditingController _temporaryHolidayController;
  late final TextEditingController _paymentController;
  late final TextEditingController _addressController;
  String _businessStatus = 'OPEN';
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.store['name']?.toString() ?? '',
    );
    _categoryController = TextEditingController(
      text: widget.store['category']?.toString() ?? '기타',
    );
    _descriptionController = TextEditingController(
      text: widget.store['description']?.toString() ?? '',
    );
    _openingController = TextEditingController(
      text: widget.store['openingTime']?.toString() ?? '09:00',
    );
    _closingController = TextEditingController(
      text: widget.store['closingTime']?.toString() ?? '20:00',
    );
    _regularHolidayController = TextEditingController(
      text: _joinList(widget.store['regularHolidays']),
    );
    _temporaryHolidayController = TextEditingController(
      text: _joinList(widget.store['temporaryHolidays']),
    );
    _paymentController = TextEditingController(
      text: _joinList(widget.store['paymentMethods']),
    );
    _addressController = TextEditingController(
      text: widget.store['addressDetail']?.toString() ?? '',
    );
    final status = widget.store['businessStatus']?.toString();
    if (status == 'OPEN' || status == 'CLOSED' || status == 'BREAK') {
      _businessStatus = status!;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    _openingController.dispose();
    _closingController.dispose();
    _regularHolidayController.dispose();
    _temporaryHolidayController.dispose();
    _paymentController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '점포 정보 수정',
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: '점포명'),
            ),
            TextField(
              controller: _categoryController,
              decoration: const InputDecoration(labelText: '카테고리'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: '설명'),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _openingController,
                    decoration: const InputDecoration(labelText: '오픈 시간'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _closingController,
                    decoration: const InputDecoration(labelText: '마감 시간'),
                  ),
                ),
              ],
            ),
            DropdownButtonFormField<String>(
              initialValue: _businessStatus,
              decoration: const InputDecoration(labelText: '영업 상태'),
              items: const [
                DropdownMenuItem(value: 'OPEN', child: Text('영업중')),
                DropdownMenuItem(value: 'BREAK', child: Text('준비중')),
                DropdownMenuItem(value: 'CLOSED', child: Text('휴무')),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _businessStatus = value);
              },
            ),
            TextField(
              controller: _regularHolidayController,
              decoration: const InputDecoration(labelText: '정기 휴무, 쉼표로 구분'),
            ),
            TextField(
              controller: _temporaryHolidayController,
              decoration: const InputDecoration(labelText: '임시 휴무, 쉼표로 구분'),
            ),
            TextField(
              controller: _paymentController,
              decoration: const InputDecoration(labelText: '결제 수단, 쉼표로 구분'),
            ),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: '시장 내 상세 위치'),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _submitting ? null : _submit,
              child: Text(_submitting ? '수정 중...' : '저장'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final storeId = int.tryParse(widget.store['id']?.toString() ?? '') ?? 0;
    if (storeId == 0 || _nameController.text.trim().isEmpty) return;
    setState(() => _submitting = true);
    await context.read<AppDataProvider>().updateMerchantStore(storeId, {
      'name': _nameController.text.trim(),
      'category': _categoryController.text.trim().isEmpty
          ? '기타'
          : _categoryController.text.trim(),
      'description': _descriptionController.text.trim(),
      'openingTime': _openingController.text.trim(),
      'closingTime': _closingController.text.trim(),
      'businessStatus': _businessStatus,
      'regularHolidays': _splitList(_regularHolidayController.text),
      'temporaryHolidays': _splitList(_temporaryHolidayController.text),
      'paymentMethods': _splitList(_paymentController.text),
      'addressDetail': _addressController.text.trim(),
    });
    if (mounted) Navigator.pop(context);
  }

  List<String> _splitList(String value) => value
      .split(',')
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .toList();

  static String _joinList(dynamic value) {
    if (value is List) return value.map((item) => item.toString()).join(', ');
    return value?.toString() ?? '';
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.stores});

  final List<Map<String, dynamic>> stores;

  @override
  Widget build(BuildContext context) {
    final hasApproved = stores.any(
      (store) => store['approvalStatus']?.toString() == 'APPROVED',
    );
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.store_rounded, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasApproved ? '영업 정보 노출 중' : '승인 대기 중',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  hasApproved ? '고객이 점포와 상품을 볼 수 있습니다' : '운영자 승인을 기다리고 있습니다',
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 12),
            Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(label, style: GoogleFonts.inter(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _ApprovalSummary extends StatelessWidget {
  const _ApprovalSummary({required this.approved, required this.pending});

  final int approved;
  final int pending;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          _row('승인 완료', '$approved', AppColors.primary),
          const Divider(height: 32),
          _row('검토 대기', '$pending', AppColors.textSecondary),
        ],
      ),
    );
  }

  Widget _row(String label, String count, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
        Text(
          count,
          style: GoogleFonts.inter(color: color, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class _DealSheet extends StatefulWidget {
  const _DealSheet({required this.stores});

  final List<Map<String, dynamic>> stores;

  @override
  State<_DealSheet> createState() => _DealSheetState();
}

class _DealSheetState extends State<_DealSheet> {
  late int _storeId;
  int? _productId;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dealPriceController = TextEditingController();
  final _originalPriceController = TextEditingController();
  final _quantityController = TextEditingController(text: '10');
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _storeId = int.tryParse(widget.stores.first['id']?.toString() ?? '') ?? 0;
    _syncFirstProduct();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _dealPriceController.dispose();
    _originalPriceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _products {
    final store = widget.stores.firstWhere(
      (row) => int.tryParse(row['id']?.toString() ?? '') == _storeId,
      orElse: () => const {},
    );
    return (store['products'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '오늘 특가 시작',
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              initialValue: _storeId,
              decoration: const InputDecoration(labelText: '점포'),
              items: widget.stores
                  .map(
                    (store) => DropdownMenuItem(
                      value: int.tryParse(store['id']?.toString() ?? '') ?? 0,
                      child: Text(store['name']?.toString() ?? '점포'),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _storeId = value;
                  _syncFirstProduct();
                });
              },
            ),
            DropdownButtonFormField<int?>(
              initialValue: _productId,
              decoration: const InputDecoration(labelText: '상품'),
              items: [
                const DropdownMenuItem<int?>(
                  value: null,
                  child: Text('상품 연결 안 함'),
                ),
                ..._products.map(
                  (product) => DropdownMenuItem<int?>(
                    value: int.tryParse(product['id']?.toString() ?? ''),
                    child: Text(product['name']?.toString() ?? '상품'),
                  ),
                ),
              ],
              onChanged: (value) => setState(() => _productId = value),
            ),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: '특가 제목'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: '설명'),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _dealPriceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: '특가'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _originalPriceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: '정가'),
                  ),
                ),
              ],
            ),
            TextField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: '판매 수량'),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _submitting ? null : _submit,
              child: Text(_submitting ? '시작 중...' : '특가 시작'),
            ),
          ],
        ),
      ),
    );
  }

  void _syncFirstProduct() {
    final rows = _products;
    _productId = rows.isEmpty
        ? null
        : int.tryParse(rows.first['id']?.toString() ?? '');
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    final dealPrice = int.tryParse(_dealPriceController.text.trim()) ?? 0;
    final quantity = int.tryParse(_quantityController.text.trim()) ?? 0;
    if (_storeId == 0 || title.isEmpty || dealPrice <= 0 || quantity <= 0) {
      return;
    }
    setState(() => _submitting = true);
    await context.read<AppDataProvider>().createDeal(
      storeId: _storeId,
      productId: _productId,
      title: title,
      description: _descriptionController.text.trim(),
      dealPrice: dealPrice,
      originalPrice: int.tryParse(_originalPriceController.text.trim()),
      availableQuantity: quantity,
      expiresAt: DateTime.now().add(const Duration(hours: 3)),
    );
    if (mounted) Navigator.pop(context);
  }
}

class _StoreRequestSheet extends StatefulWidget {
  const _StoreRequestSheet();

  @override
  State<_StoreRequestSheet> createState() => _StoreRequestSheetState();
}

class _StoreRequestSheetState extends State<_StoreRequestSheet> {
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController(text: '기타');
  final _descriptionController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

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
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: '점포명'),
          ),
          TextField(
            controller: _categoryController,
            decoration: const InputDecoration(labelText: '카테고리'),
          ),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(labelText: '설명'),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _submitting ? null : _submit,
              child: Text(_submitting ? '등록 중...' : '등록 요청'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (_nameController.text.trim().isEmpty) return;
    setState(() => _submitting = true);
    await context.read<AppDataProvider>().createStoreRequest(
      name: _nameController.text.trim(),
      category: _categoryController.text.trim().isEmpty
          ? '기타'
          : _categoryController.text.trim(),
      description: _descriptionController.text.trim(),
    );
    if (mounted) Navigator.pop(context);
  }
}

String _analyticsMetric(Map<String, dynamic> source, String key) {
  return int.tryParse(source[key]?.toString() ?? '')?.toString() ?? '0';
}

String _analyticsRate(Map<String, dynamic> source, String key) {
  final value = double.tryParse(source[key]?.toString() ?? '') ?? 0;
  return '${(value * 100).toStringAsFixed(1)}%';
}
