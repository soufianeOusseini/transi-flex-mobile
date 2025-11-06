import 'package:equatable/equatable.dart';
class CheckTransaction extends Equatable {
  final String txReference;
  final String authToken;

  const CheckTransaction({
    required this.txReference,
    required this.authToken,
  });

  factory CheckTransaction.fromJson(Map<String, dynamic> json) {
    return CheckTransaction(
      txReference: json['tx_reference'] ?? '',
      authToken: json['auth_token'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tx_reference': txReference,
      'auth_token': authToken,
    };
  }

  @override
  List<Object?> get props => [txReference, authToken];
}