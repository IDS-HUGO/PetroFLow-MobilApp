import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/session_controller.dart';
import '../../reports/presentation/reports_page.dart';
import '../../wells/presentation/wells_page.dart';

class DashboardShell extends StatefulWidget {
  const DashboardShell({super.key});

  @override
  State<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<DashboardShell> {
  int _index = 0;

  final List<Widget> _pages = const <Widget>[
    _OverviewPage(),
    WellsPage(),
    ReportsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionController>();

    return Scaffold(
      appBar: AppBar(
        title: Text('PetroFlow · ${session.user?.role.label ?? ''}'),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            onPressed: () => context.read<SessionController>().logout(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.space_dashboard_outlined), selectedIcon: Icon(Icons.space_dashboard), label: 'Inicio'),
          NavigationDestination(icon: Icon(Icons.water_outlined), selectedIcon: Icon(Icons.water), label: 'Pozos'),
          NavigationDestination(icon: Icon(Icons.description_outlined), selectedIcon: Icon(Icons.description), label: 'Reportes'),
        ],
      ),
    );
  }
}

class _OverviewPage extends StatelessWidget {
  const _OverviewPage();

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionController>().user;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xff14351f), Color(0xff2f6b3a), Color(0xffb7d6af)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Operación en campo',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        session == null
                            ? 'Sesión no disponible.'
                            : 'Hola, ${session.fullName}. Aquí centralizas pozos, reportes y control operativo.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.5,
                  children: const [
                    _SummaryCard(icon: Icons.water_drop_outlined, label: 'Control de lodo', value: '24/7'),
                    _SummaryCard(icon: Icons.analytics_outlined, label: 'Seguimiento', value: 'Tiempo real'),
                    _SummaryCard(icon: Icons.engineering_outlined, label: 'Ingeniería', value: 'Campo'),
                    _SummaryCard(icon: Icons.verified_outlined, label: 'Seguridad', value: 'JWT'),
                  ],
                ),
                const SizedBox(height: 20),
                const Card(
                  child: ListTile(
                    leading: Icon(Icons.fact_check_outlined),
                    title: Text('Flujo recomendado'),
                    subtitle: Text('1. Revisa pozos activos  2. Registra reporte  3. Corrige anomalías'),
                    trailing: Icon(Icons.chevron_right),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28),
            const SizedBox(height: 8),
            Text(label, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 4),
            Text(value, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}