import 'package:flutter/foundation.dart';
import '../../../core/models/fluid_report.dart';
import '../data/reports_repository.dart';

class ReportDetailViewModel extends ChangeNotifier {
  ReportDetailViewModel(this._repository);

  final ReportsRepository _repository;

  FluidReport? report;
  bool isLoading = false;
  String? errorMessage;

  Future<void> loadReport(int id) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      report = await _repository.fetchById(id);
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}