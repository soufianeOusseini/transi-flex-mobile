import 'package:equatable/equatable.dart';
class DepositRequest extends Equatable {
  final String authToken;
  final String phoneNumber;
  final int amount;
  final String description;
  final String identifier;
  final String network;

  const DepositRequest({
    required this.authToken,
    required this.phoneNumber,
    required this.amount,
    required this.description,
    required this.identifier,
    required this.network,
  });

  factory DepositRequest.fromJson(Map<String, dynamic> json) {
    return DepositRequest(
      authToken: json['auth_token'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      amount: json['amount'] ?? 0,
      description: json['description'] ?? '',
      identifier: json['identifier'] ?? '',
      network: json['network'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'auth_token': authToken,
      'phone_number': phoneNumber,
      'amount': amount,
      'description': description,
      'identifier': identifier,
      'network': network,
    };
  }

  @override
  List<Object?> get props => [
    authToken,
    phoneNumber,
    amount,
    description,
    identifier,
    network,
  ];
}