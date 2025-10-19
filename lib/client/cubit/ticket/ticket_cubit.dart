import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:transi_flex_mobile/client/model/ticket.dart';
import 'package:transi_flex_mobile/client/repository/ticket_repository.dart';

part 'ticket_state.dart';

class TicketCubit extends Cubit<TicketState> {
  final TicketRepository repository;

  TicketCubit({required this.repository}) : super(TicketState.initial());

  /// Récupérer tous les tickets de l'utilisateur connecté
  Future<void> getTicketsByUser() async {
    emit(state.copyWith(status: TicketBuyStatus.loading));

    final result = await repository.getTicketsByUser();

    result.fold(
          (failure) {
        emit(state.copyWith(
          status: TicketBuyStatus.error,
          errorMessage: failure.message,
        ));
      },
          (tickets) {
        emit(state.copyWith(
          status: TicketBuyStatus.success,
          tickets: tickets,
          errorMessage: null,
        ));
      },
    );
  }

  /// Créer une nouvelle réservation ou acheter un ticket
  Future<void> createTicket(Ticket ticket) async {
    emit(state.copyWith(status: TicketBuyStatus.loading));

    final result = await repository.createTicket(ticket);

    result.fold(
          (failure) {
        emit(state.copyWith(
          status: TicketBuyStatus.error,
          errorMessage: failure.message,
        ));
      },
          (newTicket) {
        final updatedTickets = List<Ticket>.from(state.tickets ?? [])
          ..add(newTicket);
        emit(state.copyWith(
          status: TicketBuyStatus.success,
          tickets: updatedTickets,
          errorMessage: null,
        ));
      },
    );
  }

  /// Confirmer une réservation (payer)
  Future<void> confirmReservation(int ticketId, String modePaiement) async {
    emit(state.copyWith(status: TicketBuyStatus.loading));

    final result = await repository.confirmReservation(ticketId, modePaiement);

    result.fold(
          (failure) {
        emit(state.copyWith(
          status: TicketBuyStatus.error,
          errorMessage: failure.message,
        ));
      },
          (updatedTicket) {
        final tickets = List<Ticket>.from(state.tickets ?? []);
        final index = tickets.indexWhere((t) => t.id == updatedTicket.id);
        if (index != -1) {
          tickets[index] = updatedTicket;
        }
        emit(state.copyWith(
          status: TicketBuyStatus.success,
          tickets: tickets,
          errorMessage: null,
        ));
      },
    );
  }

  /// Annuler un ticket
  Future<void> cancelTicket(int ticketId) async {
    emit(state.copyWith(status: TicketBuyStatus.loading));

    final result = await repository.cancelTicket(ticketId);

    result.fold(
          (failure) {
        emit(state.copyWith(
          status: TicketBuyStatus.error,
          errorMessage: failure.message,
        ));
      },
          (updatedTicket) {
        final tickets = List<Ticket>.from(state.tickets ?? []);
        final index = tickets.indexWhere((t) => t.id == updatedTicket.id);
        if (index != -1) {
          tickets[index] = updatedTicket;
        }
        emit(state.copyWith(
          status: TicketBuyStatus.success,
          tickets: tickets,
          errorMessage: null,
        ));
      },
    );
  }

  /// Récupérer les tickets par statut
  Future<void> getTicketsByStatus(String status) async {
    emit(state.copyWith(status: TicketBuyStatus.loading));

    final result = await repository.getTicketsByStatus(status);

    result.fold(
          (failure) {
        emit(state.copyWith(
          status: TicketBuyStatus.error,
          errorMessage: failure.message,
        ));
      },
          (tickets) {
        emit(state.copyWith(
          status: TicketBuyStatus.success,
          tickets: tickets,
          errorMessage: null,
        ));
      },
    );
  }

  /// Réinitialiser l'état
  void reset() {
    emit(TicketState.initial());
  }

  /// Nettoyer les erreurs
  void clearError() {
    emit(state.copyWith(errorMessage: null));
  }
}