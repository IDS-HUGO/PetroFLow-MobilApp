import 'app_user.dart';

class AuthSession {
  const AuthSession({required this.token, required this.user});

  final String token;
  final AppUser user;

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    final userJson = json['app_user'] is Map<String, dynamic>
        ? json['app_user'] as Map<String, dynamic>
        : json['user'] is Map<String, dynamic>
        ? json['user'] as Map<String, dynamic>
        : json['data'] is Map<String, dynamic>
        ? (json['data'] as Map<String, dynamic>)['user']
              as Map<String, dynamic>?
        : null;

    final token = (json['access_token'] ?? json['token'] ?? json['jwt'] ?? '')
        .toString();
    final user = AppUser.fromJson(userJson ?? json);

    return AuthSession(token: token, user: user);
  }
}
