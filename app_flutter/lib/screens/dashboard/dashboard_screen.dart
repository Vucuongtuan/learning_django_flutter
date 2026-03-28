import 'package:flutter/material.dart';
import 'package:app_flutter/theme/app_theme.dart';
import 'package:app_flutter/models/room.dart';
import 'package:app_flutter/models/invoice.dart';
import 'package:app_flutter/services/room_service.dart';
import 'package:app_flutter/services/invoice_service.dart';
import 'package:app_flutter/widgets/features/dashboard/metric_card.dart';
import 'package:app_flutter/widgets/features/dashboard/revenue_card.dart';
import 'package:app_flutter/widgets/features/dashboard/room_status_map.dart';
import 'package:app_flutter/widgets/features/dashboard/alerts_list.dart';
import 'package:app_flutter/widgets/features/dashboard/quick_input_form.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final RoomService _roomService = RoomService();
  final InvoiceService _invoiceService = InvoiceService();

  List<Room> _rooms = [];
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
      final results = await Future.wait([
        _roomService.fetchRooms(),
        _invoiceService.fetchInvoices(),
      ]);
      setState(() {
        _rooms = results[0] as List<Room>;
        _invoices = results[1] as List<Invoice>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  int get _totalRooms => _rooms.length;
  int get _occupiedRooms => _rooms.where((r) => r.isOccupied).length;
  int get _availableRooms => _rooms.where((r) => r.isAvailable).length;

  double get _monthlyRevenue {
    return _invoices.fold(0.0, (sum, inv) => sum + inv.totalAmount);
  }

  String _formatRevenue(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M đ';
    }
    final formatted = amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+$)'),
      (m) => '${m[1]}.',
    );
    return '${formatted}đ';
  }

  List<AlertItem> _buildAlerts() {
    final alerts = <AlertItem>[];

    final unpaidInvoices = _invoices.where((inv) => !inv.isPaid).toList();
    for (final inv in unpaidInvoices) {
      alerts.add(AlertItem(
        icon: Icons.payments,
        title: '${inv.roomName ?? 'Phòng'} - Chưa thanh toán',
        subtitle: '${inv.formattedBillingMonth} - ${inv.formattedTotal}',
        color: AppColors.tertiary,
      ));
    }

    return alerts;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Row(
          children: [
            const Icon(Icons.grid_view, color: AppColors.primaryContainer),
            const SizedBox(width: 8),
            Text(
              'The Ledger',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.primaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primaryFixed,
              child: Icon(Icons.person, color: AppColors.primary),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorView()
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tổng quan danh mục',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Trạng thái thời gian thực của các căn hộ.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 32),
                        Row(
                          children: [
                            Expanded(
                              child: MetricCard(
                                title: 'Tổng số',
                                value: '$_totalRooms',
                                subtitle: 'Lấp đầy',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: MetricCard(
                                title: 'Đang ở',
                                value: '$_occupiedRooms',
                                subtitle: _totalRooms > 0
                                    ? '${(_occupiedRooms / _totalRooms * 100).toStringAsFixed(0)}%'
                                    : '0%',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: MetricCard(
                                title: 'Trống',
                                value: _availableRooms.toString().padLeft(2, '0'),
                                icon: Icons.list_alt,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        RevenueCard(
                          revenue: _formatRevenue(_monthlyRevenue),
                        ),
                        const SizedBox(height: 40),
                        RoomStatusMap(rooms: _rooms),
                        const SizedBox(height: 40),
                        AlertsList(alerts: _buildAlerts()),
                        const SizedBox(height: 40),
                        const QuickInputForm(),
                      ],
                    ),
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, color: AppColors.onPrimary),
      ),
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
              'Không thể kết nối đến server',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? '',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
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
