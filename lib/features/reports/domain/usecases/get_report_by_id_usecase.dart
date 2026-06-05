import '../entities/fluid_report.dart';
import '../repositories/reports_repository.dart';

class GetReportByIdUseCase {
  const GetReportByIdUseCase(this._repository);

  final ReportsRepository _repository;

  Future<FluidReport> call(int id) => _repository.fetchById(id);
}
