class FluidReport {
  const FluidReport({
    required this.id,
    required this.pozoId,
    required this.ingenieroId,
    required this.date,
    required this.mudDensity,
    required this.viscosity,
    required this.pressure,
    required this.ph,
    required this.notes,
    required this.createdAt,
    this.wellName,
    this.engineerName,
  });

  final int id;
  final String pozoId;
  final String ingenieroId;
  final DateTime date;
  final double mudDensity;
  final int viscosity;
  final double pressure;
  final double ph;
  final String notes;
  final DateTime? createdAt;
  final String? wellName;
  final String? engineerName;

  String get formattedDate => date.toIso8601String().split('T').first;

  factory FluidReport.fromJson(Map<String, dynamic> json) {
    final pozoJson = json['pozo'] as Map<String, dynamic>?;
    final engineerJson = json['ingeniero'] as Map<String, dynamic>?;

    return FluidReport(
      id: int.tryParse(json['id'].toString()) ?? 0,
      pozoId: (json['pozo_id'] ?? json['pozoId'] ?? '').toString(),
      ingenieroId: (json['ingeniero_id'] ?? json['ingenieroId'] ?? '')
          .toString(),
      date:
          DateTime.tryParse((json['date'] ?? '').toString()) ?? DateTime.now(),
      mudDensity:
          double.tryParse(
            (json['mud_density'] ?? json['mudDensity'] ?? 0).toString(),
          ) ??
          0,
      viscosity: int.tryParse((json['viscosity'] ?? 0).toString()) ?? 0,
      pressure: double.tryParse((json['pressure'] ?? 0).toString()) ?? 0,
      ph: double.tryParse((json['ph'] ?? 0).toString()) ?? 0,
      notes: (json['notes'] ?? '').toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      wellName: pozoJson?['name']?.toString() ?? json['well_name']?.toString(),
      engineerName:
          engineerJson?['full_name']?.toString() ??
          json['engineer_name']?.toString(),
    );
  }

  Map<String, dynamic> toPayload() {
    return <String, dynamic>{
      'pozo_id': pozoId,
      'ingeniero_id': ingenieroId,
      'date': formattedDate,
      'mud_density': mudDensity,
      'viscosity': viscosity,
      'pressure': pressure,
      'ph': ph,
      'notes': notes,
    };
  }
}
