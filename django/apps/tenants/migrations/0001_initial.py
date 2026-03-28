
import django.db.models.deletion
from django.db import migrations, models


class Migration(migrations.Migration):

    initial = True

    dependencies = [
    ]

    operations = [
        migrations.CreateModel(
            name='Tenant',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('full_name', models.CharField(max_length=100)),
                ('phone', models.CharField(max_length=15, unique=True)),
                ('email', models.EmailField(blank=True, max_length=254)),
                ('date_of_birth', models.DateField()),
                ('gender', models.CharField(choices=[('male', 'Nam'), ('female', 'Nữ'), ('other', 'Khác')], max_length=10)),
                ('identity_number', models.CharField(max_length=50, unique=True)),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('updated_at', models.DateTimeField(auto_now=True)),
            ],
        ),
        migrations.CreateModel(
            name='IdentityDocument',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('doc_type', models.CharField(choices=[('cccd', 'Căn cước công dân'), ('birth_cert', 'Giấy khai sinh'), ('passport', 'Hộ chiếu')], default='cccd', max_length=20)),
                ('front_image_url', models.URLField(max_length=500)),
                ('back_image_url', models.URLField(blank=True, max_length=500, null=True)),
                ('issue_date', models.DateField(blank=True, null=True)),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('tenant', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='documents', to='tenants.tenant')),
            ],
        ),
    ]
