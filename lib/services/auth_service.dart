// Librarys
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// Environments
import 'package:chat_app/global/environment.dart';
// Models
import 'package:chat_app/models/login_response.dart';
import 'package:chat_app/models/user.dart';

class AuthService extends ChangeNotifier {
  late User user;
  bool _autenticando = false;

  // Create storage
  final _storage = const FlutterSecureStorage();

  bool get autenticando => _autenticando;
  set autenticando(bool value) {
    _autenticando = value;
    notifyListeners();
  }

  // Getters del token de forma estática
  static Future<String> getToken() async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'token');
    return token!;
  }

  static Future<void> deleteToken() async {
    const storage = FlutterSecureStorage();
    await storage.delete(key: 'token');
  }

  Future<bool> login(String email, String password) async {
    autenticando = true;

    final data = {'email': email, 'password': password};

    final url = Uri.parse('${Environment.apiUrl}/login');

    final resp = await http.post(url,
        body: jsonEncode(data), headers: {'Content-Type': 'application/json'});

    // print(resp.body);

    autenticando = false;

    if (resp.statusCode == 200) {
      final loginResponse = LoginResponse.fromJson(resp.body);
      user = loginResponse.user;

      // Guardar Token en lugar seguro
      await _guardarToken(loginResponse.token);

      return true;
    } else {
      return false;
    }
  }

  Future register(String name, String email, String password) async {
    autenticando = true;

    final data = {'name': name, 'email': email, 'password': password};
    final url = Uri.parse('${Environment.apiUrl}/login/new');
    final resp = await http.post(url,
        body: jsonEncode(data), headers: {'Content-Type': 'application/json'});

    // print(resp.body);

    autenticando = false;

    if (resp.statusCode == 200) {
      final registerResponse = LoginResponse.fromJson(resp.body);

      await _guardarToken(registerResponse.token);

      return true;
    } else {
      final respBody = jsonDecode(resp.body);
      return respBody['msg'];
    }
  }

  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'token');

    // print(token);

    final url = Uri.parse('${Environment.apiUrl}/login/renew');
    final resp = await http.get(url,
        headers: {'Content-Type': 'application/json', 'x-token': token ?? ''});

    // print(resp.body);

    if (resp.statusCode == 200) {
      final renewTokenResponse = LoginResponse.fromJson(resp.body);

      user = renewTokenResponse.user;

      await _guardarToken(renewTokenResponse.token);

      return true;
    } else {
      logout();
      return false;
    }
  }

  Future _guardarToken(String token) async {
    await _storage.write(key: 'token', value: token);
    return;
  }

  Future logout() async {
    await _storage.delete(key: 'token');
  }
}
