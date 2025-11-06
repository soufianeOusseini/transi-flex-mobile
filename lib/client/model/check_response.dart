import 'package:equatable/equatable.dart';
class CheckResponse extends Equatable {
  final String txReference;
  final String paymentReference;
  final String datetime;
  final String identifier;
  final String paymentMethod;
  final String phoneNumber;
  final int status;

  const CheckResponse({
    required this.txReference,
    required this.paymentReference,
    required this.datetime,
    required this.identifier,
    required this.paymentMethod,
    required this.phoneNumber,
    required this.status,
  });

  factory CheckResponse.fromJson(Map<String, dynamic> json) {
    return CheckResponse(
      txReference: json['tx_reference'] ?? '',
      paymentReference: json['payment_reference'] ?? '',
      datetime: json['datetime'] ?? '',
      identifier: json['identifier'] ?? '',
      paymentMethod: json['payment_method'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      status: json['status'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tx_reference': txReference,
      'payment_reference': paymentReference,
      'datetime': datetime,
      'identifier': identifier,
      'payment_method': paymentMethod,
      'phone_number': phoneNumber,
      'status': status,
    };
  }

  @override
  List<Object?> get props => [
    txReference,
    paymentReference,
    datetime,
    identifier,
    paymentMethod,
    phoneNumber,
    status,
  ];
}