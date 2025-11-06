import 'package:equatable/equatable.dart';
class PaygateCallback extends Equatable {
  final String txReference;
  final String identifier;
  final String paymentReference;
  final double amount;
  final String datetime;
  final String paymentMethod;
  final String phoneNumber;

  const PaygateCallback({
    required this.txReference,
    required this.identifier,
    required this.paymentReference,
    required this.amount,
    required this.datetime,
    required this.paymentMethod,
    required this.phoneNumber,
  });

  factory PaygateCallback.fromJson(Map<String, dynamic> json) {
    return PaygateCallback(
      txReference: json['tx_reference'] ?? '',
      identifier: json['identifier'] ?? '',
      paymentReference: json['payment_reference'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      datetime: json['datetime'] ?? '',
      paymentMethod: json['payment_method'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tx_reference': txReference,
      'identifier': identifier,
      'payment_reference': paymentReference,
      'amount': amount,
      'datetime': datetime,
      'payment_method': paymentMethod,
      'phone_number': phoneNumber,
    };
  }

  @override
  List<Object?> get props => [
    txReference,
    identifier,
    paymentReference,
    amount,
    datetime,
    paymentMethod,
    phoneNumber,
  ];
}