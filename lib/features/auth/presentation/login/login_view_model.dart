import 'package:flutter/foundation.dart';
import '../../../../core/providers/session_controller.dart';
import '../../data/auth_repository.dart';

class LoginViewModel extends ChangeNotifier {
  LoginViewModel({
    required this.authRepository,
    required this.sessionController,
  });

  final AuthRepository authRepository;
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
      final session = await authRepository.login(
        email: email.trim(),
        password: password,
      );

      sessionController.setSession(session);
    } catch (error) {
      errorMessage = error.toString();
      isSubmitting = false;
      notifyListeners();
    }
  }
}