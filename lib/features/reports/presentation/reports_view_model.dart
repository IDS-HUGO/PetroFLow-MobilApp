import 'package:flutter/foundation.dart';

import '../../../core/models/fluid_report.dart';
import '../../../core/models/well.dart';
import '../../../core/network/api_exception.dart';
import '../data/reports_repository.dart';
import '../../wells/data/wells_repository.dart';

class ReportsViewModel extends ChangeNotifier {
  ReportsViewModel({
    required ReportsRepository reportsRepository,
    required WellsRepository wellsRepository,
  })  : _reportsRepository = reportsRepository,
        _wellsRepository = wellsRepository;

  final ReportsRepository _reportsRepository;
  final WellsRepository _wellsRepository;

  // ── Estado de pozos ──
  List<Well> wells = <Well>[];
  String? selectedWellId;
  bool isLoadingWells = false;

  // ── Estado de reportes ──
  List<FluidReport> reports = <FluidReport>[];
  bool isLoadingReports = false;
  String? errorMessage;

  Future<void> init() async {
    isLoadingWells = true;
    errorMessage = null;
    notifyListeners();

    try {
      wells = await _wellsRepository.fetchActiveWells();
      if (wells.isNotEmpty) {
        selectedWellId = wells.first.id;
        await _loadReports(selectedWellId!);
      }
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isLoadingWells = false;
      notifyListeners();
    }
  }

  Future<void> selectWell(String wellId) async {
    selectedWellId = wellId;
    notifyListeners();
    await _loadReports(wellId);
  }

  Future<void> refreshReports() async {
    if (selectedWellId != null) {
      await _loadReports(selectedWellId!);
    }
  }

  Future<void> deleteReport(int id) async {
    await _reportsRepository.deleteReport(id);
    if (selectedWellId != null) {
      await _loadReports(selectedWellId!);
    }
  }

  Future<void> _loadReports(String pozoId) async {
    isLoadingReports = true;
    errorMessage = null;
    notifyListeners();

    try {
      reports = await _reportsRepository.fetchByWell(pozoId);
    } on ApiException catch (e) {
      errorMessage = e.message;
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isLoadingReports = false;
      notifyListeners();
    }
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