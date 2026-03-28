from django.contrib.auth.models import User
from django.contrib.auth.tokens import default_token_generator
from django.utils.http import urlsafe_base64_encode, urlsafe_base64_decode
from django.utils.encoding import force_bytes, force_str
from django.core.mail import send_mail
from django.conf import settings
from rest_framework import status, permissions
from rest_framework.response import Response
from rest_framework.views import APIView
from .serializers import RegisterSerializer

class RegisterView(APIView):
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        serializer = RegisterSerializer(data=request.data)
        if serializer.is_valid():
            user = serializer.save()

            uid = urlsafe_base64_encode(force_bytes(user.pk))
            token = default_token_generator.make_token(user)
            
            activation_link = f"http://localhost:8000/api/activate/{uid}/{token}/"
            
            subject = f"Yêu cầu đăng ký tài khoản mới: {user.username}"
            message = (
                f"Thông tin tài khoản mới:\n"
                f"Username: {user.username}\n"
                f"Email: {user.email}\n"
                f"Họ tên: {user.first_name} {user.last_name}\n\n"
                f"Để duyệt tài khoản này, vui lòng nhấn vào link bên dưới:\n"
                f"{activation_link}"
            )
            
            send_mail(
                subject,
                message,
                settings.DEFAULT_FROM_EMAIL,
                [settings.ADMIN_EMAIL],
                fail_silently=False,
            )

            return Response({
                "message": "Đăng ký thành công! Vui lòng chờ quản trị viên phê duyệt tài khoản."
            }, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class ActivateUserView(APIView):
    permission_classes = [permissions.AllowAny]

    def get(self, request, uidb64, token):
        try:
            uid = force_str(urlsafe_base64_decode(uidb64))
            user = User.objects.get(pk=uid)
        except (TypeError, ValueError, OverflowError, User.DoesNotExist):
            user = None

        if user is not None and default_token_generator.check_token(user, token):
            user.is_active = True
            user.save()
            return Response({"message": f"Tài khoản {user.username} đã được kích hoạt thành công!"}, status=status.HTTP_200_OK)
        else:
            return Response({"error": "Link xác thực không hợp lệ hoặc đã hết hạn!"}, status=status.HTTP_400_BAD_REQUEST)
