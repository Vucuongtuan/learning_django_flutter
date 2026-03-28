import 'package:flutter/material.dart';
import 'package:app_flutter/theme/app_theme.dart';
import 'package:app_flutter/models/room.dart';
import 'package:app_flutter/services/room_service.dart';
import 'package:app_flutter/screens/room_detail/room_detail_screen.dart';

import 'package:app_flutter/widgets/common/custom_search_bar.dart';
import 'package:app_flutter/widgets/features/room/occupied_room_card.dart';
import 'package:app_flutter/widgets/features/room/available_room_card.dart';
import 'package:app_flutter/widgets/features/room/inventory_overview_card.dart';

class RoomListScreen extends StatefulWidget {
  const RoomListScreen({super.key});

  @override
  State<RoomListScreen> createState() => _RoomListScreenState();
}

class _RoomListScreenState extends State<RoomListScreen> {
  final RoomService _roomService = RoomService();

  List<Room> _rooms = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRooms();
  }

  Future<void> _loadRooms() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final rooms = await _roomService.fetchRooms();
      setState(() {
        _rooms = rooms;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.grid_view,
                color: AppColors.primaryContainer,
              ),
            ),
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
              backgroundColor: AppColors.secondaryContainer,
              child: Icon(Icons.person, color: AppColors.onSurfaceVariant),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorView()
              : RefreshIndicator(
                  onRefresh: _loadRooms,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quản lý phòng',
                          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            fontSize: 28,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Quản lý tình trạng sử dụng, tiền thuê và chi tiết căn hộ tại The Ledger Residencies.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 32),
                        const CustomSearchBar(
                          hintText: 'Tìm kiếm theo số phòng, tên khách...',
                        ),
                        const SizedBox(height: 32),
                        _buildRoomGrid(),
                        const SizedBox(height: 32),
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

  Widget _buildRoomGrid() {
    final totalRooms = _rooms.length;
    final occupiedCount = _rooms.where((r) => r.isOccupied).length;
    final occupancyRate = totalRooms > 0 ? occupiedCount / totalRooms : 0.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = constraints.maxWidth > 900
            ? 3
            : constraints.maxWidth > 600
            ? 2
            : 1;

        final List<Widget> cards = _rooms.map((room) {
          if (room.isOccupied) {
            return GestureDetector(
              onTap: () => _navigateToDetail(room),
              child: OccupiedRoomCard(
                unit: room.name,
                tenant: room.tenantName ?? 'Chưa rõ',
                rent: '${room.price.toStringAsFixed(0)}đ',
              ),
            );
          } else {
            return AvailableRoomCard(
              unit: room.name,
              description: room.isAvailable
                  ? 'Sẵn sàng dọn vào ngay.'
                  : room.isMaintenance
                      ? 'Đang bảo trì.'
                      : 'Đã đặt trước.',
              rate: '${room.price.toStringAsFixed(0)}đ',
              rateLabel: room.isMaintenance ? 'Giá dự kiến' : 'Giá thị trường',
              isHold: room.isBooked || room.isMaintenance,
              actionText: room.isAvailable ? 'GÁN PHÒNG' : 'GIỮ CHỖ',
            );
          }
        }).toList();

        cards.add(
          InventoryOverviewCard(
            totalUnits: totalRooms,
            occupancyRate: '${(occupancyRate * 100).toStringAsFixed(0)}%',
            occupancyFactor: occupancyRate,
          ),
        );

        return GridView.count(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 24,
          mainAxisSpacing: 24,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 0.85,
          children: cards,
        );
      },
    );
  }

  void _navigateToDetail(Room room) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RoomDetailScreen(roomId: room.id),
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
              'Không thể tải danh sách phòng',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadRooms,
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
}
