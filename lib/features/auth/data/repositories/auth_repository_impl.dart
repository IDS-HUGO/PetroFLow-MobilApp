import '../../domain/entities/app_user.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../dto/auth_session_dto.dart';
import '../dto/login_request_dto.dart';
import '../dto/register_request_dto.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remoteDataSource);

  final AuthRemoteDataSource _remoteDataSource;

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final authJson = await _remoteDataSource.login(
      LoginRequestDto(email: email, password: password),
    );
    return _buildSession(authJson, fallbackEmail: email);
  }

  @override
  Future<AuthSession> register({
    required String fullName,
    required String email,
    required String password,
    required String roleName,
  }) async {
    final authJson = await _remoteDataSource.register(
      RegisterRequestDto(
        fullName: fullName,
        email: email,
        password: password,
        roleName: roleName,
      ),
    );
    return _buildSession(
      authJson,
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
    final baseDto = AuthSessionDto(
      authJson: authJson,
      fallbackEmail: fallbackEmail,
      fallbackFullName: fallbackFullName,
      fallbackRole: fallbackRole,
    );

    final profile = baseDto.userId.isEmpty
        ? null
        : await _remoteDataSource.fetchProfile(
            userId: baseDto.userId,
            token: baseDto.accessToken,
          );

    return AuthSessionDto(
      authJson: authJson,
      profileJson: profile,
      fallbackEmail: fallbackEmail,
      fallbackFullName: fallbackFullName,
      fallbackRole: fallbackRole,
    ).toEntity();
  }
}
