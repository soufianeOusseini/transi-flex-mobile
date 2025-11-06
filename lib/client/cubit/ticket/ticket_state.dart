part of 'ticket_cubit.dart';

enum TicketBuyStatus { initial, loading, success, error, payment_loading,payment_success, payment_error, transaction_success }

class TicketState extends Equatable {
  final TicketBuyStatus status;
  final List<Ticket>? tickets;
  final String? errorMessage;
  final DepositResponse? depositResponse;

  const TicketState({
    required this.status,
    this.tickets,
    this.errorMessage,
    this.depositResponse
  });

  factory TicketState.initial() {
    return const TicketState(
      status: TicketBuyStatus.initial,
      tickets: null,
      errorMessage: null,
    );
  }

  TicketState copyWith({
    TicketBuyStatus? status,
    List<Ticket>? tickets,
    String? errorMessage,
    DepositResponse? depositesponse
  }) {
    return TicketState(
      status: status ?? this.status,
      tickets: tickets ?? this.tickets,
      errorMessage: errorMessage ?? this.errorMessage,
      depositResponse: depositesponse ?? this.depositResponse
    );
  }

  @override
  List<Object?> get props => [status, tickets, errorMessage, depositResponse];
}