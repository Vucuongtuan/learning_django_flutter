import 'package:app_flutter/models/invoice.dart';
import 'package:app_flutter/services/api_client.dart';

class InvoiceService {
  final ApiClient _api = ApiClient();

  Future<List<Invoice>> fetchInvoices({int? leaseId, bool? isPaid}) async {
    final queryParams = <String, String>{};
    if (leaseId != null) queryParams['lease'] = leaseId.toString();
    if (isPaid != null) queryParams['is_paid'] = isPaid.toString();
    final data = await _api.get('/billing/invoices/', queryParams: queryParams.isNotEmpty ? queryParams : null);
    return _api.parseList(data, Invoice.fromJson);
  }

  Future<Invoice> fetchInvoice(int id) async {
    final data = await _api.get('/billing/invoices/$id/');
    return Invoice.fromJson(data as Map<String, dynamic>);
  }

  Future<Invoice> generateInvoice({
    required int leaseId,
    required String billingMonth,
  }) async {
    final data = await _api.post('/billing/invoices/generate/', body: {
      'lease_id': leaseId,
      'billing_month': billingMonth,
    });
    return Invoice.fromJson(data as Map<String, dynamic>);
  }

  Future<Invoice> markAsPaid(int id) async {
    final data = await _api.post('/billing/invoices/$id/mark_as_paid/');
    return Invoice.fromJson(data as Map<String, dynamic>);
  }
}
