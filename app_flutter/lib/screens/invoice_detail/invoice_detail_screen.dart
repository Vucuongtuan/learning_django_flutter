import 'package:flutter/material.dart';
import 'package:app_flutter/theme/app_theme.dart';
import 'package:app_flutter/models/invoice.dart';
import 'package:app_flutter/services/invoice_service.dart';
import 'package:app_flutter/widgets/features/invoice_detail/receipt_canvas.dart';

class InvoiceDetailScreen extends StatefulWidget {
  final int? invoiceId;

  const InvoiceDetailScreen({super.key, this.invoiceId});

  @override
  State<InvoiceDetailScreen> createState() => _InvoiceDetailScreenState();
}

class _InvoiceDetailScreenState extends State<InvoiceDetailScreen> {
  final InvoiceService _invoiceService = InvoiceService();

  List<Invoice> _invoices = [];
  Invoice? _selectedInvoice;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      if (widget.invoiceId != null) {
        final invoice = await _invoiceService.fetchInvoice(widget.invoiceId!);
        setState(() {
          _invoices = [invoice];
          _selectedInvoice = invoice;
          _isLoading = false;
        });
      } else {
        final invoices = await _invoiceService.fetchInvoices();
        setState(() {
          _invoices = invoices;
          _selectedInvoice = invoices.isNotEmpty ? invoices.first : null;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.grid_view, color: AppColors.primaryContainer),
            const SizedBox(width: 8),
            Text(
              'The Ledger',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.primaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.secondaryContainer,
              child: Icon(Icons.person, size: 18, color: AppColors.onSurfaceVariant),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorView()
              : _selectedInvoice == null
                  ? const Center(child: Text('Chưa có hóa đơn nào'))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(context),
                          const SizedBox(height: 16),
                          if (_invoices.length > 1) _buildInvoiceSelector(context),
                          const SizedBox(height: 24),
                          ReceiptCanvas(
                            invoice: _selectedInvoice!,
                            roomName: _selectedInvoice!.roomName,
                          ),
                          const SizedBox(height: 32),
                          _buildActionButtons(context),
                          const SizedBox(height: 48),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'QUẢN LÝ PHÒNG',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            letterSpacing: 1.2,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Hóa đơn thanh toán',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            fontSize: 28,
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildInvoiceSelector(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _selectedInvoice?.id,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down),
          items: _invoices.map((inv) {
            return DropdownMenuItem<int>(
              value: inv.id,
              child: Text(
                '${inv.roomName ?? 'Phòng'} - ${inv.formattedBillingMonth}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedInvoice = _invoices.firstWhere((i) => i.id == value);
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            padding: const EdgeInsets.symmetric(vertical: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 4,
            shadowColor: AppColors.primary.withOpacity(0.4),
            minimumSize: const Size(double.infinity, 0),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.share, size: 18),
              SizedBox(width: 12),
              Text('Chia sẻ hóa đơn (Zalo)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.surface,
            foregroundColor: AppColors.onSurfaceVariant,
            padding: const EdgeInsets.symmetric(vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: AppColors.outlineVariant.withOpacity(0.3)),
            ),
            elevation: 0,
            minimumSize: const Size(double.infinity, 0),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.file_download, size: 18),
              SizedBox(width: 12),
              Text('Tải file PDF', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off, size: 64, color: AppColors.onSurfaceVariant),
          const SizedBox(height: 16),
          Text('Không thể tải hóa đơn', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
            label: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }
}
