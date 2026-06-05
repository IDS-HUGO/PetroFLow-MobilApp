import '../entities/well.dart';
import '../repositories/wells_repository.dart';

class CreateWellUseCase {
  const CreateWellUseCase(this._repository);

  final WellsRepository _repository;

  Future<Well> call({
    required String name,
    required String campoId,
    required WellStatus status,
    required double depthTargetFt,
  }) {
    return _repository.createWell(
      name: name,
      campoId: campoId,
      status: status,
      depthTargetFt: depthTargetFt,
    );
  }
}
