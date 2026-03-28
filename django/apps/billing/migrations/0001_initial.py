
import django.db.models.deletion
from django.db import migrations, models


class Migration(migrations.Migration):

    initial = True

    dependencies = [
        ('leases', '0001_initial'),
    ]

    operations = [
        migrations.CreateModel(
            name='Discount',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('discount_type', models.CharField(choices=[('percentage', 'Giảm theo %'), ('fixed', 'Giảm số tiền cố định')], max_length=20)),
                ('value', models.DecimalField(decimal_places=2, help_text='VD: 10 = 10% hoặc 200000 = 200k VNĐ', max_digits=10)),
                ('reason', models.CharField(help_text='Lý do giảm giá (sinh viên, hoàn cảnh khó khăn...)', max_length=200)),
                ('start_date', models.DateField()),
                ('end_date', models.DateField(blank=True, help_text='Để trống = vô thời hạn', null=True)),
                ('is_active', models.BooleanField(default=True)),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('updated_at', models.DateTimeField(auto_now=True)),
                ('lease', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='discounts', to='leases.lease')),
            ],
        ),
        migrations.CreateModel(
            name='MonthlyInvoice',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('billing_month', models.DateField(help_text='Tháng tính (ngày 1 của tháng)')),
                ('rent_amount', models.DecimalField(decimal_places=2, default=0, max_digits=12)),
                ('electricity_cost', models.DecimalField(decimal_places=2, default=0, max_digits=12)),
                ('water_cost', models.DecimalField(decimal_places=2, default=0, max_digits=12)),
                ('discount_amount', models.DecimalField(decimal_places=2, default=0, max_digits=12)),
                ('total_amount', models.DecimalField(decimal_places=2, default=0, max_digits=12)),
                ('is_paid', models.BooleanField(default=False)),
                ('paid_date', models.DateField(blank=True, null=True)),
                ('note', models.TextField(blank=True)),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('updated_at', models.DateTimeField(auto_now=True)),
                ('lease', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='invoices', to='leases.lease')),
            ],
            options={
                'ordering': ['-billing_month'],
                'unique_together': {('lease', 'billing_month')},
            },
        ),
    ]
