import '../entities/fluid_report.dart';
import '../repositories/reports_repository.dart';

class UpdateReportUseCase {
  const UpdateReportUseCase(this._repository);

  final ReportsRepository _repository;

  Future<FluidReport> call({required int id, required FluidReport report}) {
    return _repository.updateReport(id: id, report: report);
  }
}
