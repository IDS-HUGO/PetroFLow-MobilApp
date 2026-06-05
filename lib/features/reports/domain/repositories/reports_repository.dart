import '../entities/fluid_report.dart';

abstract class ReportsRepository {
  Future<List<FluidReport>> fetchByWell(String pozoId);

  Future<FluidReport> fetchById(int id);

  Future<FluidReport> createReport(FluidReport report);

  Future<FluidReport> updateReport({
    required int id,
    required FluidReport report,
  });

  Future<void> deleteReport(int id);
}
