from rest_framework import permissions

class IsTenantOwner(permissions.BasePermission):
    """
    Quyền truy cập dành riêng cho Người thuê (Tenant).
    Đảm bảo người dùng chỉ xem được các bản ghi (Lease, Invoice, v.v.)
    liên quan trực tiếp tới hồ sơ Tenant của họ.
    """
    def has_permission(self, request, view):
        return request.user.is_authenticated and hasattr(request.user, 'tenant_profile')

    def has_object_permission(self, request, view, obj):
        
        tenant = request.user.tenant_profile
        
        if hasattr(obj, 'user') and obj == tenant:
            return True
        
        if hasattr(obj, 'tenant'):
            return obj.tenant == tenant
            
        if hasattr(obj, 'lease'):
            return obj.lease.tenant == tenant
            
        return False
