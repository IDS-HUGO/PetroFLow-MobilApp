import '../entities/campo.dart';
import '../entities/well.dart';

abstract class WellsRepository {
  Future<List<Campo>> fetchCampos();

  Future<List<Well>> fetchActiveWells();

  Future<Well> createWell({
    required String name,
    required String campoId,
    required WellStatus status,
    required double depthTargetFt,
  });

  Future<Well> updateWell({
    required String id,
    required String name,
    required String campoId,
    required WellStatus status,
    required double depthTargetFt,
  });

  Future<void> deleteWell(String id);
}
