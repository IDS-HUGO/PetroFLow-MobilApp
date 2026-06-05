import '../domain/entities/app_user.dart';
import '../domain/entities/auth_session.dart';
import '../domain/repositories/auth_repository.dart';
import '../../../core/network/api_client.dart';

class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.postJson(
      '/auth/v1/token?grant_type=password',
      body: <String, dynamic>{'email': email, 'password': password},
    );

    return _buildSession(_asMap(response), fallbackEmail: email);
  }

  @override
  Future<AuthSession> register({
    required String fullName,
    required String email,
    required String password,
    required String roleName,
  }) async {
    final response = await _apiClient.postJson(
      '/auth/v1/signup',
      body: <String, dynamic>{
        'email': email,
        'password': password,
        'data': <String, dynamic>{'full_name': fullName, 'role': roleName},
      },
    );

    return _buildSession(
      _asMap(response),
      fallbackEmail: email,
      fallbackFullName: fullName,
      fallbackRole: UserRole.fromApiValue(roleName),
    );
  }

  Future<AuthSession> _buildSession(
    Map<String, dynamic> authJson, {
    required String fallbackEmail,
    String fallbackFullName = '',
    UserRole fallbackRole = UserRole.fieldEngineer,
  }) async {
    final token = (authJson['access_token'] ?? '').toString();
    if (token.isEmpty) {
      throw StateError('Tu cuenta fue creada. Inicia sesión para continuar.');
    }

    final rawUser = authJson['user'] as Map<String, dynamic>?;
    final userId = (rawUser?['id'] ?? '').toString();
    final profile = userId.isEmpty ? null : await _fetchProfile(userId, token);
    final metadata = rawUser?['user_metadata'] as Map<String, dynamic>?;

    final appUser = AppUser.fromJson(<String, dynamic>{
      'id': userId,
      'email': rawUser?['email'] ?? fallbackEmail,
      'full_name':
          profile?['full_name'] ?? metadata?['full_name'] ?? fallbackFullName,
      'role': profile?['role'] ?? metadata?['role'] ?? fallbackRole.apiValue,
      'is_active': profile?['is_active'] ?? true,
      'created_at': profile?['created_at'] ?? rawUser?['created_at'],
    });

    return AuthSession(token: token, user: appUser);
  }

  Future<Map<String, dynamic>?> _fetchProfile(
    String userId,
    String token,
  ) async {
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
