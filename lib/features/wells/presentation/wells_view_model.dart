import 'package:flutter/foundation.dart';

import '../../../core/models/well.dart';
import '../data/wells_repository.dart';

class WellsViewModel extends ChangeNotifier {
  WellsViewModel(this._repository);

  final WellsRepository _repository;

  List<Well> wells = <Well>[];
  bool isLoading = false;
  String? errorMessage;

  Future<void> loadWells() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      wells = await _repository.fetchActiveWells();
    } catch (error) {
      errorMessage = error.toString();
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
    await _repository.createWell(
      name: name,
      campoId: campoId,
      status: status,
      depthTargetFt: depthTargetFt,
    );
    await loadWells();
  }
}