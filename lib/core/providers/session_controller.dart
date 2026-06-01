import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import '../models/auth_session.dart';

class SessionController extends ChangeNotifier {
  AuthSession? _session;
  bool _isBusy = false;
  String? _errorMessage;

  AuthSession? get session => _session;
  AppUser? get user => _session?.user;
  String? get token => _session?.token;
  bool get isAuthenticated => _session != null;
  bool get isBusy => _isBusy;
  String? get errorMessage => _errorMessage;

  bool get canManageWells => user?.canManageWells == true;
  bool get canManageReports => user?.canManageReports == true;

  void startLoading() {
    _isBusy = true;
    _errorMessage = null;
    notifyListeners();
  }

  void setSession(AuthSession session) {
    _session = session;
    _isBusy = false;
    _errorMessage = null;
    notifyListeners();
  }

  void setError(String message) {
    _errorMessage = message;
    _isBusy = false;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void logout() {
    _session = null;
    _isBusy = false;
    _errorMessage = null;
    notifyListeners();
  }
}