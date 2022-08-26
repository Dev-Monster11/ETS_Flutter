import 'package:get/get.dart';

import '../shot_model.dart';

class ShotProvider extends GetConnect {
  @override
  void onInit() {
    httpClient.defaultDecoder = (map) {
      if (map is Map<String, dynamic>) return Shot.fromJson(map);
      if (map is List) return map.map((item) => Shot.fromJson(item)).toList();
    };
    httpClient.baseUrl = 'YOUR-API-URL';
  }

  Future<Shot?> getShot(int id) async {
    final response = await get('shot/$id');
    return response.body;
  }

  Future<Response<Shot>> postShot(Shot shot) async => await post('shot', shot);
  Future<Response> deleteShot(int id) async => await delete('shot/$id');
}
