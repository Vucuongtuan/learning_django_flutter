from rest_framework import viewsets, status, permissions
from rest_framework.decorators import action
from rest_framework.response import Response
from pgvector.django import L2Distance
from .models import RoomEmbedding
from .utils import get_embedding, process_ai_command
from apps.rooms.serializers import RoomSerializer

class AiSearchViewSet(viewsets.ViewSet):
    """ViewSet xử lý tìm kiếm thông minh bằng AI (Vector Search)."""
    permission_classes = [permissions.AllowAny]

    @action(detail=False, methods=['post'])
    def search_rooms(self, request):
        query = request.data.get('query')
        if not query:
            return Response({"error": "Vui lòng nhập nội dung tìm kiếm"}, status=status.HTTP_400_BAD_REQUEST)

        query_vector = get_embedding(query)
        if not query_vector:
            return Response({"error": "Không thể xử lý yêu cầu AI lúc này"}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

        limit = request.data.get('limit', 5)
        results = RoomEmbedding.objects.order_by(
            L2Distance('embedding', query_vector)
        )[:limit]

        rooms = [item.room for item in results]
        serializer = RoomSerializer(rooms, many=True)
        
        return Response({
            "query": query,
            "results_count": len(rooms),
            "rooms": serializer.data
        })

class AiChatViewSet(viewsets.ViewSet):
    """ViewSet xử lý Chat thông minh với AI (Agentic Chat)."""
    permission_classes = [permissions.IsAdminUser]

    @action(detail=False, methods=['post'])
    def command(self, request):
        user_message = request.data.get('message')
        if not user_message:
            return Response({"error": "Vui lòng nhập lệnh"}, status=status.HTTP_400_BAD_REQUEST)

        response_text = process_ai_command(user_message)
        return Response({"response": response_text})
