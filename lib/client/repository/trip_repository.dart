import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:transi_flex_mobile/client/datasource/trip_data_source.dart';
import 'package:transi_flex_mobile/client/model/trip_result.dart';
import 'package:transi_flex_mobile/core/exceptions.dart';
import 'package:transi_flex_mobile/core/failures.dart';

class TripSearchRepository {
  final TripSearchDataSource tripSearchDataSource;

  TripSearchRepository({required this.tripSearchDataSource});

  Future<Either<Failure, List<TripResult>>> searchTrips({
    required String villeDepart,
    required String villeArrive,
    required DateTime dateDepart,
    required TimeOfDay heureDepart,
    required int nombrePassagers,
  }) async {
    try {
      final results = await tripSearchDataSource.searchTrips(
        villeDepart: villeDepart,
        villeArrive: villeArrive,
        dateDepart: dateDepart,
        heureDepart: heureDepart,
        nombrePassagers: nombrePassagers,
      );
      return Right(results);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Erreur inconnue: ${e.toString()}'));
    }
  }

  Future<Either<Failure, List<String>>> getDepartureCities() async {
    try {
      final cities = await tripSearchDataSource.getDepartureCities();
      return Right(cities);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Erreur inconnue: ${e.toString()}'));
    }
  }

  Future<Either<Failure, List<String>>> getArrivalCities(String villeDepart) async {
    try {
      final cities = await tripSearchDataSource.getArrivalCities(villeDepart);
      return Right(cities);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Erreur inconnue: ${e.toString()}'));
    }
  }
}