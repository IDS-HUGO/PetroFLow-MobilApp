import 'package:flutter/material.dart';

import '../../features/auth/presentation/login/login_page.dart';
import '../../features/auth/presentation/register/register_page.dart';
import '../../features/reports/presentation/report_detail_page.dart';
import '../../features/reports/presentation/report_form_page.dart';
import 'app_routes.dart';

class RouteGenerator {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.register:
        return MaterialPageRoute<void>(builder: (_) => const RegisterPage());
      case AppRoutes.reportForm:
        final args = settings.arguments as ReportFormArguments?;
        if (args == null) {
          return _errorRoute(
            'Faltan datos para abrir el formulario del reporte.',
          );
        }

        return MaterialPageRoute<void>(
          builder: (_) => ReportFormPage(arguments: args),
        );
      case AppRoutes.reportDetail:
        final reportId = settings.arguments as int?;
        if (reportId == null) {
          return _errorRoute('Falta el identificador del reporte.');
        }

        return MaterialPageRoute<void>(
          builder: (_) => ReportDetailPage(reportId: reportId),
        );
      case AppRoutes.dashboard:
      case AppRoutes.login:
      default:
        return MaterialPageRoute<void>(builder: (_) => const LoginPage());
    }
  }

  static MaterialPageRoute<void> _errorRoute(String message) {
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
