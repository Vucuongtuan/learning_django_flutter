from django.contrib import admin
from .models import Tenant, IdentityDocument


class IdentityDocumentInline(admin.TabularInline):
    model = IdentityDocument
    extra = 1


@admin.register(Tenant)
class TenantAdmin(admin.ModelAdmin):
    list_display = ('full_name', 'phone', 'gender', 'identity_number')
    search_fields = ('full_name', 'phone', 'identity_number')
    inlines = [IdentityDocumentInline]
