import 'package:flutter/foundation.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/providers/session_controller.dart';
import '../../domain/usecases/login_usecase.dart';

class LoginViewModel extends ChangeNotifier {
  LoginViewModel({required this.loginUseCase, required this.sessionController});

  final LoginUseCase loginUseCase;
  final SessionController sessionController;

  String email = '';
  String password = '';
  bool isSubmitting = false;
  String? errorMessage;

  Future<void> login() async {
    if (email.trim().isEmpty || password.trim().isEmpty) {
      errorMessage = 'Completa correo y contraseña.';
      notifyListeners();
      return;
    }

    isSubmitting = true;
    errorMessage = null;
    notifyListeners();

    try {
      final session = await loginUseCase(
        email: email.trim(),
        password: password,
      );

      sessionController.setSession(session);
    } catch (error) {
      errorMessage = getReadableError(error);
      isSubmitting = false;
      notifyListeners();
    }
  }
}
