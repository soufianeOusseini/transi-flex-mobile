import 'package:equatable/equatable.dart';
class ClientRequest extends Equatable {
  final String phone;
  final int amount;
  final String network;

  const ClientRequest({
    required this.phone,
    required this.amount,
    required this.network,
  });

  factory ClientRequest.fromJson(Map<String, dynamic> json) {
    return ClientRequest(
      phone: json['phone'] ?? '',
      amount: json['amount'] ?? 0,
      network: json['network'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
      'amount': amount,
      'network': network,
    };
  }

  @override
  List<Object?> get props => [phone, amount, network];
}