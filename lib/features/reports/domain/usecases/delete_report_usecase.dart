import '../repositories/reports_repository.dart';

class DeleteReportUseCase {
  const DeleteReportUseCase(this._repository);

  final ReportsRepository _repository;

  Future<void> call(int id) => _repository.deleteReport(id);
}
