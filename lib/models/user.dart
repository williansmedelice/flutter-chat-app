// To parse this JSON data, do
//
//     final user = userFromMap(jsonString);

// Library
import 'dart:convert';

class User {
  User({
    required this.name,
    required this.email,
    required this.online,
    required this.uid,
  });

  String name;
  String email;
  bool online;
  String uid;

  factory User.fromJson(String str) => User.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory User.fromMap(Map<String, dynamic> json) => User(
        name: json["name"],
        email: json["email"],
        online: json["online"],
        uid: json["uid"],
      );

  Map<String, dynamic> toMap() => {
        "name": name,
        "email": email,
        "online": online,
        "uid": uid,
      };
}
