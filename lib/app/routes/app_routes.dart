class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String dashboard = '/dashboard';
  static const String reportForm = '/reports/form';
  static const String reportDetail = '/reports/detail';
}

class ReportFormArguments {
  const ReportFormArguments({required this.pozoId, this.reportId});

  final String pozoId;
  final int? reportId;

  bool get isEditing => reportId != null;
}
