// ignore_for_file: prefer_initializing_formals

import 'package:flutter/foundation.dart';

import '../../wells/domain/entities/well.dart';
import '../domain/entities/fluid_report.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/providers/session_controller.dart';
import '../domain/usecases/create_report_usecase.dart';
import '../domain/usecases/delete_report_usecase.dart';
import '../domain/usecases/get_report_by_id_usecase.dart';
import '../domain/usecases/get_reports_by_well_usecase.dart';
import '../domain/usecases/update_report_usecase.dart';
import '../../wells/domain/usecases/get_wells_usecase.dart';

class ReportsViewModel extends ChangeNotifier {
  ReportsViewModel({
    required GetReportsByWellUseCase getReportsByWellUseCase,
    required DeleteReportUseCase deleteReportUseCase,
    required GetWellsUseCase getWellsUseCase,
  }) : _getReportsByWellUseCase = getReportsByWellUseCase,
       _deleteReportUseCase = deleteReportUseCase,
       _getWellsUseCase = getWellsUseCase;

  final GetReportsByWellUseCase _getReportsByWellUseCase;
  final DeleteReportUseCase _deleteReportUseCase;
  final GetWellsUseCase _getWellsUseCase;

  // ── Estado de pozos ──
  List<Well> wells = <Well>[];
  String? selectedWellId;
  bool isLoadingWells = false;

  // ── Estado de reportes ──
  List<FluidReport> reports = <FluidReport>[];
  bool isLoadingReports = false;
  bool isDeleting = false;
  String? errorMessage;

  Future<void> init() async {
    isLoadingWells = true;
    errorMessage = null;
    notifyListeners();

    try {
      wells = await _getWellsUseCase();
      if (wells.isNotEmpty) {
        selectedWellId = wells.first.id;
        await _loadReports(selectedWellId!);
      }
    } catch (error) {
      errorMessage = _readableError(error);
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
    if (selectedWellId == null) {
      await init();
      return;
    }

    await _loadReports(selectedWellId!);
  }

  Future<void> deleteReport(int id) async {
    isDeleting = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _deleteReportUseCase(id);
      if (selectedWellId != null) {
        await _loadReports(selectedWellId!);
      }
    } catch (error) {
      errorMessage = _readableError(error);
      rethrow;
    } finally {
      isDeleting = false;
      notifyListeners();
    }
  }

  Future<void> _loadReports(String pozoId) async {
    isLoadingReports = true;
    errorMessage = null;
    notifyListeners();

    try {
      reports = await _getReportsByWellUseCase(pozoId);
    } on ApiException catch (e) {
      errorMessage = e.message;
    } catch (error) {
      errorMessage = _readableError(error);
    } finally {
      isLoadingReports = false;
      notifyListeners();
    }
  }
}

class ReportFormViewModel extends ChangeNotifier {
  ReportFormViewModel({
    required GetReportByIdUseCase getReportByIdUseCase,
    required CreateReportUseCase createReportUseCase,
    required UpdateReportUseCase updateReportUseCase,
    required this.sessionController,
  }) : _getReportByIdUseCase = getReportByIdUseCase,
       _createReportUseCase = createReportUseCase,
       _updateReportUseCase = updateReportUseCase;

  final GetReportByIdUseCase _getReportByIdUseCase;
  final CreateReportUseCase _createReportUseCase;
  final UpdateReportUseCase _updateReportUseCase;
  final SessionController sessionController;

  FluidReport? existingReport;
  bool isLoadingInitial = false;
  bool isSubmitting = false;
  String? errorMessage;

  void setValidationError(String message) {
    errorMessage = message;
    notifyListeners();
  }

  Future<void> loadInitialReport(int? reportId) async {
    if (reportId == null) {
      return;
    }

    isLoadingInitial = true;
    errorMessage = null;
    notifyListeners();

    try {
      existingReport = await _getReportByIdUseCase(reportId);
    } catch (error) {
      errorMessage = _readableError(error);
    } finally {
      isLoadingInitial = false;
      notifyListeners();
    }
  }

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

    final engineerId =
        existingReport?.ingenieroId ?? sessionController.user?.id;
    if (engineerId == null || engineerId.isEmpty) {
      errorMessage = 'No hay una sesión válida para guardar el reporte.';
      isSubmitting = false;
      notifyListeners();
      throw StateError(errorMessage!);
    }

    final report = FluidReport(
      id: reportId ?? 0,
      pozoId: pozoId,
      ingenieroId: engineerId,
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
          ? await _createReportUseCase(report)
          : await _updateReportUseCase(id: reportId, report: report);

      isSubmitting = false;
      notifyListeners();
      return saved;
    } catch (error) {
      errorMessage = _readableError(error);
      isSubmitting = false;
      notifyListeners();
      rethrow;
    }
  }
}

String _readableError(Object error) {
  return getReadableError(error);
}
