part of 'ticket_cubit.dart';

enum TicketBuyStatus { initial, loading, success, error }

class TicketState extends Equatable {
  final TicketBuyStatus status;
  final List<Ticket>? tickets;
  final String? errorMessage;

  const TicketState({
    required this.status,
    this.tickets,
    this.errorMessage,
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
  }) {
    return TicketState(
      status: status ?? this.status,
      tickets: tickets ?? this.tickets,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, tickets, errorMessage];
}