import 'package:equatable/equatable.dart';
class DepositResponse extends Equatable {
  final String txReference;
  final int status;

  const DepositResponse({
    required this.txReference,
    required this.status,
  });

  factory DepositResponse.fromJson(Map<String, dynamic> json) {
    return DepositResponse(
      txReference: json['tx_reference'] ?? '',
      status: json['status'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tx_reference': txReference,
      'status': status,
    };
  }

  @override
  List<Object?> get props => [txReference, status];
}