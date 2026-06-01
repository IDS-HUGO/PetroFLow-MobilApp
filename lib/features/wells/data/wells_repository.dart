import '../../../core/models/well.dart';
import '../../../core/network/api_client.dart';

class WellsRepository {
  WellsRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<Well>> fetchActiveWells() async {
    final response = await _apiClient.getJson('/api/wells');
    final list = _toList(response);
    return list.map(Well.fromJson).toList(growable: false);
  }

  Future<Well> createWell({
    required String name,
    required String campoId,
    required WellStatus status,
    required double depthTargetFt,
  }) async {
    final response = await _apiClient.postJson(
      '/api/wells',
      body: <String, dynamic>{
        'name': name,
        'campo_id': campoId,
        'status': status.apiValue,
        'depth_target_ft': depthTargetFt,
      },
    );

    return Well.fromJson(_asMap(response));
  }

  List<Map<String, dynamic>> _toList(dynamic response) {
    if (response is List) {
      return response.cast<Map<String, dynamic>>();
    }

    if (response is Map<String, dynamic> && response['data'] is List) {
      return (response['data'] as List).cast<Map<String, dynamic>>();
    }

    return <Map<String, dynamic>>[];
  }

  Map<String, dynamic> _asMap(dynamic response) {
    if (response is Map<String, dynamic>) {
      return response;
    }

    throw StateError('La respuesta de pozos no tiene el formato esperado.');
  }
}