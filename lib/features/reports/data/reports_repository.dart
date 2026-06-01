import '../../../core/models/fluid_report.dart';
import '../../../core/network/api_client.dart';

class ReportsRepository {
  ReportsRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<FluidReport>> fetchByWell(String pozoId) async {
    final response = await _apiClient.getJson('/api/reports/well/$pozoId');
    final list = _toList(response);
    return list.map(FluidReport.fromJson).toList(growable: false);
  }

  Future<FluidReport> fetchById(int id) async {
    final response = await _apiClient.getJson('/api/reports/$id');
    return FluidReport.fromJson(_asMap(response));
  }

  Future<FluidReport> createReport(FluidReport report) async {
    final response = await _apiClient.postJson('/api/reports', body: report.toPayload());
    return FluidReport.fromJson(_asMap(response));
  }

  Future<FluidReport> updateReport({
    required int id,
    required FluidReport report,
  }) async {
    final response = await _apiClient.putJson('/api/reports/$id', body: report.toPayload());
    return FluidReport.fromJson(_asMap(response));
  }

  Future<void> deleteReport(int id) async {
    await _apiClient.deleteJson('/api/reports/$id');
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

    throw StateError('La respuesta de reportes no tiene el formato esperado.');
  }
}