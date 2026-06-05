enum UserRole {
  admin('ADMIN', 'ADMIN'),
  supervisor('SUPERVISOR', 'SUPERVISOR'),
  fieldEngineer('INGENIERO_CAMPO', 'INGENIERO DE CAMPO');

  const UserRole(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static UserRole fromApiValue(String? value) {
    return UserRole.values.firstWhere(
      (role) => role.apiValue == value,
      orElse: () => UserRole.fieldEngineer,
    );
  }
}

class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    required this.isActive,
    required this.createdAt,
  });

  final String id;
  final String email;
  final String fullName;
  final UserRole role;
  final bool isActive;
  final DateTime? createdAt;

  bool get canManageWells => true;
  bool get canManageReports =>
      role == UserRole.admin ||
      role == UserRole.fieldEngineer ||
      role == UserRole.supervisor;

  factory AppUser.fromJson(Map<String, dynamic> json) {
    final roleValue = json['role'] is Map<String, dynamic>
        ? json['role']['name']?.toString()
        : json['role']?.toString();

    return AppUser(
      id: (json['id'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      fullName: (json['full_name'] ?? json['fullName'] ?? '').toString(),
      role: UserRole.fromApiValue(roleValue),
      isActive: json['is_active'] != false && json['isActive'] != false,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }
}
