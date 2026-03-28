import 'package:flutter/material.dart';
import 'package:app_flutter/theme/app_theme.dart';
import 'package:app_flutter/models/invoice.dart';

class ReceiptCanvas extends StatelessWidget {
  final Invoice invoice;
  final String? roomName;

  const ReceiptCanvas({
    super.key,
    required this.invoice,
    this.roomName,
  });

  String _formatCurrency(double amount) {
    final formatted = amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+$)'),
      (m) => '${m[1]}.',
    );
    return '${formatted}đ';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.receipt_long, size: 40, color: AppColors.primary),
          const SizedBox(height: 12),
          Text(
            'HÓA ĐƠN THANH TOÁN',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  letterSpacing: 2.0,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            '${roomName ?? 'Phòng'} • ${invoice.formattedBillingMonth}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          _buildLineItem(context, 'Tiền phòng', _formatCurrency(invoice.rentAmount)),
          if (invoice.electricityCost != null && invoice.electricityCost! > 0) ...[
            const SizedBox(height: 12),
            _buildLineItem(context, 'Tiền điện', _formatCurrency(invoice.electricityCost!)),
          ],
          if (invoice.waterCost != null && invoice.waterCost! > 0) ...[
            const SizedBox(height: 12),
            _buildLineItem(context, 'Tiền nước', _formatCurrency(invoice.waterCost!)),
          ],
          if (invoice.otherCost != null && invoice.otherCost! > 0) ...[
            const SizedBox(height: 12),
            _buildLineItem(context, 'Dịch vụ khác', _formatCurrency(invoice.otherCost!)),
          ],
          if (invoice.discount != null && invoice.discount! > 0) ...[
            const SizedBox(height: 12),
            _buildLineItem(context, 'Giảm giá', '-${_formatCurrency(invoice.discount!)}'),
          ],
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TỔNG CỘNG',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                invoice.formattedTotal,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: invoice.isPaid
                  ? AppColors.tertiary.withOpacity(0.1)
                  : AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              invoice.isPaid ? '✓ ĐÃ THANH TOÁN' : '✗ CHƯA THANH TOÁN',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: invoice.isPaid ? AppColors.tertiary : AppColors.error,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLineItem(BuildContext context, String label, String amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        Text(
          amount,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}
