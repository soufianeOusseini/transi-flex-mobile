import 'package:dartz/dartz.dart';
import 'package:transi_flex_mobile/client/model/check_response.dart';
import 'package:transi_flex_mobile/client/model/check_transaction.dart';
import 'package:transi_flex_mobile/client/model/client_request.dart';
import 'package:transi_flex_mobile/client/model/deposit_response.dart';
import 'package:transi_flex_mobile/core/exceptions.dart';
import 'package:transi_flex_mobile/core/failures.dart';
import 'package:transi_flex_mobile/client/datasource/ticket_data_source.dart';
import 'package:transi_flex_mobile/client/model/ticket.dart';

class TicketRepository {
  final TicketDataSource ticketDataSource;

  TicketRepository({required this.ticketDataSource});

  Future<Either<Failure, List<Ticket>>> getTicketsByUser() async {
    try {
      final tickets = await ticketDataSource.getTicketsByUser();
      return Right(tickets);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Erreur inconnue: ${e.toString()}'));
    }
  }

  Future<Either<Failure, Ticket>> createTicket(Ticket ticket) async {
    try {
      final result = await ticketDataSource.createTicket(ticket);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Erreur inconnue: ${e.toString()}'));
    }
  }

  Future<Either<Failure, Ticket>> confirmReservation(
      int ticketId,
      String modePaiement,
      ) async {
    try {
      final result = await ticketDataSource.confirmReservation(
        ticketId,
        modePaiement,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Erreur inconnue: ${e.toString()}'));
    }
  }

  Future<Either<Failure, Ticket>> cancelTicket(int ticketId) async {
    try {
      final result = await ticketDataSource.cancelTicket(ticketId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Erreur inconnue: ${e.toString()}'));
    }
  }

  Future<Either<Failure, List<Ticket>>> getTicketsByStatus(String status) async {
    try {
      final tickets = await ticketDataSource.getTicketsByStatus(status);
      return Right(tickets);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Erreur inconnue: ${e.toString()}'));
    }
  }

  Future<Either<String, DepositResponse>> makeDeposit(ClientRequest request) async {
    try {
      final response = await ticketDataSource.makeDeposit(request);
      return Right(response);
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, CheckResponse>> checkTransactionStatus(CheckTransaction request) async {
    try {
      final response = await ticketDataSource.checkTransactionStatus(request);
      return Right(response);
    } catch (e) {
      return Left(e.toString());
    }
  }
}