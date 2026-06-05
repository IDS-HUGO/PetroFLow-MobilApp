import '../entities/well.dart';
import '../repositories/wells_repository.dart';

class GetWellsUseCase {
  const GetWellsUseCase(this._repository);

  final WellsRepository _repository;

  Future<List<Well>> call() => _repository.fetchActiveWells();
}
