part of 'trip_search_cubit.dart';

enum TripSearchStatus { initial, loading, success, error, citiesLoaded }

class TripSearchState extends Equatable {
  final TripSearchStatus status;
  final List<TripResult> tripResults;
  final List<String> departureCities;
  final List<String> arrivalCities;
  final String? errorMessage;

  const TripSearchState({
    required this.status,
    required this.tripResults,
    required this.departureCities,
    required this.arrivalCities,
    this.errorMessage,
  });

  factory TripSearchState.initial() {
    return const TripSearchState(
      status: TripSearchStatus.initial,
      tripResults: [],
      departureCities: [],
      arrivalCities: [],
      errorMessage: null,
    );
  }

  TripSearchState copyWith({
    TripSearchStatus? status,
    List<TripResult>? tripResults,
    List<String>? departureCities,
    List<String>? arrivalCities,
    String? errorMessage,
  }) {
    return TripSearchState(
      status: status ?? this.status,
      tripResults: tripResults ?? this.tripResults,
      departureCities: departureCities ?? this.departureCities,
      arrivalCities: arrivalCities ?? this.arrivalCities,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    tripResults,
    departureCities,
    arrivalCities,
    errorMessage,
  ];
}