
import django.db.models.deletion
from django.db import migrations, models


class Migration(migrations.Migration):

    initial = True

    dependencies = [
    ]

    operations = [
        migrations.CreateModel(
            name='Room',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('name', models.CharField(max_length=50, unique=True)),
                ('price', models.PositiveIntegerField(default=0)),
                ('capacity', models.PositiveIntegerField(default=1)),
                ('description', models.TextField(blank=True)),
                ('status', models.CharField(choices=[('available', 'Available / Trống'), ('booked', 'Booked / Đã đặt chỗ'), ('occupied', 'Occupied / Đã cho thuê'), ('maintenance', 'Maintenance / Bảo trì')], default='available', max_length=20)),
                ('thumbnail_url', models.URLField(blank=True, help_text='Ảnh chính của phòng', max_length=500, null=True)),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('updated_at', models.DateTimeField(auto_now=True)),
            ],
            options={
                'ordering': ['name'],
            },
        ),
        migrations.CreateModel(
            name='RoomImage',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('image_url', models.URLField(max_length=500)),
                ('caption', models.CharField(blank=True, help_text='Mô tả ảnh (ví dụ: Nhà bếp, Ban công)', max_length=200)),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('room', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='images', to='rooms.room')),
            ],
        ),
    ]
