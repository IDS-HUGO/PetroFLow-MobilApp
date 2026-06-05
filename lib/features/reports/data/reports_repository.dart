import '../domain/entities/fluid_report.dart';
import '../domain/repositories/reports_repository.dart';
import '../../../core/network/api_client.dart';

class SupabaseReportsRepository implements ReportsRepository {
  SupabaseReportsRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<FluidReport>> fetchByWell(String pozoId) async {
    final response = await _apiClient.getJson(
      '/rest/v1/fluid_reports?pozo_id=eq.$pozoId&select=*,pozo:pozos(name),ingeniero:profiles(full_name)&order=date.desc',
    );
    final list = _toList(response);
    return list.map(FluidReport.fromJson).toList(growable: false);
  }

  @override
  Future<FluidReport> fetchById(int id) async {
    final response = await _apiClient.getJson(
      '/rest/v1/fluid_reports?id=eq.$id&select=*,pozo:pozos(name),ingeniero:profiles(full_name)',
    );
    return FluidReport.fromJson(_firstMap(response));
  }

  @override
  Future<FluidReport> createReport(FluidReport report) async {
    final response = await _apiClient.postJson(
      '/rest/v1/fluid_reports',
      headers: const <String, String>{'Prefer': 'return=representation'},
      body: report.toPayload(),
    );
    return FluidReport.fromJson(_firstMap(response));
  }

  @override
  Future<FluidReport> updateReport({
    required int id,
    required FluidReport report,
  }) async {
    final response = await _apiClient.patchJson(
      '/rest/v1/fluid_reports?id=eq.$id',
      headers: const <String, String>{'Prefer': 'return=representation'},
      body: report.toPayload(),
    );
    return FluidReport.fromJson(_firstMap(response));
  }

  @override
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
