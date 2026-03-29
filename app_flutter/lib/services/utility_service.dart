import 'package:app_flutter/models/utility_reading.dart';
import 'package:app_flutter/services/api_client.dart';

class UtilityService {
  final ApiClient _api = ApiClient();

  Future<List<UtilityReading>> fetchUtilityReadings({int? roomId, String? type}) async {
    final queryParams = <String, String>{};
    if (roomId != null) queryParams['room'] = roomId.toString();
    if (type != null) queryParams['type'] = type;
    final data = await _api.get('/utilities/readings/', queryParams: queryParams.isNotEmpty ? queryParams : null);
    return _api.parseList(data, UtilityReading.fromJson);
  }

  Future<UtilityReading> createUtilityReading({
    required int roomId,
    required String type,
    required String billingMonth,
    required double previousReading,
    required double currentReading,
  }) async {
    final data = await _api.post('/utilities/readings/', body: {
      'room': roomId,
      'type': type,
      'billing_month': billingMonth,
      'previous_reading': previousReading,
      'current_reading': currentReading,
    });
    return UtilityReading.fromJson(data as Map<String, dynamic>);
  }
}
