import '../../domain/entities/app_user.dart';

class UserDto {
  const UserDto({required this.json});

  final Map<String, dynamic> json;

  AppUser toEntity() => AppUser.fromJson(json);
}
