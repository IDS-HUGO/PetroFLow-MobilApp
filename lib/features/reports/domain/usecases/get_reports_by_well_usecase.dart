import '../entities/fluid_report.dart';
import '../repositories/reports_repository.dart';

class GetReportsByWellUseCase {
  const GetReportsByWellUseCase(this._repository);

  final ReportsRepository _repository;

  Future<List<FluidReport>> call(String pozoId) =>
      _repository.fetchByWell(pozoId);
}
