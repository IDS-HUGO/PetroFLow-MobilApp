import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/providers/session_controller.dart';
import '../features/auth/presentation/login/login_page.dart';
import '../features/dashboard/presentation/dashboard_shell.dart';
import '../shared/theme/theme.dart';
import 'di/dependency_injection.dart';
import 'routes/route_generator.dart';
import 'theme/app_theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final materialTheme = AppTheme.build(context);
    return DependencyInjection(child: AppView(theme: materialTheme));
  }
}

class AppView extends StatelessWidget {
  const AppView({super.key, required this.theme});

  final MaterialTheme theme;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PetroFlow',
      theme: theme.light(),
      darkTheme: theme.dark(),
      themeMode: ThemeMode.system,
      home: const _AuthGate(),
      onGenerateRoute: RouteGenerator.onGenerateRoute,
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return Consumer<SessionController>(
      builder: (context, sessionController, _) {
        if (sessionController.isAuthenticated) {
          return const DashboardShell();
        }

        return const LoginPage();
      },
    );
  }
}
