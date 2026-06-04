import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/models/well.dart';
import '../../../core/providers/session_controller.dart';
import '../data/wells_repository.dart';
import 'wells_view_model.dart';

class WellsPage extends StatelessWidget {
  const WellsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<WellsViewModel>(
      create: (context) => WellsViewModel(context.read<WellsRepository>())..loadWells(),
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
      onRefresh: vm.loadWells,
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            title: const Text('Pozos activos'),
            actions: [
              if (canManage)
                IconButton(
                  tooltip: 'Crear pozo',
                  onPressed: () => _showWellForm(context, vm),
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
                        ? const SliverToBoxAdapter(
                            child: _EmptyState(
                              icon: Icons.water_outlined,
                              title: 'Sin pozos registrados',
                              subtitle: 'Crea el primer pozo para comenzar el control operativo.',
                            ),
                          )
                        : SliverList.separated(
                            itemCount: vm.wells.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final well = vm.wells[index];
                              final initial = well.name.isNotEmpty ? well.name[0].toUpperCase() : '?';

                              return Card(
                                child: ListTile(
                                  leading: CircleAvatar(child: Text(initial)),
                                  title: Text(well.name),
                                  subtitle: Text(
                                    '${well.status.label} · Profundidad objetivo: ${well.depthTargetFt.toStringAsFixed(1)} ft',
                                  ),
                                  trailing: Chip(label: Text(well.region ?? 'Sin región')),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Future<void> _showWellForm(BuildContext context, WellsViewModel vm) async {
    final nameController = TextEditingController();
    final campoController = TextEditingController();
    final depthController = TextEditingController();
    WellStatus selectedStatus = WellStatus.perforacion;

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
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Nombre del pozo'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: campoController,
                    decoration: const InputDecoration(labelText: 'Campo petrolero (id)'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: depthController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Profundidad objetivo (ft)'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<WellStatus>(
                    initialValue: selectedStatus,
                    items: WellStatus.values
                        .map((status) => DropdownMenuItem(value: status, child: Text(status.label)))
                        .toList(growable: false),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => selectedStatus = value);
                      }
                    },
                    decoration: const InputDecoration(labelText: 'Estado'),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () async {
                      await vm.createWell(
                        name: nameController.text.trim(),
                        campoId: campoController.text.trim(),
                        status: selectedStatus,
                        depthTargetFt: double.tryParse(depthController.text.trim()) ?? 0,
                      );
                      if (context.mounted) {
                        Navigator.of(context).pop(true);
                      }
                    },
                    child: const Text('Guardar pozo'),
                  ),
                ],
              );
            },
          ),
        );
      },
    );

    if (created == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pozo creado correctamente.')),
      );
    }
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.title, required this.subtitle});

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