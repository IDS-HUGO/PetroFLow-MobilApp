import '../../domain/entities/fluid_report.dart';

class FluidReportDto {
  const FluidReportDto(this.json);

  final Map<String, dynamic> json;

  FluidReport toEntity() => FluidReport.fromJson(json);

  static Map<String, dynamic> fromEntity(FluidReport report) {
    return report.toPayload();
  }
}
