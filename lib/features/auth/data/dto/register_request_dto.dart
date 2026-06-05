class RegisterRequestDto {
  const RegisterRequestDto({
    required this.fullName,
    required this.email,
    required this.password,
    required this.roleName,
  });

  final String fullName;
  final String email;
  final String password;
  final String roleName;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'email': email,
    'password': password,
    'data': <String, dynamic>{'full_name': fullName, 'role': roleName},
  };
}
