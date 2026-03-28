import 'package:flutter/material.dart';
import 'package:app_flutter/theme/app_theme.dart';

class RevenueCard extends StatelessWidget {
  final String revenue;
  final String growthPercent;
  final bool isPositiveGrowth;

  const RevenueCard({
    super.key,
    required this.revenue,
    this.growthPercent = '',
    this.isPositiveGrowth = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'DOANH THU THÁNG',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.onPrimaryContainer,
                  letterSpacing: 1.2,
                ),
              ),
              const Icon(
                Icons.payments,
                color: AppColors.onPrimaryContainer,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                revenue,
                style: Theme.of(
                  context,
                ).textTheme.headlineLarge?.copyWith(color: AppColors.onPrimary),
              ),
              if (growthPercent.isNotEmpty)
                Row(
                  children: [
                    Icon(
                      isPositiveGrowth ? Icons.trending_up : Icons.trending_down,
                      color: AppColors.onPrimaryContainer,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      growthPercent,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}
