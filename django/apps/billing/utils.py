import os
from io import BytesIO
from django.template.loader import get_template
from xhtml2pdf import pisa
from django.conf import settings
from django.core.files.base import ContentFile

def generate_invoice_pdf(invoice):
    """Biến hóa đơn MonthlyInvoice thành file PDF."""
    template = get_template('billing/invoice_pdf.html')
    
    # Dữ liệu truyền vào template
    context = {
        'invoice': invoice,
        'lease': invoice.lease,
        'room': invoice.lease.room,
        'tenant': invoice.lease.tenant,
        'billing_month_str': invoice.billing_month.strftime('%m/%Y'),
        'total_amount_str': f"{int(invoice.total_amount):,}"
    }
    
    html = template.render(context)
    result = BytesIO()
    
    # Tạo PDF từ HTML
    pdf = pisa.pisaDocument(BytesIO(html.encode("UTF-8")), result, encoding='UTF-8')
    
    if not pdf.err:
        # Lưu file vào thư mục media/invoices/
        filename = f"invoice_{invoice.id}_{invoice.billing_month.strftime('%Y%m')}.pdf"
        filepath = os.path.join('invoices', filename)
        
        # Nếu model có trường để lưu file (sẽ thêm ở bước sau)
        # invoice.pdf_file.save(filename, ContentFile(result.getvalue()), save=True)
        
        return filepath
    return None
