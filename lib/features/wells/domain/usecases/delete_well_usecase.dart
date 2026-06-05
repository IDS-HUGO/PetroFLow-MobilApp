import '../repositories/wells_repository.dart';

class DeleteWellUseCase {
  const DeleteWellUseCase(this._repository);

  final WellsRepository _repository;

  Future<void> call(String id) => _repository.deleteWell(id);
}
