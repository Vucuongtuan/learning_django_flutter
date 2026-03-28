class Room {
  final int id;
  final String name;
  final String status;
  final double price;
  final String? description;
  final String? tenantName;

  const Room({
    required this.id,
    required this.name,
    required this.status,
    required this.price,
    this.description,
    this.tenantName,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'] as int,
      name: json['name'] as String,
      status: json['status'] as String,
      price: (json['price'] as num).toDouble(),
      description: json['description'] as String?,
      tenantName: json['tenant_name'] as String?,
    );
  }

  bool get isOccupied => status == 'occupied';
  bool get isAvailable => status == 'available';
  bool get isBooked => status == 'booked';
  bool get isMaintenance => status == 'maintenance';

  String get statusLabel {
    switch (status) {
      case 'occupied':
        return 'ĐANG Ở';
      case 'available':
        return 'TRỐNG';
      case 'booked':
        return 'ĐÃ ĐẶT';
      case 'maintenance':
        return 'BẢO TRÌ';
      default:
        return status.toUpperCase();
    }
  }
}
