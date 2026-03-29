import 'package:app_flutter/models/room.dart';
import 'package:app_flutter/services/api_client.dart';

class AiSearchService {
  final ApiClient _api = ApiClient();

  Future<List<Room>> searchRooms(String query, {int limit = 5}) async {
    final data = await _api.post('/ai/search_rooms/', body: {
      'query': query,
      'limit': limit,
    });
    return _api.parseList(data, Room.fromJson);
  }
}
