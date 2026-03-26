from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/', include('apps.rooms.urls')),
    path('api/', include('apps.tenants.urls')),
    path('api/', include('apps.leases.urls')),
    path('api/', include('apps.bookings.urls')),
    path('api/', include('apps.utilities.urls')),
    path('api/', include('apps.billing.urls')),
    path('api/', include('apps.notifications.urls')),
]
