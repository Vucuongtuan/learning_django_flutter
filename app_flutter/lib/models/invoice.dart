class Invoice {
  final int id;
  final int leaseId;
  final String? roomName;
  final String? tenantName;
  final String billingMonth;
  final double rentAmount;
  final double? electricityCost;
  final double? waterCost;
  final double? otherCost;
  final double? discount;
  final double totalAmount;
  final bool isPaid;
  final String? paidDate;

  const Invoice({
    required this.id,
    required this.leaseId,
    this.roomName,
    this.tenantName,
    required this.billingMonth,
    required this.rentAmount,
    this.electricityCost,
    this.waterCost,
    this.otherCost,
    this.discount,
    required this.totalAmount,
    required this.isPaid,
    this.paidDate,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id'] as int,
      leaseId: json['lease'] is int
          ? json['lease'] as int
          : (json['lease'] as Map<String, dynamic>)['id'] as int,
      roomName: json['room_name'] as String?,
      tenantName: json['tenant_name'] as String?,
      billingMonth: json['billing_month'] as String,
      rentAmount: (json['rent_amount'] as num).toDouble(),
      electricityCost: (json['electricity_cost'] as num?)?.toDouble(),
      waterCost: (json['water_cost'] as num?)?.toDouble(),
      otherCost: (json['other_cost'] as num?)?.toDouble(),
      discount: (json['discount'] as num?)?.toDouble(),
      totalAmount: (json['total_amount'] as num).toDouble(),
      isPaid: json['is_paid'] as bool? ?? false,
      paidDate: json['paid_date'] as String?,
    );
  }

  String get statusLabel => isPaid ? 'Đã thanh toán' : 'Chưa thanh toán';

  String get formattedTotal {
    final formatted = totalAmount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+$)'),
      (m) => '${m[1]}.',
    );
    return '${formatted}đ';
  }

  String get formattedBillingMonth {
    final parts = billingMonth.split('-');
    if (parts.length >= 2) {
      return 'Tháng ${parts[1]}/${parts[0]}';
    }
    return billingMonth;
  }
}
