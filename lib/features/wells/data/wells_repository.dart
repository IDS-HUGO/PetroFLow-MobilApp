import '../../../core/network/api_client.dart';
import '../domain/entities/campo.dart';
import '../domain/entities/well.dart';
import '../domain/repositories/wells_repository.dart';

class SupabaseWellsRepository implements WellsRepository {
  SupabaseWellsRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<Campo>> fetchCampos() async {
    final response = await _apiClient.getJson(
      '/rest/v1/campos?select=*&order=name.asc',
    );
    final list = _toList(response);
    if (list.isNotEmpty) {
      return list.map(Campo.fromJson).toList(growable: false);
    }

    final created = await _apiClient.postJson(
      '/rest/v1/campos?select=*',
      headers: const <String, String>{'Prefer': 'return=representation'},
      body: const <String, dynamic>{
        'name': 'Campo principal',
        'region': 'Norte',
      },
    );

    return <Campo>[Campo.fromJson(_firstMap(created))];
  }

  @override
  Future<List<Well>> fetchActiveWells() async {
    final response = await _apiClient.getJson(
      '/rest/v1/pozos?select=*,campo:campos(name,region)&order=created_at.desc',
    );
    final list = _toList(response);
    return list.map(Well.fromJson).toList(growable: false);
  }

  @override
  Future<Well> createWell({
    required String name,
    required String campoId,
    required WellStatus status,
    required double depthTargetFt,
  }) async {
    final response = await _apiClient.postJson(
      '/rest/v1/pozos?select=*,campo:campos(name,region)',
      headers: const <String, String>{'Prefer': 'return=representation'},
      body: <String, dynamic>{
        'name': name,
        'campo_id': campoId,
        'status': status.apiValue,
        'depth_target_ft': depthTargetFt,
      },
    );

    return Well.fromJson(_firstMap(response));
  }

  @override
  Future<Well> updateWell({
    required String id,
    required String name,
    required String campoId,
    required WellStatus status,
    required double depthTargetFt,
  }) async {
    final response = await _apiClient.patchJson(
      '/rest/v1/pozos?id=eq.$id&select=*,campo:campos(name,region)',
      headers: const <String, String>{'Prefer': 'return=representation'},
      body: <String, dynamic>{
        'name': name,
        'campo_id': campoId,
        'status': status.apiValue,
        'depth_target_ft': depthTargetFt,
      },
    );

    return Well.fromJson(_firstMap(response));
  }

  @override
  Future<void> deleteWell(String id) async {
    await _apiClient.deleteJson('/rest/v1/pozos?id=eq.$id');
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

  Map<String, dynamic> _firstMap(dynamic response) {
    if (response is List && response.isNotEmpty) {
      return response.first as Map<String, dynamic>;
    }

    if (response is Map<String, dynamic>) {
      return response;
    }

    throw StateError('La respuesta de pozos no tiene el formato esperado.');
  }
}
