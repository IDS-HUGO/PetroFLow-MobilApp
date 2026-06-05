import 'package:flutter/foundation.dart';

import '../../domain/entities/app_user.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/providers/session_controller.dart';
import '../../domain/usecases/register_usecase.dart';

class RegisterViewModel extends ChangeNotifier {
  RegisterViewModel({
    required this.registerUseCase,
    required this.sessionController,
  });

  final RegisterUseCase registerUseCase;
  final SessionController sessionController;

  String fullName = '';
  String email = '';
  String password = '';
  UserRole role = UserRole.fieldEngineer;
  bool isSubmitting = false;
  String? errorMessage;

  Future<void> register() async {
    if (fullName.trim().isEmpty ||
        email.trim().isEmpty ||
        password.trim().isEmpty) {
      errorMessage = 'Completa nombre, correo y contraseña.';
      notifyListeners();
      return;
    }

    isSubmitting = true;
    errorMessage = null;
    notifyListeners();

    try {
      final session = await registerUseCase(
        fullName: fullName.trim(),
        email: email.trim(),
        password: password,
        roleName: role.apiValue,
      );

      sessionController.setSession(session);
    } catch (error) {
      errorMessage = getReadableError(error);
      isSubmitting = false;
      notifyListeners();
    }
  }
}
