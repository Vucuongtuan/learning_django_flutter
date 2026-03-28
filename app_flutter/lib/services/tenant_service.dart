import 'package:app_flutter/models/tenant.dart';
import 'package:app_flutter/services/api_client.dart';

class TenantService {
  final ApiClient _api = ApiClient();

  Future<List<Tenant>> fetchTenants({String? search}) async {
    final queryParams = <String, String>{};
    if (search != null) queryParams['search'] = search;
    final data = await _api.get('/tenants/', queryParams: queryParams.isNotEmpty ? queryParams : null);
    return _api.parseList(data, Tenant.fromJson);
  }

  Future<Tenant> fetchTenant(int id) async {
    final data = await _api.get('/tenants/$id/');
    return Tenant.fromJson(data as Map<String, dynamic>);
  }
}
