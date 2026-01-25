import 'dart:convert';

class User {
  final String id;
  final String email;
  final String nom;
  final String? prenom;
  final String? telephone;

  User({
    required this.id,
    required this.email,
    required this.nom,
    this.prenom,
    this.telephone,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      email: json['email'],
      nom: json['nom'],
      prenom: json['prenom'],
      telephone: json['telephone'],
    );
  }

  factory User.fromJsonString(String jsonString) {
    return User.fromJson(jsonDecode(jsonString));
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nom': nom,
      'prenom': prenom,
      'telephone': telephone,
    };
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }
}
