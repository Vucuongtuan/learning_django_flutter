import 'package:flutter/material.dart';
import 'package:app_flutter/theme/app_theme.dart';
import 'package:app_flutter/models/room.dart';
import 'package:app_flutter/models/utility_reading.dart';
import 'package:app_flutter/services/room_service.dart';
import 'package:app_flutter/services/utility_service.dart';
import 'package:app_flutter/widgets/features/utility_entry/ledger_card.dart';

class UtilityEntryScreen extends StatefulWidget {
  const UtilityEntryScreen({super.key});

  @override
  State<UtilityEntryScreen> createState() => _UtilityEntryScreenState();
}

class _UtilityEntryScreenState extends State<UtilityEntryScreen> {
  final RoomService _roomService = RoomService();
  final UtilityService _utilityService = UtilityService();

  final TextEditingController _electricityController = TextEditingController();
  final TextEditingController _waterController = TextEditingController();

  List<Room> _rooms = [];
  Room? _selectedRoom;
  UtilityReading? _lastElectricity;
  UtilityReading? _lastWater;
  bool _isLoadingRooms = true;
  bool _isLoadingReadings = false;
  bool _isSubmitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRooms();
  }

  @override
  void dispose() {
    _electricityController.dispose();
    _waterController.dispose();
    super.dispose();
  }

  Future<void> _loadRooms() async {
    try {
      final rooms = await _roomService.fetchRooms(status: 'occupied');
      setState(() {
        _rooms = rooms;
        _isLoadingRooms = false;
        if (rooms.isNotEmpty) {
          _selectedRoom = rooms.first;
          _loadPreviousReadings(rooms.first.id);
        }
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoadingRooms = false;
      });
    }
  }

  Future<void> _loadPreviousReadings(int roomId) async {
    setState(() => _isLoadingReadings = true);
    try {
      final readings = await _utilityService.fetchUtilityReadings(roomId: roomId);
      final electric = readings.where((r) => r.isElectricity).toList();
      final water = readings.where((r) => r.isWater).toList();
      setState(() {
        _lastElectricity = electric.isNotEmpty ? electric.first : null;
        _lastWater = water.isNotEmpty ? water.first : null;
        _isLoadingReadings = false;
      });
    } catch (e) {
      setState(() => _isLoadingReadings = false);
    }
  }

  Future<void> _submitReadings() async {
    if (_selectedRoom == null) return;

    final electricityValue = double.tryParse(_electricityController.text.replaceAll(',', '.'));
    final waterValue = double.tryParse(_waterController.text.replaceAll(',', '.'));

    if (electricityValue == null || waterValue == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập chỉ số hợp lệ')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final now = DateTime.now();
      final billingMonth = '${now.year}-${now.month.toString().padLeft(2, '0')}-01';

      await _utilityService.createUtilityReading(
        roomId: _selectedRoom!.id,
        type: 'electricity',
        billingMonth: billingMonth,
        previousReading: _lastElectricity?.currentReading ?? 0,
        currentReading: electricityValue,
      );

      await _utilityService.createUtilityReading(
        roomId: _selectedRoom!.id,
        type: 'water',
        billingMonth: billingMonth,
        previousReading: _lastWater?.currentReading ?? 0,
        currentReading: waterValue,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã gửi chỉ số thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        _electricityController.clear();
        _waterController.clear();
        _loadPreviousReadings(_selectedRoom!.id);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.grid_view, color: AppColors.primaryContainer),
            const SizedBox(width: 8),
            Text(
              'Sổ Thu Chi',
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
      body: _isLoadingRooms
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.cloud_off, size: 64, color: AppColors.onSurfaceVariant),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _loadRooms,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Thử lại'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context),
                      const SizedBox(height: 32),
                      _buildRoomSelector(context),
                      const SizedBox(height: 32),
                      if (_isLoadingReadings)
                        const Center(child: CircularProgressIndicator())
                      else ...[
                        LedgerCard(
                          icon: Icons.bolt,
                          title: 'Chỉ số điện',
                          iconColor: AppColors.primary,
                          iconBgColor: AppColors.primaryContainer.withValues(alpha: 0.2),
                          oldReading: _lastElectricity != null
                              ? _lastElectricity!.currentReading.toStringAsFixed(2)
                              : '0.00',
                          unit: 'kWh',
                          unitColor: AppColors.tertiary,
                          unitBgColor: AppColors.tertiaryContainer.withValues(alpha: 0.1),
                          controller: _electricityController,
                        ),
                        const SizedBox(height: 24),
                        LedgerCard(
                          icon: Icons.water_drop,
                          title: 'Chỉ số nước',
                          iconColor: AppColors.secondary,
                          iconBgColor: AppColors.secondaryContainer.withValues(alpha: 0.3),
                          oldReading: _lastWater != null
                              ? _lastWater!.currentReading.toStringAsFixed(2)
                              : '0.00',
                          unit: 'm³',
                          unitColor: AppColors.secondary,
                          unitBgColor: AppColors.secondaryContainer.withValues(alpha: 0.2),
                          controller: _waterController,
                        ),
                      ],
                      const SizedBox(height: 32),
                      _buildSubmitButton(context),
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
        Text(
          'Nhập chỉ số điện nước',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Nhập chỉ số hàng tháng cho từng phòng.',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildRoomSelector(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _selectedRoom?.id,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down),
          items: _rooms.map((room) {
            return DropdownMenuItem<int>(
              value: room.id,
              child: Text('Phòng ${room.name}', style: const TextStyle(fontWeight: FontWeight.w600)),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              final room = _rooms.firstWhere((r) => r.id == value);
              setState(() => _selectedRoom = room);
              _loadPreviousReadings(value);
            }
          },
        ),
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submitReadings,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            padding: const EdgeInsets.symmetric(vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
            shadowColor: AppColors.primary.withValues(alpha: 0.4),
            minimumSize: const Size(double.infinity, 0),
          ),
          child: _isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Gửi chỉ số',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward),
                  ],
                ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Text(
            _selectedRoom != null
                ? 'Sau khi gửi, hóa đơn sẽ tự động được tạo và chờ thanh toán cho Phòng ${_selectedRoom!.name} dựa trên biểu giá hiện tại.'
                : 'Vui lòng chọn phòng trước khi gửi chỉ số.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
