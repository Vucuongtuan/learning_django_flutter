class Lease {
  final int id;
  final int tenantId;
  final int roomId;
  final String? tenantName;
  final String? roomName;
  final String moveInDate;
  final String? moveOutDate;
  final double rentAmount;
  final double depositAmount;
  final bool isActive;

  const Lease({
    required this.id,
    required this.tenantId,
    required this.roomId,
    this.tenantName,
    this.roomName,
    required this.moveInDate,
    this.moveOutDate,
    required this.rentAmount,
    required this.depositAmount,
    required this.isActive,
  });

  factory Lease.fromJson(Map<String, dynamic> json) {
    return Lease(
      id: json['id'] as int,
      tenantId: json['tenant'] is int
          ? json['tenant'] as int
          : (json['tenant'] as Map<String, dynamic>)['id'] as int,
      roomId: json['room'] is int
          ? json['room'] as int
          : (json['room'] as Map<String, dynamic>)['id'] as int,
      tenantName: json['tenant_name'] as String? ??
          (json['tenant'] is Map ? (json['tenant'] as Map<String, dynamic>)['full_name'] as String? : null),
      roomName: json['room_name'] as String? ??
          (json['room'] is Map ? (json['room'] as Map<String, dynamic>)['name'] as String? : null),
      moveInDate: json['move_in_date'] as String,
      moveOutDate: json['move_out_date'] as String?,
      rentAmount: (json['rent_amount'] as num).toDouble(),
      depositAmount: (json['deposit_amount'] as num).toDouble(),
      isActive: json['is_active'] as bool? ?? true,
    );
  }
}
