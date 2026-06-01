import 'package:flutter/foundation.dart';

import '../../../core/models/fluid_report.dart';
import '../data/reports_repository.dart';

class ReportsViewModel extends ChangeNotifier {
  ReportsViewModel(this._repository);

  final ReportsRepository _repository;

  List<FluidReport> reports = <FluidReport>[];
  bool isLoading = false;
  String? errorMessage;

  Future<void> loadReportsForWell(String pozoId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      reports = await _repository.fetchByWell(pozoId);
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<FluidReport> loadDetail(int id) {
    return _repository.fetchById(id);
  }

  Future<void> deleteReport(int id, String pozoId) async {
    await _repository.deleteReport(id);
    await loadReportsForWell(pozoId);
  }
}

class ReportFormViewModel extends ChangeNotifier {
  ReportFormViewModel(this._repository);

  final ReportsRepository _repository;

  bool isSubmitting = false;
  String? errorMessage;

  Future<FluidReport> saveReport({
    int? reportId,
    required String pozoId,
    required DateTime date,
    required double mudDensity,
    required int viscosity,
    required double pressure,
    required double ph,
    required String notes,
  }) async {
    isSubmitting = true;
    errorMessage = null;
    notifyListeners();

    final report = FluidReport(
      id: reportId ?? 0,
      pozoId: pozoId,
      ingenieroId: '',
      date: date,
      mudDensity: mudDensity,
      viscosity: viscosity,
      pressure: pressure,
      ph: ph,
      notes: notes,
      createdAt: null,
    );

    try {
      final saved = reportId == null
          ? await _repository.createReport(report)
          : await _repository.updateReport(id: reportId, report: report);

      isSubmitting = false;
      notifyListeners();
      return saved;
    } catch (error) {
      errorMessage = error.toString();
      isSubmitting = false;
      notifyListeners();
      rethrow;
    }
  }
}