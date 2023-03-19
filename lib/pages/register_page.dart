// Librarys
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Services
import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/services/socket_service.dart';
// Widgets
import 'package:chat_app/widgets/btn_blue.dart';
import 'package:chat_app/widgets/custom_input.dart';
import 'package:chat_app/widgets/labels.dart';
import 'package:chat_app/widgets/logo.dart';
// Helpers
import 'package:chat_app/helpers/mostrar_alerta.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF2F2F2),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.9,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Logo(title: 'Registro'),
                _Form(),
                const Labels(
                  title: '¿Ya tienes una cuenta?',
                  subTitle: 'Ingrese ahora!',
                  route: 'login',
                ),
                const Text(
                  'Términos y condiciones de uso',
                  style: TextStyle(fontWeight: FontWeight.w200),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Form extends StatefulWidget {
  @override
  State<_Form> createState() => __FormState();
}

class __FormState extends State<_Form> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final nameCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final socketService = Provider.of<SocketService>(context);
    return Container(
      margin: const EdgeInsets.only(top: 40),
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: Column(
        children: [
          CustomInput(
            icon: Icons.perm_identity,
            placeholder: 'Nombre',
            textController: nameCtrl,
          ),
          CustomInput(
            icon: Icons.mail_outline,
            placeholder: 'Correo',
            keyboardType: TextInputType.emailAddress,
            textController: emailCtrl,
          ),
          CustomInput(
            icon: Icons.lock_outline,
            placeholder: 'Contraseña',
            textController: passCtrl,
            isPassword: true,
          ),
          BtnBlue(
            text: 'Crear cuenta',
            onPressed: authService.autenticando
                ? null
                : () async {
                    // print(emailCtrl.text);
                    // print(passCtrl.text);
                    // print(nameCtrl.text);
                    FocusScope.of(context).unfocus();
                    final registerOk = authService.register(
                        nameCtrl.text.trim(),
                        emailCtrl.text.trim(),
                        passCtrl.text.trim());

                    if (await registerOk == true) {
                      // Conectar a nuestro socket server
                      socketService.connect();
                      // Navegar a otra pantalla
                      Navigator.pushReplacementNamed(context, 'users');
                    } else {
                      // Mostrar alerta
                      mostrarAlerta(
                          context, 'Registro incorrecto', await registerOk);
                    }
                  },
          ),
        ],
      ),
    );
  }
}
