import '../../domain/entities/app_user.dart';
import '../../domain/entities/auth_session.dart';

class AuthSessionDto {
  const AuthSessionDto({
    required this.authJson,
    required this.fallbackEmail,
    this.fallbackFullName = '',
    this.fallbackRole = UserRole.fieldEngineer,
    this.profileJson,
  });

  final Map<String, dynamic> authJson;
  final Map<String, dynamic>? profileJson;
  final String fallbackEmail;
  final String fallbackFullName;
  final UserRole fallbackRole;

  String get accessToken => (authJson['access_token'] ?? '').toString();
  String get userId => (rawUser?['id'] ?? '').toString();

  Map<String, dynamic>? get rawUser =>
      authJson['user'] as Map<String, dynamic>?;

  AuthSession toEntity() {
    if (accessToken.isEmpty) {
      throw StateError('Tu cuenta fue creada. Inicia sesión para continuar.');
    }

    final metadata = rawUser?['user_metadata'] as Map<String, dynamic>?;
    final appUser = AppUser.fromJson(<String, dynamic>{
      'id': userId,
      'email': rawUser?['email'] ?? fallbackEmail,
      'full_name':
          profileJson?['full_name'] ??
          metadata?['full_name'] ??
          fallbackFullName,
      'role':
          profileJson?['role'] ?? metadata?['role'] ?? fallbackRole.apiValue,
      'is_active': profileJson?['is_active'] ?? true,
      'created_at': profileJson?['created_at'] ?? rawUser?['created_at'],
    });

    return AuthSession(token: accessToken, user: appUser);
  }
}
