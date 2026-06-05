import '../../../../core/network/api_client.dart';
import '../dto/login_request_dto.dart';
import '../dto/register_request_dto.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<Map<String, dynamic>> login(LoginRequestDto request) async {
    final response = await _apiClient.postJson(
      '/auth/v1/token?grant_type=password',
      body: request.toJson(),
    );
    return _asMap(response);
  }

  Future<Map<String, dynamic>> register(RegisterRequestDto request) async {
    final response = await _apiClient.postJson(
      '/auth/v1/signup',
      body: request.toJson(),
    );
    return _asMap(response);
  }

  Future<Map<String, dynamic>?> fetchProfile({
    required String userId,
    required String token,
  }) async {
    final response = await _apiClient.getJson(
      '/rest/v1/profiles?id=eq.$userId&select=*',
      headers: <String, String>{'Authorization': 'Bearer $token'},
    );

    final profiles = _toList(response);
    return profiles.isEmpty ? null : profiles.first;
  }

  Map<String, dynamic> _asMap(dynamic response) {
    if (response is Map<String, dynamic>) {
      return response;
    }

    throw StateError(
      'La respuesta de autenticación no tiene el formato esperado.',
    );
  }

  List<Map<String, dynamic>> _toList(dynamic response) {
    if (response is List) {
      return response.cast<Map<String, dynamic>>();
    }

    return <Map<String, dynamic>>[];
  }
}
