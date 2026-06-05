import '../../../../core/network/api_client.dart';

class ReportsRemoteDataSource {
  ReportsRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<List<Map<String, dynamic>>> fetchByWell(String pozoId) async {
    final response = await _apiClient.getJson(
      '/rest/v1/fluid_reports?pozo_id=eq.$pozoId&select=*,pozo:pozos(name),ingeniero:profiles(full_name)&order=date.desc',
    );
    return _toList(response);
  }

  Future<Map<String, dynamic>> fetchById(int id) async {
    final response = await _apiClient.getJson(
      '/rest/v1/fluid_reports?id=eq.$id&select=*,pozo:pozos(name),ingeniero:profiles(full_name)',
    );
    return _firstMap(response);
  }

  Future<Map<String, dynamic>> createReport(Map<String, dynamic> body) async {
    final response = await _apiClient.postJson(
      '/rest/v1/fluid_reports',
      headers: const <String, String>{'Prefer': 'return=representation'},
      body: body,
    );
    return _firstMap(response);
  }

  Future<Map<String, dynamic>> updateReport({
    required int id,
    required Map<String, dynamic> body,
  }) async {
    final response = await _apiClient.patchJson(
      '/rest/v1/fluid_reports?id=eq.$id',
      headers: const <String, String>{'Prefer': 'return=representation'},
      body: body,
    );
    return _firstMap(response);
  }

  Future<void> deleteReport(int id) async {
    await _apiClient.deleteJson('/rest/v1/fluid_reports?id=eq.$id');
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

    throw StateError('La respuesta de reportes no tiene el formato esperado.');
  }
}
