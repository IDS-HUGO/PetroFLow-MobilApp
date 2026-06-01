import 'package:flutter/foundation.dart';

import '../../../../core/models/app_user.dart';
import '../../../../core/providers/session_controller.dart';
import '../../data/auth_repository.dart';

class RegisterViewModel extends ChangeNotifier {
  RegisterViewModel({
    required this.authRepository,
    required this.sessionController,
  });

  final AuthRepository authRepository;
  final SessionController sessionController;

  String fullName = '';
  String email = '';
  String password = '';
  UserRole role = UserRole.fieldEngineer;
  bool isSubmitting = false;
  String? errorMessage;

  Future<void> register() async {
    if (fullName.trim().isEmpty || email.trim().isEmpty || password.trim().isEmpty) {
      errorMessage = 'Completa nombre, correo y contraseña.';
      notifyListeners();
      return;
    }

    isSubmitting = true;
    errorMessage = null;
    notifyListeners();

    try {
      final session = await authRepository.register(
        fullName: fullName.trim(),
        email: email.trim(),
        password: password,
        roleName: role.apiValue,
      );

      sessionController.setSession(session);
    } catch (error) {
      errorMessage = error.toString();
      isSubmitting = false;
      notifyListeners();
    }
  }
}