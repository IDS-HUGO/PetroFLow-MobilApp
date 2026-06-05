// ignore_for_file: prefer_initializing_formals

import 'package:flutter/foundation.dart';

import '../../../core/network/api_exception.dart';
import '../domain/entities/campo.dart';
import '../domain/entities/well.dart';
import '../domain/usecases/create_well_usecase.dart';
import '../domain/usecases/delete_well_usecase.dart';
import '../domain/usecases/get_campos_usecase.dart';
import '../domain/usecases/get_wells_usecase.dart';
import '../domain/usecases/update_well_usecase.dart';

class WellsViewModel extends ChangeNotifier {
  WellsViewModel({
    required GetCamposUseCase getCamposUseCase,
    required GetWellsUseCase getWellsUseCase,
    required CreateWellUseCase createWellUseCase,
    required UpdateWellUseCase updateWellUseCase,
    required DeleteWellUseCase deleteWellUseCase,
  }) : _getCamposUseCase = getCamposUseCase,
       _getWellsUseCase = getWellsUseCase,
       _createWellUseCase = createWellUseCase,
       _updateWellUseCase = updateWellUseCase,
       _deleteWellUseCase = deleteWellUseCase;

  final GetCamposUseCase _getCamposUseCase;
  final GetWellsUseCase _getWellsUseCase;
  final CreateWellUseCase _createWellUseCase;
  final UpdateWellUseCase _updateWellUseCase;
  final DeleteWellUseCase _deleteWellUseCase;

  List<Well> wells = <Well>[];
  List<Campo> campos = <Campo>[];
  bool isLoading = false;
  bool isSaving = false;
  bool isDeleting = false;
  String? errorMessage;

  Future<void> loadInitialData() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _getWellsUseCase(),
        _getCamposUseCase(),
      ]);
      wells = results[0] as List<Well>;
      campos = results[1] as List<Campo>;
    } catch (error) {
      errorMessage = _readableError(error);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadWells() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      wells = await _getWellsUseCase();
    } catch (error) {
      errorMessage = _readableError(error);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createWell({
    required String name,
    required String campoId,
    required WellStatus status,
    required double depthTargetFt,
  }) async {
    final cleanName = name.trim();
    if (cleanName.isEmpty || campoId.isEmpty || depthTargetFt <= 0) {
      throw ArgumentError('Completa nombre, campo y profundidad válida.');
    }

    isSaving = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _createWellUseCase(
        name: cleanName,
        campoId: campoId,
        status: status,
        depthTargetFt: depthTargetFt,
      );
      await loadWells();
    } catch (error) {
      errorMessage = _readableError(error);
      rethrow;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<void> updateWell({
    required String id,
    required String name,
    required String campoId,
    required WellStatus status,
    required double depthTargetFt,
  }) async {
    final cleanName = name.trim();
    if (id.isEmpty ||
        cleanName.isEmpty ||
        campoId.isEmpty ||
        depthTargetFt <= 0) {
      throw ArgumentError('Completa nombre, campo y profundidad válida.');
    }

    isSaving = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _updateWellUseCase(
        id: id,
        name: cleanName,
        campoId: campoId,
        status: status,
        depthTargetFt: depthTargetFt,
      );
      await loadWells();
    } catch (error) {
      errorMessage = _readableError(error);
      rethrow;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<void> deleteWell(String id) async {
    isDeleting = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _deleteWellUseCase(id);
      await loadWells();
    } catch (error) {
      errorMessage = _readableError(error);
      rethrow;
    } finally {
      isDeleting = false;
      notifyListeners();
    }
  }
}

String _readableError(Object error) {
  return getReadableError(error);
}
