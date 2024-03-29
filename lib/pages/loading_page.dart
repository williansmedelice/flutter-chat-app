// Librarys
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Services
import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/services/socket_service.dart';
// Pages
import 'package:chat_app/pages/users_page.dart';

class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: checkLoginState(context),
        builder: (context, snapshot) {
          return const Center(
            child: Text('Espere...!'),
          );
        },
      ),
    );
  }

  Future checkLoginState(BuildContext context) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final socketService = Provider.of<SocketService>(context, listen: false);

    final autenticado = authService.isLoggedIn();

    if (await autenticado == true) {
      // Conectar a nuestro socket server
      socketService.connect();
      // Navigator.pushReplacementNamed(context, 'users');
      Navigator.pushReplacement(
          context,
          PageRouteBuilder(
              pageBuilder: (_, __, ___) => const UsersPage(),
              transitionDuration: const Duration(
                milliseconds: 0,
              )));
    } else {
      Navigator.pushReplacementNamed(context, 'login');
    }
  }
}
