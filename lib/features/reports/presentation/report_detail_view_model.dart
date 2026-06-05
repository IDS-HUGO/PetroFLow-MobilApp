// ignore_for_file: prefer_initializing_formals

import 'package:flutter/foundation.dart';
import '../../../core/network/api_exception.dart';
import '../domain/entities/fluid_report.dart';
import '../domain/usecases/delete_report_usecase.dart';
import '../domain/usecases/get_report_by_id_usecase.dart';

class ReportDetailViewModel extends ChangeNotifier {
  ReportDetailViewModel({
    required GetReportByIdUseCase getReportByIdUseCase,
    required DeleteReportUseCase deleteReportUseCase,
  }) : _getReportByIdUseCase = getReportByIdUseCase,
       _deleteReportUseCase = deleteReportUseCase;

  final GetReportByIdUseCase _getReportByIdUseCase;
  final DeleteReportUseCase _deleteReportUseCase;

  FluidReport? report;
  bool isLoading = false;
  bool isDeleting = false;
  String? errorMessage;

  Future<void> loadReport(int id) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      report = await _getReportByIdUseCase(id);
    } catch (error) {
      errorMessage = _readableError(error);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteReport() async {
    final currentReport = report;
    if (currentReport == null) {
      return;
    }

    isDeleting = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _deleteReportUseCase(currentReport.id);
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
