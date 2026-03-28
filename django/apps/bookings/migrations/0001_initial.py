
import django.db.models.deletion
from django.db import migrations, models


class Migration(migrations.Migration):

    initial = True

    dependencies = [
        ('rooms', '0001_initial'),
    ]

    operations = [
        migrations.CreateModel(
            name='Booking',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('tenant_name', models.CharField(help_text='Tên khách gọi điện', max_length=100)),
                ('tenant_phone', models.CharField(help_text='Số điện thoại khách', max_length=15)),
                ('expected_move_in_date', models.DateField(help_text='Ngày dự kiến dọn vào')),
                ('deposit_amount', models.PositiveIntegerField(default=0, help_text='Số tiền cọc giữ chỗ')),
                ('status', models.CharField(choices=[('pending', 'Chờ xử lý'), ('confirmed', 'Đã xác nhận cọc'), ('cancelled', 'Đã hủy'), ('completed', 'Đã nhận phòng')], default='pending', max_length=20)),
                ('note', models.TextField(blank=True, help_text='Ghi chú thêm (ví dụ: khách đòi sơn lại tường)')),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('updated_at', models.DateTimeField(auto_now=True)),
                ('room', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='bookings', to='rooms.room')),
            ],
        ),
    ]
