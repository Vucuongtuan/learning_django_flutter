class UtilityReading {
  final int id;
  final int roomId;
  final String? roomName;
  final String type;
  final String billingMonth;
  final double previousReading;
  final double currentReading;
  final double? unitPrice;

  const UtilityReading({
    required this.id,
    required this.roomId,
    this.roomName,
    required this.type,
    required this.billingMonth,
    required this.previousReading,
    required this.currentReading,
    this.unitPrice,
  });

  factory UtilityReading.fromJson(Map<String, dynamic> json) {
    return UtilityReading(
      id: json['id'] as int,
      roomId: json['room'] is int
          ? json['room'] as int
          : (json['room'] as Map<String, dynamic>)['id'] as int,
      roomName: json['room_name'] as String? ??
          (json['room'] is Map ? (json['room'] as Map<String, dynamic>)['name'] as String? : null),
      type: json['type'] as String,
      billingMonth: json['billing_month'] as String,
      previousReading: (json['previous_reading'] as num).toDouble(),
      currentReading: (json['current_reading'] as num).toDouble(),
      unitPrice: (json['unit_price'] as num?)?.toDouble(),
    );
  }

  double get consumption => currentReading - previousReading;

  bool get isElectricity => type == 'electricity';
  bool get isWater => type == 'water';

  String get unit => isElectricity ? 'kWh' : 'm³';
}
