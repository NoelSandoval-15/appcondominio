import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final String baseUrl = 'http://10.0.2.2:8000/api/auth'; // URL base de auth
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // ------------------------------
  // LOGIN
  // ------------------------------
  Future<bool> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/login/');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      await _storage.write(key: 'accessToken', value: data['access']);
      await _storage.write(key: 'refreshToken', value: data['refresh']);

      if (data.containsKey("rol")) {
        await _storage.write(key: 'userRole', value: data["rol"]);
      }

      return true;
    }

    return false;
  }

  // ------------------------------
  // REGISTRO
  // ------------------------------
  Future<bool> register(Map<String, String> userData) async {
    final url = Uri.parse('$baseUrl/usuario/');
    final response = await http.post(url, body: userData);
    return response.statusCode == 201;
  }

  // ------------------------------
  // OBTENER USUARIO
  // ------------------------------
  Future<Map<String, dynamic>?> getUser() async {
    final token = await _storage.read(key: 'accessToken');
    if (token == null) return null;

    final url = Uri.parse('$baseUrl/me/');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    return null;
  }

  // ------------------------------
  // OBTENER TOKENS / ROL
  // ------------------------------
  Future<String?> getAccessToken() async {
    return await _storage.read(key: 'accessToken');
  }

  Future<String?> getUserRole() async {
    return await _storage.read(key: 'userRole');
  }

  // ------------------------------
  // CERRAR SESIÓN
  // ------------------------------
  Future<void> logout() async {
    await _storage.delete(key: 'accessToken');
    await _storage.delete(key: 'refreshToken');
    await _storage.delete(key: 'userRole');
  }

  // ------------------------------
  // VERIFICAR LOGIN
  // ------------------------------
  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'accessToken');
    return token != null;
  }

  // ------------------------------
  // PETICIÓN GET CON REFRESCO AUTOMÁTICO DE TOKEN
  // ------------------------------
  Future<http.Response> getWithAuth(String endpoint) async {
    String? token = await _storage.read(key: 'accessToken');
    String? refresh = await _storage.read(key: 'refreshToken');

    final url = Uri.parse(endpoint);
    http.Response response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    // Si la respuesta indica que el token no es válido o expiró
    if (response.statusCode == 401 && response.body.contains('token_not_valid')) {
      // Intentar refrescar el token
      final refreshUrl = Uri.parse('$baseUrl/refresh/');  // ← Cambiado aquí
      final refreshResponse = await http.post(
        refreshUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh': refresh}),
      );

      if (refreshResponse.statusCode == 200) {
        final data = jsonDecode(refreshResponse.body);
        final newToken = data['access'];

        await _storage.write(key: 'accessToken', value: newToken);

        // Reintentar la solicitud original con el nuevo token
        return await http.get(
          url,
          headers: {'Authorization': 'Bearer $newToken'},
        );
      } else {
        // Si el refresh falla, retornamos la respuesta original
        return response;
      }
    }

    return response;
  }
}
