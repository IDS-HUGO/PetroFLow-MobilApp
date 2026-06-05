import '../entities/fluid_report.dart';
import '../repositories/reports_repository.dart';

class CreateReportUseCase {
  const CreateReportUseCase(this._repository);

  final ReportsRepository _repository;

  Future<FluidReport> call(FluidReport report) {
    return _repository.createReport(report);
  }
}
