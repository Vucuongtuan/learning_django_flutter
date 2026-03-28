import 'package:flutter/material.dart';
import 'package:app_flutter/theme/app_theme.dart';
import 'package:app_flutter/models/room.dart';
import 'package:app_flutter/models/tenant.dart';
import 'package:app_flutter/models/lease.dart';
import 'package:app_flutter/models/utility_reading.dart';
import 'package:app_flutter/models/invoice.dart';
import 'package:app_flutter/services/room_service.dart';
import 'package:app_flutter/services/lease_service.dart';
import 'package:app_flutter/services/tenant_service.dart';
import 'package:app_flutter/services/utility_service.dart';
import 'package:app_flutter/services/invoice_service.dart';
import 'package:app_flutter/widgets/features/room_detail/tenant_info_card.dart';
import 'package:app_flutter/widgets/features/room_detail/utility_snapshot.dart';
import 'package:app_flutter/widgets/features/room_detail/billing_history_item.dart';
import 'package:app_flutter/widgets/features/room_detail/quick_action_button.dart';

class RoomDetailScreen extends StatefulWidget {
  final int roomId;

  const RoomDetailScreen({super.key, required this.roomId});

  @override
  State<RoomDetailScreen> createState() => _RoomDetailScreenState();
}

class _RoomDetailScreenState extends State<RoomDetailScreen> {
  final RoomService _roomService = RoomService();
  final LeaseService _leaseService = LeaseService();
  final TenantService _tenantService = TenantService();
  final UtilityService _utilityService = UtilityService();
  final InvoiceService _invoiceService = InvoiceService();

  Room? _room;
  Lease? _activeLease;
  Tenant? _tenant;
  List<UtilityReading> _utilityReadings = [];
  List<Invoice> _invoices = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      _room = await _roomService.fetchRoom(widget.roomId);

      final leases = await _leaseService.fetchLeases(roomId: widget.roomId, isActive: true);
      if (leases.isNotEmpty) {
        _activeLease = leases.first;
        _tenant = await _tenantService.fetchTenant(_activeLease!.tenantId);

        final invoices = await _invoiceService.fetchInvoices(leaseId: _activeLease!.id);
        _invoices = invoices;
      }

      _utilityReadings = await _utilityService.fetchUtilityReadings(roomId: widget.roomId);

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  UtilityReading? get _latestElectricity {
    final electric = _utilityReadings.where((r) => r.isElectricity).toList();
    return electric.isNotEmpty ? electric.first : null;
  }

  UtilityReading? get _latestWater {
    final water = _utilityReadings.where((r) => r.isWater).toList();
    return water.isNotEmpty ? water.first : null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryContainer),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Chi tiết phòng',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.primaryContainer,
                fontWeight: FontWeight.bold,
              ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: AppColors.onSurfaceVariant),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppColors.onSurfaceVariant),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorView()
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context),
                      const SizedBox(height: 32),
                      if (_tenant != null)
                        TenantInfoCard(
                          tenant: _tenant!,
                          moveInDate: _activeLease?.moveInDate,
                        ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: UtilitySnapshot(
                              icon: Icons.bolt,
                              title: 'Chỉ số Điện',
                              value: _latestElectricity != null
                                  ? _latestElectricity!.currentReading.toStringAsFixed(1)
                                  : '--',
                              unit: 'kWh',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: UtilitySnapshot(
                              icon: Icons.water_drop,
                              title: 'Chỉ số Nước',
                              value: _latestWater != null
                                  ? _latestWater!.currentReading.toStringAsFixed(1)
                                  : '--',
                              unit: 'm³',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      _buildQuickActions(context),
                      const SizedBox(height: 32),
                      _buildBillingHistory(context),
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              'Phòng ${_room?.name ?? ''}',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontSize: 40,
                color: AppColors.primary,
                letterSpacing: -1.0,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: _room?.isOccupied == true
                    ? AppColors.tertiary.withOpacity(0.1)
                    : AppColors.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: _room?.isOccupied == true ? AppColors.tertiary : AppColors.secondary,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _room?.statusLabel ?? '',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: _room?.isOccupied == true ? AppColors.tertiary : AppColors.secondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 12.0),
          child: Text(
            'THAO TÁC NHANH',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              letterSpacing: 1.2,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Row(
          children: [
            const Expanded(
              child: QuickActionButton(icon: Icons.edit_note, label: 'Ghi số điện nước', bgColor: AppColors.primary, fgColor: AppColors.onPrimary),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: QuickActionButton(icon: Icons.receipt_long, label: 'Tạo hóa đơn', bgColor: AppColors.primaryContainer, fgColor: AppColors.onPrimaryContainer),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const SizedBox(
          width: double.infinity,
          child: QuickActionButton(icon: Icons.settings, label: 'Chỉnh sửa thông tin', bgColor: AppColors.surfaceContainerHigh, fgColor: AppColors.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildBillingHistory(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Lịch sử hóa đơn', style: Theme.of(context).textTheme.headlineSmall),
            TextButton(
              onPressed: () {},
              child: const Row(
                children: [
                  Text('Tất cả', style: TextStyle(fontWeight: FontWeight.bold)),
                  Icon(Icons.chevron_right, size: 16),
                ],
              ),
            )
          ],
        ),
        const SizedBox(height: 16),
        if (_invoices.isEmpty)
          const Center(child: Text('Chưa có hóa đơn'))
        else
          ..._invoices.take(3).toList().asMap().entries.map((entry) {
            final index = entry.key;
            final invoice = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Opacity(
                opacity: index >= 2 ? 0.8 : 1.0,
                child: BillingHistoryItem(
                  title: invoice.formattedBillingMonth,
                  date: invoice.billingMonth,
                  amount: invoice.formattedTotal,
                  status: invoice.statusLabel,
                  isPaid: invoice.isPaid,
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off, size: 64, color: AppColors.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(
              'Không thể tải thông tin phòng',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
}
