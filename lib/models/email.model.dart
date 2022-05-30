// To parse this JSON data, do
//
//     final password = passwordFromJson(jsonString);

import 'dart:convert';

Email EmailFromJson(String str) => Email.fromJson(json.decode(str));

String EmailToJson(Email data) => json.encode(data.toJson());

class Email {
    Email({
        this.email='',
    });

    String email;

    factory Email.fromJson(Map<String, dynamic> json) => Email(
        email: json["email"],
    );

    Map<String, dynamic> toJson() => {
        "email": email,
    };
}