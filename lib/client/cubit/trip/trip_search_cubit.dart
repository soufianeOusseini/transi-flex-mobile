import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:transi_flex_mobile/client/model/trip_result.dart';
import 'package:transi_flex_mobile/client/repository/trip_repository.dart';
part 'trip_search_state.dart';

class TripSearchCubit extends Cubit<TripSearchState> {
  final TripSearchRepository repository;

  TripSearchCubit({required this.repository}) : super(TripSearchState.initial());

  // Rechercher les trajets
  Future<void> searchTrips({
    required String villeDepart,
    required String villeArrive,
    required DateTime dateDepart,
    required TimeOfDay heureDepart,
    required int nombrePassagers,
  }) async {
    emit(state.copyWith(status: TripSearchStatus.loading));

    final result = await repository.searchTrips(
      villeDepart: villeDepart,
      villeArrive: villeArrive,
      dateDepart: dateDepart,
      heureDepart: heureDepart,
      nombrePassagers: nombrePassagers,
    );

    result.fold(
          (failure) {
        emit(state.copyWith(
          status: TripSearchStatus.error,
          errorMessage: failure.message,
        ));
      },
          (trips) {
        emit(state.copyWith(
          status: TripSearchStatus.success,
          tripResults: trips,
          errorMessage: null,
        ));
      },
    );
  }

  // Récupérer les villes de départ
  Future<void> loadDepartureCities() async {
    emit(state.copyWith(status: TripSearchStatus.loading));

    final result = await repository.getDepartureCities();

    result.fold(
          (failure) {
        emit(state.copyWith(
          status: TripSearchStatus.error,
          errorMessage: failure.message,
        ));
      },
          (cities) {
        emit(state.copyWith(
          status: TripSearchStatus.citiesLoaded,
          departureCities: cities,
          errorMessage: null,
        ));
      },
    );
  }

  // Récupérer les villes d'arrivée pour une ville de départ
  Future<void> loadArrivalCities(String villeDepart) async {
    final result = await repository.getArrivalCities(villeDepart);

    result.fold(
          (failure) {
        emit(state.copyWith(
          status: TripSearchStatus.error,
          errorMessage: failure.message,
        ));
      },
          (cities) {
        emit(state.copyWith(
          status: TripSearchStatus.citiesLoaded,
          arrivalCities: cities,
          errorMessage: null,
        ));
      },
    );
  }

  // Réinitialiser l'état
  void reset() {
    emit(TripSearchState.initial());
  }

  // Nettoyer les résultats
  void clearResults() {
    emit(state.copyWith(
      status: TripSearchStatus.initial,
      tripResults: [],
      errorMessage: null,
    ));
  }
}