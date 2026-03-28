import 'package:flutter/material.dart';
import 'package:app_flutter/theme/app_theme.dart';

class InventoryOverviewCard extends StatelessWidget {
  final int totalUnits;
  final String occupancyRate;
  final double occupancyFactor;

  const InventoryOverviewCard({
    super.key,
    required this.totalUnits,
    required this.occupancyRate,
    required this.occupancyFactor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryContainer],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TỔNG QUAN',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.onPrimaryContainer,
                  letterSpacing: 1.2,
                ),
          ),
          const SizedBox(height: 16),
          Text(
            '$totalUnits',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: AppColors.onPrimary,
                  fontSize: 40,
                ),
          ),
          Text(
            'Tổng số phòng',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.onPrimaryContainer,
                ),
          ),
          const Spacer(),
          Text(
            'Tỉ lệ lấp đầy',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.onPrimaryContainer,
                ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: occupancyFactor,
                    backgroundColor: AppColors.onPrimary.withOpacity(0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.onPrimary),
                    minHeight: 6,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                occupancyRate,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
