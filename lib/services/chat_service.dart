// Librarys
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
// Models
import 'package:chat_app/models/user.dart';
import 'package:chat_app/models/messages_response.dart';
// Environments
import 'package:chat_app/global/environment.dart';
// Services
import 'package:chat_app/services/auth_service.dart';

class ChatService extends ChangeNotifier {
  late User userTo;

  Future<List<Message>> getChat(String userID) async {
    final url = Uri.parse('${Environment.apiUrl}/messages/$userID');
    final resp = await http.get(url, headers: {
      'Conten-Type': 'application/json',
      'x-token': await AuthService.getToken(),
    });

    final messagesResp = MessagesResponse.fromJson(resp.body);

    return messagesResp.messages;
  }
}
