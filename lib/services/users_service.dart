// Librarys
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
// Environments
import 'package:chat_app/global/environment.dart';
// Models
import 'package:chat_app/models/user.dart';
import 'package:chat_app/models/users_response.dart';
// Services
import 'package:chat_app/services/auth_service.dart';

class UsersService extends ChangeNotifier {
  Future<List<User>> getUsers() async {
    try {
      final url = Uri.parse('${Environment.apiUrl}/users');
      final resp = await http.get(url, headers: {
        'Conten-Type': 'application/json',
        'x-token': await AuthService.getToken(),
      });

      final usersRespose = UsersResponse.fromJson(resp.body);
      return usersRespose.users;
    } catch (e) {
      return [];
    }
  }
}
