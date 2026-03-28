import 'package:app_flutter/models/room.dart';
import 'package:app_flutter/services/api_client.dart';

class RoomService {
  final ApiClient _api = ApiClient();

  Future<List<Room>> fetchRooms({String? status}) async {
    final queryParams = <String, String>{};
    if (status != null) queryParams['status'] = status;
    final data = await _api.get('/rooms/', queryParams: queryParams.isNotEmpty ? queryParams : null);
    return _api.parseList(data, Room.fromJson);
  }

  Future<Room> fetchRoom(int id) async {
    final data = await _api.get('/rooms/$id/');
    return Room.fromJson(data as Map<String, dynamic>);
  }
}
