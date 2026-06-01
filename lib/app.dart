import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/config/app_config.dart';
import 'core/network/api_client.dart';
import 'core/providers/session_controller.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/presentation/login/login_page.dart';
import 'features/auth/presentation/register/register_page.dart';
import 'features/dashboard/presentation/dashboard_shell.dart';
import 'features/reports/data/reports_repository.dart';
import 'features/reports/presentation/report_detail_page.dart';
import 'features/reports/presentation/report_form_page.dart';
import 'features/wells/data/wells_repository.dart';
import 'shared/theme/theme.dart';
import 'shared/theme/util.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = createTextTheme(context, 'Ubuntu', 'Aclonica');
    final materialTheme = MaterialTheme(textTheme);

    return AppCompositionRoot(
      child: AppView(theme: materialTheme),
    );
  }
}

class AppCompositionRoot extends StatefulWidget {
  const AppCompositionRoot({super.key, required this.child});

  final Widget child;

  @override
  State<AppCompositionRoot> createState() => _AppCompositionRootState();
}

class _AppCompositionRootState extends State<AppCompositionRoot> {
  late final SessionController _sessionController;
  late final ApiClient _apiClient;
  late final AuthRepository _authRepository;
  late final WellsRepository _wellsRepository;
  late final ReportsRepository _reportsRepository;

  @override
  void initState() {
    super.initState();
    _sessionController = SessionController();
    _apiClient = ApiClient(
      baseUrl: AppConfig.apiBaseUrl,
      tokenProvider: () => _sessionController.token,
    );
    _authRepository = AuthRepository(_apiClient);
    _wellsRepository = WellsRepository(_apiClient);
    _reportsRepository = ReportsRepository(_apiClient);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SessionController>.value(value: _sessionController),
        Provider<ApiClient>.value(value: _apiClient),
        Provider<AuthRepository>.value(value: _authRepository),
        Provider<WellsRepository>.value(value: _wellsRepository),
        Provider<ReportsRepository>.value(value: _reportsRepository),
      ],
      child: widget.child,
    );
  }

  @override
  void dispose() {
    _sessionController.dispose();
    super.dispose();
  }
}

class AppView extends StatelessWidget {
  const AppView({super.key, required this.theme});

  final MaterialTheme theme;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Petro Flow',
      theme: theme.light(),
      darkTheme: theme.dark(),
      themeMode: ThemeMode.system,
      home: const _AuthGate(),
      onGenerateRoute: _onGenerateRoute,
    );
  }

  Route<dynamic> _onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.register:
        return MaterialPageRoute<void>(builder: (_) => const RegisterPage());
      case AppRoutes.reportForm:
        final args = settings.arguments as ReportFormArguments?;
        if (args == null) {
          return _errorRoute('Faltan datos para abrir el formulario del reporte.');
        }

        return MaterialPageRoute<void>(builder: (_) => ReportFormPage(arguments: args));
      case AppRoutes.reportDetail:
        final reportId = settings.arguments as int?;
        if (reportId == null) {
          return _errorRoute('Falta el identificador del reporte.');
        }

        return MaterialPageRoute<void>(builder: (_) => ReportDetailPage(reportId: reportId));
      case AppRoutes.dashboard:
      case AppRoutes.login:
      default:
        return MaterialPageRoute<void>(builder: (_) => const _AuthGate());
    }
  }

  MaterialPageRoute<void> _errorRoute(String message) {
    return MaterialPageRoute<void>(
      builder: (context) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              message,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String dashboard = '/dashboard';
  static const String reportForm = '/reports/form';
  static const String reportDetail = '/reports/detail';
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

class ReportFormArguments {
  const ReportFormArguments({
    required this.pozoId,
    this.reportId,
  });

  final String pozoId;
  final int? reportId;

  bool get isEditing => reportId != null;
}