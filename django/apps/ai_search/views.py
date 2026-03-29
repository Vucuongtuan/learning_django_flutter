from rest_framework import viewsets, status, permissions
from rest_framework.decorators import action
from rest_framework.response import Response
from pgvector.django import L2Distance
from .models import RoomEmbedding
from .utils import get_embedding
from apps.rooms.serializers import RoomSerializer

class AiSearchViewSet(viewsets.ViewSet):
    """ViewSet xử lý tìm kiếm thông minh bằng AI."""
    permission_classes = [permissions.AllowAny]

    @action(detail=False, methods=['post'])
    def search_rooms(self, request):
        query = request.data.get('query')
        if not query:
            return Response({"error": "Vui lòng nhập nội dung tìm kiếm"}, status=status.HTTP_400_BAD_REQUEST)

        # 1. Biến câu hỏi của khách thành Vector
        query_vector = get_embedding(query)
        if not query_vector:
            return Response({"error": "Không thể xử lý yêu cầu AI lúc này"}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

        # 2. Tìm kiếm trong database các phòng có vector "gần" nhất
        # Chúng ta lấy Top 5 kết quả phù hợp nhất
        limit = request.data.get('limit', 5)
        
        # Sắp xếp theo khoảng cách L2 (càng nhỏ càng giống)
        results = RoomEmbedding.objects.order_by(
            L2Distance('embedding', query_vector)
        )[:limit]

        # 3. Lấy dữ liệu phòng tương ứng
        rooms = [item.room for item in results]
        serializer = RoomSerializer(rooms, many=True)
        
        return Response({
            "query": query,
            "results_count": len(rooms),
            "rooms": serializer.data
        })
