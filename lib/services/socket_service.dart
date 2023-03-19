// Librarys
import 'package:chat_app/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart';
// Environments
import 'package:chat_app/global/environment.dart';

enum ServerStatus {
  online,
  offline,
  connecting,
}

class SocketService extends ChangeNotifier {
  ServerStatus _serverStatus = ServerStatus.connecting;
  late Socket _socket;

  ServerStatus get serverStatus => _serverStatus;

  Socket get socket => _socket;
  Function get emit => _socket.emit;

  void connect() async {
    // Obtener Token
    final token = await AuthService.getToken();

    // Dart client
    _socket = io(
      Environment.socketUrl,
      OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .enableForceNew()
          .setExtraHeaders({
            "x-token": token,
          })
          .build(),
    );

    _socket.onConnect((_) {
      print("onConnect");
      _serverStatus = ServerStatus.online;
      notifyListeners();
    });

    _socket.onDisconnect((_) {
      print("onDisconnect");
      _serverStatus = ServerStatus.offline;
      notifyListeners();
    });
  }

  void disconnect() {
    _socket.disconnect();
  }
}
