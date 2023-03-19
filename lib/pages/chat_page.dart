// Librerys
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Widgets
import 'package:chat_app/widgets/chat_message.dart';
// Services
import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/services/chat_service.dart';
import 'package:chat_app/services/socket_service.dart';
// Models
import 'package:chat_app/models/messages_response.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with TickerProviderStateMixin {
  final _textController = TextEditingController();
  final _focusNode = FocusNode();

  late ChatService chatService;
  late SocketService socketService;
  late AuthService authService;

  final List<ChatMessage> _myMessages = [];

  bool _isWriting = false;

  @override
  void initState() {
    // implement initState
    super.initState();
    chatService = Provider.of<ChatService>(context, listen: false);
    socketService = Provider.of<SocketService>(context, listen: false);
    authService = Provider.of<AuthService>(context, listen: false);

    socketService.socket.on("private-message", _listenMessage);

    _loadHistory(chatService.userTo.uid);
  }

  void _loadHistory(String userID) async {
    List<Message> chat = await chatService.getChat(userID);

    // print(chat);

    final history = chat.map(
      (message) => ChatMessage(
        text: message.message,
        uid: message.from,
        animationController: AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 300),
        )..forward(),
      ),
    );

    setState(() {
      _myMessages.insertAll(0, history);
    });
  }

  void _listenMessage(dynamic payload) {
    // print('Tengo Mensaje! $payload');
    ChatMessage message = ChatMessage(
      text: payload['message'],
      uid: payload['from'],
      animationController: AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 300),
      ),
    );

    setState(() {
      _myMessages.insert(0, message);
    });

    message.animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final userTo = chatService.userTo;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Column(
          children: [
            CircleAvatar(
              backgroundColor: Colors.blue[100],
              maxRadius: 14,
              child: Text(userTo.name.substring(0, 2),
                  style: const TextStyle(fontSize: 12)),
            ),
            const SizedBox(height: 3),
            Text(userTo.name,
                style: const TextStyle(color: Colors.black87, fontSize: 12)),
          ],
        ),
        centerTitle: true,
        elevation: 1,
      ),
      body: Container(
        child: Column(
          children: [
            Flexible(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: _myMessages.length,
                itemBuilder: (_, i) => _myMessages[i],
                reverse: true,
              ),
            ),
            const Divider(),
            Container(
              color: Colors.white,
              child: _inputChat(),
            )
          ],
        ),
      ),
    );
  }

  Widget _inputChat() {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            Flexible(
              child: TextField(
                controller: _textController,
                onSubmitted: _handleSubmit,
                onChanged: (String text) {
                  setState(() {
                    if (text.trim().isNotEmpty) {
                      _isWriting = true;
                    } else {
                      _isWriting = false;
                    }
                  });
                },
                decoration:
                    const InputDecoration.collapsed(hintText: 'Enviar Mensaje'),
                focusNode: _focusNode,
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Platform.isIOS
                  ? CupertinoButton(
                      onPressed: (_isWriting)
                          ? () => _handleSubmit(_textController.text)
                          : null,
                      child: const Text('Enviar'))
                  : IconTheme(
                      data: IconThemeData(color: Colors.blue[400]),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: IconButton(
                          icon: const Icon(Icons.send),
                          onPressed: (_isWriting)
                              ? () => _handleSubmit(_textController.text.trim())
                              : null,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  _handleSubmit(String text) {
    // print(text);

    if (text.isEmpty) {
      return;
    }

    _textController.clear();
    _focusNode.requestFocus();

    final newMessage = ChatMessage(
      uid: authService.user.uid,
      text: text,
      animationController: AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      ),
    );
    _myMessages.insert(0, newMessage);
    newMessage.animationController.forward();

    setState(() {
      _isWriting = false;
    });

    socketService.emit('private-message', {
      'from': authService.user.uid,
      'to': chatService.userTo.uid,
      'message': text,
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    // TODO: Off Socket

    for (ChatMessage message in _myMessages) {
      message.animationController.dispose();
    }

    socketService.socket.off('private-message');

    super.dispose();
  }
}
