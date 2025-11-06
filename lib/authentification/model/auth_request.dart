class LoginRequest {
  final String username;
  final String password;

  LoginRequest({
    required this.username,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
    };
  }
}
class RegisterRequest {
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String email;

  RegisterRequest({
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.email,
  });

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'email': email,
    };
  }

  // Méthode factory pour créer depuis un JSON (optionnel)
  factory RegisterRequest.fromJson(Map<String, dynamic> json) {
    return RegisterRequest(
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      phoneNumber: json['phoneNumber'] as String,
      email: json['email'] as String,
    );
  }

  @override
  String toString() {
    return 'RegisterRequest(firstName: $firstName, lastName: $lastName, phoneNumber: $phoneNumber, email: $email)';
  }
}