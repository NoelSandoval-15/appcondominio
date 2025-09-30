import 'package:appcondominio/features/auth/data/auth_service.dart';
import 'package:http/http.dart' as http;

class AuthRepository {
  final AuthService _authService = AuthService();

  Future<bool> login(String emailOrUsername, String password) {
    return _authService.login(emailOrUsername, password);
  }

  Future<bool> register(Map<String, String> userData) {
    return _authService.register(userData);
  }

  Future<Map<String, dynamic>?> getUser() {
    return _authService.getUser();
  }

  Future<void> logout() {
    return _authService.logout();
  }

  Future<bool> isLoggedIn() {
    return _authService.isLoggedIn();
  }

  // NUEVOS MÉTODOS
  Future<String?> getUserRole() {
    return _authService.getUserRole();
  }

  Future<String?> getAccessToken() {
    return _authService.getAccessToken();
  }

  Future<http.Response> getWithAuth(String endpoint) {
    return _authService.getWithAuth(endpoint);
  }

}
