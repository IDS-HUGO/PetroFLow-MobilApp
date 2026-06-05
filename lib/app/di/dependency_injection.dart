import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../core/config/app_config.dart';
import '../../core/network/api_client.dart';
import '../../core/providers/session_controller.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/reports/data/datasources/reports_remote_datasource.dart';
import '../../features/reports/data/repositories/reports_repository_impl.dart';
import '../../features/reports/domain/repositories/reports_repository.dart';
import '../../features/reports/domain/usecases/create_report_usecase.dart';
import '../../features/reports/domain/usecases/delete_report_usecase.dart';
import '../../features/reports/domain/usecases/get_report_by_id_usecase.dart';
import '../../features/reports/domain/usecases/get_reports_by_well_usecase.dart';
import '../../features/reports/domain/usecases/update_report_usecase.dart';
import '../../features/wells/data/datasources/wells_remote_datasource.dart';
import '../../features/wells/data/repositories/wells_repository_impl.dart';
import '../../features/wells/domain/repositories/wells_repository.dart';
import '../../features/wells/domain/usecases/create_well_usecase.dart';
import '../../features/wells/domain/usecases/delete_well_usecase.dart';
import '../../features/wells/domain/usecases/get_campos_usecase.dart';
import '../../features/wells/domain/usecases/get_wells_usecase.dart';
import '../../features/wells/domain/usecases/update_well_usecase.dart';

class DependencyInjection extends StatefulWidget {
  const DependencyInjection({super.key, required this.child});

  final Widget child;

  @override
  State<DependencyInjection> createState() => _DependencyInjectionState();
}

class _DependencyInjectionState extends State<DependencyInjection> {
  late final SessionController _sessionController;
  late final ApiClient _apiClient;

  late final AuthRemoteDataSource _authRemoteDataSource;
  late final AuthRepository _authRepository;
  late final LoginUseCase _loginUseCase;
  late final RegisterUseCase _registerUseCase;

  late final WellsRemoteDataSource _wellsRemoteDataSource;
  late final WellsRepository _wellsRepository;
  late final GetCamposUseCase _getCamposUseCase;
  late final GetWellsUseCase _getWellsUseCase;
  late final CreateWellUseCase _createWellUseCase;
  late final UpdateWellUseCase _updateWellUseCase;
  late final DeleteWellUseCase _deleteWellUseCase;

  late final ReportsRemoteDataSource _reportsRemoteDataSource;
  late final ReportsRepository _reportsRepository;
  late final GetReportsByWellUseCase _getReportsByWellUseCase;
  late final GetReportByIdUseCase _getReportByIdUseCase;
  late final CreateReportUseCase _createReportUseCase;
  late final UpdateReportUseCase _updateReportUseCase;
  late final DeleteReportUseCase _deleteReportUseCase;

  @override
  void initState() {
    super.initState();
    _sessionController = SessionController();
    _apiClient = ApiClient(
      baseUrl: AppConfig.apiBaseUrl,
      apiKey: AppConfig.supabaseAnonKey,
      tokenProvider: () => _sessionController.token,
    );

    _authRemoteDataSource = AuthRemoteDataSource(_apiClient);
    _authRepository = AuthRepositoryImpl(_authRemoteDataSource);
    _loginUseCase = LoginUseCase(_authRepository);
    _registerUseCase = RegisterUseCase(_authRepository);

    _wellsRemoteDataSource = WellsRemoteDataSource(_apiClient);
    _wellsRepository = WellsRepositoryImpl(_wellsRemoteDataSource);
    _getCamposUseCase = GetCamposUseCase(_wellsRepository);
    _getWellsUseCase = GetWellsUseCase(_wellsRepository);
    _createWellUseCase = CreateWellUseCase(_wellsRepository);
    _updateWellUseCase = UpdateWellUseCase(_wellsRepository);
    _deleteWellUseCase = DeleteWellUseCase(_wellsRepository);

    _reportsRemoteDataSource = ReportsRemoteDataSource(_apiClient);
    _reportsRepository = ReportsRepositoryImpl(_reportsRemoteDataSource);
    _getReportsByWellUseCase = GetReportsByWellUseCase(_reportsRepository);
    _getReportByIdUseCase = GetReportByIdUseCase(_reportsRepository);
    _createReportUseCase = CreateReportUseCase(_reportsRepository);
    _updateReportUseCase = UpdateReportUseCase(_reportsRepository);
    _deleteReportUseCase = DeleteReportUseCase(_reportsRepository);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SessionController>.value(
          value: _sessionController,
        ),
        Provider<ApiClient>.value(value: _apiClient),
        Provider<AuthRepository>.value(value: _authRepository),
        Provider<LoginUseCase>.value(value: _loginUseCase),
        Provider<RegisterUseCase>.value(value: _registerUseCase),
        Provider<WellsRepository>.value(value: _wellsRepository),
        Provider<GetCamposUseCase>.value(value: _getCamposUseCase),
        Provider<GetWellsUseCase>.value(value: _getWellsUseCase),
        Provider<CreateWellUseCase>.value(value: _createWellUseCase),
        Provider<UpdateWellUseCase>.value(value: _updateWellUseCase),
        Provider<DeleteWellUseCase>.value(value: _deleteWellUseCase),
        Provider<ReportsRepository>.value(value: _reportsRepository),
        Provider<GetReportsByWellUseCase>.value(
          value: _getReportsByWellUseCase,
        ),
        Provider<GetReportByIdUseCase>.value(value: _getReportByIdUseCase),
        Provider<CreateReportUseCase>.value(value: _createReportUseCase),
        Provider<UpdateReportUseCase>.value(value: _updateReportUseCase),
        Provider<DeleteReportUseCase>.value(value: _deleteReportUseCase),
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
