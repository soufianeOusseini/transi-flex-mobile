import 'package:dartz/dartz.dart';
import 'package:transi_flex_mobile/core/exceptions.dart';
import 'package:transi_flex_mobile/core/failures.dart';
import 'package:transi_flex_mobile/client/datasource/colis_data_source.dart';
import 'package:transi_flex_mobile/client/model/colis.dart';

class ColisRepository {
  final ColisDataSource colisDataSource;

  ColisRepository({required this.colisDataSource});

  Future<Either<Failure, List<Colis>>> getColisByUser() async {
    try {
      final colis = await colisDataSource.getColisByUser();
      return Right(colis);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Erreur inconnue: ${e.toString()}'));
    }
  }

  Future<Either<Failure, Colis>> createColis(Colis colis) async {
    try {
      final result = await colisDataSource.createColis(colis);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Erreur inconnue: ${e.toString()}'));
    }
  }

  Future<Either<Failure, Colis>> updateColis(Colis colis) async {
    try {
      final result = await colisDataSource.updateColis(colis);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Erreur inconnue: ${e.toString()}'));
    }
  }

  Future<Either<Failure, void>> deleteColis(int colisId) async {
    try {
      await colisDataSource.deleteColis(colisId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Erreur inconnue: ${e.toString()}'));
    }
  }
}