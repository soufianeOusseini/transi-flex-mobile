import 'package:equatable/equatable.dart';

class User extends Equatable{

  final int id;
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String username;
  final String? token;
  final DateTime? createdAt;
  final String phone;

  const User({
    required this.id,
    required this.email,
    required this.password,
    required this.lastName,
    required this.firstName,
    required this.username,
    this.token,
    this.createdAt,
    required this.phone
  });

  @override
  List<Object?> get props => [id, email, firstName, lastName, username];

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      lastName: json['lastName'] ?? '',
      firstName: json['firstName'] ?? '',
      password: json['password'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      token: json['token'],
      phone: json['phone'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'username': username,
      'email': email,
      'token': token,
      'created_at': createdAt?.toIso8601String(),
      'phone': phone
    };
  }

  User copyWith({
    int? id,
    String? username,
    String? email,
    String? token,
    DateTime? createdAt,
    String? lastName,
    String? firstName,
    String? password,
    String? phone
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      token: token ?? this.token,
      createdAt: createdAt ?? this.createdAt,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      password: password ?? this.password,
        phone: phone ?? this.phone
    );
  }
}