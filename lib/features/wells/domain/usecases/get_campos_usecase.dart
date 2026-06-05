import '../entities/campo.dart';
import '../repositories/wells_repository.dart';

class GetCamposUseCase {
  const GetCamposUseCase(this._repository);

  final WellsRepository _repository;

  Future<List<Campo>> call() => _repository.fetchCampos();
}
