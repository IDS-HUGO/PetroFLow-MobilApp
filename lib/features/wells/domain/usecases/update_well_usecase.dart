import '../entities/well.dart';
import '../repositories/wells_repository.dart';

class UpdateWellUseCase {
  const UpdateWellUseCase(this._repository);

  final WellsRepository _repository;

  Future<Well> call({
    required String id,
    required String name,
    required String campoId,
    required WellStatus status,
    required double depthTargetFt,
  }) {
    return _repository.updateWell(
      id: id,
      name: name,
      campoId: campoId,
      status: status,
      depthTargetFt: depthTargetFt,
    );
  }
}
