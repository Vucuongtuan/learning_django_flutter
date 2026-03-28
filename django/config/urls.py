from django.contrib import admin
from django.urls import path, include
from rest_framework_simplejwt.views import (
    TokenObtainPairView,
    TokenRefreshView,
)
from .views import RegisterView, ActivateUserView

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/register/', RegisterView.as_view(), name='register'),
    path('api/activate/<uidb64>/<token>/', ActivateUserView.as_view(), name='activate'),
    path('api/token/', TokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('api/token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('api/', include('apps.rooms.urls')),
    path('api/', include('apps.tenants.urls')),
    path('api/', include('apps.leases.urls')),
    path('api/', include('apps.bookings.urls')),
    path('api/', include('apps.utilities.urls')),
    path('api/', include('apps.billing.urls')),
    path('api/', include('apps.notifications.urls')),
]
