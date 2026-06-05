import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/routes/app_routes.dart';
import '../domain/entities/fluid_report.dart';
import '../../../core/providers/session_controller.dart';
import '../../wells/domain/usecases/get_wells_usecase.dart';
import '../domain/usecases/delete_report_usecase.dart';
import '../domain/usecases/get_reports_by_well_usecase.dart';
import 'reports_view_model.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ReportsViewModel>(
      create: (context) => ReportsViewModel(
        getReportsByWellUseCase: context.read<GetReportsByWellUseCase>(),
        deleteReportUseCase: context.read<DeleteReportUseCase>(),
        getWellsUseCase: context.read<GetWellsUseCase>(),
      )..init(),
      child: const _ReportsView(),
    );
  }
}

class _ReportsView extends StatelessWidget {
  const _ReportsView();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ReportsViewModel>();
    final canManage = context.watch<SessionController>().canManageReports;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: vm.refreshReports,
        child: CustomScrollView(
          slivers: [
            const SliverAppBar(
              pinned: true,
              title: Text('Reportes de fluidos'),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (vm.isLoadingWells)
                      const Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else
                      DropdownButtonFormField<String>(
                        initialValue: vm.selectedWellId,
                        items: vm.wells
                            .map(
                              (well) => DropdownMenuItem<String>(
                                value: well.id,
                                child: Text(well.name),
                              ),
                            )
                            .toList(growable: false),
                        onChanged: (value) {
                          if (value != null) {
                            context.read<ReportsViewModel>().selectWell(value);
                          }
                        },
                        decoration: const InputDecoration(
                          labelText: 'Selecciona un pozo',
                          prefixIcon: Icon(Icons.water_outlined),
                        ),
                      ),
                    const SizedBox(height: 16),
                    if (vm.isLoadingReports)
                      const Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (vm.errorMessage != null)
                      _StateMessage(
                        icon: Icons.error_outline,
                        title: 'Error',
                        subtitle: vm.errorMessage!,
                      )
                    else if (vm.selectedWellId == null)
                      const _StateMessage(
                        icon: Icons.water_outlined,
                        title: 'Sin pozos',
                        subtitle: 'No hay pozos activos para mostrar reportes.',
                      )
                    else if (vm.reports.isEmpty)
                      const _StateMessage(
                        icon: Icons.description_outlined,
                        title: 'Sin reportes',
                        subtitle:
                            'Registra el primer reporte diario para este pozo.',
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: vm.reports.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final report = vm.reports[index];
                          return _ReportCard(
                            report: report,
                            canManage: canManage,
                            onTap: () async {
                              final changed = await Navigator.of(context)
                                  .pushNamed(
                                    AppRoutes.reportDetail,
                                    arguments: report.id,
                                  );
                              if (changed != null && context.mounted) {
                                await context
                                    .read<ReportsViewModel>()
                                    .refreshReports();
                              }
                            },
                            onEdit: canManage
                                ? () async {
                                    final saved = await Navigator.of(context)
                                        .pushNamed(
                                          AppRoutes.reportForm,
                                          arguments: ReportFormArguments(
                                            pozoId: report.pozoId,
                                            reportId: report.id,
                                          ),
                                        );
                                    if (saved != null && context.mounted) {
                                      await context
                                          .read<ReportsViewModel>()
                                          .refreshReports();
                                    }
                                  }
                                : null,
                            onDelete: canManage
                                ? () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text('¿Eliminar reporte?'),
                                        content: const Text(
                                          'Esta acción no se puede deshacer.',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(ctx, false),
                                            child: const Text('Cancelar'),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(ctx, true),
                                            child: const Text('Eliminar'),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirm == true && context.mounted) {
                                      try {
                                        await context
                                            .read<ReportsViewModel>()
                                            .deleteReport(report.id);
                                      } catch (_) {
                                        if (context.mounted) {
                                          final message = context
                                              .read<ReportsViewModel>()
                                              .errorMessage;
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                message ??
                                                    'No fue posible eliminar el reporte.',
                                              ),
                                            ),
                                          );
                                        }
                                        return;
                                      }
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text('Reporte eliminado.'),
                                          ),
                                        );
                                      }
                                    }
                                  }
                                : null,
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: canManage && vm.selectedWellId != null
          ? FloatingActionButton.extended(
              onPressed: () async {
                final saved = await Navigator.of(context).pushNamed(
                  AppRoutes.reportForm,
                  arguments: ReportFormArguments(pozoId: vm.selectedWellId!),
                );
                if (saved != null && context.mounted) {
                  await context.read<ReportsViewModel>().refreshReports();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Reporte guardado.')),
                    );
                  }
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Nuevo reporte'),
            )
          : null,
    );
  }
}

// ── Widgets auxiliares (sin cambios) ──────────────────────────────────────────

class _ReportCard extends StatelessWidget {
  const _ReportCard({
    required this.report,
    required this.canManage,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final FluidReport report;
  final bool canManage;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final isDeleting = context.select<ReportsViewModel, bool>(
      (vm) => vm.isDeleting,
    );

    return Card(
      child: InkWell(
        onTap: isDeleting ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      report.wellName ?? 'Pozo ${report.pozoId}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  Text(
                    report.formattedDate,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _MetricChip(
                    label: 'Mud',
                    value: report.mudDensity.toStringAsFixed(2),
                  ),
                  _MetricChip(label: 'Visc', value: '${report.viscosity} s'),
                  _MetricChip(
                    label: 'Presión',
                    value: '${report.pressure.toStringAsFixed(1)} psi',
                  ),
                  _MetricChip(label: 'pH', value: report.ph.toStringAsFixed(1)),
                ],
              ),
              if (report.notes.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  report.notes,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (canManage) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (onEdit != null)
                      TextButton.icon(
                        onPressed: isDeleting ? null : onEdit,
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('Editar'),
                      ),
                    if (onDelete != null)
                      TextButton.icon(
                        onPressed: isDeleting ? null : onDelete,
                        icon: isDeleting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.delete_outline),
                        label: const Text('Eliminar'),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Chip(label: Text('$label: $value'));
  }
}

class _StateMessage extends StatelessWidget {
  const _StateMessage({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(icon, size: 56),
          const SizedBox(height: 12),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(subtitle, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
