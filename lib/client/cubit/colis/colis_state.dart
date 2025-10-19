part of 'colis_cubit.dart';

enum ColisSendStatus { initial, loading, success, error }

class ColisState extends Equatable {
  final ColisSendStatus status;
  final List<Colis>? colis;
  final String? errorMessage;

  const ColisState({
    required this.status,
    this.colis,
    this.errorMessage,
  });

  factory ColisState.initial() {
    return const ColisState(
      status: ColisSendStatus.initial,
      colis: null,
      errorMessage: null,
    );
  }

  ColisState copyWith({
    ColisSendStatus? status,
    List<Colis>? colis,
    String? errorMessage,
  }) {
    return ColisState(
      status: status ?? this.status,
      colis: colis ?? this.colis,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, colis, errorMessage];
}