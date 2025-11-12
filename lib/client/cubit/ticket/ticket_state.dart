part of 'ticket_cubit.dart';

enum TicketBuyStatus { initial, loading, success, error, payment_loading,payment_success, payment_error, transaction_success, seats_loaded,pdf_downloaded }

class TicketState extends Equatable {
  final TicketBuyStatus status;
  final List<Ticket>? tickets;
  final String? errorMessage;
  final DepositResponse? depositResponse;
  final Uint8List? pdfBytes;
  final List<int>? occupiedSeats;

  const TicketState({
    required this.status,
    this.tickets,
    this.errorMessage,
    this.depositResponse,
    this.pdfBytes,
    this.occupiedSeats
  });

  factory TicketState.initial() {
    return const TicketState(
      status: TicketBuyStatus.initial,
      tickets: null,
      errorMessage: null,
      depositResponse: null,
      pdfBytes: null,
      occupiedSeats: null,
    );
  }

  TicketState copyWith({
    TicketBuyStatus? status,
    List<Ticket>? tickets,
    String? errorMessage,
    DepositResponse? depositesponse,
    Uint8List? pdfBytes,
    List<int>? occupiedSeats,
  }) {
    return TicketState(
      status: status ?? this.status,
      tickets: tickets ?? this.tickets,
      errorMessage: errorMessage ?? this.errorMessage,
      depositResponse: depositesponse ?? this.depositResponse,
      pdfBytes: pdfBytes ?? this.pdfBytes,
      occupiedSeats: occupiedSeats ?? this.occupiedSeats,
    );
  }

  @override
  List<Object?> get props => [
    status,
    tickets,
    errorMessage,
    depositResponse,
    pdfBytes,
    occupiedSeats,
  ];

}