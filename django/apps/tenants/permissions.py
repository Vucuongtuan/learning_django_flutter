from rest_framework import permissions

class IsTenantOwner(permissions.BasePermission):
    """
    Quyền truy cập dành riêng cho Người thuê (Tenant).
    Đảm bảo người dùng chỉ xem được các bản ghi (Lease, Invoice, v.v.)
    liên quan trực tiếp tới hồ sơ Tenant của họ.
    """
    def has_permission(self, request, view):
        # Yêu cầu người dùng phải đăng nhập và có hồ sơ Tenant liên kết
        return request.user.is_authenticated and hasattr(request.user, 'tenant_profile')

    def has_object_permission(self, request, view, obj):
        # Kiểm tra xem object đó có thuộc về Tenant của người dùng hiện tại không
        # Đối với Lease: obj.tenant
        # Đối với Invoice: obj.lease.tenant
        
        tenant = request.user.tenant_profile
        
        # Nếu object là chính Tenant đó
        if hasattr(obj, 'user') and obj == tenant:
            return True
        
        # Nếu object là Lease
        if hasattr(obj, 'tenant'):
            return obj.tenant == tenant
            
        # Nếu object là Invoice (liên kết qua lease)
        if hasattr(obj, 'lease'):
            return obj.lease.tenant == tenant
            
        return False
