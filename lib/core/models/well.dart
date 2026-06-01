enum WellStatus {
  perforacion('PERFORACION', 'Perforación'),
  produccion('PRODUCCION', 'Producción'),
  cerrado('CERRADO', 'Cerrado'),
  mantenimiento('MANTENIMIENTO', 'Mantenimiento');

  const WellStatus(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static WellStatus fromApiValue(String? value) {
    return WellStatus.values.firstWhere(
      (status) => status.apiValue == value,
      orElse: () => WellStatus.perforacion,
    );
  }
}

class Well {
  const Well({
    required this.id,
    required this.name,
    required this.campoId,
    required this.status,
    required this.depthTargetFt,
    required this.createdAt,
    this.region,
  });

  final String id;
  final String name;
  final String campoId;
  final WellStatus status;
  final double depthTargetFt;
  final String? region;
  final DateTime? createdAt;

  bool get isActive => status != WellStatus.cerrado;

  factory Well.fromJson(Map<String, dynamic> json) {
    return Well(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      campoId: (json['campo_id'] ?? json['campoId'] ?? '').toString(),
      status: WellStatus.fromApiValue((json['status'] ?? '').toString()),
      depthTargetFt: double.tryParse((json['depth_target_ft'] ?? json['depthTargetFt'] ?? 0).toString()) ?? 0,
      region: json['location']?.toString() ?? json['region']?.toString(),
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
    );
  }
}