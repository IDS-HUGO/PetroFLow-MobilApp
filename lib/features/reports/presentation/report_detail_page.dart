import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/reports_repository.dart';
import 'report_detail_view_model.dart';

class ReportDetailPage extends StatelessWidget {
  const ReportDetailPage({super.key, required this.reportId});

  final int reportId;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ReportDetailViewModel>(
      create: (context) => ReportDetailViewModel(context.read<ReportsRepository>())
        ..loadReport(reportId),
      child: const _ReportDetailView(),
    );
  }
}

class _ReportDetailView extends StatelessWidget {
  const _ReportDetailView();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ReportDetailViewModel>();

    if (vm.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (vm.errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalle del reporte')),
        body: Center(child: Text(vm.errorMessage!)),
      );
    }

    final report = vm.report;
    if (report == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del reporte')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    report.wellName ?? 'Pozo ${report.pozoId}',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text('Fecha: ${report.formattedDate}'),
                  const SizedBox(height: 16),
                  _DetailLine(label: 'Mud density', value: '${report.mudDensity.toStringAsFixed(2)} ppg'),
                  _DetailLine(label: 'Viscosidad',  value: '${report.viscosity} s'),
                  _DetailLine(label: 'Presión',     value: '${report.pressure.toStringAsFixed(2)} psi'),
                  _DetailLine(label: 'pH',          value: report.ph.toStringAsFixed(1)),
                  const SizedBox(height: 16),
                  Text('Notas', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(report.notes),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(value, style: Theme.of(context).textTheme.titleSmall),
        ],
      ),
    );
  }
}