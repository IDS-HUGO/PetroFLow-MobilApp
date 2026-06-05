import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/session_controller.dart';
import '../domain/entities/campo.dart';
import '../domain/entities/well.dart';
import '../domain/usecases/create_well_usecase.dart';
import '../domain/usecases/delete_well_usecase.dart';
import '../domain/usecases/get_campos_usecase.dart';
import '../domain/usecases/get_wells_usecase.dart';
import '../domain/usecases/update_well_usecase.dart';
import 'wells_view_model.dart';

class WellsPage extends StatelessWidget {
  const WellsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<WellsViewModel>(
      create: (context) => WellsViewModel(
        getCamposUseCase: context.read<GetCamposUseCase>(),
        getWellsUseCase: context.read<GetWellsUseCase>(),
        createWellUseCase: context.read<CreateWellUseCase>(),
        updateWellUseCase: context.read<UpdateWellUseCase>(),
        deleteWellUseCase: context.read<DeleteWellUseCase>(),
      )..loadInitialData(),
      child: const _WellsView(),
    );
  }
}

class _WellsView extends StatelessWidget {
  const _WellsView();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<WellsViewModel>();
    final canManage = context.watch<SessionController>().canManageWells;

    return RefreshIndicator(
      onRefresh: vm.loadInitialData,
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            title: const Text('Pozos activos'),
            actions: [
              if (canManage)
                IconButton(
                  tooltip: 'Crear pozo',
                  onPressed: vm.isSaving
                      ? null
                      : () => _showWellForm(context, vm),
                  icon: const Icon(Icons.add_circle_outline),
                ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: vm.isLoading
                ? const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  )
                : vm.errorMessage != null
                ? SliverToBoxAdapter(
                    child: _EmptyState(
                      icon: Icons.error_outline,
                      title: 'No fue posible cargar los pozos',
                      subtitle: vm.errorMessage!,
                    ),
                  )
                : vm.wells.isEmpty
                ? SliverToBoxAdapter(
                    child: _EmptyState(
                      icon: Icons.water_outlined,
                      title: 'Sin pozos registrados',
                      subtitle: 'Agrega tu primer pozo para comenzar.',
                    ),
                  )
                : SliverList.separated(
                    itemCount: vm.wells.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final well = vm.wells[index];
                      final initial = well.name.isNotEmpty
                          ? well.name[0].toUpperCase()
                          : '?';

                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(child: Text(initial)),
                          title: Text(well.name),
                          subtitle: Text(
                            '${well.status.label} · ${well.campoName ?? 'Campo sin nombre'} · ${well.region ?? 'Sin región'} · ${well.depthTargetFt.toStringAsFixed(1)} ft',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: canManage
                              ? PopupMenuButton<_WellAction>(
                                  onSelected: (action) async {
                                    switch (action) {
                                      case _WellAction.edit:
                                        await _showWellForm(
                                          context,
                                          vm,
                                          existingWell: well,
                                        );
                                      case _WellAction.delete:
                                        await _confirmDeleteWell(
                                          context,
                                          vm,
                                          well,
                                        );
                                    }
                                  },
                                  itemBuilder: (context) => const [
                                    PopupMenuItem(
                                      value: _WellAction.edit,
                                      child: ListTile(
                                        leading: Icon(Icons.edit_outlined),
                                        title: Text('Editar'),
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: _WellAction.delete,
                                      child: ListTile(
                                        leading: Icon(Icons.delete_outline),
                                        title: Text('Eliminar'),
                                      ),
                                    ),
                                  ],
                                )
                              : null,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _showWellForm(
    BuildContext context,
    WellsViewModel vm, {
    Well? existingWell,
  }) async {
    if (vm.campos.isEmpty) {
      await vm.loadInitialData();
    }

    if (!context.mounted) {
      return;
    }

    if (vm.campos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No fue posible preparar el formulario.')),
      );
      return;
    }

    final nameController = TextEditingController(text: existingWell?.name);
    final depthController = TextEditingController(
      text: existingWell?.depthTargetFt.toString(),
    );
    final isEditing = existingWell != null;
    Campo selectedCampo = vm.campos.firstWhere(
      (campo) => campo.id == existingWell?.campoId,
      orElse: () => vm.campos.first,
    );
    WellStatus selectedStatus = existingWell?.status ?? WellStatus.perforacion;
    String? formError;

    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    isEditing ? 'Editar pozo' : 'Nuevo pozo',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del pozo',
                      prefixIcon: Icon(Icons.water_drop_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<Campo>(
                    initialValue: selectedCampo,
                    isExpanded: true,
                    items: vm.campos
                        .map(
                          (campo) => DropdownMenuItem<Campo>(
                            value: campo,
                            child: Text(campo.label),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => selectedCampo = value);
                      }
                    },
                    decoration: const InputDecoration(
                      labelText: 'Campo petrolero',
                      prefixIcon: Icon(Icons.map_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: depthController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Profundidad objetivo (ft)',
                      prefixIcon: Icon(Icons.straighten_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<WellStatus>(
                    initialValue: selectedStatus,
                    items: WellStatus.values
                        .map(
                          (status) => DropdownMenuItem(
                            value: status,
                            child: Text(status.label),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => selectedStatus = value);
                      }
                    },
                    decoration: const InputDecoration(
                      labelText: 'Estado',
                      prefixIcon: Icon(Icons.flag_outlined),
                    ),
                  ),
                  if (formError != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      formError!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: vm.isSaving
                        ? null
                        : () async {
                            final depth = double.tryParse(
                              depthController.text.trim(),
                            );
                            if (nameController.text.trim().isEmpty ||
                                depth == null ||
                                depth <= 0) {
                              setState(
                                () => formError =
                                    'Completa nombre y profundidad válida.',
                              );
                              return;
                            }

                            try {
                              if (isEditing) {
                                await vm.updateWell(
                                  id: existingWell.id,
                                  name: nameController.text,
                                  campoId: selectedCampo.id,
                                  status: selectedStatus,
                                  depthTargetFt: depth,
                                );
                              } else {
                                await vm.createWell(
                                  name: nameController.text,
                                  campoId: selectedCampo.id,
                                  status: selectedStatus,
                                  depthTargetFt: depth,
                                );
                              }
                              if (context.mounted) {
                                Navigator.of(context).pop(true);
                              }
                            } catch (error) {
                              if (context.mounted) {
                                setState(() => formError = error.toString());
                              }
                            }
                          },
                    icon: vm.isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save_outlined),
                    label: Text(isEditing ? 'Actualizar pozo' : 'Guardar pozo'),
                  ),
                ],
              );
            },
          ),
        );
      },
    );

    nameController.dispose();
    depthController.dispose();

    if (created == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditing
                ? 'Pozo actualizado correctamente.'
                : 'Pozo creado correctamente.',
          ),
        ),
      );
    }
  }

  Future<void> _confirmDeleteWell(
    BuildContext context,
    WellsViewModel vm,
    Well well,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Eliminar pozo?'),
        content: Text(
          'Se eliminará ${well.name}. Si tiene reportes, elimínalos primero.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton.tonalIcon(
            onPressed: () => Navigator.pop(ctx, true),
            icon: const Icon(Icons.delete_outline),
            label: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm != true || !context.mounted) {
      return;
    }

    try {
      await vm.deleteWell(well.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pozo eliminado correctamente.')),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              vm.errorMessage ?? 'No fue posible eliminar el pozo.',
            ),
          ),
        );
      }
    }
  }
}

enum _WellAction { edit, delete }

class _EmptyState extends StatelessWidget {
  const _EmptyState({
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(subtitle, textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }
}
