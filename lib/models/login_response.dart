// To parse this JSON data, do
//
//     final loginResponse = loginResponseFromMap(jsonString);

// Library
import 'dart:convert';
// Models
import 'package:chat_app/models/user.dart';

class LoginResponse {
    LoginResponse({
        required this.ok,
        required this.user,
        required this.token,
    });

    bool ok;
    User user;
    String token;

    factory LoginResponse.fromJson(String str) => LoginResponse.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory LoginResponse.fromMap(Map<String, dynamic> json) => LoginResponse(
        ok: json["ok"],
        user: User.fromMap(json["user"]),
        token: json["token"],
    );

    Map<String, dynamic> toMap() => {
        "ok": ok,
        "user": user.toMap(),
        "token": token,
    };
}
