import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app.dart';
import '../../../core/models/fluid_report.dart';
import '../data/reports_repository.dart';
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
      create: (context) => ReportFormViewModel(context.read<ReportsRepository>()),
      child: Consumer<ReportFormViewModel>(
        builder: (context, vm, _) {
          return Scaffold(
            appBar: AppBar(
              title: Text(widget.arguments.isEditing ? 'Editar reporte' : 'Nuevo reporte'),
            ),
            body: SafeArea(
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverToBoxAdapter(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Registro técnico del día',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: _dateController,
                                decoration: const InputDecoration(labelText: 'Fecha (YYYY-MM-DD)'),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _mudDensityController,
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(labelText: 'Mud density ppg'),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: TextField(
                                      controller: _viscosityController,
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(labelText: 'Viscosidad (s)'),
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
                                      decoration: const InputDecoration(labelText: 'Presión (psi)'),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: TextField(
                                      controller: _phController,
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(labelText: 'pH'),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _notesController,
                                maxLines: 4,
                                decoration: const InputDecoration(labelText: 'Observaciones'),
                              ),
                              if (vm.errorMessage != null) ...[
                                const SizedBox(height: 12),
                                Text(
                                  vm.errorMessage!,
                                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                                ),
                              ],
                              const SizedBox(height: 20),
                              FilledButton(
                                onPressed: vm.isSubmitting
                                    ? null
                                    : () async {
                                        final saved = await vm.saveReport(
                                          reportId: widget.arguments.reportId,
                                          pozoId: widget.arguments.pozoId,
                                          date: DateTime.parse(_dateController.text.trim()),
                                          mudDensity: double.tryParse(_mudDensityController.text.trim()) ?? 0,
                                          viscosity: int.tryParse(_viscosityController.text.trim()) ?? 0,
                                          pressure: double.tryParse(_pressureController.text.trim()) ?? 0,
                                          ph: double.tryParse(_phController.text.trim()) ?? 0,
                                          notes: _notesController.text.trim(),
                                        );

                                        if (context.mounted) {
                                          Navigator.of(context).pop<FluidReport>(saved);
                                        }
                                      },
                                child: vm.isSubmitting
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : Text(widget.arguments.isEditing ? 'Actualizar' : 'Guardar'),
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
}