import 'package:app_flutter/models/lease.dart';
import 'package:app_flutter/services/api_client.dart';

class LeaseService {
  final ApiClient _api = ApiClient();

  Future<List<Lease>> fetchLeases({int? roomId, bool? isActive}) async {
    final queryParams = <String, String>{};
    if (roomId != null) queryParams['room'] = roomId.toString();
    if (isActive != null) queryParams['is_active'] = isActive.toString();
    final data = await _api.get('/leases/', queryParams: queryParams.isNotEmpty ? queryParams : null);
    return _api.parseList(data, Lease.fromJson);
  }

  Future<Lease> fetchLease(int id) async {
    final data = await _api.get('/leases/$id/');
    return Lease.fromJson(data as Map<String, dynamic>);
  }

  Future<Lease> createLease({
    required int tenantId,
    required int roomId,
    required String moveInDate,
    required double rentAmount,
    required double depositAmount,
  }) async {
    final data = await _api.post('/leases/', body: {
      'tenant': tenantId,
      'room': roomId,
      'move_in_date': moveInDate,
      'rent_amount': rentAmount,
      'deposit_amount': depositAmount,
    });
    return Lease.fromJson(data as Map<String, dynamic>);
  }
}
