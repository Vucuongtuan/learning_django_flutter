import 'package:flutter/material.dart';
import 'package:app_flutter/theme/app_theme.dart';
import 'package:app_flutter/models/room.dart';

class RoomStatusMap extends StatelessWidget {
  final List<Room> rooms;

  const RoomStatusMap({super.key, required this.rooms});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Bản đồ phòng',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Row(
              children: [
                _buildLegendItem(context, AppColors.error, 'Đang ở'),
                const SizedBox(width: 12),
                _buildLegendItem(context, AppColors.tertiary, 'Trống'),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        rooms.isEmpty
            ? const Center(child: Text('Chưa có dữ liệu phòng'))
            : Wrap(
                spacing: 8,
                runSpacing: 8,
                children: rooms.map((room) {
                  final isEmpty = room.isAvailable;
                  return Container(
                    width: 38,
                    height: 38,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isEmpty ? AppColors.tertiary : AppColors.error,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      room.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }).toList(),
              ),
      ],
    );
  }

  Widget _buildLegendItem(BuildContext context, Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
