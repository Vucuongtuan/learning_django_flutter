import 'package:app_flutter/services/api_client.dart';

class DiscountService {
  final ApiClient _api = ApiClient();

  Future<dynamic> bulkApplyDiscount({
    required String description,
    required double amount,
    List<int>? roomIds,
    bool applyAll = false,
  }) async {
    final body = <String, dynamic>{
      'description': description,
      'amount': amount,
      'apply_all': applyAll,
    };
    if (roomIds != null) body['room_ids'] = roomIds;

    return await _api.post('/billing/discounts/bulk_apply/', body: body);
  }
}
