import '../../../core/models/auth_session.dart';
import '../../../core/network/api_client.dart';

class AuthRepository {
  AuthRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.postJson(
      '/api/auth/login',
      body: <String, dynamic>{
        'email': email,
        'password': password,
      },
    );

    return AuthSession.fromJson(_asMap(response));
  }

  Future<AuthSession> register({
    required String fullName,
    required String email,
    required String password,
    required String roleName,
  }) async {
    final response = await _apiClient.postJson(
      '/api/auth/register',
      body: <String, dynamic>{
        'full_name': fullName,
        'email': email,
        'password': password,
        'role_name': roleName,
      },
    );

    return AuthSession.fromJson(_asMap(response));
  }

  Map<String, dynamic> _asMap(dynamic response) {
    if (response is Map<String, dynamic>) {
      return response;
    }

    throw StateError('La respuesta de autenticación no tiene el formato esperado.');
  }
}