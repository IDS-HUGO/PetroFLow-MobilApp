import '../../domain/entities/campo.dart';
import '../../domain/entities/well.dart';
import '../../domain/repositories/wells_repository.dart';
import '../datasources/wells_remote_datasource.dart';
import '../dto/campo_dto.dart';
import '../dto/well_dto.dart';

class WellsRepositoryImpl implements WellsRepository {
  WellsRepositoryImpl(this._remoteDataSource);

  final WellsRemoteDataSource _remoteDataSource;

  @override
  Future<List<Campo>> fetchCampos() async {
    final rows = await _remoteDataSource.fetchCampos();
    return rows
        .map((json) => CampoDto(json).toEntity())
        .toList(growable: false);
  }

  @override
  Future<List<Well>> fetchActiveWells() async {
    final rows = await _remoteDataSource.fetchActiveWells();
    return rows.map((json) => WellDto(json).toEntity()).toList(growable: false);
  }

  @override
  Future<Well> createWell({
    required String name,
    required String campoId,
    required WellStatus status,
    required double depthTargetFt,
  }) async {
    final json = await _remoteDataSource.createWell(
      name: name,
      campoId: campoId,
      status: status,
      depthTargetFt: depthTargetFt,
    );
    return WellDto(json).toEntity();
  }

  @override
  Future<Well> updateWell({
    required String id,
    required String name,
    required String campoId,
    required WellStatus status,
    required double depthTargetFt,
  }) async {
    final json = await _remoteDataSource.updateWell(
      id: id,
      name: name,
      campoId: campoId,
      status: status,
      depthTargetFt: depthTargetFt,
    );
    return WellDto(json).toEntity();
  }

  @override
  Future<void> deleteWell(String id) => _remoteDataSource.deleteWell(id);
}
