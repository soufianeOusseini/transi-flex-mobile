import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:transi_flex_mobile/client/model/colis.dart';
import 'package:transi_flex_mobile/client/repository/colis_repository.dart';

import '../../../authentification/service/user_service.dart';

part 'colis_state.dart';

class ColisCubit extends Cubit<ColisState> {
  final ColisRepository repository;
  final UserService userService;

  ColisCubit({required this.repository, required this.userService}) : super(ColisState.initial());

  /// Récupérer tous les colis de l'utilisateur connecté
  Future<void> getColisByUser() async {
    emit(state.copyWith(status: ColisSendStatus.loading));

    final result = await repository.getColisByUser();

    result.fold(
          (failure) {
        emit(state.copyWith(
          status: ColisSendStatus.error,
          errorMessage: failure.message,
        ));
      },
          (colis) {
        emit(state.copyWith(
          status: ColisSendStatus.success,
          colis: colis,
          errorMessage: null,
        ));
      },
    );
  }

  /// Créer un nouveau colis
  Future<void> createColis(Colis colis) async {
    emit(state.copyWith(status: ColisSendStatus.loading));

    colis.user = await this.userService.getCurrentUser();
    final result = await repository.createColis(colis);

    result.fold(
          (failure) {
        emit(state.copyWith(
          status: ColisSendStatus.error,
          errorMessage: failure.message,
        ));
      },
          (newColis) {
            final updatedColis = List<Colis>.from(state.colis ?? [])..add(newColis);
        emit(state.copyWith(
          status: ColisSendStatus.success,
          colis: updatedColis,
          errorMessage: null,
        ));
      },
    );
  }

  /// Modifier un colis existant
  Future<void> updateColis(Colis colis) async {
    emit(state.copyWith(status: ColisSendStatus.loading));

    final result = await repository.updateColis(colis);

    result.fold(
          (failure) {
        emit(state.copyWith(
          status: ColisSendStatus.error,
          errorMessage: failure.message,
        ));
      },
          (updatedColis) {
            final colisList = List<Colis>.from(state.colis ?? []);
        final index = colisList.indexWhere((c) => c.id == updatedColis.id);
        if (index != -1) {
          colisList[index] = updatedColis;
        }
        emit(state.copyWith(
          status: ColisSendStatus.success,
          colis: colisList,
          errorMessage: null,
        ));
      },
    );
  }

  /// Supprimer un colis
  Future<void> deleteColis(int colisId) async {
    emit(state.copyWith(status: ColisSendStatus.loading));

    final result = await repository.deleteColis(colisId);

    result.fold(
          (failure) {
        emit(state.copyWith(
          status: ColisSendStatus.error,
          errorMessage: failure.message,
        ));
      },
          (_) {
        final updatedColis = (state.colis ?? [])
            .where((c) => c.id != colisId)
            .toList();
        emit(state.copyWith(
          status: ColisSendStatus.success,
          colis: updatedColis,
          errorMessage: null,
        ));
      },
    );
  }

  /// Réinitialiser l'état
  void reset() {
    emit(ColisState.initial());
  }

  /// Nettoyer les erreurs
  void clearError() {
    emit(state.copyWith(errorMessage: null));
  }
}