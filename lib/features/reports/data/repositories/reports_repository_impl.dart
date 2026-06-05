import '../../domain/entities/fluid_report.dart';
import '../../domain/repositories/reports_repository.dart';
import '../datasources/reports_remote_datasource.dart';
import '../dto/fluid_report_dto.dart';

class ReportsRepositoryImpl implements ReportsRepository {
  ReportsRepositoryImpl(this._remoteDataSource);

  final ReportsRemoteDataSource _remoteDataSource;

  @override
  Future<List<FluidReport>> fetchByWell(String pozoId) async {
    final rows = await _remoteDataSource.fetchByWell(pozoId);
    return rows
        .map((json) => FluidReportDto(json).toEntity())
        .toList(growable: false);
  }

  @override
  Future<FluidReport> fetchById(int id) async {
    final json = await _remoteDataSource.fetchById(id);
    return FluidReportDto(json).toEntity();
  }

  @override
  Future<FluidReport> createReport(FluidReport report) async {
    final json = await _remoteDataSource.createReport(
      FluidReportDto.fromEntity(report),
    );
    return FluidReportDto(json).toEntity();
  }

  @override
  Future<FluidReport> updateReport({
    required int id,
    required FluidReport report,
  }) async {
    final json = await _remoteDataSource.updateReport(
      id: id,
      body: FluidReportDto.fromEntity(report),
    );
    return FluidReportDto(json).toEntity();
  }

  @override
  Future<void> deleteReport(int id) => _remoteDataSource.deleteReport(id);
}
