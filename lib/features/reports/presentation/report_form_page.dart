import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/routes/app_routes.dart';
import '../domain/entities/fluid_report.dart';
import '../../../core/providers/session_controller.dart';
import '../domain/usecases/create_report_usecase.dart';
import '../domain/usecases/get_report_by_id_usecase.dart';
import '../domain/usecases/update_report_usecase.dart';
import 'reports_view_model.dart';

class ReportFormPage extends StatefulWidget {
  const ReportFormPage({super.key, required this.arguments});

  final ReportFormArguments arguments;

  @override
  State<ReportFormPage> createState() => _ReportFormPageState();
}

class _ReportFormPageState extends State<ReportFormPage> {
  late final TextEditingController _dateController;
  late final TextEditingController _mudDensityController;
  late final TextEditingController _viscosityController;
  late final TextEditingController _pressureController;
  late final TextEditingController _phController;
  late final TextEditingController _notesController;
  bool _hydratedFromExistingReport = false;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now().toIso8601String().split('T').first;
    _dateController = TextEditingController(text: today);
    _mudDensityController = TextEditingController();
    _viscosityController = TextEditingController();
    _pressureController = TextEditingController();
    _phController = TextEditingController();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _dateController.dispose();
    _mudDensityController.dispose();
    _viscosityController.dispose();
    _pressureController.dispose();
    _phController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ReportFormViewModel>(
      create: (context) => ReportFormViewModel(
        getReportByIdUseCase: context.read<GetReportByIdUseCase>(),
        createReportUseCase: context.read<CreateReportUseCase>(),
        updateReportUseCase: context.read<UpdateReportUseCase>(),
        sessionController: context.read<SessionController>(),
      )..loadInitialReport(widget.arguments.reportId),
      child: Consumer<ReportFormViewModel>(
        builder: (context, vm, _) {
          if (vm.existingReport != null && !_hydratedFromExistingReport) {
            _hydrateControllers(vm.existingReport!);
          }

          return Scaffold(
            appBar: AppBar(
              title: Text(
                widget.arguments.isEditing ? 'Editar reporte' : 'Nuevo reporte',
              ),
            ),
            body: SafeArea(
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverToBoxAdapter(
                      child: vm.isLoadingInitial
                          ? const Padding(
                              padding: EdgeInsets.all(40),
                              child: Center(child: CircularProgressIndicator()),
                            )
                          : Card(
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      'Registro técnico del día',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleLarge,
                                    ),
                                    const SizedBox(height: 16),
                                    TextField(
                                      controller: _dateController,
                                      decoration: const InputDecoration(
                                        labelText: 'Fecha (YYYY-MM-DD)',
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextField(
                                            controller: _mudDensityController,
                                            keyboardType: TextInputType.number,
                                            decoration: const InputDecoration(
                                              labelText: 'Mud density ppg',
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: TextField(
                                            controller: _viscosityController,
                                            keyboardType: TextInputType.number,
                                            decoration: const InputDecoration(
                                              labelText: 'Viscosidad (s)',
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextField(
                                            controller: _pressureController,
                                            keyboardType: TextInputType.number,
                                            decoration: const InputDecoration(
                                              labelText: 'Presión (psi)',
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: TextField(
                                            controller: _phController,
                                            keyboardType: TextInputType.number,
                                            decoration: const InputDecoration(
                                              labelText: 'pH',
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    TextField(
                                      controller: _notesController,
                                      maxLines: 4,
                                      decoration: const InputDecoration(
                                        labelText: 'Observaciones',
                                      ),
                                    ),
                                    if (vm.errorMessage != null) ...[
                                      const SizedBox(height: 12),
                                      Text(
                                        vm.errorMessage!,
                                        style: TextStyle(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.error,
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 20),
                                    FilledButton(
                                      onPressed: vm.isSubmitting
                                          ? null
                                          : () async {
                                              final date = DateTime.tryParse(
                                                _dateController.text.trim(),
                                              );
                                              final mudDensity =
                                                  double.tryParse(
                                                    _mudDensityController.text
                                                        .trim(),
                                                  );
                                              final viscosity = int.tryParse(
                                                _viscosityController.text
                                                    .trim(),
                                              );
                                              final pressure = double.tryParse(
                                                _pressureController.text.trim(),
                                              );
                                              final ph = double.tryParse(
                                                _phController.text.trim(),
                                              );

                                              if (date == null ||
                                                  mudDensity == null ||
                                                  viscosity == null ||
                                                  pressure == null ||
                                                  ph == null) {
                                                vm.setValidationError(
                                                  'Captura fecha y métricas numéricas válidas.',
                                                );
                                                return;
                                              }

                                              try {
                                                final saved = await vm
                                                    .saveReport(
                                                      reportId: widget
                                                          .arguments
                                                          .reportId,
                                                      pozoId: widget
                                                          .arguments
                                                          .pozoId,
                                                      date: date,
                                                      mudDensity: mudDensity,
                                                      viscosity: viscosity,
                                                      pressure: pressure,
                                                      ph: ph,
                                                      notes: _notesController
                                                          .text
                                                          .trim(),
                                                    );

                                                if (context.mounted) {
                                                  Navigator.of(
                                                    context,
                                                  ).pop<FluidReport>(saved);
                                                }
                                              } catch (_) {
                                                // El ViewModel conserva el mensaje para pintarlo en pantalla.
                                              }
                                            },
                                      child: vm.isSubmitting
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : Text(
                                              widget.arguments.isEditing
                                                  ? 'Actualizar'
                                                  : 'Guardar',
                                            ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _hydrateControllers(FluidReport report) {
    _dateController.text = report.formattedDate;
    _mudDensityController.text = report.mudDensity.toString();
    _viscosityController.text = report.viscosity.toString();
    _pressureController.text = report.pressure.toString();
    _phController.text = report.ph.toString();
    _notesController.text = report.notes;
    _hydratedFromExistingReport = true;
  }
}
